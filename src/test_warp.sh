#!/bin/bash

export PATH=/wkdir/src:$PATH
export out_dir=/OUTPUTS
export matlab_dir=/wkdir/matlab/bin
export mcr_dir=/usr/local/MATLAB/MATLAB_Runtime/v92

warpdir.sh ${out_dir}/PROBTRACK_FS6/FS_THALAMUS_L_to_FS_PFC_L
