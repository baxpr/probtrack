#!/bin/bash
#
# Compute probmaps with proj_thresh - multiple target setting

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Process for each source and hemisphere. proj_thresh is picky about where
# files are, so we copy the desired set of seeds_to files to a working dir
# and run proj_thresh within that dir, then clean up.
for source in ${source_regions} ; do
	for LR in L R ; do

		pmap_dir="${track_dir}/PROBMAPS_MULTI_${source}_${LR}"
		mkdir -p "${pmap_dir}"/seeds_to
		
		seed_dir="${track_dir}/${source}_${LR}_to_TARGETS_${LR}"
		cp "${seed_dir}"/seeds_to_*_"${LR}".nii.gz "${pmap_dir}"/seeds_to
		
		cd "${pmap_dir}"/seeds_to
		proj_thresh seeds_to_*_${LR}.nii.gz 0 > "${pmap_dir}"/proj_thresh.log
		mv *proj_seg*.nii.gz total.nii.gz "${pmap_dir}"
		rm -fr "${pmap_dir}"/seeds_to
		
	done
done	

