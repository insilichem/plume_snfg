#!/usr/bin/env python
# encoding: utf-8

from __future__ import print_function, division
from textwrap import dedent
import numpy as np
from collections import defaultdict
try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO
from snfg_definitions import COLORS, RESIDUES, SCALES, ATOM_NAMES, REVERSE_RESIDUE_CODES, SUGAR_BOND_COLORS
import chimera
import Matrix as M
from chimera import runCommand as run, cross, Point, Vector, preferences
from Bld2VRML import openFileObject as openBildFileObject
from VolumePath import Marker_Set as MarkerSet

_defined_colors = False
def _define_snfg_colors():
    """
    Change colors to official SNFG standard
    """
    for color, cmyk in COLORS.items():
        c, m, y, k = cmyk
        R = (1. - c) * (1. - k)
        G = (1. - m) * (1. - k)
        B = (1. - y) * (1. - k)
        run('colordef snfg_{} {} {} {}'.format(color, R, G, B))
    global _defined_colors
    _defined_colors = True


class SNFG(object):

    _instances = []

    def __init__(self, size=4.0, connect=True, cylinder_radius=0.5, cylinder_redfac=0,
                 sphere_redfac=0, molecules=None, hide_residue=False, bondtypes=False):
        self._instances.append(self)
        if molecules is None:
            molecules = chimera.openModels.list(modelTypes=[chimera.Molecule])
        self.molecules = {m: None for m in molecules}
        self.size = size
        self.connect = connect
        self.cylinder_radius = cylinder_radius
        self.cylinder_redfac = cylinder_redfac
        self.sphere_redfac = sphere_redfac
        self.hide_residue = hide_residue
        self.bondtypes = bondtypes
        self.saccharydes = {}
        self._problematic_residues = []
        self._handler_mol, self._handler_res = None, None
        self.enable()
    
    def __del__(self):
        self._instances.remove(self)

    @classmethod
    def as_icon(cls, molecules=None, size=None):
        if size is None:
            size = preferences.get('plume_snfg', 'icon_size')
        return cls(size=size, connect=False, molecules=molecules,
                   hide_residue=False)

    @classmethod
    def as_full(cls, molecules=None, size=None, cylinder_radius=None,
                     connect=None, bondtypes=None):
        if size is None:
            size = preferences.get('plume_snfg', 'full_size')
        if cylinder_radius is None:
            cylinder_radius = preferences.get('plume_snfg', 'cylinder_radius')
        if connect is None:
            connect = preferences.get('plume_snfg', 'connect')
        if bondtypes is None:
            bondtypes = preferences.get('plume_snfg', 'bondtypes')
        return cls(size=size, cylinder_radius=cylinder_radius, 
                   cylinder_redfac=0, sphere_redfac=0, molecules=molecules,
                   hide_residue=True, connect=connect, bondtypes=bondtypes)

    @classmethod
    def as_fullred(cls, molecules=None, size=None, cylinder_radius=None,
                     connect=None, bondtypes=None):
        if size is None:
            size = preferences.get('plume_snfg', 'full_size')
        if cylinder_radius is None:
            cylinder_radius = preferences.get('plume_snfg', 'cylinder_radius')
        if connect is None:
            connect = preferences.get('plume_snfg', 'connect')
        if bondtypes is None:
            bondtypes = preferences.get('plume_snfg', 'bondtypes')
        return cls(size=size, cylinder_radius=cylinder_radius, cylinder_redfac=0.4,
                   sphere_redfac=0.25, molecules=molecules, hide_residue=True,
                   connect=connect, bondtypes=bondtypes)
    
    @classmethod
    def as_fullshown(cls, molecules=None, size=None, cylinder_radius=None,
                     connect=None, bondtypes=None):
        if size is None:
            size = preferences.get('plume_snfg', 'full_size')
        if cylinder_radius is None:
            cylinder_radius = preferences.get('plume_snfg', 'cylinder_radius')
        if connect is None:
            connect = preferences.get('plume_snfg', 'connect')
        if bondtypes is None:
            bondtypes = preferences.get('plume_snfg', 'bondtypes')
        return cls(size=size, cylinder_radius=cylinder_radius, cylinder_redfac=0.4,
                   sphere_redfac=0.25, molecules=molecules, hide_residue=False,
                   connect=connect, bondtypes=bondtypes)

    def enable(self):
        self.disable()
        global _defined_colors
        if not _defined_colors:
            _define_snfg_colors()
        self.detect()
        self.draw()
        self._handler_mol = chimera.triggers.addHandler('Molecule', self._update_cb, None)
        self._handler_res= chimera.triggers.addHandler('Residue', self._update_res_cb, None)
        if self._problematic_residues:
            chimera.statusline.show_message('Detected carbohydrate residues with potentially'
                                            ' wrong atom names. Check reply log!', 
                                            color='red', blankAfter=5)
            for r in set(self._problematic_residues):
                print('! Residue {} might be a carbohydrate'
                      ' with wrong atom names.'.format(r))
    
    def disable(self):
        self._problematic_residues = []
        to_remove = []
        for vrml in chimera.openModels.list():
            if vrml.name.startswith('SNFG'):
                to_remove.append(vrml)
                if vrml in self.molecules:
                    del self.molecules[vrml]
        chimera.openModels.close(to_remove)
        for s in self.saccharydes.values():
            s.destroy()
        self.saccharydes = {}
        if self._handler_mol is not None:
            chimera.triggers.deleteHandler('Molecule', self._handler_mol)
            self._handler_mol = None
        if self._handler_res is not None:
            chimera.triggers.deleteHandler('Residue', self._handler_res)
            self._handler_res = None
        Saccharyde._base_id[0] = 99

    def detect(self):
        """
        Assign appropriate shape/color based on residue name
        """
        # Collect a list of residues that contain carbohydrate ring atoms
        rings_per_molecule = self.find_saccharydic_residues(molecules=self.molecules.keys())
        # TODO: set carbatoms
        # TODO: Filter out rings that aren't actually carbohydrates
        #       (can happen with linear carbohydrates with coordinating ions)
        # TODO: Check for GLYCAM reducing-terminal ROH to assign appropriate resname color

        for molecule, residues in rings_per_molecule.items():
            self.molecules[molecule] = []
            for residue, ring in residues.items():
                # Assign shape/size/color properties based on recognized residue names
                saccharyde = Saccharyde(residue, ring.orderedAtoms, base_size=self.size)
                self.saccharydes[residue] = saccharyde
                self.molecules[molecule].append(residue)

    def find_saccharydic_residues(self, molecules=None):
        if molecules is None:
            molecules = chimera.openModels.list(modelTypes=[chimera.Molecule])
        hetero = chimera.specifier.evalSpec('ligand', models=molecules).residues()
        rings_per_molecule = defaultdict(dict)
        for m in molecules:
            for ring in m.minimumRings():
                a = next(iter(ring.atoms)) 
                if len(ring.atoms) <= 6 and a.residue in hetero:
                    if all(a.name in ATOM_NAMES for a in ring.atoms):
                        rings_per_molecule[m][a.residue] = ring
                    elif a.residue.type in REVERSE_RESIDUE_CODES:
                        self._problematic_residues.append(a.residue)
        return rings_per_molecule

    def draw(self):
        """
        Draw each residue shape according to its SNFG assignment
        """
        for residue, saccharyde in self.saccharydes.items():
            saccharyde.build()
            for a in residue.atoms:
                a.display = not self.hide_residue
        if self.connect:
            for residue, saccharyde in self.saccharydes.items():
                self.connect_attached_rings(saccharyde)

    def connect_attached_rings(self, ring):
        """
        Build a cylinder that connects `ring` with its adjacent one,
        given by `ring.a1`
        """
        geom_center = ring.center
        bild = ""
        # Connections (cylinders) depend on linkage type
        O_att, N_att, C_att = None, None, None
        for neighbor in ring.a1.neighbors:
            if (neighbor.element.name == 'O' and
                neighbor.residue != ring.residue and
                neighbor.name != 'O{}'.format(ring.shifted + 5)):
                O_att = neighbor
                break
            elif neighbor.element.name == 'N':
                N_att = neighbor
                break
        if O_att is not None:
            # Check if the oxygen is then attached to a carbon
            for neighbor in O_att.neighbors:
                if neighbor.element.name == 'C' and neighbor.residue != ring.a1.residue:
                    C_att = neighbor
                    break
            # If the oxygen is attached to a carbon
            # Then the attached residue is a carbohydrate or this is an O-linked glycan
            # Check for ring atoms of the attached carbohydrate residue
            if C_att is not None:
                attached_ring = self.saccharydes.get(C_att.residue)
                # If the attached residue contains ring atoms
                # Then the attached residue is a carbohydrate
                # Set position of attachment as geometric center of ring atoms
                # of attached carbohydrate residue
                if attached_ring is not None and attached_ring is not ring:
                    # TODO: Check name of C and color accordingly
                    bild_attrs = dict(start=geom_center, end=attached_ring.center,
                                      sphere_radius=self.cylinder_radius,
                                      cylinder_radius=self.cylinder_radius,
                                      kind='saccharyde ' + C_att.name,
                                      label=C_att.name)
                # Otherwise this is an O-linked glycan or GLYCAM OME or TBT
                else:
                    # Check for alpha carbon of attached protein residue
                    att_CA = C_att.residue.atomsMap.get('CA')
                    if att_CA is not None:
                        # Then it is attached to a protein via CA and is an O-linked glycan
                        bild_attrs = dict(start=geom_center, end=att_CA[0].coord(),
                                          sphere_radius=self.cylinder_radius,
                                          cylinder_radius=self.cylinder_radius,
                                          kind='O-linked glycan')
                    else:
                        # Then GLYCAM OME or TBT
                        bild_attrs = dict(start=geom_center, end=O_att.coord(),
                                          sphere_radius=self.size *
                                          SCALES['sphere'] * self.sphere_redfac,
                                          cylinder_radius=self.cylinder_radius * self.cylinder_redfac,
                                          kind='GLYCAM OME or TBT')
            # If the oxygen is not attached to a carbon
            else:
                # Then it is a terminal oxygen and marks the reducing end
                bild_attrs = dict(start=geom_center, end=O_att.coord(),
                                  sphere_radius=self.size * SCALES['sphere'] * self.sphere_redfac,
                                  cylinder_radius=self.cylinder_radius * self.cylinder_redfac,
                                  kind='reducing end')
                # If the residue has an attached nitrogen
        elif N_att is not None:
            # Then we assume this is an N-linked glycan
                        # Set position of attachment as the linked CA
            att_CA = N_att.residue.atomsMap['CA']
            bild_attrs = dict(start=geom_center, end=att_CA[0].coord(),
                              sphere_radius=self.cylinder_radius,
                              cylinder_radius=self.cylinder_radius,
                              kind='N-linked glycan')
        # If there is no oxygen or nitrogen attached
        else:
            # Generate a point to denote terminal
            vec = ring.p1 - chimera.Point(*geom_center)
            vecadj = (1.43 / vec.length) * vec
            geom_center_att = ring.p1 + vecadj
            bild_attrs = dict(start=geom_center, end=geom_center_att,
                              sphere_radius=self.cylinder_radius,
                              cylinder_radius=self.cylinder_radius,
                              kind='terminal')

        geom_center_att = bild_attrs['end']
        bild = """
        .color gray
        .sphere {end[0]} {end[1]} {end[2]} {sphere_radius}
        .cylinder {start[0]} {start[1]} {start[2]} {end[0]} {end[1]} {end[2]} {cylinder_radius}
        """.format(**bild_attrs)

        ring.vrml._vrml_connector = ring.vrml._build_vrml(bild, name='SNFG connector {}'.format(bild_attrs['kind']))
        ring.vrml._vrml_connector[0].attrs = bild_attrs

        if self.bondtypes and 'label' in bild_attrs:
            ms = MarkerSet('SNFG label {}'.format(bild_attrs['kind']))
            ms.marker_model((ring.vrml._vrml_connector[0].id, 
                             ring.vrml._vrml_connector[0].subid + 1))
            ring.vrml._vrml_connector[0].markerset = ms
            ms.place_marker(bild_attrs['start'], None, 0.1)
            ms.place_marker(bild_attrs['end'], None, 0.1)
            link = ms.molecule.newBond(*ms.molecule.atoms[:2])
            link.label = bild_attrs['label']
            link.labelColor = chimera.colorTable.getColorByName('black')
        return ring.vrml._vrml_connector

    def destroy_shapes(self):
        for s in self.saccharydes.values():
            s.destroy()
        self.saccharydes = {}

    def _update_cb(self, name, data, changes):
        """
        Update shapes position and orientation after coordinates change.
        """
        if (set(self.molecules) & changes.modified 
            and 'activeCoordSet changed' in changes.reasons):
            self.draw()
    
    def _update_res_cb(self, name, data, changes):
        if changes.deleted:
            for r, saccharyde in self.saccharydes.items():
                try:
                    self._problematic_residues.remove(r)
                except:
                    pass
                if r in changes.deleted:
                    saccharyde.destroy()
                    del self.saccharydes[r]


