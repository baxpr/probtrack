#!/bin/bash
#
# Generate PDF for QA

echo Running ${0}

wkdir="${out_dir}"/makepdf
mkdir "${wkdir}"

# Coreg verification - outline of cortex ROI on coregistered T1
fsleyes render --outfile "${wkdir}"/coreg.pdf \
	--hideCursor \
	--xzoom 1000 --yzoom 1000 --zzoom 1000 \
	--size 1200 600 \
	"${out_dir}"/norm_to_DWI \
	"${rois_dwi_dir}"/FS_CORTEX \
		--overlayType label --outline --outlineWidth 2 --lut harvard-oxford-subcortical



# Original stuff

# View some tracts

