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
export probtrack_options="--loopcheck --onewaycondition --verbose=0 --modeuler --pd"
export dirname_tag="FS6"
export source_regions="FS_THALAMUS"
export target_regions="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"

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
		--probtrack_options)
			export probtrack_options="$2"; shift; shift ;;
		--dirname_tag)
			export dirname_tag="$2"; shift; shift ;;
		--source_regions)
			export source_regions="$2"; shift; shift ;;
		--target_regions)
			export target_regions="$2"; shift; shift ;;
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


# Date stamp
export thedate=$(date)


# Inputs report
echo "${project} ${subject} ${session}"
echo ${thedate}
echo "fs_subject_dir:          ${fs_subject_dir}"
echo "fs_nii_thalamus_niigz:   ${fs_nii_thalamus_niigz}"
echo "b0mean_niigz:            ${b0mean_niigz}"
echo "bedpost_dir:             ${bedpost_dir}"
echo "fwddef_niigz:            ${fwddef_niigz}"
echo "invdef_niigz:            ${invdef_niigz}"
echo "dirname_tag:             ${dirname_tag}"
echo "source_regions:          ${source_regions}"
echo "target_regions:          ${target_regions}"
echo "probtrack_samples:       ${probtrack_samples}"
echo "probtrack_options:       ${probtrack_options}"
echo "out_dir:                 ${out_dir}"


# Dirs in the container we need to access
export yeo_dir="${src_dir}"/external/yeo_networks


# Set up Freesurfer
source ${FREESURFER_HOME}/SetUpFreeSurfer.sh


# ROI dirs for region masks in the two different geometries
export rois_fs_dir=${out_dir}/ROIS_FS ; mkdir "${rois_fs_dir}"
export rois_dwi_dir=${out_dir}/ROIS ; mkdir "${rois_dwi_dir}"


# Prep the deformation images for SPM
cp "${fwddef_niigz}" "${out_dir}"/y_fwddef.nii.gz
cp "${invdef_niigz}" "${out_dir}"/iy_invdef.nii.gz
gunzip -f "${out_dir}"/y_fwddef.nii.gz
gunzip -f "${out_dir}"/iy_invdef.nii.gz


### Coreg FS-space T1 to DWI-space b=0
coreg_FS_to_DWI.sh


### Make DWI native space region masks from freesurfer and Yeo segmentations
make_FS_rois.sh
make_Yeo_rois.sh


### Probtracks for the requested ROI set
probtracks.sh


### Transform all the DWI space ROIs we used to FS and MNI geometry
warpdir.sh "${rois_dwi_dir}"


### PDF
make_pdf.sh


### Organize outputs for XNAT
organize_outputs.sh