class Saccharyde(object):

    _base_id = [99]

    def __init__(self, residue, ring_atoms, base_size=4.0):
        self.residue = residue
        self.name = REVERSE_RESIDUE_CODES.get(residue.type, 'UNK')
        self.atoms = ring_atoms
        self.base_size = base_size
        self.info = RESIDUES[self.name]
        self.fullname = self.info.get('name')
        self.shape = self.info.get('shape')
        self.size = SCALES.get(self.shape, 1.0) * base_size
        colors = self.info.get('color').split()
        self.color2 = self.color1 = 'snfg_' + colors[0]
        if len(colors) == 2:
            self.color2 = 'snfg_' + colors[1]
        self.atom_map = {a.name: a for a in self.atoms}
        self.shifted = min(self.atom_map.keys()) == 'C2'
        self.vrml = None
        self._base_id[0] += 1
        self._id = self._base_id[0]

    def destroy(self):
        if self.vrml is not None:
            self.vrml.destroy()

    @property
    def center(self):
        masses = [a.element.mass for a in self.atoms]
        return np.average(self.xyz, axis=0, weights=masses)

    @property
    def center_att(self):
        """
        Get the geometric center of the ring attached to this
        ring, and draw cylinders connecting rings. In some cases,
        there is no attached residue. The following line assigns
        the coordinates of the C1 atom (or C2 for sialic acids)
        to be the geometric center of the attached residue so that
        the shapes can be aligned properly without crashing when no
        residue is attached. 
        """
        return self.p1

    @property
    def a1(self):
        """
        first member of the ring: usually the first carbon atom.
        """
        return self.atom_map['C{}'.format(self.shifted + 1)]

    @property
    def a6(self):
        """
        sixth member of the ring: usually the last oxygen atom.
        """
        return self.atom_map['O{}'.format(self.shifted + 5)]

    @property
    def p1(self):
        """
        Coordinates of the first member of the ring: usually the first carbon atom.
        """
        return self.a1.coord()

    @property
    def p6(self):
        """
        Coordinates of the sixth member of the ring: usually the last oxygen atom.
        """
        return self.a6.coord()

    @property
    def xyz(self):
        return [a.coord() for a in self.atoms]

    @property
    def xform_xyz(self):
        return [a.xformCoord() for a in self.atoms]

    def build(self):
        if self.vrml is not None:
            self.vrml.destroy()
        name = 'SNFG {}'.format(self.fullname)
        self.vrml = OrientedShape(self.shape, self.p6, self.size, self.center,
                                  self.center_att, self.color1, self.color2, name,
                                  parent_id=self._id)
        self.vrml.draw()


