#!/bin/bash
#

echo Running ${0}


# Set up
source functions.sh
cd "${rois_fs_dir}"

# Get FS space aparc in .nii format
mri_convert "${fs_subject_dir}/mri/aparc.DKTatlas+aseg.mgz" aparc.DKTatlas+aseg.nii.gz


# Create single-ROI masks for FS thalamus using thal segmentation output
fslmaths "${fs_nii_thalamus_niigz}" -thr 8100 -uthr 8199 -bin FS_THALAMUS_L
fslmaths "${fs_nii_thalamus_niigz}" -thr 8200 -uthr 8299 -bin FS_THALAMUS_R

 
# Re-combine aparc into the needed single-ROI masks, files labeled by ROI name
aparc=aparc.DKTatlas+aseg

combine_rois "${aparc}"   FS_WM_L               "2"
combine_rois "${aparc}"   FS_WM_R               "41"
combine_rois "${aparc}"   FS_WM_LR              "2 41"

combine_rois "${aparc}"   FS_BRAINSTEM          "16"

combine_rois "${aparc}"   FS_CSFVENT            "4 5 14 15 24 43 44"

combine_rois "${aparc}"   FS_SUBC_L             "11 12 13 17 18 26 28"
combine_rois "${aparc}"   FS_SUBC_R             "50 51 52 53 54 58 60"

combine_rois "${aparc}"   FS_INSULA_L           "1035"
combine_rois "${aparc}"   FS_INSULA_R           "2035"

combine_rois "${aparc}"   FS_CEREBELLUM_L       "7 8"
combine_rois "${aparc}"   FS_CEREBELLUM_R       "46 47"

#combine_rois "${aparc}"   FS_CAUD_PUT_PALL_L    "11 12 13"
#combine_rois "${aparc}"   FS_CAUD_PUT_PALL_R    "50 51 52"

#combine_rois "${aparc}"   FS_AMYG_HIPP_L        "17 18"
#combine_rois "${aparc}"   FS_AMYG_HIPP_R        "53 54"
	
combine_rois "${aparc}"   FS_MOTOR_L     "1003 1017 1024"
combine_rois "${aparc}"   FS_MOTOR_R     "2003 2017 2024"

combine_rois "${aparc}"   FS_OCC_L       "1005 1011 1013 1021"
combine_rois "${aparc}"   FS_OCC_R       "2005 2011 2013 2021"

combine_rois "${aparc}"   FS_PFC_L       "1002 1012 1014 1018 1019 1020 1026 1027 1028"
combine_rois "${aparc}"   FS_PFC_R       "2002 2012 2014 2018 2019 2020 2026 2027 2028"

combine_rois "${aparc}"   FS_POSTPAR_L   "1008 1025 1029 1010 1023 1031"
combine_rois "${aparc}"   FS_POSTPAR_R   "2008 2025 2029 2010 2023 2031"

combine_rois "${aparc}"   FS_SOMATO_L    "1022"
combine_rois "${aparc}"   FS_SOMATO_R    "2022"

combine_rois "${aparc}"   FS_TEMP_L      "1006 1007 1009 1015 1016 1030 1034"
combine_rois "${aparc}"   FS_TEMP_R      "2006 2007 2009 2015 2016 2030 2034"

combine_rois "${aparc}"   FS_MOFC_L      "1012 1014 1028"
combine_rois "${aparc}"   FS_MOFC_R      "2012 2014 2028"

combine_rois "${aparc}"   FS_LPFC_L      "1018 1019 1020 1027"
combine_rois "${aparc}"   FS_LPFC_R      "2018 2019 2020 2027"

combine_rois "${aparc}"   FS_ACC_L       "1002 1026"
combine_rois "${aparc}"   FS_ACC_R       "2002 2026"

combine_rois "${aparc}"   FS_PPC_L       "1008 1025 1029"
combine_rois "${aparc}"   FS_PPC_R       "2008 2025 2029"

combine_rois "${aparc}"   FS_PARDMN_L    "1010 1031"
combine_rois "${aparc}"   FS_PARDMN_R    "2010 2031"

combine_rois "${aparc}"   FS_AUD_L       "1030 1034"
combine_rois "${aparc}"   FS_AUD_R       "2030 2034"

combine_rois "${aparc}"   FS_ITEMP_L     "1006 1007 1009 1015 1016"
combine_rois "${aparc}"   FS_ITEMP_R     "2006 2007 2009 2015 2016"


# Clean up
cp "${fs_nii_thalamus_niigz}" "${rois_fs_dir}"

