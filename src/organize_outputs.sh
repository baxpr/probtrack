#!/bin/bash
#
# Organize outputs for XNAT

COREG_MAT
	DWI_to_FS.mat
	FS_to_DWI.mat

PROBTRACK
	PROBTRACK_*

ROIS

ROIS_FS

b0_mean_to_FS.nii.gz ?  (we have it below)
b0_mean_to_FS_fast_wmedge.nii.gz ?
b0_mean_to_FS_init.mat ?


norm_to_DWI.nii.gz ? (make norm/rnorm/wrnorm set if we will keep)


B0_MEAN
	makepdf/coreg_imgs/b0_mean.nii.gz
	makepdf/coreg_imgs/rb0_mean.nii.gz
	makepdf/coreg_imgs/wrb0_mean.nii.gz

