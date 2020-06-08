#!/bin/bash
#
# Organize outputs for XNAT

# We already have:
#    PDF
#    ROIS_FS
#    PROBTRACKS

cd "${out_dir}"

mkdir -p COREG_MAT
mv DWI_to_FS.mat FS_to_DWI.mat COREG_MAT

mkdir -p B0_MEAN_TO_FS
mv makepdf/coreg_imgs/b0_mean_to_FS.nii.gz B0_MEAN_TO_FS
mv makepdf/coreg_imgs/wb0_mean_to_FS.nii.gz B0_MEAN_TO_FS
