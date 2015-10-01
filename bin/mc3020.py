#!/usr/bin/env python
# encoding: utf-8
# Copyright (C) 2015 John Törnblom
import optparse
import logging
import sys
import os

import xtuml
import rsl


def fix_incorrect_phrases(m):
    '''
    Fix incorrect phrases caused by a faulty BridgePoint lexer.
    '''
    for inst in m.select_many('ACT_LNK'):
        inst.Rel_Phrase = inst.Rel_Phrase.replace("'", "")
        
    for key_letter in ['ACT_REL', 'ACT_UNR', 'ACT_RU', 'ACT_URU']:
        for inst in m.select_many(key_letter):
            inst.relationship_phrase = inst.relationship_phrase.replace("'", "")
            
    for key_letter in ['R_PART', 'R_FORM', 'R_AONE', 'R_AOTH', 'R_CONE', 'R_COTH']:
        for inst in m.select_many(key_letter):
            inst.Txt_Phrs = inst.Txt_Phrs.replace("'", "")

        
def main():
    '''
    Parse command line options and launch mc3020.
    '''
    parser = optparse.OptionParser(usage="%prog [options] model.sql", formatter=optparse.TitledHelpFormatter())
    parser.add_option("-m", "--markings", dest="markings", metavar="PATH", help="use markings from PATH", action="store", default=None)
    parser.add_option("-e", "--emit", dest='emit', metavar="WHEN", choices=['never', 'change', 'always'], action="store", help="choose when to emit (never, change, always)", default='change')
    parser.add_option("-f", "--force", dest='force', action="store_true", help="make read-only emit files writable", default=False)
    parser.add_option("-d", "--diff", dest='diff', metavar="PATH", action="store", help="save a diff of all emits to PATH", default=None)
    
    (opts, args) = parser.parse_args()
    if len(args) == 0:
        parser.print_help()
        sys.exit(1)

    dirname = os.path.dirname(__file__) + '/..'
    
    logging.basicConfig(level=logging.INFO)
    loader = xtuml.load.ModelLoader()
    loader.build_parser()
    loader.filename_input(dirname + '/schema/sql/xtumlmc_schema.sql')        
    for sql_file in args:
        loader.filename_input(sql_file)
        
    metamodel = loader.build_metamodel(ignore_undefined_classes=True)
    fix_incorrect_phrases(metamodel)
                
    includes = [dirname + '/arc',
                dirname + '/arc/c',
                dirname + '/schema/colors']
    
    if opts.markings:
        includes.insert(0, opts.markings)
        
    if opts.diff:
        with open(opts.diff, 'w') as f:
            f.write(' '.join(sys.argv))
            f.write('\n')
            
    rt = rsl.Runtime(metamodel, opts.emit, opts.force, opts.diff)
    rt.put_env_var('.', 'ROX_MC_ARC_DIR')
    ast = rsl.parse_file(dirname + '/arc/c/sys.arc')
    rsl.evaluate(rt, ast, includes)
        


if __name__ == '__main__':
    main()

