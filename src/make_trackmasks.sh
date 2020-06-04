#!/bin/bash
#
# Make target, stop, avoid, waypoint masks for specific ROI set

echo Running "${0}"


mkdir -p "${track_dir}"/TRACKMASKS
cd "${track_dir}"/TRACKMASKS


# Masks marking all sources, all targets
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


# Avoid masks for single target. Includes:
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
