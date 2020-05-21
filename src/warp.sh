#!/bin/bash
#
# Transform some outputs from native to MNI space. First step, reverse of the
# FS-to-DWI coreg. Second step, SPM12 warp.

towarp_dir="${out_dir}"/PROBTRACK_FS6/FS_THALAMUS_L_to_FS_PFC_L

# Affine to FS space with DWI_to_FS.mat, then SPM12 warp
cd "${towarp_dir}"
flirtopts="-applyxfm -init ${out_dir}/DWI_to_FS.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/norm.nii.gz"
for f in *.nii.gz ; do
	flirt ${flirtopts} -in "${f}" -out "r${f}"
	"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function warp "${out_dir}"/iy_invdef.nii "${towarp_dir}/${f}"
done
