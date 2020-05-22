#!/bin/bash
#
# Warp MNI space Yeo network maps to subject FS geometry, then apply coreg
# and resample to DWI geometry

echo Running ${0}

# Set up
source functions.sh
cd "${rois_dwi_dir}"


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

# Resample Yeo FS-space ROI images to DWI space (transform obtained from coreg_FS_to_DWI.sh)
# Force to short datatype to avoid rounding error that affects later -thr and -uthr
flirtopts="-applyxfm -init ${out_dir}/FS_to_DWI.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/b0_mean.nii.gz"
flirt ${flirtopts} \
	-in "${rois_fs_dir}"/uYeo7_split \
	-datatype short \
	-out uYeo7_split_to_DWI
flirt ${flirtopts} \
	-in "${rois_fs_dir}"/uYeo17_split \
	-datatype short \
	-out uYeo17_split_to_DWI


# Re-combine into the needed single-ROI masks, files labeled by ROI name
yeo7=uYeo7_split_to_DWI

combine_rois "${yeo7}"   Yeo7_N1_L      "101"
combine_rois "${yeo7}"   Yeo7_N2_L      "102"
combine_rois "${yeo7}"   Yeo7_N3_L      "103"
combine_rois "${yeo7}"   Yeo7_N4_L      "104"
combine_rois "${yeo7}"   Yeo7_N5_L      "105"
combine_rois "${yeo7}"   Yeo7_N6_L      "106"
combine_rois "${yeo7}"   Yeo7_N7_L      "107"

combine_rois "${yeo7}"   Yeo7_N1_R      "201"
combine_rois "${yeo7}"   Yeo7_N2_R      "202"
combine_rois "${yeo7}"   Yeo7_N3_R      "203"
combine_rois "${yeo7}"   Yeo7_N4_R      "204"
combine_rois "${yeo7}"   Yeo7_N5_R      "205"
combine_rois "${yeo7}"   Yeo7_N6_R      "206"
combine_rois "${yeo7}"   Yeo7_N7_R      "207"


yeo17=uYeo17_split_to_DWI

combine_rois "${yeo17}"   Yeo17_N01_L     "101"
combine_rois "${yeo17}"   Yeo17_N02_L     "102"
combine_rois "${yeo17}"   Yeo17_N03_L     "103"
combine_rois "${yeo17}"   Yeo17_N04_L     "104"
combine_rois "${yeo17}"   Yeo17_N05_L     "105"
combine_rois "${yeo17}"   Yeo17_N06_L     "106"
combine_rois "${yeo17}"   Yeo17_N07_L     "107"
combine_rois "${yeo17}"   Yeo17_N08_L     "108"
combine_rois "${yeo17}"   Yeo17_N09_L     "109"
combine_rois "${yeo17}"   Yeo17_N10_L     "110"
combine_rois "${yeo17}"   Yeo17_N11_L     "111"
combine_rois "${yeo17}"   Yeo17_N12_L     "112"
combine_rois "${yeo17}"   Yeo17_N13_L     "113"
combine_rois "${yeo17}"   Yeo17_N14_L     "114"
combine_rois "${yeo17}"   Yeo17_N15_L     "115"
combine_rois "${yeo17}"   Yeo17_N16_L     "116"
combine_rois "${yeo17}"   Yeo17_N17_L     "117"

combine_rois "${yeo17}"   Yeo17_N01_R     "201"
combine_rois "${yeo17}"   Yeo17_N02_R     "202"
combine_rois "${yeo17}"   Yeo17_N03_R     "203"
combine_rois "${yeo17}"   Yeo17_N04_R     "204"
combine_rois "${yeo17}"   Yeo17_N05_R     "205"
combine_rois "${yeo17}"   Yeo17_N06_R     "206"
combine_rois "${yeo17}"   Yeo17_N07_R     "207"
combine_rois "${yeo17}"   Yeo17_N08_R     "208"
combine_rois "${yeo17}"   Yeo17_N09_R     "209"
combine_rois "${yeo17}"   Yeo17_N10_R     "210"
combine_rois "${yeo17}"   Yeo17_N11_R     "211"
combine_rois "${yeo17}"   Yeo17_N12_R     "212"
combine_rois "${yeo17}"   Yeo17_N13_R     "213"
combine_rois "${yeo17}"   Yeo17_N14_R     "214"
combine_rois "${yeo17}"   Yeo17_N15_R     "215"
combine_rois "${yeo17}"   Yeo17_N16_R     "216"
combine_rois "${yeo17}"   Yeo17_N17_R     "217"


