#!/usr/bin/env python
# encoding: utf-8


from __future__ import print_function, division
import chimera
from Midas.midas_text import addCommand, doExtensionFunc
import prefs as _prefs
from core import SNFG


class SNFGExtension(chimera.extension.EMO):

    def name(self):
        return 'Tangram 3D-SNFG'

    def description(self):
        return "3D representation for saccharydes"

    def categories(self):
        return ['InsiliChem']

    def icon(self):
        return

    def activate(self):
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