function warp(fwddef_nii,src_nii,interp)

% Warp a native space image to MNI, with nearest neighbor interpolation.
% Output image w*.nii is saved in the same dir as src_nii
%   fwddef_nii    Forward deformation from CAT12
%   src_nii       Native space image (CAT12 T1 aligned)

clear matlabbatch

matlabbatch{1}.spm.util.defs.comp{1}.def = {fwddef_nii};
matlabbatch{1}.spm.util.defs.comp{2}.id.space = {which('TPM.nii')};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {src_nii};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {fileparts(src_nii)};
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = interp;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'w';

spm_jobman('run',matlabbatch)
