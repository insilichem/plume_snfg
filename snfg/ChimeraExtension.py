#!/usr/bin/env python
# encoding: utf-8

# get used to importing this in your Py27 projects!
from __future__ import print_function, division 
import chimera.extension
from Midas.midas_text import addCommand, doExtensionFunc
from snfg import SNFG

def cmd_snfg(cmdName, args):
    def cmd(models=None, method='icon', **kwargs):
        if models or models is None:
            snfg = getattr(SNFG, 'as_'+method)(molecules=models, **kwargs)
            snfg.enable()

    doExtensionFunc(cmd, args, specInfo=[("spec", "models", 'molecules')])

def cmd_undo_snfg(cmdName, args):
    doExtensionFunc(SNFG.disable, args)

addCommand("snfg", cmd_snfg, cmd_undo_snfg)