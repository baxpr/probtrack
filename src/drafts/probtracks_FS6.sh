#!/bin/bash
#
### TRACTOGRAPHY - FREESURFER THALAMUS TO FREESURFER CORTICAL MASKS

echo Running ${0}

# Track function is here
source functions.sh


# Root dir for all tracking output folders
track_dir=${out_dir}/PROBTRACK_FS6


# Options for all tracking
trackopts="-P ${probtrack_samples} -l --onewaycondition --verbose=0 --forcedir --modeuler --pd --os2t --s2tastext --opd --ompl"


# Thalamus to individual cortical regions
trackcmd="track ${bedpost_dir} ${rois_dwi_dir} ${track_dir}"
for region in \
  FS_PFC \
  FS_MOTOR \
  FS_SOMATO \
  FS_POSTPAR \
  FS_OCC \
  FS_TEMP \
; do
	${trackcmd} "${trackopts}" FS_THALAMUS_L ${region}_L
	${trackcmd} "${trackopts}" FS_THALAMUS_R ${region}_R
done


# L thalamus to L multiple targets
cd "${rois_dwi_dir}"
probtrackx2 \
	-s "${bedpost_dir}"/merged \
	-m "${bedpost_dir}"/nodif_brain_mask \
	-x FS_THALAMUS_L \
	--targetmasks="${targets_dir}"/TARGETS_FS6_L.txt \
	--stop=FS_LHCORTEX_STOP \
	--avoid=FS_RH_AVOID \
	--dir="${track_dir}"/FS_THALAMUS_L_to_TARGETS_L \
	${trackopts}
cp "${targets_dir}"/TARGETS_FS6_L.txt ${track_dir}/FS_THALAMUS_L_to_TARGETS_L

# R thalamus to R multiple targets
cd "${rois_dwi_dir}"
probtrackx2 \
	-s "${bedpost_dir}"/merged \
	-m "${bedpost_dir}"/nodif_brain_mask \
	-x FS_THALAMUS_R \
	--targetmasks="${targets_dir}"/TARGETS_FS6_R.txt \
	--stop=FS_RHCORTEX_STOP \
	--avoid=FS_LH_AVOID \
	--dir="${track_dir}"/FS_THALAMUS_R_to_TARGETS_R \
	${trackopts}
cp "${targets_dir}"/TARGETS_FS6_R.txt "${track_dir}"/FS_THALAMUS_R_to_TARGETS_R



# Segmentation
cd "${track_dir}"
mkdir BIGGEST
for LR in L R ; do

	find_the_biggest \
		FS_THALAMUS_${LR}_to_FS_PFC_${LR}/seeds_to_FS_PFC_${LR} \
		FS_THALAMUS_${LR}_to_FS_MOTOR_${LR}/seeds_to_FS_MOTOR_${LR} \
		FS_THALAMUS_${LR}_to_FS_SOMATO_${LR}/seeds_to_FS_SOMATO_${LR} \
		FS_THALAMUS_${LR}_to_FS_POSTPAR_${LR}/seeds_to_FS_POSTPAR_${LR} \
		FS_THALAMUS_${LR}_to_FS_OCC_${LR}/seeds_to_FS_OCC_${LR} \
		FS_THALAMUS_${LR}_to_FS_TEMP_${LR}/seeds_to_FS_TEMP_${LR} \
		BIGGEST/seg_all_${LR}
		
	fslmaths BIGGEST/seg_all_${LR} -thr 1 -uthr 1 -bin BIGGEST/seg_FS_PFC_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 2 -uthr 2 -bin BIGGEST/seg_FS_MOTOR_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 3 -uthr 3 -bin BIGGEST/seg_FS_SOMATO_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 4 -uthr 4 -bin BIGGEST/seg_FS_POSTPAR_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 5 -uthr 5 -bin BIGGEST/seg_FS_OCC_${LR}
	fslmaths BIGGEST/seg_all_${LR} -thr 6 -uthr 6 -bin BIGGEST/seg_FS_TEMP_${LR}

done

# Combine left and right
fslmaths BIGGEST/seg_all_L -add BIGGEST/seg_all_R BIGGEST/seg_all_LR

# Make label list for segmentations
cat > BIGGEST/seg_all-labels.csv <<HERE
1,FS_PFC
2,FS_MOTOR
3,FS_SOMATO
4,FS_POSTPAR
5,FS_OCC
6,FS_TEMP
HERE

