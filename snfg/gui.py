#!/usr/bin/env python
# encoding: utf-8

# Get used to importing this in your Py27 projects!
from __future__ import print_function, division 
# Python stdlib
import Tkinter as tk
import webbrowser as web
# Chimera stuff
import chimera
from chimera.baseDialog import ModelessDialog
# Additional 3rd parties

# Own
from prefs import get_preferences, set_preferences, DEFAULTS

"""
The gui.py module contains the interface code, and only that. 
It should only 'draw' the window, and should NOT contain any
business logic like parsing files or applying modifications
to the opened molecules. That belongs to core.py.
"""

# This is a Chimera thing. Do it, and deal with it.
ui = None
def showUI(callback=None):
    """
    Requested by Chimera way-of-doing-things
    """
    if chimera.nogui:
        tk.Tk().withdraw()
    global ui
    if not ui: # Edit this to reflect the name of the class!
        ui = SNFGDialog()
    ui.enter()
    if callback:
        ui.addCallback(callback)


STYLES = {
    tk.Scale: {
        'borderwidth': 1,
        'highlightthickness': 0,
        'sliderrelief': 'flat'
    },
    tk.Button: {
        'borderwidth': 1,
        'highlightthickness': 0,
    },
    tk.Checkbutton: {
        'highlightbackground': chimera.tkgui.app.cget('bg'),
        'activebackground': chimera.tkgui.app.cget('bg'),
    }
}


