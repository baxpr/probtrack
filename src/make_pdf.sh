#!/bin/bash
#
# Generate PDF for QA

echo Running ${0}

wkdir="${out_dir}"/makepdf
mkdir "${wkdir}"

# Coreg verification - outline of FS cortex ROI on mean b=0 DWI
fsleyes render --outfile "${wkdir}"/coreg.pdf \
	--hideCursor \
	--xzoom 1000 --yzoom 1000 --zzoom 1000 \
	--size 1200 500 \
	"${out_dir}"/b0_mean \
	"${rois_dwi_dir}"/FS_CORTEX \
		--overlayType label --outline --outlineWidth 2 --lut harvard-oxford-subcortical



# Original stuff

# View some tracts

