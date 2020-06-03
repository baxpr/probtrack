#!/bin/bash



# Transform all probtrack related images to FS and MNI geometry
for source in ${source_regions} ; do
	warpdir.sh "${track_dir}/BIGGEST_INDIV_${source}"
	warpdir.sh "${track_dir}/BIGGEST_MULTI_${source}"
	warpdir.sh "${track_dir}/PROBMAPS_INDIV_${source}"
	warpdir.sh "${track_dir}/PROBMAPS_MULTI_${source}"
	for LR in L R ; do
		warpdir.sh "${track_dir}/${source}_${LR}_to_TARGETS_${LR}"
		for target in ${target_regions} ; do
			warpdir.sh "${track_dir}/${source}_${LR}_to_${target}_${LR}"
		done
	done
done
warpdir.sh "${track_dir}/TRACKMASKS"


# Leave a single-volume indexed ROI image in the roi directory with this
# set of targets in it, named by the dirname_tag. Assumes the target masks
# do not overlap. Repeat for source ROIs.
cd "${rois_fs_dir}"
csv_file="${dirname_tag}_targetrois-label.csv"
fslmaths FS_WM_LR -thr 0 -uthr 0 tmp
let ind=0
> "${csv_file}"
for target in ${target_regions} ; do
	let ind+=1
	echo "${ind},${target}" >> "${csv_file}"
	fslmaths ${target}_L -add ${target}_R -bin -mul ${ind} -add tmp tmp
done
mv tmp.nii.gz ${dirname_tag}_targetrois.nii.gz

csv_file="${dirname_tag}_sourcerois-label.csv"
fslmaths FS_WM_LR -thr 0 -uthr 0 tmp
let ind=0
> "${csv_file}"
for source in ${source_regions} ; do
	let ind+=1
	echo "${ind},${source}" >> "${csv_file}"
	fslmaths ${source}_L -add ${source}_R -bin -mul ${ind} -add tmp tmp
done
mv tmp.nii.gz ${dirname_tag}_sourcerois.nii.gz


# Make PDF pages for this set of tracks
probtracks_snapshots.sh