class SNFGDialog(ModelessDialog):

    """
    To display a new dialog on the interface, you will normally inherit from
    ModelessDialog class of chimera.baseDialog module. Being modeless means
    you can have this dialog open while using other parts of the interface.
    If you don't want this behaviour and instead you want your extension to 
    claim exclusive usage, use ModalDialog.
    """

    buttons = ('Apply', 'Reset', 'Close')
    default = None
    resize = False
    help = 'http://www.insilichem.com'

    def __init__(self, *args, **kwarg):
        # GUI init
        self.title = 'Plume 3D-SNFG'
        self.controller = None

        # Variables
        self.var_connect = tk.IntVar()
        self.var_bondtypes = tk.IntVar()

        # Fire up
        ModelessDialog.__init__(self, resizable=False)
        if not chimera.nogui:  # avoid useless errors during development
            chimera.extension.manager.registerInstance(self)

        # Fix styles
        self._fix_styles(*self.buttonWidgets.values())
        self._set_defaults()

    def _initialPositionCheck(self, *args):
        try:
            ModelessDialog._initialPositionCheck(self, *args)
        except Exception as e:
            if not chimera.nogui:  # avoid useless errors during development
                raise e

    def _fix_styles(self, *widgets):
        for widget in widgets:
            try:
                widget.configure(**STYLES[widget.__class__])
            except Exception as e:
                print('Error fixing styles:', type(e), str(e))

    def fillInUI(self, parent):
        # Create main window
        self.canvas = tk.Frame(parent)
        self.canvas.pack(expand=False, fill='both')
        self.ui_labels = {}
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
        self.ui_bondtypes = tk.Checkbutton(self.canvas, text='Color by bond type',
                                           variable=self.var_bondtypes)

        self.ui_more_info_btn = tk.Button(self.canvas, text='SNFG legend and details',
                                          command=lambda *a: web.open_new(r"https://www.ncbi.nlm.nih.gov/glycans/snfg.html"))

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
        
        self._fix_styles(*[getattr(self, attr) for attr in dir(self) 
                           if attr.startswith('ui_')])


        # InsiliChem copyright
        bg = chimera.tkgui.app.cget('bg')
        img_data = r"R0lGODlhZABrAOeeADhwWDBzWTlxWTF0WjpyWjtzWzx0XD11XT52Xj93X0B4YEF5YUJ6YkN7Yz98aEt6Y0R8ZEB9aUx7ZEV9ZU18ZUZ+Zk59Zkt+bE9+Z0x/bVB/aE2AblGAaU6Bb1KBak+CcFOCa1CDcVSDbFGEclWEbVKFc1OHdFSIdVuGdVWJdlyHdlaKd12Id1eLeF6JeFiMeV+KeWCLemGMe2KNfGOOfWSPfmWQf2aSgGeTgW6RgWiUgm+SgmmVg3CTg3GUhHKVhXOWhnSXh3WYiHaZiXebinici3mdjICcjXqejYGdjnufjoKej3ygj4OfkH2hkISgkYGhl4WhkoKimIaik4OjmYeklIWlm4illYmmloennYqnmIionouomYmpn4ypmoqqoI2qm4uroY6rnJGqopKro5OspJStpZWuppiuoJavp5ewqJixqZqyqpuzq5y0rJ21rZ62rqS1rp+3r6W2r6a3sKe4sai5sqm6tKq7tau8tqy9t62+uK6/ubW/uq/BurbAu7DCu7jBvLLDvLnCvbPEvbrDvrvEv7zFwL3Hwr7Iw7/JxMDKxcHLxsLMx8PNyMrMycTOycbPysvOys3Py87QzM/RztDSz9HT0NLU0dPV0tTW09XX1NbY1dja1v///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////yH5BAEKAP8ALAAAAABkAGsAQAj+ADsJHEiwoMGDCA1ienTITpgiNEJAMAAhU4YPK2wU8SKnECNKmxKKHEmyJME9BgCkaUQAgMuXMGPKBMBAU8uZOGfGoeIyTCaTQDtFUpBz5iMylIIqJRiJyqSURWMGAjonqssC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"
        img = tk.PhotoImage(data=img_data)
        logo = tk.Button(self.canvas, image=img, background=bg, borderwidth=0,
                         activebackground=bg, highlightcolor=bg, cursor="hand2",
                         command=lambda *a: web.open_new(r"http://www.insilichem.com/"))
        logo.image = img
        text = tk.Text(self.canvas, background=bg, borderwidth=0, height=4, width=30)
        hrefs = HyperlinkManager(text)
        big = text.tag_config("big", font="-size 18", foreground="#367159")
        text.insert(tk.INSERT, "InsiliChem", "big")
        text.insert(tk.INSERT, "\nDeveloped by ")
        text.insert(tk.INSERT, "@jaimergp", hrefs.add(lambda *a: web.open_new(r"https://github.com/jaimergp")))
        text.insert(tk.INSERT, "\nat Maréchal Group, UAB, Spain")
        text.configure(state='disabled')
        
        logo.grid(row=5, column=0, sticky='we', padx=5, pady=3)
        text.grid(row=5, column=1, sticky='we', padx=5, pady=3)

    def _set_defaults(self):
        preferences = get_preferences()
        self.ui_icon_size.set(preferences['icon_size'])
        self.ui_full_size.set(preferences['full_size'])
        self.ui_cylinder_radius.set(preferences['cylinder_radius'])
        self.var_connect.set(int(preferences['connect']))
        self.var_bondtypes.set(int(preferences['bondtypes']))
    
    def _reset_defaults(self):
        self.ui_icon_size.set(DEFAULTS['size'] / 2.5)
        self.ui_full_size.set(DEFAULTS['size'])
        self.ui_cylinder_radius.set(DEFAULTS['cylinder_radius'])
        self.var_connect.set(int(DEFAULTS['connect']))
        self.var_bondtypes.set(int(DEFAULTS['bondtypes']))
    Reset = _reset_defaults

    def _get_current_values(self):
        return dict(icon_size = float(self.ui_icon_size.get()),
                    full_size = float(self.ui_full_size.get()),
                    cylinder_radius = float(self.ui_cylinder_radius.get()),
                    connect = bool(self.var_connect.get()),
                    bondtypes = bool(self.var_bondtypes.get()))

    def Apply(self):
        set_preferences(**self._get_current_values())

    def OK(self):
        self.Apply()
        self.Close()

    def Close(self):
        global ui
        ui = None
        ModelessDialog.Close(self)
        chimera.extension.manager.deregisterInstance(self)
        self.destroy()


class HyperlinkManager:
    """
    from http://effbot.org/zone/tkinter-text-hyperlink.htm
    """

    def __init__(self, text):

        self.text = text

        self.text.tag_config("hyper", foreground="#367159", underline=1)

        self.text.tag_bind("hyper", "<Enter>", self._enter)
        self.text.tag_bind("hyper", "<Leave>", self._leave)
        self.text.tag_bind("hyper", "<Button-1>", self._click)

        self.reset()

    def reset(self):
        self.links = {}

    def add(self, action):
        # add an action to the manager.  returns tags to use in
        # associated text widget
        tag = "hyper-%d" % len(self.links)
        self.links[tag] = action
        return "hyper", tag

    def _enter(self, event):
        self.text.config(cursor="hand2")

    def _leave(self, event):
        self.text.config(cursor="")

    def _click(self, event):
        for tag in self.text.tag_names(tk.CURRENT):
            if tag[:6] == "hyper-":
                self.links[tag]()
                return