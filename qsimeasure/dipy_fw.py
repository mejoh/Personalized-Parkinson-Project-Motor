#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
dipy_fw.py generates FW-images and related output using the
DIpy-implementation. Regular FA and MD images are provided
for reference.

"""


from pathlib import Path
import shutil
import pandas as pd
import dipy.reconst.fwdti as fwdti
import dipy.reconst.dti as dti
from dipy.io.image import load_nifti
from dipy.io.image import save_nifti
from dipy.io import read_bvals_bvecs
from dipy.core.gradients import gradient_table
from fsl.wrappers.dtifit import dtifit as fsldti
#from nipype.interfaces import fsl


def dipy_fw(qsiprepdir: str, subid: str):
    """

    :param qsiprepdir: Directory containing QSIprep output
    :param subid: Subject id of form POMU*
    :return:
    """

    print(f">>> Running DIPY-FW for sub-{subid}")

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
        outputdir = ses / 'metrics' / 'dipy_fw'

        # Input files
        preproc = list(dwidir.glob('*space-T1w_desc-preproc_dwi.nii.gz'))[0]
        mask = list(dwidir.glob('*space-T1w_desc-brain_mask.nii.gz'))[0]
        bval = list(dwidir.glob('*space-T1w_desc-preproc_dwi.bval'))[0]
        bvec = list(dwidir.glob('*space-T1w_desc-preproc_dwi.bvec'))[0]

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

        # DIpy-FW
        # Load data
        data_dwi, affine_dwi, img_dwi = load_nifti(str(preproc), return_img=True)
        data_mask, affine_mask, img_mask = load_nifti(str(mask), return_img=True)
        bvals, bvecs = read_bvals_bvecs(fbvals=str(bval), fbvecs=str(bvec))
        #bvals = bvals.round(-2)
        gtab = gradient_table(bvals, bvecs)
        # Model and fit
        fwdtimodel = fwdti.FreeWaterTensorModel(gtab, fit_method='WLS')
        fwdtifit = fwdtimodel.fit(data_dwi, mask=data_mask)
        # Extract metrics
        dtifw_FA = fwdtifit.fa
        dtifw_MD = fwdtifit.md
        dtifw_FW = fwdtifit.f
        dtifw_FA[dtifw_FW > 0.75] = 0
        dtifw_MD[dtifw_MD > 0.75] = 0
        # Save metrics
        save_nifti(str(outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-FAc.nii.gz')), dtifw_FA, affine_dwi)
        save_nifti(str(outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-MDc.nii.gz')), dtifw_MD, affine_dwi)
        save_nifti(str(outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-FW.nii.gz')), dtifw_FW, affine_dwi)

        # Fit alternative model without fw-compartment
        dtimodel = dti.TensorModel(gtab, fit_method='WLS')
        dtifit = dtimodel.fit(data_dwi, mask=data_mask)
        dti_FA = dtifit.fa
        dti_MD = dtifit.md
        dti_FA[dtifw_FW > 0.75] = 0
        dti_MD[dtifw_MD > 0.75] = 0
        save_nifti(str(outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-FA.nii.gz')), dti_FA, affine_dwi)
        save_nifti(str(outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-MD.nii.gz')), dti_MD, affine_dwi)

        # Compare against FSL output
        conffile = list(dwidir.glob('*_confounds.tsv'))[0]
        confs = pd.read_csv(conffile, sep='\t')
        confs.fillna(0, inplace=True)
        confs = confs.iloc[:, 0:7]
        confs.to_csv(outputdir / ('sub-' + subid + '_' + ses.name + '_fsl-confs.csv'), sep='\t',header=False)
        fsldti(preproc, str(outputdir / ('sub-' + subid + '_' + ses.name + '_fsl')), mask, bvec, bval, w=True)


def main():

    # Parse arguments
    import argparse

    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter,
                                     description=__doc__,
                                     epilog='For more information, see:\n'
                                            '  <https://dipy.org/>\n\n'
                                            'Examples:\n'
                                            '  /home/marjoh/scripts/qsimeasure/dipy_fw.py /project/3022026.01/pep/bids/derivatives/qsiprep sub-POMUB0140EA8042C4E37\n'
                                            '  ex 2\n\n'
                                            'Author:\n'
                                            '  Martin E. Johansson\n')
    parser.add_argument('qsiprepdir', help='BIDS-directory with subject-level data')
    parser.add_argument('participant_label', help='Subject ID')
    args = parser.parse_args()

    dipy_fw(qsiprepdir=args.qsiprepdir,
            subid=args.participant_label)


if __name__ == "__main__":
    main()
