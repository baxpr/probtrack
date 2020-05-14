#!/bin/bash
#
# Probtracks for specified sets of source and target ROIs
#
# Call as
#    probtracks.sh <dirname_tag> <source_roi_list> <target_roi_list>
#
# Example (the quotes are critical):
#    probtracks.sh FS6 \
#        "FS_THALAMUS" \
#        "FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"
#
# dirname_tag is used to name the output directory
# source_roi_list and target_roi_list are space-separated. Corresponding files must 
# exist in ${rois_dwi_dir} as created by make_DWI_rois.sh, e.g.
#     FS_THALAMUS_L.nii.gz
#     FS_THALAMUS_R.nii.gz
#     FS_PFC_L.nii.gz
#     FS_PFC_R.nii.gz
#     ...
# These ROI files must be in the same voxel/world geometry as the BEDPOST images.
dirname_tag="${1}"
export source_regions="${2}"
export target_regions="${3}"

# Options for all tracking
trackopts="-P ${probtrack_samples} -l --onewaycondition --verbose=0 --forcedir --modeuler --pd --os2t --s2tastext --opd --ompl"

# Root dir for all tracking output folders
export track_dir=${out_dir}/"PROBTRACK_${dirname_tag}"

# Include a couple necessary functions from another file
source functions.sh

# Clean up our region lists to get correct spaces for how we'll use them later
source_regions="$(echo "${source_regions}" | xargs ) "
target_regions="$(echo "${target_regions}" | xargs ) "

# Help out the log file with a little extra info
echo Running ${0}
echo "Tracking for ${dirname_tag}:"
echo "    Sources: ${source_regions}"
echo "    Targets: ${target_regions}"
echo "    Dir:     ${track_dir}"


# Track each source to each individual target cortical region, in each hemisphere. This 
# uses the track function from functions.sh
for source in ${source_regions} ; do
	for target in ${target_regions} ; do
		for LR in L R ; do
			track ${bedpost_dir} ${rois_dwi_dir} ${track_dir} "${trackopts}" \
				${source}_${LR} ${target}_${LR}
		done
	done
done


# Create multiple targets files for L and R. These are text files with the 
# "short" region names e.g. FS_PFC_L and so on that probtrack can map to
# the corresponding ROI files e.g. FS_PFC_L.nii.gz. We get this by replacing
# the spaces in the supplied targets list.
echo "${target_regions}" | sed $'s/ /_L\\\n/g' > ${track_dir}/TARGETS_L.txt
echo "${target_regions}" | sed $'s/ /_R\\\n/g' > ${track_dir}/TARGETS_R.txt


# Track each source to all targets, for each hemisphere. probtrack is run 
# from the ROI directory so we don't need pathnames in the targets.txt files.
cd "${rois_dwi_dir}"
for source in ${source_regions} ; do
	for LR in L R ; do
		RL=$(swapLR ${LR})
		probtrackx2 \
			-s "${bedpost_dir}"/merged \
			-m "${bedpost_dir}"/nodif_brain_mask \
			-x ${source}_${LR} \
			--targetmasks=${track_dir}/TARGETS_${LR}.txt \
			--stop=FS_${LR}HCORTEX_STOP \
			--avoid=FS_${RL}H_AVOID \
			--dir="${track_dir}"/${source}_${LR}_to_TARGETS_${LR} \
			${trackopts}
	done
done


# Segmentation for all targets, for each combo of source+hemisphere. First
# using the results from the individual probtrack runs, then using the result
# from the multi-target run. Because we exported source_regions, target_regions,
# and track_dir above, they will be available in the subshell here.
do_biggest.sh INDIV
do_biggest.sh MULTI

