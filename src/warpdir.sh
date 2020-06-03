#!/bin/bash
#
# Transform some outputs from native FS to MNI space.

towarp_dir="${1}"
echo Warping in "${towarp_dir}"
cd "${towarp_dir}"

# SPM12 warp for entire directory (all *.nii.gz files)
"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function warpdir "${towarp_dir}" "${out_dir}"
