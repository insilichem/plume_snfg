#!/usr/bin/env python
# encoding: utf-8


from __future__ import print_function, division
# Python stdlib
import Tkinter as tk
import webbrowser as web
# Chimera stuff
import chimera
from chimera.baseDialog import ModelessDialog
# Additional 3rd parties

# Own
from libplume.ui import PlumeBaseDialog
from prefs import prefs, _defaults


ui = None  # singleton
def showUI():
    if chimera.nogui:
        tk.Tk().withdraw()
    global ui
    if not ui:
        ui = SNFGDialog()
    ui.enter()


class SNFGDialog(PlumeBaseDialog):

    buttons = ('OK', 'Apply', 'Reset', 'Cancel')
    default = None
    help = 'http://www.insilichem.com'

    def __init__(self, *args, **kwargs):
        # GUI init
        self.title = 'Plume 3D-SNFG'
        self.controller = None

        # Variables
        self.var_connect = tk.IntVar()
        self.var_bondtypes = tk.IntVar()

        # Fire up
        super(SNFGDialog, self).__init__(resizable=False, *args, **kwargs)
        self._set_defaults()

    def fill_in_ui(self, parent):
        self.ui_full_size = tk.Scale(self.canvas, from_=0.5, to=6.0,
                                orient='horizontal', label='Full Size',
                                resolution=0.1)
        self.ui_icon_size = tk.Scale(self.canvas, from_=0.5, to=6.0,
                                orient='horizontal', label='Icon Size',
                                resolution=0.1)
        self.ui_cylinder_radius = tk.Scale(self.canvas, from_=0.1, to=6.0,
                                           orient='horizontal', label='Connector Size',
                                           resolution=0.1)
        self.ui_connect = tk.Checkbutton(self.canvas, text='Connect residues',
                                         variable=self.var_connect)
        self.ui_bondtypes = tk.Checkbutton(self.canvas, text='Label bonds',
                                           variable=self.var_bondtypes)

        self.ui_more_info_btn = tk.Button(self.canvas, text='SNFG legend and details',
                                          command=lambda *a: web.open_new(r"https://www.ncbi.nlm.nih.gov/glycans/snfg.html"))

        self.canvas.columnconfigure(0, weight=1)
        self.canvas.columnconfigure(1, weight=1)
        self.ui_full_size.grid(row=0, column=0, sticky='we', padx=5, pady=3,
                               columnspan=2)
        self.ui_icon_size.grid(row=1, column=0, sticky='we', padx=5, pady=3,
                               columnspan=2)
        self.ui_cylinder_radius.grid(row=2, column=0, sticky='we', padx=5, pady=3,
                               columnspan=2)
        self.ui_connect.grid(row=3, column=0, padx=5, pady=3)
        self.ui_bondtypes.grid(row=3, column=1, padx=5, pady=3)
        self.ui_more_info_btn.grid(row=4, column=0, sticky='we', padx=5, pady=3,
                                   columnspan=2)

    def _set_defaults(self):
        self.ui_icon_size.set(prefs['icon_size'])
        self.ui_full_size.set(prefs['full_size'])
        self.ui_cylinder_radius.set(prefs['cylinder_radius'])
        self.var_connect.set(int(prefs['connect']))
        self.var_bondtypes.set(int(prefs['bondtypes']))

    def _get_current_values(self):
        return dict(icon_size = float(self.ui_icon_size.get()),
                    full_size = float(self.ui_full_size.get()),
                    cylinder_radius = float(self.ui_cylinder_radius.get()),
                    connect = bool(self.var_connect.get()),
                    bondtypes = bool(self.var_bondtypes.get()))

    def Reset(self):
        DEFAULTS = _defaults()
        self.ui_icon_size.set(DEFAULTS['size'] / 2.5)
        self.ui_full_size.set(DEFAULTS['size'])
        self.ui_cylinder_radius.set(DEFAULTS['cylinder_radius'])
        self.var_connect.set(int(DEFAULTS['connect']))
        self.var_bondtypes.set(int(DEFAULTS['bondtypes']))

    def Apply(self):
        for k, v in self._get_current_values().items():
            prefs.set(k, v, saveToFile=False)
        prefs.saveToFile()

    def OK(self):
        self.Apply()
        self.Close()

    def Close(self):  # Singleton mode
        global ui
        ui = None
        super(SNFGDialog, self).Close()