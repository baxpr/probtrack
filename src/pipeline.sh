#!/bin/bash
#
# Main pipeline

echo Running ${0}

# Initialize defaults (will be changed later if passed as options)
export project=NO_PROJ
export subject=NO_SUBJ
export session=NO_SESS
#export src_dir=/opt/thaltrack-whole/src
export src_dir=/repo/thaltrack-whole/src

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
    --out_dir)
        export out_dir="$2"; shift; shift ;;
    --src_dir)
        export src_dir="$2"; shift; shift ;;
    *)
        shift ;;
  esac
done


# Inputs report
echo "${project} ${subject} ${session}"
echo "fs_subject_dir:          ${fs_subject_dir}"
echo "fs_nii_thalamus_niigz:   ${fs_nii_thalamus_niigz}"
echo "bedpost_dir:             ${bedpost_dir}"
echo "out_dir:                 ${out_dir}"


# Dirs in the container we need to access
export targets_dir="${src_dir}"/targets
export yeo_dir="${src_dir}"/external/yeo_networks


# Output dirs
# ROIS_FS, ROIS_DWI for region masks in the two different geometries
# OUTPUT_FS6, OUTPUT_FS10, OUTPUT_YEO7, OUTPUT_YEO17 for the different ROI tracksets
export rois_fs_dir=${out_dir}/ROIS_FS ; mkdir "${rois_fs_dir}"
export rois_dwi_dir=${out_dir}/ROIS_DWI ; mkdir "${rois_dwi_dir}"
mkdir "${out_dir}"/OUTPUT_FS6
mkdir "${out_dir}"/OUTPUT_FS10
mkdir "${out_dir}"/OUTPUT_YEO7
mkdir "${out_dir}"/OUTPUT_YEO17

### Extract region masks from FS-space DKT atlas
make_fs_rois.sh

### Coreg FS-space T1 to DWI-space b=0
coreg_t1_to_dwi.sh

### Extract region masks from DWI-space DKT atlas after resampling
make_dwi_rois.sh


### Warp Yeo ROI images to FS space


### Extract region masks from FS-space Yeo atlases


### Resample FS-space Yeo region masks to DWI space. Be sure to apply the coreg


### Probtracks for FS6 set
probtracks_FS6.sh


