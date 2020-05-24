#!/bin/bash
#
# Transform some outputs from native to MNI space. First step, reverse of the
# FS-to-DWI coreg. Second step, SPM12 warp.

towarp_dir="${1}"
echo Warping in "${towarp_dir}"

# Affine to FS space with DWI_to_FS.mat (all *.nii.gz files)
cd "${towarp_dir}"
flirtopts="-applyxfm -init ${out_dir}/DWI_to_FS.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/norm.nii.gz"
for f in *.nii.gz ; do
	flirt ${flirtopts} -in "${f}" -out "r${f}"
done

# SPM12 warp for entire directory (all r*.nii.gz files)
"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function warpdir "${towarp_dir}" "${out_dir}"
