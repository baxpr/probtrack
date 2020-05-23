#!/bin/bash
#
# Main pipeline

echo Running ${0}

# Initialize defaults (will be changed later if passed as options)
export project=NO_PROJ
export subject=NO_SUBJ
export session=NO_SESS
export src_dir=/opt/thaltrack-whole/src
export matlab_dir=/opt/thaltrack-whole/matlab/bin
export mcr_dir=/usr/local/MATLAB/MATLAB_Runtime/v92
export probtrack_samples=5000

# Parse options
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		--project)
			export project="$2"; shift; shift ;;
		--subject)
			export subject="$2"; shift; shift ;;
		--session)
			export session="$2"; shift; shift ;;
		--fs_subject_dir)
			export fs_subject_dir="$2"; shift; shift ;;
		--fs_nii_thalamus_niigz)
			export fs_nii_thalamus_niigz="$2"; shift; shift ;;
		--b0mean_niigz)
			export b0mean_niigz="$2"; shift; shift ;;
		--bedpost_dir)
			export bedpost_dir="$2"; shift; shift ;;
		--fwddef_niigz)
			export fwddef_niigz="$2"; shift; shift ;;
		--invdef_niigz)
			export invdef_niigz="$2"; shift; shift ;;
		--probtrack_samples)
			export probtrack_samples="$2"; shift; shift ;;
		--out_dir)
			export out_dir="$2"; shift; shift ;;
		--src_dir)
			export src_dir="$2"; shift; shift ;;
		--matlab_dir)
			export matlab_dir="$2"; shift; shift ;;
		--mcr_dir)
			export mcr_dir="$2"; shift; shift ;;
		*)
			echo Unknown input "${1}"; shift ;;
	esac
done


# Inputs report
echo "${project} ${subject} ${session}"
echo "fs_subject_dir:          ${fs_subject_dir}"
echo "fs_nii_thalamus_niigz:   ${fs_nii_thalamus_niigz}"
echo "b0mean_niigz:            ${b0mean_niigz}"
echo "bedpost_dir:             ${bedpost_dir}"
echo "fwddef_niigz:            ${fwddef_niigz}"
echo "invdef_niigz:            ${invdef_niigz}"
echo "probtrack_samples:       ${probtrack_samples}"
echo "out_dir:                 ${out_dir}"


# Dirs in the container we need to access
export yeo_dir="${src_dir}"/external/yeo_networks


# Set up Freesurfer
source ${FREESURFER_HOME}/SetUpFreeSurfer.sh


# ROI dirs for region masks in the two different geometries
export rois_fs_dir=${out_dir}/ROIS_FS ; mkdir "${rois_fs_dir}"
export rois_dwi_dir=${out_dir}/ROIS_DWI ; mkdir "${rois_dwi_dir}"


# Prep the deformation images for SPM
cp "${fwddef_niigz}" "${out_dir}"/y_fwddef.nii.gz
cp "${invdef_niigz}" "${out_dir}"/iy_invdef.nii.gz
gunzip -f "${out_dir}"/y_fwddef.nii.gz
gunzip -f "${out_dir}"/iy_invdef.nii.gz


### Coreg FS-space T1 to DWI-space b=0
coreg_FS_to_DWI.sh


### Extract region masks from DWI-space DKT atlas after resampling
make_FS_rois.sh


### Warp Yeo ROI images to DWI space and extract individual ROIs
make_Yeo_rois.sh


### Probtracks for various ROI sets
probtracks.sh "FS6" \
"FS_THALAMUS" \
"FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"

#probtracks.sh "FS10" \
#"FS_THALAMUS" \
#"FS_MOFC FS_LPFC FS_ACC FS_PPC FS_PARDMN FS_AUD FS_ITEMP FS_MOTOR FS_SOMATO FS_OCC"

probtracks.sh "Yeo7" \
"FS_THALAMUS" \
"Yeo7_N1 Yeo7_N2 Yeo7_N3 Yeo7_N4 Yeo7_N5 Yeo7_N6 Yeo7_N7"

#probtracks.sh "Yeo17" \
#"FS_THALAMUS" \
#"Yeo17_N01 Yeo17_N02 Yeo17_N03 Yeo17_N04 Yeo17_N05 Yeo17_N06 Yeo17_N07 Yeo17_N08 Yeo17_N09 \
#Yeo17_N10 Yeo17_N11 Yeo17_N12 Yeo17_N13 Yeo17_N14 Yeo17_N15 Yeo17_N16 Yeo17_N17"


### Transform all the DWI space ROIs we used to FS and MNI geometry
warp.sh "${rois_dwi_dir}"


### PDF
make_pdf.sh

