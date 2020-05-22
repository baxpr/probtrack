#!/bin/bash

export PATH=/wkdir/src:$PATH
export out_dir=/wkdir/OUTPUTS
export matlab_dir=/wkdir/matlab/bin
export mcr_dir=/usr/local/MATLAB/MATLAB_Runtime/v92

warp.sh ${out_dir}/PROBTRACK_FS6/FS_THALAMUS_L_to_FS_MOTOR_L
