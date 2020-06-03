#!/bin/bash
#
# CSV outputs in format for REDCap

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"

# Fraction of seeds reaching each target, over whole source ROI
mkdir -p "${out_dir}"/STATS_INDIV
csv_file="${out_dir}"/STATS_INDIV/seed_fractions_INDIV.csv
> "${csv_file}"
echo "probtrack_dir,source,source_voxels,source_mm3,target,target_voxels,target_mm3,target_tracks,total_tracks,target_tracks_fraction,target_seg_voxels,total_seg_voxels,target_seg_voxels_fraction" \
	> "${csv_file}"

for source in ${source_regions} ; do
	for LR in L R ; do

		cd ${out_dir}

		# Total voxelwise streamline count and ROI voxel count
		fslmaths "${bedpost_dir}"/nodif_brain_mask -mul 0 tmp_emptymask
		addstr=""
		for target in ${target_regions} ; do
			addstr="${addstr} -add ${track_dir}/${source}_${LR}_to_${target}_${LR}/seeds_to_${target}_${LR}"
		done
		fslmaths tmp_emptymask ${addstr} tmp_total_${source}_${LR}
		#echo "${addstr}" > tmp_addstr_${source}_${LR}.txt
		
		nvox="$(fslstats ${rois_fs_dir}/${source}_${LR} -V | awk '{print $1}')"
		
		# Per region ratios of seed counts. Build a line for the CSV file with a combo
		# of shell script and python
		for target in ${target_regions} ; do
			csv_line="$(csv_line.py \
				${source}_${LR}_to_${target}_${LR} \
				${source}_${LR} \
				${target}_${LR} \
				${rois_fs_dir}/${source}_${LR}.nii.gz \
				${rois_fs_dir}/${target}_${LR}.nii.gz \
				${track_dir}/${source}_${LR}_to_${target}_${LR}/seeds_to_${target}_${LR}.nii.gz \
				${out_dir}/tmp_total_${source}_${LR}.nii.gz \
				${track_dir}/BIGGEST_INDIV_${source}/seg_${target}_${LR}.nii.gz \
				${track_dir}/BIGGEST_INDIV_${source}/seg_all_${LR}.nii.gz)"
			echo ${csv_line} >> "${csv_file}"
		done
		
		rm tmp_emptymask.nii.gz tmp_total_${source}_${LR}.nii.gz
		
	done
done
