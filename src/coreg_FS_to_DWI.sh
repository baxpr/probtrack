#!/bin/bash
#
# Coregister T1 (nu.mgz) to dwi

echo Running ${0}

source functions.sh
cd "${out_dir}"

# Get input files from freesurfer and dwipre
for mgz in norm nu aparc.DKTatlas+aseg ; do
	mri_convert "${fs_subject_dir}"/mri/${mgz}.mgz ${mgz}.nii.gz
done
cp "${b0mean_niigz}" b0_mean.nii.gz


# Make WM image to initialize epi_reg. epi_reg bug means we must use 
# the b0_mean_to_FS_fast_wmseg filename
combine_rois aparc.DKTatlas+aseg  b0_mean_to_FS_fast_wmseg  "2 41"


# Register b=0 to FS T1 using FS white matter mask
epi_reg \
	--epi=b0_mean \
	--t1=nu \
	--t1brain=norm \
	--out=b0_mean_to_FS \
	--wmseg=b0_mean_to_FS_fast_wmseg
mv b0_mean_to_FS.mat DWI_to_FS.mat
convert_xfm -omat FS_to_DWI.mat -inverse DWI_to_FS.mat


# Resample norm to DWI space
flirtopts="-applyxfm -init ${out_dir}/FS_to_DWI.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/b0_mean.nii.gz"
flirt ${flirtopts} \
	-in norm \
	-out norm_to_DWI
