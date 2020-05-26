#!/bin/bash
#
# CSV outputs in format for REDCap

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Fraction of seeds reaching each target, over whole source ROI
mkdir -p "${out_dir}"/CSV
csv_file="${out_dir}"/CSV/seedfractions.csv
> csv_file
echo "probtrack_dir,source,target,tracks_to_target,total_tracks,tracks_to_target_fraction" > csv_file

for source in ${source_regions} ; do
	for LR in L R ; do

		cd ${track_dir}/${source}_${LR}_to_TARGETS_${LR}

		# Total streamline count
		fsladd seedtotal seeds_to_*_${LR}.nii.gz
		
		# Per region ratio of means (same as ratio of sums
		# because the volumes are the same)
		for target in ${target_regions} ; do
			let totalcount=$(fslstats seedtotal -M)
			let targetcount=$(fslstats seeds_to_${target}_${LR} -M)
			let targetfrac=$(echo "${targetcount}/${totalcount}" | bc -l)
			echo "${source}_${LR}_to_TARGETS_${LR},${source}_${LR},${target}_${LR},${targetcount},${totalcount},${targetfrac}" > csv_file			
		done
		
	done
done

