#!/bin/bash
#
# Coregister T1 (nu.mgz) to dwi

echo Running ${0}

cd "${out_dir}"

# Get input files
cp "${fs_subject_dir}"/mri/{norm,nu}.mgz .
mri_convert nu.mgz nu.nii.gz
mri_convert norm.mgz norm.nii.gz
cp "${b0mean_niigz}" ./b0_mean.nii.gz

# Register b=0 to FS T1 using FS white matter mask
# epi_reg bug means we must use the b0_mean_to_FS_fast_wmseg filename
cp "${rois_fs_dir}"/FS_WM_LR.nii.gz b0_mean_to_FS_fast_wmseg.nii.gz
epi_reg \
	--epi=b0_mean \
	--t1=nu \
	--t1brain=norm \
	--out=b0_mean_to_FS \
	--wmseg=b0_mean_to_FS_fast_wmseg
mv b0_mean_to_FS.mat DWI_to_FS.mat
convert_xfm -omat FS_to_DWI.mat -inverse DWI_to_FS.mat
