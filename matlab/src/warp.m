function warp(invdef_nii,src_nii)

% Warp a native space image to MNI, with nearest neighbor interpolation.
% Output image w*.nii is saved in the same dir as src_nii
%   invdef_nii    Inverse deformation from CAT12
%   src_nii       Native space image (CAT12 T1 aligned)

clear matlabbatch

matlabbatch{1}.spm.util.defs.comp{1}.def = {invdef_nii};
matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {src_nii};
matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {fileparts(src_nii)};
matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {which('TPM.nii')};
matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.push.prefix = 'w';
spm_jobman('run',matlabbatch)

if isdeployed
	exit
end
