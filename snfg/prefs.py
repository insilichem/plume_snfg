#!/usr/bin/env python
# encoding: utf-8

"""
This is the preferences file for the extension. All default values
should be listed here for reference and easy reuse.
"""

# Get used to importing this in your Py27 projects!
from __future__ import print_function, division
from distutils.spawn import find_executable
import os
# Chimera
from chimera import preferences
from core import SNFG


def _defaults():
    return dict(zip(SNFG.__init__.im_func.func_code.co_varnames[1:],
                    SNFG.__init__.im_func.func_defaults))

DEFAULTS = _defaults() 

def assert_preferences():
    try:
        data = get_preferences()
    except KeyError:
        set_preferences()
    else:
        for k, v in data.items():
            if v is None:
                if k == 'icon_size':
                    preferences.set('plume_snfg', k, DEFAULTS['size'] / 2.5)
                elif k == 'full_size':
                    preferences.set('plume_snfg', k, DEFAULTS['size'])
                else:
                    preferences.set('plume_snfg', k, DEFAULTS[k])
            
        preferences.save(preferences.preferences._filename)

def set_preferences(icon_size=DEFAULTS['size'] / 2.5,
                    full_size=DEFAULTS['size'],
                    cylinder_radius=DEFAULTS['cylinder_radius'], 
                    connect=DEFAULTS['connect'], 
                    bondtypes=DEFAULTS['bondtypes']):
    preferences.set('plume_snfg', 'icon_size', icon_size),
    preferences.set('plume_snfg', 'full_size', full_size),
    preferences.set('plume_snfg', 'cylinder_radius', cylinder_radius)
    preferences.set('plume_snfg', 'connect', connect)
    preferences.set('plume_snfg', 'bondtypes', bondtypes)
    preferences.save(preferences.preferences._filename)


def get_preferences():
    return {'icon_size': preferences.get('plume_snfg', 'icon_size'),
            'full_size': preferences.get('plume_snfg', 'full_size'),
            'cylinder_radius': preferences.get('plume_snfg', 'cylinder_radius'),
            'connect': preferences.get('plume_snfg', 'connect'),
            'bondtypes': preferences.get('plume_snfg', 'bondtypes')}


preferences.addCategory('plume_snfg', preferences.HiddenCategory)
assert_preferences()