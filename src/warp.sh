#!/bin/bash
#
# Transform some outputs from native to MNI space. First step, reverse of the
# FS-to-DWI coreg. Second step, SPM12 warp.

towarp_dir="${out_dir}"/PROBTRACK_FS6/FS_THALAMUS_L_to_FS_PFC_L

# Affine to FS space with DWI_to_FS.mat
cd "${towarp_dir}"
flirtopts="-applyxfm -init ${out_dir}/DWI_to_FS.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/norm.nii.gz"
for f in *.nii.gz ; do
	flirt ${flirtopts} -in "${f}" -out "r${f}"
done

# FS to MNI via SPM12 deformation
