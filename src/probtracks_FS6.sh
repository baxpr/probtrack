#!/bin/bash
#
### TRACTOGRAPHY - FREESURFER THALAMUS TO FREESURFER CORTICAL MASKS

echo Running ${0}


# Probtrack function for single ROI
function track () {
	trackopts="${1}"
	bedpost_dir="${2}"
	roi_dir="${3}"
	track_dir="${4}"
	roi_from="${5}"
	roi_to="${6}"

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


# Options for all tracking
trackopts="-l --onewaycondition --verbose=1 --forcedir --modeuler --pd --os2t --s2tastext --opd --ompl"


# Thalamus to individual cortical regions
trackcmd="track ${trackopts} ${bedpost_dir} ${rois_dwi_dir} ${out_dir}/OUTPUT_FS6"
for region in \
  FS_PFC \
  FS_MOTOR \
  FS_SOMATO \
  FS_POSTPAR \
  FS_OCC \
  FS_TEMP \
; do
	${trackcmd} FS_THALAMUS_L ${region}_L
	${trackcmd} FS_THALAMUS_R ${region}_R
done


# L thalamus to L multiple targets
cd "${rois_dwi_dir}"
probtrackx2 \
	-s "${bedpost_dir}"/merged \
	-m "${bedpost_dir}"/nodif_brain_mask \
	-x FS_THALAMUS_L \
	--targetmasks="${targets_dir}"/TARGETS_FS6_L.txt \
	--stop=FS_LHCORTEX_STOP \
	--avoid=FS_RH_AVOID \
	--dir="${out_dir}"/OUTPUTS_FS6/FS_THALAMUS_L_to_TARGETS_L \
	${trackopts}
cp "${targets_dir}"/TARGETS_FS6_L.txt "${out_dir}"/OUTPUTS_FS6/FS_THALAMUS_L_to_TARGETS_L

# R thalamus to R multiple targets
cd "${rois_dwi_dir}"
probtrackx2 \
	-s "${bedpost_dir}"/merged \
	-m "${bedpost_dir}"/nodif_brain_mask \
	-x FS_THALAMUS_R \
	--targetmasks="${targets_dir}"/TARGETS_FS6_R.txt \
	--stop=FS_RHCORTEX_STOP \
	--avoid=FS_LH_AVOID \
	--dir="${out_dir}"/OUTPUTS_FS6/FS_THALAMUS_R_to_TARGETS_R \
	${trackopts}
cp "${targets_dir}"/TARGETS_FS6_R.txt "${out_dir}"/OUTPUTS_FS6/FS_THALAMUS_R_to_TARGETS_R

