#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rename_ses renames the session directory from "ses-mri01" to either "ses-Visit1" or "ses-Visit3,
depending on the (4th character of the) POM-identifier (e.g. POM3FM9188415 -> Visit3)".
"""

from pathlib import Path

rawdir = Path('/project/3024006.01/raw')


def rename(dryrun):

    for subdir in rawdir.glob('sub-PIT*'):
        oldses = subdir/'ses-mri01'
        newses = subdir/f"ses-PITVisit{subdir.name.split('sub-PIT')[1][0]}"
        if oldses.is_dir():
            if newses.is_dir():
                print(f"Warning: Skipping renaming because {newses} already exists")
                continue
            print(f"Renaming: {oldses} -> {newses}")
            if not dryrun:
                oldses.rename(newses)
        elif not newses.is_dir():
            print(f"Found unexpected session folders in {subdir}\n: {list(subdir.iterdir())}")


# Shell usage
if __name__ == "__main__":

    # Parse the input arguments and run bidsmapper(args)
    import argparse
    import textwrap
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  rename_ses.py -d\n')
    parser.add_argument('-d','--dryrun', help='Add this flag to just print the rename_ses commands without actually doing anything', action='store_true')
    args = parser.parse_args()

    rename(args.dryrun)
