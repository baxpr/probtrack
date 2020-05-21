#!/bin/bash
#
# Generate PDF for QA

echo Running ${0}

wkdir="${out_dir}"/makepdf
mkdir "${wkdir}"
cd "${wkdir}"

# Make an overlay ROI for coreg check
fslmaths \
	     "${rois_dwi_dir}"/FS_THALAMUS_L \
	-add "${rois_dwi_dir}"/FS_THALAMUS_R \
	-mul 2 \
	-add "${rois_dwi_dir}"/FS_CORTEX \
	coregmask

# Coreg verification - outline of FS cortex ROI on mean b=0 DWI
fsleyes render --outfile coreg.pdf \
	--hideCursor --layout grid \
	--xzoom 1000 --yzoom 1000 --zzoom 1000 \
	--size 1000 1000 \
	"${out_dir}"/b0_mean --displayRange 0 "99%" \
	coregmask --overlayType label --outline --outlineWidth 2 --lut harvard-oxford-cortical



# Original stuff

# View some tracts

