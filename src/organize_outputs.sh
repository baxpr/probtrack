#!/bin/bash
#
# Organize outputs for XNAT

# We already have:
#    PDF
#    PDF_DETAILED
#    ROIS

cd "${out_dir}"

mkdir -p COREG_MAT
mv DWI_to_FS.mat FS_to_DWI.mat COREG_MAT

mkdir -p PROBTRACKS
mv PROBTRACK_* PROBTRACKS

mkdir -p B0_MEAN
mv makepdf/coreg_imgs/b0_mean.nii.gz B0_MEAN
mv makepdf/coreg_imgs/rb0_mean.nii.gz B0_MEAN
mv makepdf/coreg_imgs/wrb0_mean.nii.gz B0_MEAN

mkdir NORM
mv norm_to_DWI.nii.gz NORM

