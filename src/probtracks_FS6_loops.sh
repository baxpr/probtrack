#!/bin/bash

echo Running ${0}

# Root dir for all tracking output folders
track_dir=${out_dir}/PROBTRACK_FS6_LOOPS

# Source and target regions
source_regions="FS_THALAMUS"
target_regions="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"

# Options for all tracking
trackopts="-P ${probtrack_samples} -l --onewaycondition --verbose=0 --forcedir --modeuler --pd --os2t --s2tastext --opd --ompl"


# Need some functions
source functions.sh


# Sources to individual target cortical regions
trackcmd="track ${bedpost_dir} ${rois_dwi_dir} ${track_dir}"
for source in ${source_regions} ; do
	for target in ${target_regions} ; do
		for LR in L R ; do
			${trackcmd} "${trackopts}" ${source}_${LR} ${target}_${LR}
		done
	done
done


# Create multiple targets files for L and R
echo "${target_regions}" | sed $'s/ /_L\\\n/g' > ${track_dir}/TARGETS_L.txt
echo "${target_regions}" | sed $'s/ /_R\\\n/g' > ${track_dir}/TARGETS_R.txt


# Track all sources to all targets
cd "${rois_dwi_dir}"
for source in ${source_regions} ; do
	for LR in L R ; do
		probtrackx2 \
			-s "${bedpost_dir}"/merged \
			-m "${bedpost_dir}"/nodif_brain_mask \
			-x ${source}_${LR} \
			--targetmasks=${track_dir}/TARGETS_${LR}.txt \
			--stop=FS_${LR}HCORTEX_STOP \
			--avoid=FS_$(swapLR ${LR})H_AVOID \
			--dir="${track_dir}"/${source}_${LR}_to_TARGETS_${LR} \
			${trackopts}
	done
done


exit 0

#FIXME Make the below work for arbitrary number/name of target regions
# Then loop that over source regions
# Need a counter in the loop to get ROI value for fslmaths, and also
# append to label file with ROI name at the same time

# Segmentation
cd "${track_dir}"
mkdir BIGGEST
for LR in L R ; do

	find_the_biggest \
		FS_THALAMUS_${LR}_to_FS_PFC_${LR}/seeds_to_FS_PFC_${LR} \
		FS_THALAMUS_${LR}_to_FS_MOTOR_${LR}/seeds_to_FS_MOTOR_${LR} \
		FS_THALAMUS_${LR}_to_FS_SOMATO_${LR}/seeds_to_FS_SOMATO_${LR} \
		FS_THALAMUS_${LR}_to_FS_POSTPAR_${LR}/seeds_to_FS_POSTPAR_${LR} \
		FS_THALAMUS_${LR}_to_FS_OCC_${LR}/seeds_to_FS_OCC_${LR} \
		FS_THALAMUS_${LR}_to_FS_TEMP_${LR}/seeds_to_FS_TEMP_${LR} \
		BIGGEST/seg_all_${LR}
		
	fslmaths BIGGEST/seg_all_${LR} -thr 1 -uthr 1 -bin BIGGEST/seg_FS_PFC_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 2 -uthr 2 -bin BIGGEST/seg_FS_MOTOR_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 3 -uthr 3 -bin BIGGEST/seg_FS_SOMATO_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 4 -uthr 4 -bin BIGGEST/seg_FS_POSTPAR_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 5 -uthr 5 -bin BIGGEST/seg_FS_OCC_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 6 -uthr 6 -bin BIGGEST/seg_FS_TEMP_${LR}

done

# Combine left and right
fslmaths BIGGEST/seg_all_L -add BIGGEST/seg_all_R BIGGEST/seg_all_LR

# Make label list for segmentations
cat > BIGGEST/seg_all-labels.csv <<HERE
1,FS_PFC
2,FS_MOTOR
3,FS_SOMATO
4,FS_POSTPAR
5,FS_OCC
6,FS_TEMP
HERE

