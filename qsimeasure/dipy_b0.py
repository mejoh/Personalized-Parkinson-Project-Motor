#!/usr/bin/env python3
"""
dipy_b0.py generates mean B0-image from preprocessed DWI-data.
"""


from pathlib import Path
import shutil
from dipy.io.image import load_nifti
from dipy.io.image import save_nifti
from dipy.io import read_bvals_bvecs
from dipy.core.gradients import gradient_table
from dipy.segment.mask import applymask
import numpy as np


def dipy_b0(qsiprepdir, subid, b0thr=100):

    """
    Extract volumes below the B0 threshold from preprocessed DWI-data
    and average them to create a single B0-image.

    :param qsiprepdir: Directory containing QSIprep output
    :param subid: Subject id of form POMU*
    :param b0thr: Threshold for B0-values
    :return:
    """

    print(f">>> Running dipy_b0 for sub-{subid}")

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
        outputdir = ses / 'metrics' / 'dipy_b0'

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

        # Load data
        data_dwi, affine_dwi, img_dwi = load_nifti(str(preproc), return_img=True)
        data_mask, affine_mask, img_mask = load_nifti(str(mask), return_img=True)
        bvals, bvecs = read_bvals_bvecs(fbvals=str(bval), fbvecs=str(bvec))
        gtab = gradient_table(bvals, bvecs, b0_threshold=b0thr)

        # Mask data
        data_dwi_mas = applymask(data_dwi, data_mask)

        # Extract b0 images
        #outputname1 = outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-b0.nii.gz')
        outputname2 = outputdir / ('sub-' + subid + '_' + ses.name + '_dipy-b0mean.nii.gz')
        data_dwi_b0 = data_dwi_mas[:, :, :, gtab.b0s_mask]
        #save_nifti(str(outputname1), data_dwi_b0, affine_dwi)
        data_dwi_b0_Tmean = np.average(data_dwi_b0, keepdims=True, axis=3)
        save_nifti(str(outputname2), data_dwi_b0_Tmean, affine_dwi)


def main():

    import argparse

    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter,
                                     description=__doc__,
                                     epilog='Examples:\n'
                                            '  dipy_b0.py qsiprepdir subid\n\n'
                                            'Author:\n'
                                            '  Martin E. Johansson\n\n')
    parser.add_argument('qsiprepdir', help='Directory containing QSIprep derivatives')
    parser.add_argument('subject_label', help='Subject id')
    parser.add_argument('-b', '--b0_threshold', help='Volumes with b-values below this threhsold will be used to construct the final b0-image', default=100)
    args = parser.parse_args()

    dipy_b0(qsiprepdir=args.qsiprepdir,
            subid=args.subject_label,
            b0thr=args.b0_threshold)


if __name__ == '__main__':
    main()
