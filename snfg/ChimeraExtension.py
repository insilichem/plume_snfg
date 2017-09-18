#!/usr/bin/env python
# encoding: utf-8

# get used to importing this in your Py27 projects!
from __future__ import print_function, division 
import chimera
from Midas.midas_text import addCommand, doExtensionFunc
import prefs as _prefs
from core import SNFG


# Edit the name 
class SNFGExtension(chimera.extension.EMO):

    def name(self):
        # Always prefix with 'Plume'
        return 'Plume 3D-SNFG'

    def description(self):
        # Something short but meaningful
        return "3D representation for saccharydes"

    def categories(self):
        # Don't touch
        return ['InsiliChem']

    def icon(self):
        # To be implemented
        return

    def activate(self):
        # Don't edit unless you know what you're doing
        self.module('gui').showUI()


def cmd_snfg(cmdName, args):
    def cmd(models=None, method='icon', size=None, **kwargs):
        methods = ('icon', 'full', 'fullred', 'fullshown')
        if method not in methods:
            chimera.statusline.show_message('Method {} not supported. Try with: {}'.format(
                                            method, ', '.join(methods)), color='red')
        if models or models is None:
            snfg = getattr(SNFG, 'as_'+method)(molecules=models, size=size, **kwargs)

    doExtensionFunc(cmd, args, specInfo=[("spec", "models", 'molecules')])


def cmd_undo_snfg(cmdName, args):
    def cmd(*args):
        for instance in SNFG._instances:
            instance.disable()
            chimera.viewer.updateCB(chimera.viewer)

    doExtensionFunc(cmd, args)

chimera.extension.manager.registerExtension(SNFGExtension(__file__))
addCommand("snfg", cmd_snfg, cmd_undo_snfg)