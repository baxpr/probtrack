#!/bin/bash
#
# Probtracks for specified sets of source and target ROIs

# Source and target region names as space-separated lists. Corresponding files must 
# exist in ${rois_dwi_dir} as created by make_DWI_rois.sh, e.g.
#     FS_THALAMUS_L.nii.gz
#     FS_THALAMUS_R.nii.gz
#     FS_PFC_L.nii.gz
#     FS_PFC_R.nii.gz
#     ...
# The ROI files must be in the same voxel/world geometry as the BEDPOST images. The
# format of this list (short ROI names followed by one space each) is critical for some
# assumptions that are made below.
source_regions="FS_THALAMUS"
target_regions="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"

# Options for all tracking
trackopts="-P ${probtrack_samples} -l --onewaycondition --verbose=0 --forcedir --modeuler --pd --os2t --s2tastext --opd --ompl"


# Help out the log file with a little extra info
echo Running ${0}

# Root dir for all tracking output folders
track_dir=${out_dir}/PROBTRACK_FS6_LOOPS

# Include a couple necessary functions from another file
source functions.sh


# Track each source to each individual target cortical region, in each hemisphere. This uses
# the track function from functions.sh
trackcmd="track ${bedpost_dir} ${rois_dwi_dir} ${track_dir}"
for source in ${source_regions} ; do
	for target in ${target_regions} ; do
		for LR in L R ; do
			${trackcmd} "${trackopts}" ${source}_${LR} ${target}_${LR}
		done
	done
done


# Create multiple targets files for L and R. These are text files with the 
# "short" region names e.g. FS_PFC_L and so on that probtrack can map to
# the corresponding ROI files e.g. FS_PFC_L.nii.gz. We get this by replacing
# some characters in the supplied targets list.
echo "${target_regions}" | sed $'s/ /_L\\\n/g' > ${track_dir}/TARGETS_L.txt
echo "${target_regions}" | sed $'s/ /_R\\\n/g' > ${track_dir}/TARGETS_R.txt


# Track each source to all targets, for each hemisphere. This tracking is done 
# in the ROI directory so we don't need pathnames in the targets.txt files.
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


# Segmentation for all targets, for each combo of source+hemisphere
cd "${track_dir}"
for LR in L R ; do
	for source in ${source_regions} ; do
		mkdir "BIGGEST_INDIV_${source}"
		bigstr=""
		for target in ${target_regions} ; do
			bigstr="${bigstr} ${source}_${LR}_to_${target}_${LR}/seeds_to_${target}_${LR}"
		done
		find_the_biggest ${bigstr} "BIGGEST_INDIV_${source}"/seg_all_${LR}
	done
done

# Make separate ROI images from segmentation, and make label file for seg_all
for LR in L R ; do
	for source in ${source_regions} ; do
		let ind=0
		csv_file="BIGGEST_INDIV_${source}/seg_${target}_${LR}-label.csv"
		> "${csv_file}"
		for target in ${target_regions} ; do
			let ind+=1
			echo "${ind},${target}\n" >> csv_file
			fslmaths \
				"BIGGEST_INDIV_${source}"/seg_all_${LR} \
				-thr ${ind} -uthr ${ind} -bin \
				"BIGGEST_INDIV_${source}/seg_${target}_${LR}"
		done
	done
done


# Combine left and right segs for each source in the multi-target runs
for source in ${source_regions} ; do
	cd "${track_dir}/BIGGEST_INDIV_${source}"
	fslmaths seg_all_L -add seg_all_R seg_all_LR
done