class OrientedShape(object):

    """
    Build 3D objects for several polyhedron while handling spatial orientation
    and dual coloring by triangles.

    Parameters
    ----------
    shape : str
    p6 : 3-tuple of float
    size : float
    center: 3-tuple of float
    center_att: 3-tuple of float
    color1: str
    color2: str
    name: str, optional

    Note
    ----
    The objective is to orient the shapes so that they face the neighboring residue,
    connected at C1. This is accomplished by calculating the equation for the line
    that connects the geometric centers of the target residue (where the shape will
    be placed) and the neighboring residue (which is attached at the C1 atom). 
    If we consider the geometric center of the target residue to be point A, the 
    center of the neighboring residue to be point B, and the origin to be point O, 
    then vector_AB=vector_OB - vector_OA. Knowing vector AB allows us to put new points
    along the line; however, we want the shapes to be of a defined size. 
    In order to adjust the size properly, the distance between geometric centers is
    determined, scaled to match the desired size, and then added/subtracted from the
    geometric center of the target sugar.
    """

    SUPPORTED_SHAPES = set('sphere cube diamond cone rectangle star hexagon pentagon'.split())

    def __init__(self, shape, p6, size, center, center_att, color1, color2,
                 name='SNFG', parent_id=100):
        if shape not in self.SUPPORTED_SHAPES:
            raise ValueError('`shape` should be one of: '
                             '{}'.format(', '.join(self.SUPPORTED_SHAPES)))
        self.shape = shape
        self.name = name
        self.p6 = p6
        self.size = size
        self.center = center
        self.center_att = center_att
        self.color1 = color1
        self.color2 = color2
        self._vrml_shape = None
        self._vrml_connector = None
        self._id = parent_id
        self._subid = 0

    def destroy(self):
        if self._vrml_shape is not None:
            chimera.openModels.close(self._vrml_shape)
            self._vrml_shape = None
        if self._vrml_connector is not None:
            chimera.openModels.close(self._vrml_connector)
            self._vrml_connector = None

    def draw(self):
        self._vrml_shape = getattr(self, '_draw_' + self.shape)()

    def _draw_sphere(self):
        x, y, z = self.center
        bild = """
        .color {}
        .sphere {} {} {} {}
        """.format(self.color1, x, y, z, self.size)
        return self._build_vrml(bild)

    def _draw_cube(self):
        center = Point(*self.center)
        center_att = Point(*self.center_att)
        p6 = Point(*self.p6)
        vec_AB = center_att - center

        # Resize the shape. $size refers to the total size,
        # $half_length refers to the distance required create
        # points on either side of the geometric center.
        half_length = self.size / 2.0

        # Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset
        # that will be used to place the ponits around the geometric center. The equation asks the question,
        # what factor should be multiplied times the distance in order to prodce $half-length?
        adjustment = half_length / center.distance(center_att)

        # Adjust vector_AB by the amount determined in both the forward and reverse directions
        adj_vec_AB_1 = vec_AB * adjustment
        adj_vec_AB_2 = adj_vec_AB_1 * -1

        # Add two points along the line connecting the residues in the forward and reverse direction
        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        # perp_1 represents a point perpendicular to the previously created two
        perp_1 = normalize(cross(x1 - x2, x2 - p6))
        perp1 = perp_1 * half_length
        perp2 = perp1 * -1

        # Each 'o' represents a point on the box (o stands for original points, which are based on the two that
        # lie along the line connecting the two residues)
        o1 = perp1 + x1
        o2 = perp1 + x2
        o3 = perp2 + x1
        o4 = perp2 + x2

        # This creates 8 points (the corners of the box) based upon the coordinates of o1-o4
        perp_for = normalize(cross(o1 - o2, o3 - o1)) * half_length
        perp_back = perp_for * -1
        points = dict(s1=perp_for + o1,
                      s2=perp_for + o2,
                      s3=perp_for + o3,
                      s4=perp_for + o4,
                      s5=perp_back + o1,
                      s6=perp_back + o2,
                      s7=perp_back + o3,
                      s8=perp_back + o4)

        # Draw the Cube - some cubes require two colors, so the triangles are intentionally divided so that one
        # side shows both colors
        # Color 1 (blue, yellow, or green)
        bild = """
        .color {color1}
        .polygon {s2} {s3} {s4}
        .polygon {s1} {s2} {s6}
        .polygon {s4} {s7} {s8}
        .polygon {s5} {s6} {s8}
        .polygon {s2} {s4} {s8}
        .polygon {s1} {s5} {s7}
        .color {color2}
        .polygon {s1} {s3} {s2}
        .polygon {s3} {s7} {s4}
        .polygon {s1} {s6} {s5}
        .polygon {s5} {s8} {s7}
        .polygon {s2} {s8} {s6}
        .polygon {s1} {s7} {s3}
        """.format(color1=self.color1, color2=self.color2, **points)
        return self._build_vrml(bild)

    def _draw_diamond(self):
        center_att = Point(*self.center_att)
        center = Point(*self.center)
        p6 = Point(*self.p6)

        vec_AB = center_att - center
        shape_size = self.size * 0.5
        adjustment = shape_size / center.distance(center_att)
        adj_vec_AB_1 = adjustment * vec_AB
        adj_vec_AB_2 = -adjustment * vec_AB
        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        perp_1 = cross(x1 - x2, x2 - p6)
        perp1 = perp_1 * shape_size
        perp2 = perp_1 * -shape_size

        # The number of sides to the diamond is up for debate. It was suggested to use six sides since the
        # diamond could look like a cube that has been rotated; however, four seems to work since the cylinder
        # goes directly through one corner. Maybe it could be an option for the user?
        # Each 'o' represents a corner of a square that is centered on $geom_center
        o1 = perp1 + x1
        o2 = perp1 + x2
        o3 = perp2 + x1
        o4 = perp2 + x2

        # Determine coordinates for outer points of the diamond
        # Top point of star is $shape_size above geometric center
        # Vector distance between center and top point of star
        d1 = x2 - center
        outer = [_rotate(o1, center, o2, alpha, d1) + center
                 for alpha in (90, 180, 270, 360)]

        # The following function creates the top and bottom of the diamond by creating two points at the geometric
        # center that are perpendicular to the plane of the square (and parallel with the plane of the ring).
        perp_for = normalize(cross(o1 - o2, o3 - o1)) * shape_size
        top = perp_for + center
        bottom = perp_for * -1 + center

        color_and_points = {'outer_{}'.format(i + 1): value
                            for i, value in enumerate(outer)}
        color_and_points.update(dict(top=top, bottom=bottom,
                                     color1=self.color1, color2=self.color2))
        bild = """
        .color {color1}
        .polygon {outer_1} {bottom} {outer_2}
        .polygon {outer_1} {outer_4} {bottom}
        .polygon {outer_3} {top} {outer_2}
        .polygon {outer_3} {outer_4} {top}
        .color {color2}
        .polygon {outer_1} {outer_2} {top}
        .polygon {outer_1} {top} {outer_4}
        .polygon {outer_3} {outer_2} {bottom}
        .polygon {outer_3} {bottom} {outer_4}
        """.format(**color_and_points)
        return self._build_vrml(bild)

    def _draw_cone(self):
        center_att = Point(*self.center_att)
        center = Point(*self.center)
        p6 = Point(*self.p6)

        vec_AB = center_att - center
        half_length = self.size / 2.0

        # Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset
        # that will be used to place the points around the geometric center. The equation asks the question,
        # what factor should be multiplied times the distance in order to prodce $half-length?
        # Two adjustments are added to shift the geom_center of the shape.
        _adjustment = half_length / center.distance(center_att)
        adjustment1 = _adjustment * 0.66
        adjustment2 = _adjustment * 1.33
        # Adjust vector_AB by the amount determined in both the forward and reverse directions
        adj_vec_AB_1 = adjustment1 * vec_AB
        adj_vec_AB_2 = -adjustment2 * vec_AB

        # Add two points along the line connecting the residues in the forward and reverse direction
        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        # perp_1 represents a point perpendicular to the previously created two
        perp1 = normalize(cross(x1 - x2, x2 - p6))
        perp2 = -0.5 * perp1
        o1 = perp1 + x1
        o2 = perp2 + x1
        perp3 = normalize(cross(o1 - x2, x2 - center_att)) * half_length
        o3 = perp3 + x1

        # Determine coordinates for outer points of the rectangle
        # Top point of rectangle is $half_length above geometric center
        # Vector distance between center and top point of rectangle
        d1 = o3 - x1

        # Rotate by 90 degrees to identify other points of the rectangle - note that t5 is the same as x1
        outer = [_rotate(o1, o3, x1, alpha, d1) + x1
                 for alpha in (45, 90, 135, 180, 225, 270, 315, 360)]

        # Draw the cone
        color_and_points = {'outer_{}'.format(i + 1): value
                            for i, value in enumerate(outer)}
        color_and_points.update(dict(x1=x1, x2=x2,
                                     color1=self.color1, color2=self.color2))

        bild = """
        .color {color1}
        .polygon {outer_1} {outer_2} {x1}
        .polygon {outer_1} {x1} {outer_8}
        .polygon {outer_3} {x1} {outer_2}
        .polygon {outer_3} {outer_4} {x1}
        .color {color2}
        .polygon {outer_5} {x1} {outer_4}
        .polygon {outer_5} {outer_6} {x1}
        .polygon {outer_7} {x1} {outer_6}
        .polygon {outer_7} {outer_8} {x1}
        .color {color1}
        .polygon {outer_1} {x2} {outer_2}
        .polygon {outer_1} {outer_8} {x2}
        .polygon {outer_5} {outer_4} {x2}
        .polygon {outer_5} {x2} {outer_6}
        .color {color2}
        .polygon {outer_3} {outer_2} {x2}
        .polygon {outer_3} {x2} {outer_4}
        .polygon {outer_7} {outer_6} {x2}
        .polygon {outer_7} {x2} {outer_8}
        """.format(**color_and_points)

        return self._build_vrml(bild)

    def _draw_rectangle(self):
        center_att = Point(*self.center_att)
        center = Point(*self.center)
        p6 = Point(*self.p6)

        vec_AB = center_att - center
        half_length = self.size / 1.2
        thickness = self.size / 1.8

        adjustment = half_length / center.distance(center_att)
        adj_vec_AB_1 = adjustment * vec_AB
        adj_vec_AB_2 = -adjustment * vec_AB

        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        perp1 = normalize(cross(x1 - x2, x2 - p6)) * half_length
        perp2 = perp1 * -1

        o1 = perp1 + x1
        o2 = perp1 + x2
        o3 = perp2 + x1
        o4 = perp2 + x2
        d1 = x2 - center

        outer = [_rotate(o1, center, o2, alpha, d1) + center
                 for alpha in (45, 90, 225, 270)]

        perp_for = thickness * normalize(cross(o1 - o2, o3 - o1))
        perp_back = perp_for * -1
        color_and_points = dict(
            center_1=perp_for + center,
            center_2=perp_back + center,
            front_1=perp_for + outer[0],
            front_2=perp_for + outer[1],
            front_3=perp_for + outer[2],
            front_4=perp_for + outer[3],
            back_1=perp_back + outer[0],
            back_2=perp_back + outer[1],
            back_3=perp_back + outer[2],
            back_4=perp_back + outer[3],
            color1=self.color1, color2=self.color2)
        # Draw the rectangle

        bild = """
        .color {color1}
        .polygon {front_1} {front_2} {center_1}
        .polygon {front_1} {center_1} {front_4}
        .polygon {front_3} {center_1} {front_2}
        .polygon {front_3} {front_4} {center_1}
        .polygon {back_1} {center_2} {back_2}
        .polygon {back_1} {back_4} {center_2}
        .polygon {back_3} {back_2} {center_2}
        .polygon {back_3} {center_2} {back_4}
        .polygon {back_1} {back_2} {front_1}
        .polygon {back_2} {front_2} {front_1}
        .polygon {back_2} {back_3} {front_2}
        .polygon {back_3} {front_3} {front_2}
        .polygon {back_3} {back_4} {front_3}
        .polygon {back_4} {front_4} {front_3}
        .polygon {back_4} {back_1} {front_4}
        .polygon {back_1} {front_1} {front_4}
        """.format(**color_and_points)

        return self._build_vrml(bild)

    def _draw_star(self):
        center_att = Point(*self.center_att)
        center = Point(*self.center)
        p6 = Point(*self.p6)

        vec_AB = center_att - center
        shape_size = self.size * 1.5
        half_length = shape_size / 2.0
        thickness = shape_size / 4.0

        adjustment = half_length / center.distance(center_att)
        adj_vec_AB_1 = adjustment * vec_AB
        adj_vec_AB_2 = -1 * adj_vec_AB_1

        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        perp1 = normalize(cross(x1 - x2, x2 - p6)) * half_length
        perp2 = -1 * perp1

        o1 = perp1 + x1
        o2 = perp1 + x2
        o3 = perp2 + x1
        o4 = perp2 + x2
        d1 = x2 - center
        d2 = (x1 - center) * 0.5

        # Rotate by 72 degrees to identify other points of the star
        outer = [_rotate(o1, center, o2, alpha, d1) + center
                 for alpha in (72, 144, 216, 288, 360)]
        inner = [_rotate(o1, center, o2, alpha, d2) + center
                 for alpha in (72, 144, 216, 288, 360)]

        perp_for = thickness * normalize(cross(o1 - o2, o3 - o1))
        perp_back = -1 * perp_for
        center_1 = perp_for + center
        center_2 = perp_back + center

        color_and_points = {'outer_{}'.format(i + 1): value
                            for i, value in enumerate(outer)}
        color_and_points.update({'inner_{}'.format(i + 1): value
                                 for i, value in enumerate(inner)})
        color_and_points.update(dict(color1=self.color1, color2=self.color2,
                                     center_1=center_1, center_2=center_2))

        bild = """
        .color {color1}
        .polygon {outer_1} {center_1} {inner_3}
        .polygon {outer_1} {inner_3} {center_2}
        .polygon {outer_1} {inner_4} {center_1}
        .polygon {outer_1} {center_2} {inner_4}
        .polygon {outer_2} {center_1} {inner_4}
        .polygon {outer_2} {inner_4} {center_2}
        .polygon {outer_2} {inner_5} {center_1}
        .polygon {outer_2} {center_2} {inner_5}
        .polygon {outer_3} {center_1} {inner_5}
        .polygon {outer_3} {inner_5} {center_2}
        .polygon {outer_3} {inner_1} {center_1}
        .polygon {outer_3} {center_2} {inner_1}
        .polygon {outer_4} {center_1} {inner_1}
        .polygon {outer_4} {inner_1} {center_2}
        .polygon {outer_4} {inner_2} {center_1}
        .polygon {outer_4} {center_2} {inner_2}
        .polygon {outer_5} {center_1} {inner_2}
        .polygon {outer_5} {inner_2} {center_2}
        .polygon {outer_5} {inner_3} {center_1}
        .polygon {outer_5} {center_2} {inner_3}
        """.format(**color_and_points)

        return self._build_vrml(bild)

    def _draw_hexagon(self):
        center_att = Point(*self.center_att)
        center = Point(*self.center)
        p6 = Point(*self.p6)

        vec_AB = center_att - center
        shape_size = self.size
        half_length = shape_size / 2.0
        thickness = shape_size / 4.0

        adjustment = half_length / center.distance(center_att)
        adj_vec_AB_1 = adjustment * vec_AB
        adj_vec_AB_2 = -1 * adj_vec_AB_1

        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        perp1 = normalize(cross(x1 - x2, x2 - p6)) * half_length
        perp2 = -1 * perp1

        o1 = perp1 + x1
        o2 = perp1 + x2
        o3 = perp2 + x1
        o4 = perp2 + x2
        d1 = x2 - center

        # Rotate by 60 degrees to identify other points of the hexagon - note that t5 is the same as n1
        outer = [_rotate(o1, center, o2, alpha, d1) + center
                 for alpha in (0, 45, 135, 180, 225, 315)]

        perp_for = thickness * normalize(cross(o1 - o2, o3 - o1))
        perp_back = -1 * perp_for

        color_and_points = dict(
            front_1=perp_for + outer[0],
            front_2=perp_for + outer[1],
            front_3=perp_for + outer[2],
            front_4=perp_for + outer[3],
            front_5=perp_for + outer[4],
            front_6=perp_for + outer[5],
            back_1=perp_back + outer[0],
            back_2=perp_back + outer[1],
            back_3=perp_back + outer[2],
            back_4=perp_back + outer[3],
            back_5=perp_back + outer[4],
            back_6=perp_back + outer[5],
            center_1=perp_for + center,
            center_2=perp_back + center,
            color1=self.color1, color2=self.color2,
        )

        bild = """
        .color {color1}
        .polygon {front_1} {front_2} {center_1}
        .polygon {front_1} {center_1} {front_6}
        .polygon {front_3} {center_1} {front_2}
        .polygon {front_3} {front_4} {center_1}
        .polygon {front_5} {center_1} {front_4}
        .polygon {front_5} {front_6} {center_1}
        .polygon {back_1} {center_2} {back_2}
        .polygon {back_1} {back_6} {center_2}
        .polygon {back_3} {back_2} {center_2}
        .polygon {back_3} {center_2} {back_4}
        .polygon {back_5} {back_4} {center_2}
        .polygon {back_5} {center_2} {back_6}
        .polygon {back_1} {back_2} {front_1}
        .polygon {back_2} {front_2} {front_1}
        .polygon {back_2} {back_3} {front_2}
        .polygon {back_3} {front_3} {front_2}
        .polygon {back_3} {back_4} {front_3}
        .polygon {back_4} {front_4} {front_3}
        .polygon {back_4} {back_5} {front_4}
        .polygon {back_5} {front_5} {front_4}
        .polygon {back_5} {back_6} {front_5}
        .polygon {back_6} {front_6} {front_5}
        .polygon {back_6} {back_1} {front_6}
        .polygon {back_1} {front_1} {front_6}
        """.format(**color_and_points)
        return self._build_vrml(bild)

    def _draw_pentagon(self):
        center_att = Point(*self.center_att)
        center = Point(*self.center)
        p6 = Point(*self.p6)

        vec_AB = center_att - center
        shape_size = self.size
        half_length = shape_size / 2.0
        thickness = shape_size / 4.0

        adjustment = half_length / center.distance(center_att)
        adj_vec_AB_1 = adjustment * vec_AB
        adj_vec_AB_2 = -1 * adj_vec_AB_1

        x1 = adj_vec_AB_1 + center
        x2 = adj_vec_AB_2 + center

        perp1 = normalize(cross(x1 - x2, x2 - p6)) * half_length
        perp2 = -1 * perp1

        o1 = perp1 + x1
        o2 = perp1 + x2
        o3 = perp2 + x1
        o4 = perp2 + x2
        d1 = x2 - center

        # Rotate by 60 degrees to identify other points of the hexagon - note that t5 is the same as n1
        outer = [_rotate(o1, center, o2, alpha, d1) + center
                 for alpha in (72, 144, 216, 288, 360)]

        perp_for = thickness * normalize(cross(o1 - o2, o3 - o1))
        perp_back = -1 * perp_for

        color_and_points = dict(
            front_1=perp_for + outer[0],
            front_2=perp_for + outer[1],
            front_3=perp_for + outer[2],
            front_4=perp_for + outer[3],
            front_5=perp_for + outer[4],
            back_1=perp_back + outer[0],
            back_2=perp_back + outer[1],
            back_3=perp_back + outer[2],
            back_4=perp_back + outer[3],
            back_5=perp_back + outer[4],
            center_1=perp_for + center,
            center_2=perp_back + center,
            color1=self.color1, color2=self.color2,
        )

        bild = """
        .color {color1}
        .polygon {front_1} {front_2} {center_1}
        .polygon {front_1} {center_1} {front_5}
        .polygon {front_3} {center_1} {front_2}
        .polygon {front_3} {front_4} {center_1}
        .polygon {front_5} {center_1} {front_4}
        .polygon {back_1} {center_2} {back_2}
        .polygon {back_1} {back_5} {center_2}
        .polygon {back_3} {back_2} {center_2}
        .polygon {back_3} {center_2} {back_4}
        .polygon {back_5} {back_4} {center_2}
        .polygon {back_1} {back_2} {front_1}
        .polygon {back_2} {front_2} {front_1}
        .polygon {back_2} {back_3} {front_2}
        .polygon {back_3} {front_3} {front_2}
        .polygon {back_3} {back_4} {front_3}
        .polygon {back_4} {front_4} {front_3}
        .polygon {back_4} {back_5} {front_4}
        .polygon {back_5} {front_5} {front_4}
        .polygon {back_5} {back_1} {front_5}
        .polygon {back_1} {front_1} {front_5}
        """.format(**color_and_points)
        return self._build_vrml(bild)

    def _build_vrml(self, bild, name=None):
        if name is None:
            name = self.name
        f = StringIO(dedent(bild))
        try:
            vrml = openBildFileObject(f, '<string>', name)
        except chimera.NotABug:
            print(bild)
        chimera.openModels.add(vrml, baseId=self._id, subid=self._subid)
        self._subid += 1
        return vrml


def _vmd_trans_angle(a, b, c, delta):
    """
    Simulates VMD's `trans angle` command
    """
    ZERO = Point(0, 0, 0)
    xf = chimera.Xform.translation(b - ZERO)
    xf.rotate(cross(a - b, b - c), delta)
    xf.translate(ZERO - b)
    return xf


def _rotate(a, b, c, delta, x):
    rotation_xform = _vmd_trans_angle(a, b, c, delta)
    rotation_array = np.array(rotation_xform.getOpenGLMatrix()).reshape(4, 4).T
    return Vector(*np.dot(rotation_array, x.data() + (0,))[:3])


def normalize(v):
    return Vector(*M.normalize_vector(v))
