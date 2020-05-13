#!/bin/bash
#

echo Running ${0}


# Set up
source functions.sh
cd "${rois_dwi_dir}"

# Resample FS ROI images to DWI space (transform from coreg_t1_to_dwi.sh)
mri_convert "${fs_subject_dir}/mri/aparc.DKTatlas+aseg.mgz" aparc.DKTatlas+aseg.nii.gz
flirt \
	-in aparc.DKTatlas+aseg \
	-applyxfm \
	-init "${out_dir}"/FS_to_DWI.mat \
	-out aparc.DKTatlas+aseg_to_DWI \
	-paddingsize 0.0 \
	-interp nearestneighbour \
	-ref "${out_dir}"/b0_mean.nii.gz
flirt \
	-in "${fs_nii_thalamus_niigz}" \
	-applyxfm \
	-init "${out_dir}"/FS_to_DWI.mat \
	-out nii_thalamus_to_DWI \
	-paddingsize 0.0 \
	-interp nearestneighbour \
	-ref "${out_dir}"/b0_mean.nii.gz



# Create single-ROI masks for FS thalamus
fslmaths nii_thalamus_to_DWI -thr 8100 -uthr 8199 FS_THALAMUS_L
fslmaths nii_thalamus_to_DWI -thr 8200 -uthr 8299 FS_THALAMUS_R


# Create single-ROI masks for the needed ROIs, files labeled by number
aparc=aparc.DKTatlas+aseg_to_DWI
for v in \
	2 \
	41 \
	16 \
	7 8 \
	46 47 \
	11 12 13 \
	50 51 52 \
	17 18 \
	53 54 \
	1003 1017 1024 \
	2003 2017 2024 \
	1005 1011 1013 1021 \
	2005 2011 2013 2021 \
	1002 1012 1014 1018 1019 1020 1026 1027 1028 \
	2002 2012 2014 2018 2019 2020 2026 2027 2028 \
	1008 1025 1029 1010 1023 1031 \
	2008 2025 2029 2010 2023 2031 \
	1022 \
	2022 \
	1006 1007 1009 1015 1016 1030 1034 \
	2006 2007 2009 2015 2016 2030 2034 \
	1012 1014 1028 \
	2012 2014 2028 \
	1018 1019 1020 1027 \
	2018 2019 2020 2027 \
	1002 1026 \
	2002 2026 \
	1008 1025 1029 \
	2008 2025 2029 \
	1010 1031 \
	2010 2031 \
	1030 1034 \
	2030 2034 \
	1006 1007 1009 1015 1016 \
	2006 2007 2009 2015 2016 \
; do
	split_roi "${aparc}" $v
done



# Re-join into the needed single-ROI masks, files labeled by ROI name
join_rois "${aparc}"   FS_WM_L               "2"
join_rois "${aparc}"   FS_WM_R               "41"
join_rois "${aparc}"   FS_WM_LR              "2 41"

join_rois "${aparc}"   FS_BRAINSTEM          "16"

join_rois "${aparc}"   FS_CEREBELLUM_L       "7 8"
join_rois "${aparc}"   FS_CEREBELLUM_R       "46 47"

join_rois "${aparc}"   FS_CAUD_PUT_PALL_L    "11 12 13"
join_rois "${aparc}"   FS_CAUD_PUT_PALL_R    "50 51 52"

join_rois "${aparc}"   FS_AMYG_HIPP_L        "17 18"
join_rois "${aparc}"   FS_AMYG_HIPP_R        "53 54"
	
join_rois "${aparc}"   FS_MOTOR_L     "1003 1017 1024"
join_rois "${aparc}"   FS_MOTOR_R     "2003 2017 2024"

join_rois "${aparc}"   FS_OCC_L       "1005 1011 1013 1021"
join_rois "${aparc}"   FS_OCC_R       "2005 2011 2013 2021"

join_rois "${aparc}"   FS_PFC_L       "1002 1012 1014 1018 1019 1020 1026 1027 1028"
join_rois "${aparc}"   FS_PFC_R       "2002 2012 2014 2018 2019 2020 2026 2027 2028"

join_rois "${aparc}"   FS_POSTPAR_L   "1008 1025 1029 1010 1023 1031"
join_rois "${aparc}"   FS_POSTPAR_R   "2008 2025 2029 2010 2023 2031"

join_rois "${aparc}"   FS_SOMATO_L    "1022"
join_rois "${aparc}"   FS_SOMATO_R    "2022"

join_rois "${aparc}"   FS_TEMP_L      "1006 1007 1009 1015 1016 1030 1034"
join_rois "${aparc}"   FS_TEMP_R      "2006 2007 2009 2015 2016 2030 2034"

join_rois "${aparc}"   FS_MOFC_L      "1012 1014 1028"
join_rois "${aparc}"   FS_MOFC_R      "2012 2014 2028"

join_rois "${aparc}"   FS_LPFC_L      "1018 1019 1020 1027"
join_rois "${aparc}"   FS_LPFC_R      "2018 2019 2020 2027"

join_rois "${aparc}"   FS_ACC_L       "1002 1026"
join_rois "${aparc}"   FS_ACC_R       "2002 2026"

join_rois "${aparc}"   FS_PPC_L       "1008 1025 1029"
join_rois "${aparc}"   FS_PPC_R       "2008 2025 2029"

join_rois "${aparc}"   FS_PARDMN_L    "1010 1031"
join_rois "${aparc}"   FS_PARDMN_R    "2010 2031"

