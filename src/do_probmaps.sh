#!/bin/bash
#
# Compute probmaps with proj_thresh

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"

# Process for each source and hemisphere
for source in ${source_regions} ; do
	for LR in L R ; do

		# Get seed filenames for this multi-probtrack
		seed_dir="${track_dir}/${source}_to_TARGETS_${LR}"
		seed_files=""
		for target in ${target_regions} ; do
			seed_files="${seed_files} ${seed_dir}/seeds_to_${target}_${LR}"
		done

		cd "${seed_dir}"
		proj_thresh "${seed_files}" 0

	done
done	
