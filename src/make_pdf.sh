#!/bin/bash
#
# Generate PDF for QA

echo Running ${0}

wkdir="${out_dir}"/makepdf
mkdir "${wkdir}"
cd "${wkdir}"


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

exit 0




# Make an overlay ROI for coreg check
fslmaths \
	     "${rois_dwi_dir}"/FS_THALAMUS_L \
	-add "${rois_dwi_dir}"/FS_THALAMUS_R \
	-mul 2 \
	-add "${rois_dwi_dir}"/FS_CORTEX \
	coregmask

# Coreg verification - outline of FS cortex ROI on mean b=0 DWI
fsleyes render --outfile coreg.pdf \
	--size 1000 1000 \
	--displaySpace world \
	--hideCursor --layout grid \
	--xzoom 1000 --yzoom 1000 --zzoom 1000 \
	"${out_dir}"/b0_mean --displayRange 0 "99%" \
	coregmask --overlayType label --outline --outlineWidth 2 --lut harvard-oxford-cortical



# View some tracts
pdir="${out_dir}"/PROBTRACK_FS6
nopts="--interpolation linear --clipMode intersection --clipPlane 55 0 0 --clipPlane 50 -90 90 --blendFactor 0.5 --numSteps 500"
copts="--interpolation linear --displayRange 25 99.9% --blendFactor 0.5 --numSteps 500"
fsleyes render --outfile tracts.png \
	--size 600 600 --zoom 100 --bgColour 0 0 0 \
	--scene 3d --cameraRotation -70 -5 -5 \
	--hideCursor --hideLegend \
	"${pdir}"/FS_THALAMUS_L_to_FS_PFC_L/fdt_paths ${copts} --cmap red \
	"${out_dir}"/norm ${nopts}



#	FS_THALAMUS_L_to_FS_MOTOR_L
#	FS_THALAMUS_L_to_FS_SOMATO_L
#	FS_THALAMUS_L_to_FS_POSTPAR_L
#	FS_THALAMUS_L_to_FS_TEMP_L
#	FS_THALAMUS_L_to_FS_OCC_L
