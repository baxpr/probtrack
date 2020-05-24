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






exit 0
# Coronal slices of tracts (now in probtracks.sh)
pdir="${out_dir}"/PROBTRACK_FS6
vx=$(get_com.py x "${rois_dwi_dir}"/FS_CORTEX.nii.gz)
vy=$(get_com.py y "${rois_dwi_dir}"/FS_CORTEX.nii.gz)
vz=$(get_com.py z "${rois_dwi_dir}"/FS_CORTEX.nii.gz)
tgts="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"
deltas="-75 -65 -55 -45 -35 -25 -15 -05 +05 +15 +25 +35 +45 +55 +65 +75"
for tgt in ${tgts} ; do

	mstr=""
	for delta in ${deltas} ; do

		of=tracts_${tgt}_${delta}.png

		fsleyes render --outfile ${of} \
			--displaySpace world \
			--size 600 600 --hideCursor --hideLabels --hidex --hidez --yzoom 1200 \
			--worldLoc ${vx} $((${vy}+${delta})) ${vz} \
			"${out_dir}"/norm_to_DWI --interpolation none \
			"${rois_dwi_dir}"/${tgt}_L --cmap blue \
			"${rois_dwi_dir}"/${tgt}_R --cmap blue \
			"${pdir}"/FS_THALAMUS_L_to_${tgt}_L/fdt_paths_75pct --cmap red-yellow \
			"${pdir}"/FS_THALAMUS_R_to_${tgt}_R/fdt_paths_75pct --cmap red-yellow

		mstr="${mstr} ${of}"

	done
	
	montage -mode concatenate ${mstr} -tile 4x4 -quality 100 -background black -gravity center \
		-resize 600x tracts_${tgt}.png
	rm ${mstr}
	convert \
	  -size 2600x3365 xc:white \
	  -gravity center \( tracts_${tgt}.png -resize 2400x \) -geometry +0+0 -composite \
	  -gravity North -pointsize 48 -annotate +0+150 "FS_THALAMUS to ${tgt}" \
	  -gravity SouthEast -pointsize 48 -annotate +50+50 "${thedate}" \
	  -gravity NorthWest -pointsize 48 -annotate +50+50 "${project} ${subject} ${session}" \
	  tracts_${tgt}.png

done


exit 0


### Efforts below have been a failure
exit 0




# Slices of tracts with lightbox - impossible to get right
pdir="${out_dir}"/PROBTRACK_FS6
#for tgt in FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP ; do
for tgt in FS_PFC ; do
	fsleyes render --outfile tracts_${tgt}.png \
		--scene lightbox --displaySpace world \
		--size 800 1200 --hideCursor \
		--zaxis Y --sliceSpacing 11 --zrange -75 60 --ncols 3 --nrows 4 \
		"${out_dir}"/norm_to_DWI --interpolation none \
		"${rois_dwi_dir}"/${tgt}_L --cmap blue \
		"${rois_dwi_dir}"/${tgt}_R --cmap blue \
		"${pdir}"/FS_THALAMUS_L_to_${tgt}_L/fdt_paths_75pct --cmap red-yellow \
		"${pdir}"/FS_THALAMUS_R_to_${tgt}_R/fdt_paths_75pct --cmap red-yellow
done
	

# Test tracts, copied directly from fsleyes
pdir="${out_dir}"/PROBTRACK_FS6
fsleyes render --outfile tracts.png \
--scene 3d --worldLoc 2.6482467651367188 2.8584442138671875 0.39475250244140625 --displaySpace world \
--cameraRotation -70.17 -5.93 -7.06 --zoom 150.1635177527004 --hideLegend \
--lightPos 258.6481399536133 258.85833740234375 0.39475250244140625 --offset 0.0 0.0 --hideCursor --bgColour 0.0 0.0 0.0 \
--fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --performance 3 \
"${out_dir}"/norm --name "norm" --overlayType volume --alpha 100.0 --brightness 50.0 --contrast 50.0 --cmap greyscale \
--negativeCmap greyscale --clipPlane 55.000 0.000 0.000 --clipPlane 50.000 -90.000 90.000 --displayRange 0.0 137.0 \
--clippingRange 0.0 138.37 --cmapResolution 256 --interpolation none --numSteps 500 --blendFactor 0.5 --resolution 100 \
--numInnerSteps 10 --clipMode intersection --volume 0 \
"${pdir}"/FS_THALAMUS_L_to_FS_PFC_L/fdt_paths --name "fdt_paths" --overlayType volume --alpha 100.0 \
--brightness 53.746617169899544 --contrast 57.49323433979908 --cmap red --negativeCmap greyscale --unlinkLowRanges \
--displayRange 0.0 30000.0 --clippingRange 5000.0 35641.385 --cmapResolution 256 --interpolation linear --numSteps 500 \
--blendFactor 0.5 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0


pdir="${out_dir}"/PROBTRACK_FS6
nopts="--interpolation linear --clipMode intersection --clipPlane 55 0 0 --clipPlane 50 -90 90 --blendFactor 0.5 --numSteps 500"
copts="--interpolation linear --unlinkLowRanges --displayRange 0 99% --clippingRange 25 99% --blendFactor 0.5 --numSteps 500"
fsleyes render --outfile tracts.png \
	--size 600 600 --zoom 100 --bgColour 0 0 0 \
	--scene 3d --cameraRotation -70 -5 -5 \
	--hideCursor --hideLegend \
	"${pdir}"/FS_THALAMUS_L_to_FS_PFC_L/fdt_paths ${copts} --cmap red \
	"${pdir}"/FS_THALAMUS_L_to_FS_POSTPAR_L/fdt_paths ${copts} --cmap blue \

#	"${pdir}"/FS_THALAMUS_L_to_FS_MOTOR_L/fdt_paths ${copts} --cmap green \
#	"${pdir}"/FS_THALAMUS_L_to_FS_SOMATO_L/fdt_paths ${copts} --cmap pink \
#	"${pdir}"/FS_THALAMUS_L_to_FS_TEMP_L/fdt_paths ${copts} --cmap copper \
#	"${pdir}"/FS_THALAMUS_L_to_FS_OCC_L/fdt_paths ${copts} --cmap yellow
