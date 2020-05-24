#!/bin/bash
#
# Generate PDF for QA

echo Running ${0}
thedate=$(date)

wkdir="${out_dir}"/makepdf
mkdir -p "${wkdir}"
cd "${wkdir}"


# Make an overlay ROI for coreg check (seeds and full cortex)
fslmaths \
	"${rois_dwi_dir}"/FS_THALAMUS_L -add "${rois_dwi_dir}"/FS_THALAMUS_R \
	-mul 2 \
	-add "${rois_dwi_dir}"/FS_PFC_L -add "${rois_dwi_dir}"/FS_PFC_R \
	-add "${rois_dwi_dir}"/FS_MOTOR_L -add "${rois_dwi_dir}"/FS_MOTOR_R \
	-add "${rois_dwi_dir}"/FS_SOMATO_L -add "${rois_dwi_dir}"/FS_SOMATO_R \
	-add "${rois_dwi_dir}"/FS_POSTPAR_L -add "${rois_dwi_dir}"/FS_POSTPAR_R \
	-add "${rois_dwi_dir}"/FS_OCC_L -add "${rois_dwi_dir}"/FS_OCC_R \
	-add "${rois_dwi_dir}"/FS_TEMP_L -add "${rois_dwi_dir}"/FS_TEMP_R \
	-add "${rois_dwi_dir}"/FS_INSULA_L -add "${rois_dwi_dir}"/FS_INSULA_R \
	coregmask

# Position centered on L thalamus
vx=$(get_com.py x "${rois_dwi_dir}"/FS_THALAMUS_L.nii.gz)
vy=$(get_com.py y "${rois_dwi_dir}"/FS_THALAMUS_L.nii.gz)
vz=$(get_com.py z "${rois_dwi_dir}"/FS_THALAMUS_L.nii.gz)

# Coreg verification - outline of FS cortex ROI on mean b=0 DWI
fsleyes render --outfile coreg.png \
	--size 1000 1000 \
	--worldLoc ${vx} ${vy} ${vz} \
	--displaySpace world \
	--hideCursor --layout grid \
	--xzoom 1000 --yzoom 1000 --zzoom 1000 \
	"${out_dir}"/b0_mean --displayRange 0 "99%" \
	coregmask --overlayType label --outline --outlineWidth 3 --lut harvard-oxford-subcortical

convert \
	-size 2600x3365 xc:white \
	-gravity center \( "coreg.png" -resize 2400x \) -geometry +0+0 -composite \
	-gravity North -pointsize 48 -annotate +0+150 "Coregistration of FS segmentation (color) and mean b=0 DWI" \
	-gravity SouthEast -pointsize 48 -annotate +50+50 "${thedate}" \
	-gravity NorthWest -pointsize 48 -annotate +50+50 "${project} ${subject} ${session}" \
	"coreg.png"


# Finalize PDF
convert \
	coreg.png \
	tracts_*.png \
	thaltrack_whole.pdf
	


