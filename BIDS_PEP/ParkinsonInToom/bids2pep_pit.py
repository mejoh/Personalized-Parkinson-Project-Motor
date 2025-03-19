#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bids2pep.py is a wrapper around the pepcli that queries the pep repository for the subject
participants and uploads them using the compute cluster.
"""

import pandas as pd
import subprocess
import json
import os
import shutil
import logging
import coloredlogs
import shutil
from pathlib import Path

bidsdir = Path('/project/3024006.01/bids')
pepdir  = Path('/project/3024006.01/pep/upload')
pepcli  = 'module add singularity; singularity run /project/3022026.01/pep/pepcli/pep-client-ppp.simg /app/pepcli'


def store2pep(peptoken: str, POMid: str, datacolumn: str, dryrun: bool):
    """

    :param peptoken:
    :param POMid:
    :param datacolumn:
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

        # Create symlinks to the dataset_description.json, participants.json and README files
        os.link(bidsdir/'dataset_description.json', datadir/'dataset_description.json')
        os.link(bidsdir/'participants.json',        datadir/'participants.json')
        os.link(bidsdir/'README',                   datadir/'README')
        os.link(bidsdir/'.bidsignore',              datadir/'.bidsignore')

        # Create the subject / session directory
        ses = f"ses-PIT{datacolumn.split('.')[1]}" #CHECK THIS NUMB ER HERE DATA COLUMN NAME IS SPLITST
        (datadir/f"sub-{POMid}"/ses).mkdir(parents=True)

        # Create symbolic links to the Anat data
        def createsymlink(modality):
            if (bidsdir/f"sub-{POMid}"/ses/modality).is_dir():
                shutil.copytree(bidsdir/f"sub-{POMid}"/ses/modality, datadir/f"sub-{POMid}"/ses/modality, copy_function=os.link)

        if 'Anat' in datacolumn:
            createsymlink('anat')
            createsymlink('dwi')
            createsymlink('fmap')
            # createsymlink('extra_data')

        elif 'Func' in datacolumn or 'FMRI' in datacolumn:
            createsymlink('func')
            createsymlink('beh')
            createsymlink('eeg')

        else:
            logger.warning(f"Unknown data-column '{datacolumn}'")

    # Store the data in PEP
    # /app/pepcli --client-working-directory ~/pom/pepcli --oauth-token ~/peptoken.json --client-config-name ~/pom/pepcli/ClientConfig.json store -c "Visit1.MRI.Anat" --sp POM1FM0416036 -i /home/mrphys/marzwi/pom/DR_DAC
    command = f"{pepcli} --client-working-directory /config --oauth-token {peptoken} store -c {datacolumn} --sp {POMid} -i {datadir}"
    logger.info(command)
    if not dryrun:
        proc = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        if proc.returncode != 0:
            logger.error(f"Job submission failed with error-code {proc.returncode}:\n{proc.stderr.decode('utf-8')}\n")


def listpep(peptoken: str, datacolumn: str) -> list:
    """

    :param peptoken:
    :param datacolumn:
    :return:
    """

    # Query the pep-repository: /app/pepcli --client-working-directory /project/3022026.01/pepcli --oauth-token /home/mrphys/marzwi/peptoken.json --client-config-name /project/3022026.01/pepcli/ClientConfig.json list -c Visit1.MRI.Anat -c ShortPseudonym.Visit1.FMRI -l -P \*
    spcolumn = f"ShortPseudonym.{datacolumn.split('.')[0]}.{datacolumn.split('.')[1]}.FMRI"
    command  = f"{pepcli} --client-working-directory /config --oauth-token {peptoken} list -c {datacolumn} -c {spcolumn} -P all-ppp"
    logger.info(f"--> Querying {datacolumn} in PEP:\n{command}")
    proc = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    if proc.returncode!=0:
        logger.error(f"PEP cli command failed with error-code {proc.returncode}:\n{proc.stderr.decode('utf-8')}\n")

    # Parse the participants from the json output
    pepdata = json.loads(proc.stdout.decode())
    POMids  = [pepitem['data'][spcolumn] for pepitem in pepdata if 'data' in pepitem and datacolumn in pepitem['data']]

    logger.info(f"Found {len(POMids)} subjects with {datacolumn} data in the PEP repository\n")

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
                logger.info('')

        elif filehandler.name == 'loghandler':
            logfile = Path(filehandler.baseFilename)

    if 'logfile' in locals():
        logger.info(f"For the complete log see: {logfile}")


# Shell usage
if __name__ == "__main__":

    # Parse the input arguments and run bidsmapper(args)
    import argparse
    import textwrap
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  bids2pep.py -t /home/mrphys/marzwi/mytoken.json\n'
                                            '  bids2pep.py -p POM1FM0023671\n')
    parser.add_argument('-p','--POMids',  help='Space separated list of POM-identifiers that can be uploaded. If empty all subjects in the raw-folder will be selected', nargs='+')
    parser.add_argument('-c','--columns', default=['Pit.Visit1.MRI.Func', 'Pit.Visit1.MRI.Anat', 'Pit.Visit2.MRI.Func', 'Pit.Visit2.MRI.Anat'], help='The data columns that are to be uploaded to the PEP repository', nargs='+')
    parser.add_argument('-t','--token',   default=Path.home()/'peptoken.json', help='The token for logging on the PEP repository')
    parser.add_argument('-f','--force',   help='Add this flag to force uploading of the data', action='store_true')
    parser.add_argument('-d','--dryrun',  help='Add this flag to just print the bids2pep commands without actually doing anything', action='store_true')
    args = parser.parse_args()

    logger = setup_logging(pepdir/'bids2pep.log')

    # Make a list of the participants on disk
    if args.POMids:
        POMids = args.POMids
    else:
        #logger.info(f"Querrying bidsdir {bidsdir.glob('sub-PIT*')} ...")
        POMids = [subdir.name[4:] for subdir in bidsdir.glob('sub-PIT*')]
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
