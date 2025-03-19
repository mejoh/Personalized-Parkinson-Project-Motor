#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
pep2bids.py merges back the pep-uploaded separate (single-subject) BIDS repositories
into a single normal BIDS data repository. Use this function after running "pepdownload.py"
"""

import pandas as pd
import shutil
from pathlib import Path


def mergepulldir(pulldir: Path, bidsdir: Path, method: str, force: bool, dryrun: bool):
    """
    Merges a dwonloaded single-subject BIDS repository into the BIDS directory

    :param pulldir: The single subject data directory as downloaded by the pepcli client
    :param bidsdir: The target BIDS directory in which the downloaded dat ais merged
    :param method:  Either 'move' or 'copy' the downloaded data into the BIDS directory
    :param force:   Overwite data in bidsdir
    :param dryrun:  Only print the intended actions if True
    :return:
    """

    pulldir = Path(pulldir)
    bidsdir = Path(bidsdir)
    if not dryrun:
        bidsdir.mkdir(parents=True, exist_ok=True)

    # Loop over the PEP data-columns (data column = single subject BIDS repository)
    columns = [item for item in pulldir.glob('*') if item.is_dir()]
    if not columns:
        print(f"WARNING: No data columns found in: {pulldir}")
    for column in columns:

        if not (column/'participants.tsv').is_file():
            print(f"WARNING: No participants.tsv file found, skipping: {column}")
            continue

        # Copy pulled files in the pulled root directory to the bids directory if needed
        for item in column.glob('*'):
            if item.is_file() and not (bidsdir/item.name).is_file():
                print(f"Copying pulled data file:\n{item} -> {bidsdir/item.name}\n")
                if not dryrun:
                    shutil.copy2(item, bidsdir)

        # Merge the pulled participants.tsv file with the bids participants.tsv file
        participants_pull = pd.read_csv(column/'participants.tsv', sep='\t')
        participants_pull.set_index(['participant_id'], verify_integrity=True, inplace=True)
        participants_bids = pd.read_csv(bidsdir/'participants.tsv', sep='\t')
        participants_bids.set_index(['participant_id'], verify_integrity=True, inplace=True)
        sub     = participants_pull.index[0]
        ses     = list((column/sub).glob('ses-*'))[0].name      # NB: There is always only 1 session (because we have a subject/column/subject/session directory structure with column = session)
        sources = [item for item in (column/sub/ses).glob('*') if item.is_dir()]
        if not sources:
            print(f"WARNING: Skipping subject, no BIDS modalities / data found in: {column/sub/ses}")
            continue
        if sub not in participants_bids.index:
            print(f"Merging pulled participant data:\n{participants_pull.loc[sub]} -> {bidsdir/'participants.tsv'}")
            participants_bids.loc[sub] = participants_pull.loc[sub]
            if not dryrun:
                participants_bids.to_csv(bidsdir/'participants.tsv', sep='\t', encoding='utf-8', na_rep='n/a')

        # Copy or move the pulled session modalities to the BIDS directory
        for source in sources:
            destination = bidsdir/sub/ses/source.name
            if not force and destination.is_dir():
                print(f"WARNING: Skipping {method}, destination folder already exists:\n{source} -> {destination}\n")
                continue
            else:
                print(f"{method} pulled data files:\n{source} -> {destination}\n")
            if not dryrun:
                destination.parent.mkdir(parents=True, exist_ok=True)
                if destination.is_dir():
                    shutil.rmtree(destination)
                if method == 'move':
                    shutil.move(source, destination)
                else:
                    shutil.copytree(source, destination)


# Shell usage
if __name__ == "__main__":

    # Parse the input arguments and run mergepulldir(args)
    import argparse
    import textwrap
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  pep2bids.py /project/3022026.01/pep/download /project/3022026.01/pep/bids -m move\n')
    parser.add_argument('pulldir',       help='The root pulled-data directory containing the data downloaded by the pepcli client')
    parser.add_argument('bidsdir',       help='The destination BIDS directory in which the dowloaded data will be merged')
    parser.add_argument('-m','--method', help='Method for merging the pulled directories into the bidsdir. NB: move is much fast and does not need extra disc-space, but it is a one-time operation', choices=['move', 'copy'], default='copy')
    parser.add_argument('-f','--force',  help='Add this flag to overwrite existing data in the bids directory', action='store_true')
    parser.add_argument('-d','--dryrun', help='Add this flag to just print the pep2bids commands without actually doing anything', action='store_true')
    args = parser.parse_args()

    # Make a list of the downloaded participants on disk
    pulldirs = [subdir for subdir in Path(args.pulldir).glob('*') if subdir.is_dir() and not subdir.name.startswith('.')]
    print(f"Found {len(pulldirs)} subjects in the pulled-data repository")

    # Merge the downloaded participant directories into a single BIDS directory
    for n, pulldir in enumerate(pulldirs, start=1):
        print(f"\n==> Merging {pulldir} ({n}/{len(pulldirs)})\n")
        mergepulldir(pulldir, args.bidsdir, args.method, args.force, args.dryrun)
