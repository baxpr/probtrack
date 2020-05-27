#!/bin/bash

# FSL Setup
FSLDIR=/usr/local/fsl5
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

# Freesurfer
export FREESURFER_HOME=/usr/local/freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh


#export src_dir=/repo/thaltrack-whole/src
export src_dir=/wkdir/src
export PATH=${src_dir}:$PATH


# csvs
export out_dir=/OUTPUTS
export track_dir=/OUTPUTS/PROBTRACKS
export source_regions="FS_THALAMUS"
export target_regions="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"
export rois_dwi_dir=/OUTPUTS/ROIS
export bedpost_dir=/INPUTS/BEDPOSTX
make_csvs_INDIV.sh
make_csvs_MULTI.sh

exit 0



# PDF
export project=TESTPROJ
export subject=TESTSUBJ
export session=TESTSESS
export out_dir=/OUTPUTS
export rois_dwi_dir=/OUTPUTS/ROIS_DWI
export thedate=$(date)
export matlab_dir=/wkdir/matlab/bin
export mcr_dir=/usr/local/MATLAB/MATLAB_Runtime/v92
xwrapper.sh make_pdf.sh

exit 0


# Probtrack snapshots
export dirname_tag=FS6
export track_dir=/OUTPUTS/PROBTRACK_FS6
export source_regions="FS_THALAMUS"
export target_regions="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"
export rois_dwi_dir=/OUTPUTS/ROIS_DWI
export project=TESTPROJ
export subject=TESTSUBJ
export session=TESTSESS
export out_dir=/OUTPUTS
export thedate=$(date)
xwrapper.sh probtracks_snapshots.sh


exit 0






# probmaps
export source_regions="FS_THALAMUS"
export target_regions="FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"
export track_dir=/OUTPUTS/PROBTRACK_FS6
do_probmaps.sh

exit 0


# whole pipeline
pipeline.sh \
--fs_subject_dir ${src_dir}/testdir/assessors/freesurfer/SUBJECT \
--fs_nii_thalamus_niigz ${src_dir}/testdir/assessors/freesurfer/NII_THALAMUS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz \
--b0mean_niigz ${src_dir}/testdir/assessors/dwipre/B0_MEAN/b0_mean.nii.gz \
--invdef_niigz ${src_dir}/testdir/assessors/cat12/DEF_INV/iy_t1.nii.gz \
--bedpost_dir ${src_dir}/testdir/assessors/bedpost/BEDPOSTX \
--probtrack_samples 100 \
--out_dir ${src_dir}/testdir/OUTPUTS \
--src_dir ${src_dir} \
--matlab_dir ${src_dir}/../matlab/bin_mac \
--mcr_dir 

exit 0





export out_dir=${src_dir}/testdir/OUTPUTS
export fs_subject_dir=${src_dir}/testdir/assessors/freesurfer/SUBJECT
export b0mean_niigz=${src_dir}/testdir/assessors/dwipre/B0_MEAN/b0_mean.nii.gz
export rois_fs_dir=${src_dir}/testdir/OUTPUTS/ROIS_FS
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export yeo_dir=${src_dir}/external/yeo_networks
export invdef_niigz=${src_dir}/testdir/assessors/cat12/DEF_INV/iy_t1.nii.gz
export fs_nii_thalamus_niigz=${src_dir}/testdir/assessors/freesurfer/NII_THALAMUS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz
export probtrack_samples=100
export bedpost_dir=${src_dir}/testdir/assessors/bedpost/BEDPOSTX





# One probtracks
probtracks.sh "Yeo7" \
"FS_THALAMUS" \
"Yeo7_N1 Yeo7_N2 Yeo7_N3 Yeo7_N4 Yeo7_N5 Yeo7_N6 Yeo7_N7"

exit 0


# Just through ROIs
mkdir "${rois_fs_dir}"
mkdir "${rois_dwi_dir}"
#coreg_FS_to_DWI.sh
#make_FS_rois.sh
make_Yeo_rois.sh

exit 0



# All probtracks
probtracks.sh "FS6" \
"FS_THALAMUS" \
"FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"

probtracks.sh "FS10" \
"FS_THALAMUS" \
"FS_MOFC FS_LPFC FS_ACC FS_PPC FS_PARDMN FS_AUD FS_ITEMP FS_MOTOR FS_SOMATO FS_OCC"

probtracks.sh "Yeo7" \
"FS_THALAMUS" \
"Yeo7_N1 Yeo7_N2 Yeo7_N3 Yeo7_N4 Yeo7_N5 Yeo7_N6 Yeo7_N7"

probtracks.sh "Yeo17" \
"FS_THALAMUS" \
"Yeo17_N01 Yeo17_N02 Yeo17_N03 Yeo17_N04 Yeo17_N05 Yeo17_N06 Yeo17_N07 Yeo17_N08 Yeo17_N09 \
Yeo17_N10 Yeo17_N11 Yeo17_N12 Yeo17_N13 Yeo17_N14 Yeo17_N15 Yeo17_N16 Yeo17_N17"

exit 0


