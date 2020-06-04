#!/bin/bash
#
# Compute probmaps with proj_thresh - individual targets put together.
#
# Perform for FS native space images seeds_to_X, or for MNI space
# images wseeds_to_X, depending on $2. This avoids interpolating the probmaps

bigtag="${1}"     # INDIV or MULTI
space="${2}"      # native or MNI


# Working in native space (no image filename prefix) or MNI space ('w' prefix)
case ${space} in
	native)
		pfx= ;;
	MNI)
		pfx=w ;;
	*)
		echo "Unknown space ${space}"
		exit 1 ;;
esac


# Info output
echo "Running ${0} for ${bigtag} ${space}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Process for each source and hemisphere. proj_thresh is picky about where
# files are, so we copy the desired set of seeds_to files to a working dir
# and run proj_thresh within that dir, then clean up.
for source in ${source_regions} ; do

	# Both hemispheres probmaps stored in same dir
	pmap_dir="${track_dir}/PROBMAPS_${biggest}_${source}"
	mkdir -p "${pmap_dir}"/${pfx}seeds_to

	for LR in L R ; do
		
		# Collect separate seed images for INDIV, or use the <>_to_TARGET dir for MULTI
		case ${bigtag} in
			INDIV)
				for target in ${target_regions} ; do
					seed_dir="${track_dir}/${source}_${LR}_to_${target}_${LR}"
					cp "${seed_dir}/${pfx}seeds_to_"${target}"_${LR}.nii.gz" "${pmap_dir}"/${pfx}seeds_to
				done ;;
			MULTI)
				seed_dir="${track_dir}/${source}_${LR}_to_TARGETS_${LR}"
				cp "${seed_dir}/${pfx}seeds_to_*_${LR}.nii.gz" "${pmap_dir}"/${pfx}seeds_to
			*)
				echo "Unknown bigtag ${bigtag}"
				exit 1
				;;
		esac
		
		# Make probmaps
		cd "${pmap_dir}"/${pfx}seeds_to
		proj_thresh ${pfx}seeds_to_*_${LR}.nii.gz 0 > "${pmap_dir}"/${pfx}proj_thresh.log
		mv ${pfx}*proj_seg*.nii.gz "${pmap_dir}"
		mv total.nii.gz "${pmap_dir}"/${pfx}total_${LR}.nii.gz
		
	done

	# Combine two hemispheres. proj_thresh puts NaN in non-seed voxels
	# so that has to be handled
	cd "${pmap_dir}"
	fslmaths ${pfx}total_L -add ${pfx}total_R ${pfx}total_LR
	for target in ${target_regions} ; do
		for LR in L R ; do
			fslmaths ${pfx}seeds_to_"${target}"_${LR}_proj_seg_thr_0 -nan ${pfx}seeds_to_"${target}"_${LR}_proj_seg_thr_0
		done
		fslmaths ${pfx}seeds_to_"${target}"_L_proj_seg_thr_0 \
			-add ${pfx}seeds_to_"${target}"_R_proj_seg_thr_0 \
			${pfx}seeds_to_"${target}"_LR_proj_seg_thr_0
	done

	# Clean up
	rm -fr "${pmap_dir}"/${pfx}seeds_to
	
done	


