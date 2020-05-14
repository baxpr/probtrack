function unwarp(invdef_nii,nu_nii,mniimg_nii,out_dir)

% Unwarp an MNI space ROI image to a subject's native space, with nearest
% neighbor interpolation. Input images must be unzipped .nii and already 
% copied to out_dir. Pass bare filenames (no prepended path).
%   invdef_nii    Inverse deformation from CAT12
%   nu_nii        nu image from Freesurfer (subject space)
%   mniimg_nii    ROI image in MNI space
%   out_dir       Location of files

clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.def = {fullfile(out_dir,invdef_nii)};
matlabbatch{1}.spm.util.defs.comp{2}.id.space = {fullfile(out_dir,nu_nii)};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {fullfile(out_dir,mniimg_nii)};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {out_dir};
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'u';
spm_jobman('run',matlabbatch)

if is_deployed
	exit
end