join_rois "${aparc}"   FS_AUD_L       "1030 1034"
join_rois "${aparc}"   FS_AUD_R       "2030 2034"

join_rois "${aparc}"   FS_ITEMP_L     "1006 1007 1009 1015 1016"
join_rois "${aparc}"   FS_ITEMP_R     "2006 2007 2009 2015 2016"



# Create 6- and 10-ROI single-image sets and corresponding label lists

# 6-ROI
fslmaths FS_PFC_L     -add FS_PFC_R       -mul 1             tmp
fslmaths FS_MOTOR_L   -add FS_MOTOR_R     -mul 2  -add tmp   tmp
fslmaths FS_SOMATO_L  -add FS_SOMATO_R    -mul 3  -add tmp   tmp
fslmaths FS_POSTPAR_L -add FS_POSTPAR_R   -mul 4  -add tmp   tmp
fslmaths FS_OCC_L      -add FS_OCC_R      -mul 5  -add tmp   tmp
fslmaths FS_TEMP_L    -add FS_TEMP_R      -mul 6  -add tmp   tmp
mv tmp.nii.gz FS_6MASKS.nii.gz

cat > FS_6MASKS-labels.csv <<HERE
1,FS_PFC
2,FS_MOTOR
3,FS_SOMATO
4,FS_POSTPAR
5,FS_OCC
6,FS_TEMP
HERE

# 10-ROI
fslmaths FS_MOFC_L    -add FS_MOFC_R     -mul 1              tmp
fslmaths FS_LPFC_L    -add FS_LPFC_R     -mul 2   -add tmp   tmp
fslmaths FS_ACC_L     -add FS_ACC_R      -mul 3   -add tmp   tmp
fslmaths FS_PPC_L     -add FS_PPC_R      -mul 4   -add tmp   tmp
fslmaths FS_PARDMN_L  -add FS_PARDMN_R   -mul 5   -add tmp   tmp
fslmaths FS_AUD_L     -add FS_AUD_R      -mul 6   -add tmp   tmp
fslmaths FS_ITEMP_L   -add FS_ITEMP_R    -mul 7   -add tmp   tmp
fslmaths FS_MOTOR_L   -add FS_MOTOR_R    -mul 8   -add tmp   tmp
fslmaths FS_SOMATO_L  -add FS_SOMATO_R   -mul 9   -add tmp   tmp
fslmaths FS_OCC_L     -add FS_OCC_R      -mul 10  -add tmp   tmp
mv tmp.nii.gz FS_10MASKS.nii.gz

cat > FS_10MASKS-labels.csv <<HERE
1,FS_MOFC
2,FS_LPFC
3,FS_ACC
4,FS_PPC
5,FS_PARDMN
6,FS_AUD
7,FS_ITEMP
8,FS_MOTOR
9,FS_SOMATO
10,FS_OCC
HERE


# Subcortical mask
fslmaths \
	FS_BRAINSTEM \
	-add FS_CEREBELLUM_L    -add FS_CEREBELLUM_R \
	-add FS_CAUD_PUT_PALL_L -add FS_CAUD_PUT_PALL_R \
	-add FS_AMYG_HIPP_L     -add FS_AMYG_HIPP_R \
	-bin \
	FS_CEREBELLAR_SUBCORTICAL


# Whole brain gray matter mask
fslmaths FS_PFC_R -add FS_MOTOR_R -add FS_SOMATO_R -add FS_POSTPAR_R -add FS_OCC_R -add FS_TEMP_R \
	-add FS_PFC_L -add FS_MOTOR_L -add FS_SOMATO_L -add FS_POSTPAR_L -add FS_OCC_L -add FS_TEMP_L \
	FS_CORTEX


# Add white matter, subcortical to gray matter to make large avoid masks
fslmaths FS_CORTEX -add FS_WM_R -add FS_CEREBELLAR_SUBCORTICAL -bin FS_RH_LHCORTEX_AVOID
fslmaths FS_CORTEX -add FS_WM_L -add FS_CEREBELLAR_SUBCORTICAL -bin FS_LH_RHCORTEX_AVOID


# Avoid masks for specific seed regions
for region in \
  FS_PFC \
  FS_MOTOR \
  FS_SOMATO \
  FS_POSTPAR \
  FS_OCC \
  FS_TEMP \
  FS_MOFC \
  FS_LPFC \
  FS_ACC \
  FS_PPC \
  FS_PARDMN \
  FS_AUD \
  FS_ITEMP \
; do
	fslmaths FS_RH_LHCORTEX_AVOID -sub ${region}_L -thr 1 ${region}_L_AVOID
	fslmaths FS_LH_RHCORTEX_AVOID -sub ${region}_R -thr 1 ${region}_R_AVOID
done

# Stop and avoid masks for hemispheres
for hemi in L R ; do

	fslmaths \
			 FS_PFC_${hemi} \
		-add FS_MOTOR_${hemi} \
		-add FS_SOMATO_${hemi} \
		-add FS_POSTPAR_${hemi} \
		-add FS_OCC_${hemi} \
		-add FS_TEMP_${hemi} \
		-bin FS_${hemi}HCORTEX_STOP

	fslmaths \
			 FS_${hemi}HCORTEX_STOP \
		-add FS_WM_${hemi} \
		-add FS_THALAMUS_${hemi} \
		-bin FS_${hemi}H_AVOID

done


# Clean up
rm -f ${aparc}_*.nii.gz
