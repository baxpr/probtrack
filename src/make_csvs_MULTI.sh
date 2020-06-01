#!/bin/bash
#
# CSV outputs in format for REDCap

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"

# Fraction of seeds reaching each target, over whole source ROI
mkdir -p "${out_dir}"/STATS_MULTI
csv_file="${out_dir}"/STATS_MULTI/seed_fractions_MULTI.csv
> "${csv_file}"
echo "probtrack_dir,source,source_voxels,source_mm3,target,target_voxels,target_mm3,target_tracks,total_tracks,target_tracks_fraction,target_seg_voxels,total_seg_voxels,target_seg_voxels_fraction" \
	> "${csv_file}"

for source in ${source_regions} ; do
	for LR in L R ; do

		cd ${track_dir}/${source}_${LR}_to_TARGETS_${LR}

		# Total voxelwise streamline count and ROI voxel count
		fsladd seedtotal seeds_to_*_${LR}.nii.gz
		nvox="$(fslstats ${rois_dwi_dir}/${source}_${LR} -V | awk '{print $1}')"
		
		# Per region ratios of seed counts
		for target in ${target_regions} ; do
			csv_line="$(csv_line.py \
				${source}_${LR}_to_TARGETS_${LR} \
				${source}_${LR} \
				${target}_${LR} \
				${rois_dwi_dir}/${source}_${LR}.nii.gz \
				${rois_dwi_dir}/${target}_${LR}.nii.gz \
				seeds_to_${target}_${LR}.nii.gz \
				seedtotal.nii.gz \
				${track_dir}/BIGGEST_MULTI_${source}/seg_${target}_${LR}.nii.gz \
				${track_dir}/BIGGEST_MULTI_${source}/seg_all_${LR}.nii.gz)"
			echo ${csv_line} >> "${csv_file}"			
		done
		
		rm seedtotal.nii.gz
		
	done
done
