#!/bin/bash
#
# Support functions

# Sometimes in a loop we need R when we have L and vice versa
function swapLR () {
 	case $1 in
		L)
			echo R ;;
		R)
			echo L ;;
		*)
			echo "Unknown LR in swapLR"
			exit 1
			;;
		esac
}


# Join multiple ROIs into a single binary mask using fslmaths
# Usage:
#    combine_rois <source_roi_image> <roi_name> "<values_to_include>"
# Example:
#    combine_rois aparc.DKTatlas+aseg FS_MOTOR_L "1003 1017 1024"
function combine_rois () {
	local in_niigz="${1}"
	local out_niigz="${2}"
	local vals="${3}"
	
	local addstr=""
	for v in $vals ; do
		fslmaths "${in_niigz}" -thr "${v}" -uthr "${v}" -bin tmp_"${v}"
		addstr="${addstr} -add tmp_${v}"
	done
	fslmaths "${in_niigz}" -thr 0 -uthr 0 ${addstr} -bin "${out_niigz}"
	rm -f tmp_*.nii.gz
}


# Same, but don't rely on exact integer values
function combine_rois_approx () {
	local in_niigz="${1}"
	local out_niigz="${2}"
	local vals="${3}"
		
	local addstr=""
	for v in $vals ; do

		# Get min and max thresholds from vals
		minv=$(echo "$v - 0.5" | bc -l)
		maxv=$(echo "$v + 0.5" | bc -l)
		
		# Apply thresholds
		fslmaths "${in_niigz}" -thr "${minv}" -uthr "${maxv}" -bin tmp_"${v}"
		addstr="${addstr} -add tmp_${v}"

	done
	fslmaths "${in_niigz}" -thr 0 -uthr 0 ${addstr} -bin "${out_niigz}"
	rm -f tmp_*.nii.gz
}


