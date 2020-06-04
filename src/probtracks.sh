#!/bin/bash
#
# Probtracks for specified sets of source and target ROIs
#
# dirname_tag is used to name the output files
#
# source_regions and target_region are space-separated. Corresponding files must 
# exist in ${rois_fs_dir} as created by make_FS_rois.sh, e.g.
#     FS_THALAMUS_L.nii.gz
#     FS_THALAMUS_R.nii.gz
#     FS_PFC_L.nii.gz
#     FS_PFC_R.nii.gz
#     ...

# Options for all tracking
trackopts="--nsamples=${probtrack_samples} ${probtrack_options} --forcedir --opd --ompl --s2tastext --os2t"

# Masks are in FS space so we also need to use the transform to DWI
trackopts="${trackopts} --xfm=${out_dir}/FS_to_DWI.mat"

# Root dir for all tracking output folders
export track_dir="${out_dir}"/PROBTRACKS
mkdir -p "${track_dir}"

# Copy some helpful info to the track dir
cp "${src_dir}"/README_image_files.txt "${track_dir}"

# Include a couple necessary functions from another file
source functions.sh

# Clean up our region lists. Later on we need exactly one space between
# region names, and one space following the last one, so that we'll get the
# correct format in the target.txt files.
source_regions="$(echo "${source_regions}" | xargs ) "
target_regions="$(echo "${target_regions}" | xargs ) "

# Help out the log file with a little extra info
echo Running ${0}
echo "Tracking for ${dirname_tag}:"
echo "    Sources: ${source_regions}"
echo "    Targets: ${target_regions}"
echo "    Dir:     ${track_dir}"
echo "    Opts:    ${trackopts}"


# Make track masks - target, avoid, stop, waypoint. Store these in the probtrack dir
mkdir -p "${track_dir}"/TRACKMASKS
cd "${track_dir}"/TRACKMASKS

fslmaths "${rois_fs_dir}"/FS_WM_LR -mul 0 emptymask

allsrcLstr=""
allsrcRstr=""
for source in ${source_regions} ; do
	allsrcLstr="${allsrcLstr} -add ${rois_fs_dir}/${source}_L"
	allsrcRstr="${allsrcRstr} -add ${rois_fs_dir}/${source}_R"
done
alltgtLstr=""
alltgtRstr=""
for target in ${target_regions} ; do
	alltgtLstr="${alltgtLstr} -add ${rois_fs_dir}/${target}_L"
	alltgtRstr="${alltgtRstr} -add ${rois_fs_dir}/${target}_R"
done

fslmaths emptymask ${allsrcLstr} ${alltgtLstr} -bin all_src_tgt_L
fslmaths emptymask ${allsrcRstr} ${alltgtRstr} -bin all_src_tgt_R
fslmaths emptymask ${alltgtLstr} -bin all_tgt_L
fslmaths emptymask ${alltgtRstr} -bin all_tgt_R
fslmaths all_tgt_L -add all_tgt_R -bin all_tgt_LR

rm emptymask.nii.gz


# Avoid masks for single target
#   All tgt in this hemisphere except current target;
#   All src, tgt, WM in opposite hemisphere
#   All CERSUBC, brainstem in both hemispheres
for source in ${source_regions} ; do
	for target in ${target_regions} ; do
		for LR in L R ; do
			RL=$(swapLR ${LR})
			fslmaths \
				all_tgt_${LR} -sub "${rois_fs_dir}"/"${target}_${LR}" -bin \
				-add all_src_tgt_${RL} -add "${rois_fs_dir}"/FS_WM_${RL} \
				-add "${rois_fs_dir}"/FS_SUBC_${LR} \
				-add "${rois_fs_dir}"/FS_SUBC_${RL} \
				-add "${rois_fs_dir}"/FS_CEREBELLUM_${LR} \
				-add "${rois_fs_dir}"/FS_CEREBELLUM_${RL} \
				-add "${rois_fs_dir}"/FS_BRAINSTEM \
				-add "${rois_fs_dir}"/FS_CSFVENT \
				-bin \
				"${source}_${LR}_to_${target}_${LR}_AVOID"
		done
	done
done

# Stop, waypoint masks for multi target are just all the targets, all_tgt_{L,R}

# Avoid masks for multi are all src, tgt, WM in the opposite hemisphere
# and CERSUBC, brainstem in both hemispheres
fslmaths all_src_tgt_L \
	-add "${rois_fs_dir}"/FS_WM_L \
	-add "${rois_fs_dir}"/FS_SUBC_L -add "${rois_fs_dir}"/FS_SUBC_R \
	-add "${rois_fs_dir}"/FS_CEREBELLUM_L -add "${rois_fs_dir}"/FS_CEREBELLUM_R \
	-add "${rois_fs_dir}"/FS_BRAINSTEM \
	-add "${rois_fs_dir}"/FS_CSFVENT \
	-bin multi_L_AVOID
