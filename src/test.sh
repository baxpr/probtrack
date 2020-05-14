#!/bin/bash

# FSL Setup
FSLDIR=/usr/local/fsl5
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

# Freesurfer
export FREESURFER_HOME=/usr/local/freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh


src_dir=/repo/thaltrack-whole/src
export PATH=${src_dir}:$PATH



# probtracks loops
export probtrack_samples=100
export bedpost_dir=${src_dir}/testdir/assessors/bedpost/BEDPOSTX
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export out_dir=${src_dir}/testdir/OUTPUTS
probtracks.sh "FStest" \
	"FS_THALAMUS FS_AMYG_HIPP" \
	"FS_PFC FS_MOTOR FS_SOMATO FS_POSTPAR FS_OCC FS_TEMP"


exit 0


# whole pipeline
pipeline.sh \
--fs_subject_dir ${src_dir}/testdir/assessors/freesurfer/SUBJECT \
--fs_nii_thalamus_niigz ${src_dir}/testdir/assessors/freesurfer/NII_THALAMUS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz \
--b0mean_niigz ${src_dir}/testdir/assessors/dwipre/B0_MEAN/b0_mean.nii.gz \
--bedpost_dir ${src_dir}/testdir/assessors/bedpost/BEDPOSTX \
--probtrack_samples 100 \
--out_dir ${src_dir}/testdir/OUTPUTS

exit 0


# probtracks
export probtrack_samples=100
export bedpost_dir=${src_dir}/testdir/assessors/bedpost/BEDPOSTX
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export out_dir=${src_dir}/testdir/OUTPUTS
export targets_dir=${src_dir}/targets
probtracks_FS6.sh

exit 0


# targets probtrack
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export bedpost_dir=${src_dir}/testdir/assessors/bedpost/BEDPOSTX
export targets_dir=${src_dir}/targets
export track_dir=${src_dir}/testdir/OUTPUTS/PROBTRACK_FS6
trackopts="-l --onewaycondition --verbose=0 --forcedir --modeuler --pd --os2t --s2tastext --opd --ompl"
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

exit 0



# dwi rois
export rois_dwi_dir=${src_dir}/testdir/OUTPUTS/ROIS_DWI
export fs_subject_dir=${src_dir}/testdir/assessors/freesurfer/SUBJECT
export out_dir=${src_dir}/testdir/OUTPUTS
export fs_nii_thalamus_niigz=${src_dir}/testdir/assessors/freesurfer/NII_THALAMUS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz
make_DWI_rois.sh

exit 0




# coreg
export out_dir=${src_dir}/testdir/OUTPUTS
export fs_subject_dir=${src_dir}/testdir/assessors/freesurfer/SUBJECT
export b0mean_niigz=${src_dir}/testdir/assessors/dwipre/B0_MEAN/b0_mean.nii.gz
export rois_fs_dir=${src_dir}/testdir/OUTPUTS/ROIS_FS
coreg_t1_to_dwi.sh


exit 0

