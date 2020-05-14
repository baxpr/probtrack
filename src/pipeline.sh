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
	--probtrack_samples)
		export probtrack_samples="$2"; shift; shift ;;
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
echo "b0mean_niigz:            ${b0mean_niigz}"
echo "bedpost_dir:             ${bedpost_dir}"
echo "probtrack_samples:       ${probtrack_samples}"
echo "out_dir:                 ${out_dir}"


# Dirs in the container we need to access
export targets_dir="${src_dir}"/targets
export yeo_dir="${src_dir}"/external/yeo_networks


# ROI dirs for region masks in the two different geometries
#export rois_fs_dir=${out_dir}/ROIS_FS ; mkdir "${rois_fs_dir}"
export rois_dwi_dir=${out_dir}/ROIS_DWI ; mkdir "${rois_dwi_dir}"


### Extract region masks from FS-space DKT atlas
#make_FS_rois.sh

### Coreg FS-space T1 to DWI-space b=0
coreg_FS_to_DWI.sh

### Extract region masks from DWI-space DKT atlas after resampling
make_DWI_rois.sh


### Warp Yeo ROI images to FS space


### Extract region masks from FS-space Yeo atlases


### Resample FS-space Yeo region masks to DWI space. Be sure to apply the coreg


### Probtracks for FS6 set
#probtracks_FS6.sh

probtracks.sh "FS6" \
	"FS_THALAMUS" \
	"FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"

