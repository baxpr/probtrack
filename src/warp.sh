#!/bin/bash
#
# Transform some outputs from native to MNI space. First step, reverse of the
# FS-to-DWI coreg. Second step, SPM12 warp.

towarp_dir="${1}"

# Get the deformation image
cp "${fwddef_niigz}" "${out_dir}"/y_fwddef.nii.gz
gunzip -f "${out_dir}"/y_fwddef.nii.gz


# Affine to FS space with DWI_to_FS.mat, then SPM12 warp
cd "${towarp_dir}"
flirtopts="-applyxfm -init ${out_dir}/DWI_to_FS.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/norm.nii.gz"
for f in *.nii.gz ; do
	flirt ${flirtopts} -in "${f}" -out "r${f}"
	gunzip "r${f}"
	"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function warp "${out_dir}"/y_fwddef.nii "${towarp_dir}/r$(basename ${f} .gz)"
	gzip "r$(basename ${f} .gz)" "wr$(basename ${f} .gz)"
done
