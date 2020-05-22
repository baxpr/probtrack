#!/bin/bash

export PATH=/wkdir/src:$PATH
export out_dir=/wkdir/src/testdir/OUTPUTS
export matlab_dir=/wkdir/matlab/bin
export mcr_dir=/usr/local/MATLAB/MATLAB_Runtime/v92
export fwddef_niigz=/INPUTS/y_t1.nii.gz

warp.sh ${out_dir}/PROBTRACK_FS6/FS_THALAMUS_L_to_FS_MOTOR_L
