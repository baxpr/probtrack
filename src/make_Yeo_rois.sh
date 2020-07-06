#!/bin/bash
#
# Warp MNI space Yeo network maps to subject FS geometry

echo Running ${0}

# Set up
source functions.sh
cd "${rois_fs_dir}"


# Copy Yeo network templates to working directory and unzip
cp "${yeo_dir}"/Yeo{7,17}_split.nii.gz "${out_dir}"
gunzip -f "${out_dir}"/Yeo{7,17}_split.nii.gz


# Make unzipped copy of nu for SPM
gunzip -fk "${out_dir}"/nu.nii.gz


# Call the compiled matlab unwarping function, zip the results,
# move to ROI dir
"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function unwarp iy_invdef.nii nu.nii Yeo7_split.nii "${out_dir}"
"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function unwarp iy_invdef.nii nu.nii Yeo17_split.nii "${out_dir}"
gzip "${out_dir}"/uYeo{7,17}_split.nii
mv "${out_dir}"/uYeo{7,17}_split.nii.gz "${rois_fs_dir}"


# Re-combine into the needed single-ROI masks, files labeled by ROI name
yeo7=uYeo7_split

combine_rois_approx "${yeo7}"   Yeo7_N1_L      "101"
combine_rois_approx "${yeo7}"   Yeo7_N2_L      "102"
combine_rois_approx "${yeo7}"   Yeo7_N3_L      "103"
combine_rois_approx "${yeo7}"   Yeo7_N4_L      "104"
combine_rois_approx "${yeo7}"   Yeo7_N5_L      "105"
combine_rois_approx "${yeo7}"   Yeo7_N6_L      "106"
combine_rois_approx "${yeo7}"   Yeo7_N7_L      "107"

combine_rois_approx "${yeo7}"   Yeo7_N1_R      "201"
combine_rois_approx "${yeo7}"   Yeo7_N2_R      "202"
combine_rois_approx "${yeo7}"   Yeo7_N3_R      "203"
combine_rois_approx "${yeo7}"   Yeo7_N4_R      "204"
combine_rois_approx "${yeo7}"   Yeo7_N5_R      "205"
combine_rois_approx "${yeo7}"   Yeo7_N6_R      "206"
combine_rois_approx "${yeo7}"   Yeo7_N7_R      "207"


yeo17=uYeo17_split

combine_rois_approx "${yeo17}"   Yeo17_N01_L     "101"
combine_rois_approx "${yeo17}"   Yeo17_N02_L     "102"
combine_rois_approx "${yeo17}"   Yeo17_N03_L     "103"
combine_rois_approx "${yeo17}"   Yeo17_N04_L     "104"
combine_rois_approx "${yeo17}"   Yeo17_N05_L     "105"
combine_rois_approx "${yeo17}"   Yeo17_N06_L     "106"
combine_rois_approx "${yeo17}"   Yeo17_N07_L     "107"
combine_rois_approx "${yeo17}"   Yeo17_N08_L     "108"
combine_rois_approx "${yeo17}"   Yeo17_N09_L     "109"
combine_rois_approx "${yeo17}"   Yeo17_N10_L     "110"
combine_rois_approx "${yeo17}"   Yeo17_N11_L     "111"
combine_rois_approx "${yeo17}"   Yeo17_N12_L     "112"
combine_rois_approx "${yeo17}"   Yeo17_N13_L     "113"
combine_rois_approx "${yeo17}"   Yeo17_N14_L     "114"
combine_rois_approx "${yeo17}"   Yeo17_N15_L     "115"
combine_rois_approx "${yeo17}"   Yeo17_N16_L     "116"
combine_rois_approx "${yeo17}"   Yeo17_N17_L     "117"

combine_rois_approx "${yeo17}"   Yeo17_N01_R     "201"
combine_rois_approx "${yeo17}"   Yeo17_N02_R     "202"
combine_rois_approx "${yeo17}"   Yeo17_N03_R     "203"
combine_rois_approx "${yeo17}"   Yeo17_N04_R     "204"
combine_rois_approx "${yeo17}"   Yeo17_N05_R     "205"
combine_rois_approx "${yeo17}"   Yeo17_N06_R     "206"
combine_rois_approx "${yeo17}"   Yeo17_N07_R     "207"
combine_rois_approx "${yeo17}"   Yeo17_N08_R     "208"
combine_rois_approx "${yeo17}"   Yeo17_N09_R     "209"
combine_rois_approx "${yeo17}"   Yeo17_N10_R     "210"
combine_rois_approx "${yeo17}"   Yeo17_N11_R     "211"
combine_rois_approx "${yeo17}"   Yeo17_N12_R     "212"
combine_rois_approx "${yeo17}"   Yeo17_N13_R     "213"
combine_rois_approx "${yeo17}"   Yeo17_N14_R     "214"
combine_rois_approx "${yeo17}"   Yeo17_N15_R     "215"
combine_rois_approx "${yeo17}"   Yeo17_N16_R     "216"
combine_rois_approx "${yeo17}"   Yeo17_N17_R     "217"

