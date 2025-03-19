#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
qsimeasure.py is a bids-compatible utility that uses various
methods to derive measurements from DWI data that has been
pre-processed using QSIprep.

*The structure of this script is based on fmriprep_sub.py.
"""


from pathlib import Path
import shutil
import subprocess


def qsimeasure(qsiprepdir: str, dtimethod='dipy_fw', subject_label=(), force=False, dryrun=False, skip=True, qargstr=''):

    # Defaults
    qsiprepdir = Path(qsiprepdir)

    scriptdir = Path.home() / 'scripts' / 'qsimeasure'
    if dtimethod == 'amico_noddi':
        run_script = scriptdir / 'amico_noddi.py'
    elif dtimethod == 'dipy_fw':
        run_script = scriptdir / 'dipy_fw.py'
    elif dtimethod == 'dipy_b0':
        run_script = scriptdir / 'dipy_b0.py'
    else:
        print(f">>> Invalid dtimethod: {dtimethod}")
        return

    print(f">>> QSIprep directory: {qsiprepdir}")

    # Map the subject directories
    if not subject_label:
        sub_dirs = list(qsiprepdir.glob('sub-*[!.html]'))
    else:
        sub_dirs = [qsiprepdir / ('sub-' + label.replace('sub-', '')) for label in subject_label]

    # Loop over subjects
    for n, sub_dir in enumerate(sub_dirs, 1):

        sub_id = [part for part in sub_dir.parts if part.startswith('sub-')][0]

        # Check existance of full qsiprep output
        report = qsiprepdir/(sub_id + '.html')
        if not report.is_file():
            print(f">>> QSIprep not completed (no .html file): {sub_id}")
            continue

        # Check existance of previous output, potentially overwrite
        sessions = list(sub_dir.glob('ses-*'))
        nses = len(sessions)
        dircount = 0
        for i in sessions:
            checkdir = (i / 'metrics' / dtimethod)
            if checkdir.is_dir():
                dircount = dircount + 1
        if dircount == nses:
            print(f">>> Already processed: {sub_id}")
            if not bool(force):
                continue
            else:
                print(f">>> Overwriting previous output: {sub_id}")

        print(f">>> Processing: {sub_id}")

        command = """qsub -l nodes=1:ppn=1,walltime=01:00:00,mem=10gb -N qsim_{sub_id} {qargs} <<EOF
        echo QSIMEASURE.PY
        cd {pwd}
        {sleep}
        {run_script} {qsiprepdir} {sub_id}\nEOF"""\
        .format(pwd = Path.cwd(),
                sleep = 'sleep 1m' if n > 1 else '',
                run_script = str(run_script),
                qsiprepdir = qsiprepdir,
                sub_id = sub_id[4:],
                qargs = qargstr)

        running = subprocess.run('if [ ! -z "$(qselect -s RQH)" ]; then qstat -f $(qselect -s RQH) | grep Job_Name | grep qsim_; fi',stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        if skip and f"qsim_{sub_id}" in running.stdout.decode():
            print(f">>> Skipping already running / scheduled job ({n}/{len(sub_dirs)}): dtigen_{sub_id}")
        else:
            print(f">>> Submitting job ({n}/{len(sub_dirs)}):\n{command}")
            if not dryrun:
                process = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
                if process.returncode != 0:
                    print(f"ERROR {process.returncode}: Job submission failed\n{process.stderr.decode()}\n{process.stdout.decode()}")


def main():

    # Parse arguments
    import argparse

    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter,
                                     description=__doc__,
                                     epilog='For more information, see:\n'
                                            '  <dipy_fw.py>\n'
                                            '  <amico_noddi.py>\n'
                                            '  <dipy_b0.py>\n\n'
                                            'Examples:\n'
                                            '  /home/marjoh/scripts/qsimeasure/qsimeasure.py /project/3022026.01/pep/bids/derivatives/qsiprep -m dipy_fw -p sub-POMUB0140EA8042C4E37 -d\n'
                                            '  ex 2\n\n'
                                            'Author:\n'
                                            '  Martin E. Johansson\n')
    parser.add_argument('qsiprepdir',                       help='BIDS-directory with subject-level data')
    parser.add_argument('-p', '--participant_label',        help='Space seperated list of sub-# identifiers to be processed (the sub- prefix can be removed). Otherwise all sub-folders in the bidsfolder will be processed.', nargs='+')
    parser.add_argument('-m', '--dti-method',               help='Method used to generate output. Choose from: dipy_fw, amico_noddi, dipy_b0 (default: dipy_fw).')
    parser.add_argument('-f', '--force',                    help='Overwrite pre-existing output.', action='store_true')
    parser.add_argument('-d', '--dryrun',                   help='Print qsub commands without submitting them.', action='store_true')
    parser.add_argument('-i', '--ignore',                   help='Submit jobs when there are already jobs with the same name in queue or running.', action='store_false')
    parser.add_argument('-q', '--qargs',                    help='Arguments to qsub', type=str, default='')
    args = parser.parse_args()

    qsimeasure(qsiprepdir=args.qsiprepdir,
         subject_label=args.participant_label,
         dtimethod=args.dti_method,
         dryrun=args.dryrun,
         force=args.force,
         skip=args.ignore,
         qargstr=args.qargs)


if __name__ == "__main__":
    main()

