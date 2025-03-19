#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
pepdownload.py is a wrapper around the pepcli that downloads data for all subjects in the PEP repository
for each data column. Run this function from a compute-node on which a singularity module is available.
Run "pep2bids.py" afterwards to merge the downloaded data back into a single BIDS repository
"""

import subprocess
from pathlib import Path

pepcfg = Path('/project/3022026.01/pep/pepcli/ClientConfig.json')
pepcli = 'module add singularity; singularity run /project/3022026.01/pep/pepcli/pep-services_latest.sif /app/pepcli'


def pullpep(peptoken: str, datacolumns: str, outputdir: str, resume: bool):
    """
    Download all data in the datacolumns

    :param peptoken:
    :param datacolumn:
    :param outputdir:
    :param resume:
    :return:
    """

    # Pull the data from PEP
    # /app/pepcli --client-working-directory ~/pom/pepcli --oauth-token ~/peptoken.json --client-config-name ~/pom/pepcli/ClientConfig.json pull -c "Visit1.MRI.Anat" -c Visit1.MRI.Func -P /* -o ~/pom/pepdownload
    columns = ''
    if resume:
        command = f"{pepcli} --client-working-directory {pepcfg.parent} --oauth-token {peptoken} --client-config-name {pepcfg} pull -u -r -o {outputdir}"
    else:
        for column in datacolumns:
            columns = columns + f" -c {column}"
        command = f"{pepcli} --client-working-directory {pepcfg.parent} --oauth-token {peptoken} --client-config-name {pepcfg} pull {columns} -o {outputdir} -P \*"
    print(f">>> Pulling data from the PEP repository:\n{command}\n")
    proc = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    if proc.returncode != 0:
        print(f"WARNING: Job failed with error-code {proc.returncode}:\n{proc.stderr.decode('utf-8')}\n")


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
                                            '  pepdownload.py -t /home/mrphys/marzwi/mytoken.json\n'
                                            '  pepdownload.py -c Visit1.MRI.Func -o ~/mypomdata -r')
    # parser.add_argument('-p','--POMids',  help='Space separated list of POM-identifiers that can be uploaded. If empty all subjects in the raw-folder will be selected', nargs='+')
    parser.add_argument('-c','--columns',   default=['Visit1.MRI.Func', 'Visit1.MRI.Anat', 'Visit3.MRI.Func', 'Visit3.MRI.Anat'], help='The data columns that are to be uploaded to the PEP repository', nargs='+')
    parser.add_argument('-t','--token',     default=Path.home()/'peptoken.json', help='The token for logging on the PEP repository')
    parser.add_argument('-o','--outputdir', default='/project/3022026.01/pep/download', help='Directory to write files to')
    parser.add_argument('-r','--resume',    action='store_true', help='Add this flag to resume a download from the temporary (pending) directory')
    args = parser.parse_args()

    # Download the participant data in the PEP repository
    pullpep(args.token, args.columns, args.outputdir, args.resume)
