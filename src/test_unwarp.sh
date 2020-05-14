#!/bin/bash

out_dir=/wkdir/src/testdir/OUTPUTS

/wkdir/matlab/bin/run_spm12.sh /usr/local/MATLAB/MATLAB_Runtime/v92 function unwarp iy_invdef.nii nu.nii Yeo7_split.nii "${out_dir}"
/wkdir/matlab/bin/run_spm12.sh /usr/local/MATLAB/MATLAB_Runtime/v92 function unwarp iy_invdef.nii nu.nii Yeo17_split.nii "${out_dir}"

