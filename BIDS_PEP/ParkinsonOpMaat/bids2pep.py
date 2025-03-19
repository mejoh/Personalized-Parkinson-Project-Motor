#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bids2pep.py is a wrapper around the pepcli that queries the PEP repository for previously uploaded subjects and
uploads any new subjects to PEP. Run this function from a compute-node on which a singularity module is available.
"""

import pandas as pd
import subprocess
import json
import os
import shutil
import logging
import coloredlogs
import sys
import shutil
from pathlib import Path

bidsdir = Path('/project/3022026.01/bids')
pepdir  = Path('/project/3022026.01/pep/upload')
pepcli  = 'module add singularity; singularity run /project/3022026.01/pep/pepcli/pep-client-ppp.simg /app/pepcli'

logger  = logging.getLogger()


def store2pep(peptoken: str, POMid: str, datacolumn: str, dryrun: bool):
    """
    Uploads data to the PEP repository

    :param peptoken:    The token for logging on the PEP repository
    :param POMid:       The POMids' for which data is uploaded
    :param datacolumn:  The data column to which the data is uploaded
    :param dryrun:      If True, print the output to screen but don't actually do anything else
    :return:
    """

    # Create a clean bids-directory for this participant
    datadir = pepdir/POMid/datacolumn
    if not dryrun:
        if datadir.is_dir():
            shutil.rmtree(datadir)
        datadir.mkdir(parents=True)

    # Create a single-subject participants.tsv file
    participants_table = pd.read_csv(bidsdir/'participants.tsv', sep='\t')
    participants_table.set_index(['participant_id'], verify_integrity=True, inplace=True)
    if 'sub-'+POMid in participants_table.index:
        logger.info(f"Creating a custom participants.tsv file and symbolic links to the data in: {datadir}")
    else:
        logger.warning(f"Skipping {POMid} because this subject was not found in {bidsdir/'participants.tsv'}")
        return
    participant_table = participants_table[participants_table.index=='sub-' + POMid]
    if not dryrun:
        participant_table.replace('','n/a').to_csv(datadir/'participants.tsv', sep='\t', encoding='utf-8', na_rep='n/a')

        # Create symlinks to the dataset_description.json, participants.json and README source files
        os.link(bidsdir/'dataset_description.json', datadir/'dataset_description.json')
        os.link(bidsdir/'participants.json',        datadir/'participants.json')
        os.link(bidsdir/'README',                   datadir/'README')
        os.link(bidsdir/'.bidsignore',              datadir/'.bidsignore')

        # Create the subject / session directory
        ses = f"ses-POM{datacolumn.split('.')[0]}"
        (datadir/f"sub-{POMid}"/ses).mkdir(parents=True)

        # Create symbolic links to the source BIDS-modality directories for the Anat and Func data columns
        def makesymlinks(modalities):
            for modality in modalities:
                if (bidsdir/f"sub-{POMid}"/ses/modality).is_dir():
                    shutil.copytree(bidsdir/f"sub-{POMid}"/ses/modality, datadir/f"sub-{POMid}"/ses/modality, copy_function=os.link)

        if 'Anat' in datacolumn:
            makesymlinks(['anat', 'dwi', 'fmap'])  #, 'extra_data'])
        elif 'Func' in datacolumn or 'FMRI' in datacolumn:
            makesymlinks(['func', 'beh', 'eeg'])
        else:
            logger.warning(f"Unknown data-column '{datacolumn}'")

    # Store the data in PEP
    # /app/pepcli --client-working-directory ~/pom/pepcli --oauth-token ~/peptoken.json --client-config-name ~/pom/pepcli/ClientConfig.json store -c "Visit1.MRI.Anat" --sp POM1FM0416036 -i /home/mrphys/marzwi/pom/DR_DAC
    command = f"{pepcli} --client-working-directory /config --oauth-token {peptoken} store -c {datacolumn} --sp {POMid} -i {datadir}"
    logger.info(command)
    if not dryrun:
        proc = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        if proc.returncode != 0:
            logger.error(f"PEP cli command failed with error-code {proc.returncode}:\n{proc.stderr.decode('utf-8')}\n")


def listpep(peptoken: str, datacolumn: str) -> list:
    """
    Queries the PEP server for previously uploaded subjects

    :param peptoken:    The token for logging on the PEP repository
    :param datacolumn:  The data columns that are to be uploaded to the PEP repository
    :return:            List of POMid's that have uploaded data in the data column
    """

    # Query the pep-repository: /app/pepcli --client-working-directory /project/3022026.01/pepcli --oauth-token /home/mrphys/marzwi/peptoken.json --client-config-name /project/3022026.01/pepcli/ClientConfig.json list -c Visit1.MRI.Anat -c ShortPseudonym.Visit1.FMRI -l -P \*
    spcolumn = f"ShortPseudonym.{datacolumn.split('.')[0]}.FMRI"
    command  = f"{pepcli} --client-working-directory /config --oauth-token {peptoken} list -g -c {datacolumn} -c {spcolumn}"
    logger.info(f"--> Querying {datacolumn} in PEP:\n{command}")
    proc = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    if proc.returncode != 0:
        logger.error(f"PEP cli command failed with error-code {proc.returncode}:\n{proc.stderr.decode('utf-8')}\n")

    # Parse the participants from the json output
    pepdata = json.loads(proc.stdout.decode())
    POMids  = [pepitem['data'][spcolumn] for pepitem in pepdata if 'ids' in pepitem and datacolumn in pepitem['ids']]

    logger.info(f"Found {len(POMids)}/{len(pepdata)} subjects with {datacolumn} data in the PEP repository\n")

    return POMids


def setup_logging(log_file: Path=Path(), debug: bool=False) -> logging.Logger:
    """
    Setup the logging

    :param log_file:    Name of the logfile
    :param debug:       Set log level to DEBUG if debug==True
    :return:            Logger object
     """

    # debug = True
    logger = logging.getLogger('BIDS2PEP')

    # Set the format and logging level
    fmt       = '%(asctime)s - %(name)s - %(levelname)s %(message)s'
    datefmt   = '%Y-%m-%d %H:%M:%S'
    formatter = logging.Formatter(fmt=fmt, datefmt=datefmt)
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    # Set & add the streamhandler and add some color to those boring terminal logs! :-)
    coloredlogs.install(level=logger.level, fmt=fmt, datefmt=datefmt)

    if not log_file.name:
        return

    # Set & add the log filehandler
    log_file.parent.mkdir(parents=True, exist_ok=True)      # Create the log dir if it does not exist
    loghandler = logging.FileHandler(log_file)
    loghandler.setLevel(logging.DEBUG)
    loghandler.setFormatter(formatter)
    loghandler.set_name('loghandler')
    logger.addHandler(loghandler)

    # Set & add the error / warnings handler
    error_file = log_file.with_suffix('.errors')            # Derive the name of the error logfile from the normal log_file
    errorhandler = logging.FileHandler(error_file, mode='w')
    errorhandler.setLevel(logging.WARNING)
    errorhandler.setFormatter(formatter)
    errorhandler.set_name('errorhandler')
    logger.addHandler(errorhandler)

    return logger


def reporterrors() -> None:
    """
    Summarized the warning and errors from the logfile

    :return:
    """

    for filehandler in logger.handlers:
        if filehandler.name == 'errorhandler':

            errorfile = Path(filehandler.baseFilename)
            if errorfile.stat().st_size:
                with errorfile.open('r') as fid:
                    errors = fid.read()
                logger.info(f"The following bids2pep errors and warnings were reported:\n\n{40*'>'}\n{errors}{40*'<'}\n")

            else:
                logger.info(f'No bids2pep errors or warnings were reported')
                logger.info(f"{'-' * 30} END {'-' * 42}")

        elif filehandler.name == 'loghandler':
            logfile = Path(filehandler.baseFilename)

    if 'logfile' in locals():
        logger.info(f"For the complete log see: {logfile}")


# Shell usage
if __name__ == "__main__":

    import argparse
    import textwrap

    # Parse the input arguments and run bidsmapper(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter,
                                     description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  bids2pep.py -t /home/mrphys/marzwi/mytoken.json\n'
                                            '  bids2pep.py -p POM1FM0023671\n')
    parser.add_argument('-p','--POMids',  help='Space separated list of POM-identifiers that can be uploaded. If empty all subjects in the raw-folder will be selected', nargs='+')
    parser.add_argument('-c','--columns', default=['Visit1.MRI.Func', 'Visit1.MRI.Anat', 'Visit3.MRI.Func', 'Visit3.MRI.Anat'], help='The data columns that are to be uploaded to the PEP repository', nargs='+')
    parser.add_argument('-t','--token',   default=Path.home()/'peptoken.json', help='The token for logging on the PEP repository')
    parser.add_argument('-f','--force',   help='Add this flag to force uploading all of the data', action='store_true')
    parser.add_argument('-d','--dryrun',  help='Add this flag to just print the bids2pep commands without actually doing anything', action='store_true')
    args = parser.parse_args()

    # Start logging
    logger = setup_logging(pepdir/'bids2pep.log')
    logger.info(f"{'-'*30} START {'-'*40}\n$ {' '.join(sys.argv)}")

    # Make a list of the participants on disk
    if args.POMids:
        POMids = args.POMids
    else:
        POMids = [subdir.name[4:] for subdir in bidsdir.glob('sub-POM*')]
        logger.info(f"Found {len(POMids)} subjects in the bids repository")

    # Upload the participant if it is not present in the PEP repository
    for datacolumn in args.columns:
        if args.force:
            POMids_pep = []
        else:
            POMids_pep = listpep(args.token, datacolumn)
        for n, POMid in enumerate(POMids):
            if POMid not in POMids_pep and datacolumn.split('Visit')[1][0]==POMid[3]:
                logger.info(f"\n--> Storing {POMid}/{datacolumn} in the PEP repository ({n}/{len(POMids)})")
                store2pep(args.token, POMid, datacolumn, args.dryrun)
            elif POMid in POMids_pep:
                logger.info(f"\n>>> Skipping storing {POMid}/{datacolumn}, data already present in the PEP repository ({n}/{len(POMids)})")

    reporterrors()
