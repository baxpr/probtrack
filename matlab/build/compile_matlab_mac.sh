#!/bin/sh
#
# Compile the matlab code for Mac

SPM_PATH=/repo/thaltrack-whole/matlab/spm12_r7487

export PATH=/Applications/MATLAB_R2019a.app/bin:${PATH}

WD=`pwd`
matlab -nodisplay -nodesktop -nosplash -sd "${WD}" -r \
    "spm_make_standalone_local('${SPM_PATH}','${WD}/../bin_mac','${WD}/../src'); exit"

chmod go+rx "${WD}"/../bin_mac/spm12
chmod go+rx "${WD}"/../bin_mac/run_spm12.sh

