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

