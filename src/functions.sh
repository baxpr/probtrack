#!/bin/bash
#
# Support functions


# Split a single ROI mask from a multi-ROI image
function split_roi () {
	local in_niigz="${1}"
	local val="${2}"
	
	out_niigz=$( basename "${in_niigz}" .nii.gz )_"${val}"
	fslmaths "${in_niigz}" -thr "${val}" -uthr "${val}" -bin "${out_niigz}"
}


# Join multiple ROI masks into a single one
function join_rois () {
	local in_niigz="${1}"
	local out_niigz="${2}"
	local vals="${3}"
	
	addstr=""
	for v in $vals ; do
		fstr=$( basename ${in_niigz} .nii.gz)_"${v}"
		addstr="${addstr} -add ${fstr}"
	done
	fslmaths "${in_niigz}" -thr 0 -uthr 0 ${addstr} -bin "${out_niigz}"
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