# Whole brain gray matter mask. Note that Yeo7 and Yeo17 cover the same voxels
fslmaths uYeo7_split_to_DWI -bin Yeo_CORTEX


# Add white matter, subcortical to gray matter to make large avoid masks
# Pull in the white matter, cerebellum, subcortical regions from make_FS_rois.sh 
# because Yeo does not provide these 
fslmaths Yeo_CORTEX -add FS_WM_R -add FS_CEREBELLAR_SUBCORTICAL -bin Yeo7_RH_LHCORTEX_AVOID
fslmaths Yeo_CORTEX -add FS_WM_L -add FS_CEREBELLAR_SUBCORTICAL -bin Yeo7_LH_RHCORTEX_AVOID
cp Yeo7_RH_LHCORTEX_AVOID.nii.gz Yeo17_RH_LHCORTEX_AVOID.nii.gz
cp Yeo7_LH_RHCORTEX_AVOID.nii.gz Yeo17_LH_RHCORTEX_AVOID.nii.gz


# Avoid masks for all Yeo seed regions
for region in \
  Yeo7_N1 Yeo7_N2 Yeo7_N3 Yeo7_N4 Yeo7_N5 Yeo7_N6 Yeo7_N7 \
; do
	fslmaths Yeo7_RH_LHCORTEX_AVOID -sub ${region}_L -thr 1 -bin ${region}_L_AVOID
	fslmaths Yeo7_LH_RHCORTEX_AVOID -sub ${region}_R -thr 1 -bin ${region}_R_AVOID
done

for region in \
  Yeo17_N01 Yeo17_N02 Yeo17_N03 Yeo17_N04 Yeo17_N05 Yeo17_N06 \
  Yeo17_N07 Yeo17_N08 Yeo17_N09 Yeo17_N10 Yeo17_N11 Yeo17_N12 \
  Yeo17_N13 Yeo17_N14 Yeo17_N15 Yeo17_N16 Yeo17_N17 \
; do
	fslmaths Yeo17_RH_LHCORTEX_AVOID -sub ${region}_L -thr 1 -bin ${region}_L_AVOID
	fslmaths Yeo17_LH_RHCORTEX_AVOID -sub ${region}_R -thr 1 -bin ${region}_R_AVOID
done



  
# Stop and avoid masks for hemispheres
for LR in L R ; do

	fslmaths \
			 Yeo7_N1_${LR} \
		-add Yeo7_N2_${LR} \
		-add Yeo7_N3_${LR} \
		-add Yeo7_N4_${LR} \
		-add Yeo7_N5_${LR} \
		-add Yeo7_N6_${LR} \
		-add Yeo7_N7_${LR} \
		-bin Yeo7_${LR}HCORTEX_STOP

	fslmaths \
			 Yeo7_${LR}HCORTEX_STOP \
		-add FS_WM_${LR} \
		-add FS_THALAMUS_${LR} \
		-bin Yeo7_${LR}H_AVOID

done


for LR in L R ; do

	fslmaths \
			 Yeo17_N01_${LR} \
		-add Yeo17_N02_${LR} \
		-add Yeo17_N03_${LR} \
		-add Yeo17_N04_${LR} \
		-add Yeo17_N05_${LR} \
		-add Yeo17_N06_${LR} \
		-add Yeo17_N07_${LR} \
		-add Yeo17_N08_${LR} \
		-add Yeo17_N09_${LR} \
		-add Yeo17_N10_${LR} \
		-add Yeo17_N11_${LR} \
		-add Yeo17_N12_${LR} \
		-add Yeo17_N13_${LR} \
		-add Yeo17_N14_${LR} \
		-add Yeo17_N15_${LR} \
		-add Yeo17_N16_${LR} \
		-add Yeo17_N17_${LR} \
		-bin Yeo17_${LR}HCORTEX_STOP

	fslmaths \
			 Yeo17_${LR}HCORTEX_STOP \
		-add FS_WM_${LR} \
		-add FS_THALAMUS_${LR} \
		-bin Yeo17_${LR}H_AVOID

done
