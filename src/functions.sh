#!/bin/bash
#
# Support functions


# Join multiple ROIs into a single binary mask
# Usage:
#    combine_rois <source_roi_image> <roi_name> "<values_to_include>"
# Example:
#    combine_rois aparc.DKTatlas+aseg FS_MOTOR_L "1003 1017 1024"
function combine_rois () {
	local in_niigz="${1}"
	local out_niigz="${2}"
	local vals="${3}"
	
	addstr=""
	for v in $vals ; do
		fslmaths "${in_niigz}" -thr "${v}" -uthr "${v}" -bin tmp_"${v}"
		addstr="${addstr} -add tmp_${v}"
	done
	fslmaths "${in_niigz}" -thr 0 -uthr 0 ${addstr} -bin "${out_niigz}"
	rm -f tmp_*.nii.gz
}


# Probtrack function for single ROI
function track () {
	local bedpost_dir="${1}"
	local roi_dir="${2}"
	local track_dir="${3}"
	local trackopts="${4}"
	local roi_from="${5}"
	local roi_to="${6}"

	echo trackopts "${trackopts}"
	echo bedpost_dir $bedpost_dir
	echo roi_dir $roi_dir
	echo track_dir $track_dir
	echo roi_from $roi_from
	echo roi_to $roi_to

	probtrackx2 \
		-s "${bedpost_dir}"/merged \
		-m "${bedpost_dir}"/nodif_brain_mask \
		-x "${roi_dir}"/"${roi_from}" \
		--targetmasks="${roi_dir}"/"${roi_to}" \
		--stop="${roi_dir}"/"${roi_to}" \
		--avoid="${roi_dir}"/"${roi_to}"_AVOID \
		--dir="${track_dir}"/"${roi_from}"_to_"${roi_to}" \
		${trackopts}

}

