#!/bin/bash

# FSL Setup
FSLDIR=/usr/local/fsl5
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

# Freesurfer
export FREESURFER_HOME=/usr/local/freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh


src_dir=/repo/thaltrack-whole/src
export PATH=${src_dir}:$PATH

# whole pipeline
pipeline.sh \
--fs_subject_dir ${src_dir}/testdir/assessors/freesurfer/SUBJECT \
--fs_nii_thalamus_niigz ${src_dir}/testdir/assessors/freesurfer/NII_THALAMUS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz \
--b0mean_niigz ${src_dir}/testdir/assessors/dwipre/B0_MEAN/b0_mean.nii.gz \
--bedpost_dir ${src_dir}/testdir/assessors/bedpost/BEDPOSTX \
--out_dir ${src_dir}/testdir/OUTPUTS

exit 0



# probtracks
export bedpost_dir=${src_dir}/testdir/assessors/bedpost/BEDPOSTX
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export out_dir=${src_dir}/testdir/OUTPUTS
export targets_dir=${src_dir}/targets
probtracks_FS6.sh

exit 0


# dwi rois
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export fs_subject_dir=${src_dir}/testdir/assessors/freesurfer/SUBJECT
export out_dir=${src_dir}/testdir/OUTPUTS
export fs_nii_thalamus_niigz=${src_dir}/testdir/assessors/freesurfer/NII_THALAMUS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz
make_DWI_rois.sh

exit 0



# coreg
export out_dir=${src_dir}/testdir/OUTPUTS
export fs_subject_dir=${src_dir}/testdir/assessors/freesurfer/SUBJECT
export b0mean_niigz=${src_dir}/testdir/assessors/dwipre/B0_MEAN/b0_mean.nii.gz
export rois_fs_dir=${src_dir}/testdir/OUTPUTS/ROIS_FS
coreg_t1_to_dwi.sh

exit 0

