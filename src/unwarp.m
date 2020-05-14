function unwarp(invdef_niigz,nu_niigz,mniimg_niigz,out_dir)

% Unwarp an MNI space ROI image to a subject's native space, with nearest
% neighbor interpolation.
%   invdef_niigz    Inverse deformation from CAT12
%   nu_niigz        nu image from Freesurfer (subject space)
%   mniimg_niigz    ROI image in MNI space
%   out_dir         Location of files

system(['gunzip -k ' invdef_niigz]);
invdef_nii = invdef_niigz(1:end-3);

system(['gunzip -k ' nu_niigz]);
nu_nii = nu_niigz(1:end-3);

copyfile(mniimg_niigz,out_dir);
[~,n,e] = fileparts(mniimg_niigz);
system(['gunzip -k ' fullfile(out_dir,[n e])])
mniimg_nii = fullfile(out_dir,n);

clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.def = {invdef_nii};
matlabbatch{1}.spm.util.defs.comp{2}.id.space = {nu_nii};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {mniimg_nii};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {out_dir};
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'u';
spm_jobman('run',matlabbatch)
