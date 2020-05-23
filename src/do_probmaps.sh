#!/bin/bash
#
# Compute probmaps with proj_thresh

# FIXME implement for INDIV and MULTI?

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"

# Process for each source and hemisphere. proj_thresh is very picky
# about how filenames are specified - we have a wildcard that should
# find all the seeds_to files but exclude the _lengths files. And
# it should be run from the seed files directory.
for source in ${source_regions} ; do
	for LR in L R ; do

		seed_dir="${track_dir}/${source}_${LR}_to_TARGETS_${LR}"
		cd "${seed_dir}"
		pwd
		proj_thresh seeds_to_*_${LR}.nii.gz 0 > proj_thresh.log
		
	done
done	
