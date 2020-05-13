#!/bin/bash

# Run FSL setup if needed
FSLDIR=/usr/local/fsl5
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

# Run Freesurfer setup if needed
export FREESURFER_HOME=/usr/local/freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# We also need to be able to find the spider code.
# This should point to the src dir of the checked-out git repo
src_dir=/repo/thaltrack-whole/src
export PATH=${src_dir}:$PATH

# Set paths to the test input data. Must be fully qualified (no ./ or partial paths)
fs_subject_dir=/path/to/freesurfer/SUBJECTS
fs_nii_thalamus_niigz=/path/to/freesurfer/NII_THALAMUS/file.nii.gz
b0mean_niigz=/path/to/dwipre/b0_mean.nii.gz
bedpost_dir=/path/to/bedpost/BEDPOSTX
out_dir=/path/to/where/you/want/outputs


# Run whole pipeline
pipeline.sh \
--fs_subject_dir ${fs_subject_dir} \
--fs_nii_thalamus_niigz ${fs_nii_thalamus_niigz} \
--b0mean_niigz ${b0mean_niigz} \
--bedpost_dir ${bedpost_dir} \
--out_dir ${out_dir} \
--src_dir ${src_dir}
