#!/bin/bash
#
# Compute probmaps with proj_thresh - individual targets put together.
#
# Performed separately for FS native space images seeds_to_X, and for
# MNI space images wseeds_to_X. This avoids interpolating the probmaps

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Process for each source and hemisphere. proj_thresh is picky about where
# files are, so we copy the desired set of seeds_to files to a working dir
# and run proj_thresh within that dir, then clean up.
for source in ${source_regions} ; do

	# Both hemispheres probmaps stored in same dir
	pmap_dir="${track_dir}/PROBMAPS_INDIV_${source}"
	mkdir -p "${pmap_dir}"/seeds_to

	for LR in L R ; do
		
		# Collect separate seed images
		for target in ${target_regions} ; do
			cp "${track_dir}/${source}_${LR}_to_${target}_${LR}"/seeds_to_"${target}"_${LR}.nii.gz "${pmap_dir}"/seeds_to
		done
		
		# Make probmaps
		cd "${pmap_dir}"/seeds_to
		proj_thresh seeds_to_*_${LR}.nii.gz 0 > "${pmap_dir}"/proj_thresh.log
		mv *proj_seg*.nii.gz "${pmap_dir}"
		mv total.nii.gz "${pmap_dir}"/total_${LR}.nii.gz
		
	done

	# Combine two hemispheres. proj_thresh puts NaN in non-seed voxels
	# so that has to be handled
	cd "${pmap_dir}"
	fslmaths total_L -add total_R total_LR
	for target in ${target_regions} ; do
		for LR in L R ; do
			fslmaths seeds_to_"${target}"_${LR}_proj_seg_thr_0 -nan seeds_to_"${target}"_${LR}_proj_seg_thr_0
		done
		fslmaths seeds_to_"${target}"_L_proj_seg_thr_0 \
			-add seeds_to_"${target}"_R_proj_seg_thr_0 \
			seeds_to_"${target}"_LR_proj_seg_thr_0
	done

	# Clean up
	rm -fr "${pmap_dir}"/seeds_to
	
done	



# Repeat for MNI space inputs
for source in ${source_regions} ; do

	# Both hemispheres probmaps stored in same dir
	pmap_dir="${track_dir}/PROBMAPS_INDIV_${source}"
	mkdir -p "${pmap_dir}"/wseeds_to

	for LR in L R ; do
		
		# Collect separate seed images
		for target in ${target_regions} ; do
			cp "${track_dir}/${source}_${LR}_to_${target}_${LR}"/wseeds_to_"${target}"_${LR}.nii.gz "${pmap_dir}"/wseeds_to
		done
		
		# Make probmaps
		cd "${pmap_dir}"/wseeds_to
		proj_thresh wseeds_to_*_${LR}.nii.gz 0 > "${pmap_dir}"/wproj_thresh.log
		mv *proj_seg*.nii.gz "${pmap_dir}"
		mv total.nii.gz "${pmap_dir}"/wtotal_${LR}.nii.gz
		
	done

	# Combine two hemispheres. proj_thresh puts NaN in non-seed voxels
	# so that has to be handled
	cd "${pmap_dir}"
	fslmaths wtotal_L -add wtotal_R wtotal_LR
	for target in ${target_regions} ; do
		for LR in L R ; do
			fslmaths wseeds_to_"${target}"_${LR}_proj_seg_thr_0 -nan wseeds_to_"${target}"_${LR}_proj_seg_thr_0
		done
		fslmaths wseeds_to_"${target}"_L_proj_seg_thr_0 \
			-add wseeds_to_"${target}"_R_proj_seg_thr_0 \
			wseeds_to_"${target}"_LR_proj_seg_thr_0
	done

	# Clean up
	rm -fr "${pmap_dir}"/wseeds_to
	
done	

