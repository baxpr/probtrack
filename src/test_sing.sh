#!/bin/bash

singularity run \
	--cleanenv \
	--home $(pwd) \
	--bind $(pwd)/INPUTS:/INPUTS \
	--bind $(pwd)/OUTPUTS:/OUTPUTS \
	--bind $(pwd)/freesurfer_license.txt:/usr/local/freesurfer/.license \
	baxpr-thaltrack-whole-master-v2.0.0.simg \
	--fs_subject_dir /INPUTS/SUBJECT \
	--fs_nii_thalamus_niigz /INPUTS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz \
	--b0mean_niigz /INPUTS/b0_mean.nii.gz \
	--invdef_niigz /INPUTS/iy_t1.nii.gz \
	--fwddef_niigz /INPUTS/y_t1.nii.gz \
	--bedpost_dir /INPUTS/BEDPOSTX \
	--probtrack_samples 100 \
	--project TESTPROJ \
	--subject TESTSUBJ \
	--session TESTSESS \
	--out_dir /OUTPUTS