fslmaths all_src_tgt_R \
	-add "${rois_fs_dir}"/FS_WM_R \
	-add "${rois_fs_dir}"/FS_SUBC_L -add "${rois_fs_dir}"/FS_SUBC_R \
	-add "${rois_fs_dir}"/FS_CEREBELLUM_L -add "${rois_fs_dir}"/FS_CEREBELLUM_R \
	-add "${rois_fs_dir}"/FS_BRAINSTEM \
	-add "${rois_fs_dir}"/FS_CSFVENT \
	-bin multi_R_AVOID


# Work in the ROI dir for tracking
cd "${rois_fs_dir}"


# Track each source to each individual target cortical region, in each hemisphere.
# probtrack is run from the ROI directory to simplify the command here.
for source in ${source_regions} ; do
	for target in ${target_regions} ; do
		for LR in L R ; do

			probtrackx2 \
				--samples="${bedpost_dir}"/merged \
				--mask="${bedpost_dir}"/nodif_brain_mask \
				--seed="${rois_fs_dir}"/"${source}_${LR}" \
				--targetmasks="${rois_fs_dir}"/"${target}_${LR}" \
				--waypoints="${rois_fs_dir}"/"${target}_${LR}" \
				--stop="${rois_fs_dir}"/"${target}_${LR}" \
				--avoid="${track_dir}"/TRACKMASKS/"${source}_${LR}_to_${target}_${LR}_AVOID" \
				--dir="${track_dir}/${source}_${LR}_to_${target}_${LR}" \
				${trackopts}

			fdt="${track_dir}/${source}_${LR}_to_${target}_${LR}/fdt_paths"
			thresh=$(fslstats "${fdt}" -P 75)
			fslmaths "${fdt}" -thr $thresh "${fdt}"_75pct
			
		done
	done
done


# Create multiple-targets files for L and R. These are text files with the 
# "short" region names e.g. FS_PFC_L and so on that probtrack can map to
# the corresponding ROI files e.g. FS_PFC_L.nii.gz. We get this by replacing
# the spaces in the supplied targets list with e.g. "_L\n"
echo "${target_regions}" | sed $'s/ /_L\\\n/g' > ${track_dir}/TARGETS_L.txt
echo "${target_regions}" | sed $'s/ /_R\\\n/g' > ${track_dir}/TARGETS_R.txt


# Track each source to all targets, for each hemisphere. probtrack is run 
# from the ROI directory so we don't need pathnames in the targets.txt files.
cd "${rois_fs_dir}"
for source in ${source_regions} ; do
	for LR in L R ; do
		
		RL=$(swapLR ${LR})
		probtrackx2 \
			--samples="${bedpost_dir}"/merged \
			--mask="${bedpost_dir}"/nodif_brain_mask \
			--seed=${source}_${LR} \
			--targetmasks=${track_dir}/TARGETS_${LR}.txt \
			--waypoints="${track_dir}"/TRACKMASKS/all_tgt_${LR} \
			--stop="${track_dir}"/TRACKMASKS/all_tgt_${LR} \
			--avoid="${track_dir}"/TRACKMASKS/multi_${RL}_AVOID \
			--dir="${track_dir}"/${source}_${LR}_to_TARGETS_${LR} \
			${trackopts}

			fdt="${track_dir}/${source}_${LR}_to_TARGETS_${LR}/fdt_paths"
			thresh=$(fslstats "${fdt}" -P 75)
			fslmaths "${fdt}" -thr $thresh "${fdt}"_75pct

	done
done


# Warp probtrack output images to MNI space. seeds_to_X with linear,
# masks with nearest neighbor interpolation
for source in ${source_regions} ; do
	for LR in L R ; do
		warpdir.sh "${track_dir}/${source}_${LR}_to_TARGETS_${LR}" 1
		for target in ${target_regions} ; do
			warpdir.sh "${track_dir}/${source}_${LR}_to_${target}_${LR}" 1
		done
	done
done
warpdir.sh "${track_dir}/TRACKMASKS" 0


# Segmentation for all targets, for each combo of source+hemisphere. First
# using the results from the individual probtrack runs, then using the result
# from the multi-target run. Because we exported source_regions, target_regions,
# and track_dir above, they will be available in the subshell here.
do_biggest.sh INDIV
do_biggest.sh MULTI


# Probmaps for the multi-target probtrack run, using proj_thresh
do_probmaps_INDIV.sh
do_probmaps_MULTI.sh


# Get stats to CSV format
make_csvs_INDIV.sh
make_csvs_MULTI.sh


# Leave a single-volume indexed ROI image in the roi directory with this
# set of targets in it, named by the dirname_tag. Assumes the target masks
# do not overlap. Repeat for source ROIs.
cd "${rois_fs_dir}"
csv_file="${dirname_tag}_targetrois-label.csv"
fslmaths "${bedpost_dir}"/nodif_brain_mask -thr 0 -uthr 0 tmp
let ind=0
> "${csv_file}"
for target in ${target_regions} ; do
	let ind+=1
	echo "${ind},${target}" >> "${csv_file}"
	fslmaths ${target}_L -add ${target}_R -bin -mul ${ind} -add tmp tmp
done
mv tmp.nii.gz ${dirname_tag}_targetrois.nii.gz

csv_file="${dirname_tag}_sourcerois-label.csv"
fslmaths "${bedpost_dir}"/nodif_brain_mask -thr 0 -uthr 0 tmp
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
