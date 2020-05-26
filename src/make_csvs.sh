#!/bin/bash
#
# CSV outputs in format for REDCap

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Fraction of seeds reaching each target, over whole source ROI
mkdir -p "${out_dir}"/STATS
csv_file="${out_dir}"/STATS/seedfractions.csv
> "${csv_file}"
echo "probtrack_dir,source,source_voxels,target,tracks_to_target,total_tracks,tracks_to_target_fraction" > "${csv_file}"

for source in ${source_regions} ; do
	for LR in L R ; do

		cd ${track_dir}/${source}_${LR}_to_TARGETS_${LR}

		# Total streamline count and voxel count
		fsladd seedtotal seeds_to_*_${LR}.nii.gz
		nvox="$(fslstats ${rois_dwi_dir}/${source}_${LR} -v | awk '{print $1}')"
		
		# Per region ratio of seed counts
		for target in ${target_regions} ; do
			echo "${source}_${LR}_to_TARGETS_${LR},${nvox},${source}_${LR},${target}_${LR},$(csv_line.py seeds_to_${target}_${LR}.nii.gz)" \
				>> "${csv_file}"			
		done
		
	done
done

