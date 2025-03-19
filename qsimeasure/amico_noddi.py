#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
amico_noddi.py applies the AMICO-implementation of the NODDI method to
preprocessed DWI data

"""


from pathlib import Path
import shutil
import amico
amico.setup()

def amico_noddi(qsiprepdir: str, subid: str):

    """
    Applies the AMICO-implementation of the NODDI method, which involves
    fitting a three-compartment tissue model to DWI data.

    Output:
    OD = Orientation dispersion index
    ICVF = Intra-cellular volume fraction
    ISOVF = Isotropic volume fraction (CSF/Free water)

    :param qsiprepdir: Directory containing QSIprep output
    :param subid: Subject id of form POMU*
    :return:
    """

    print(f">>> Running AMICO-NODDI for sub-{subid}")

    # Set up
    qsiprepdir = Path(qsiprepdir)
    sub_dir = qsiprepdir / f'sub-{subid}'
    sessions = list(sub_dir.glob('ses-*'))

    # Loop over sessions
    for n, ses in enumerate(sessions, 1):

        print(f">>> Processing session {n}/{len(sessions)}, {ses.name}")

        # Paths
        dwidir = ses / 'dwi'
        if dwidir.is_dir():
            print(F">>> DWI directory located, proceeding...")
        else:
            print(F">>> DWI directory missing!")
            continue
        outputdir = ses / 'metrics' / 'amico_noddi'

        # Input files
        preproc = list(dwidir.glob('*space-T1w_desc-preproc_dwi.nii.gz'))[0]
        mask = list(dwidir.glob('*space-T1w_desc-brain_mask.nii.gz'))[0]
        bval = list(dwidir.glob('*space-T1w_desc-preproc_dwi.bval'))[0]
        bvec = list(dwidir.glob('*space-T1w_desc-preproc_dwi.bvec'))[0]
        scheme = outputdir / 'NODDI_protocol.scheme'

        # Check files
        if preproc.is_file() & mask.is_file() & bval.is_file() & bvec.is_file():
            print(f">>> Input files exist, proceeding...")
        else:
            print(f">>> Input files missing!")
            continue

        # Start clean
        if outputdir.is_dir():
            shutil.rmtree(outputdir, ignore_errors=True)
        outputdir.mkdir(parents=True, exist_ok=True)

        # AMICO-NODDI
        # Set up amico
        ae = amico.Evaluation(study_path=str(qsiprepdir), subject=f"sub-{subid}", output_path=str(outputdir))
        # Bval/Bvec scheme
        amico.util.fsl2scheme(bvalsFilename=str(bval), bvecsFilename=str(bvec), schemeFilename=str(scheme))
        # Load data
        ae.load_data(dwi_filename=str(preproc), scheme_filename=str(scheme), mask_filename=str(mask), b0_thr=100)
        # Set model
        ae.set_model('NODDI')
        # Generate kernels (only needs to be done once)
        ae.generate_kernels(regenerate=False)
        # Resample kernels to subject
        ae.load_kernels()
        # Fit model
        ae.fit()
        # Write output
        ae.save_results()


def main():

    # Parse arguments
    import argparse

    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter,
                                     description=__doc__,
                                     epilog='For more information, see:\n'
                                            '  <https://github.com/daducci/AMICO>\n\n'
                                            'Examples:\n'
                                            '  /home/marjoh/scripts/qsimeasure/amico_noddi.py /project/3022026.01/pep/bids/derivatives/qsiprep sub-POMUB0140EA8042C4E37\n'
                                            '  ex 2\n\n'
                                            'Author:\n'
                                            '  Martin E. Johansson\n')
    parser.add_argument('qsiprepdir', help='BIDS-directory with subject-level data')
    parser.add_argument('participant_label', help='Subject ID')
    args = parser.parse_args()

    amico_noddi(qsiprepdir=args.qsiprepdir,
                subid=args.participant_label)


if __name__ == "__main__":
    main()
