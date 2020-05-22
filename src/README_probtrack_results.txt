Prefixes of output image files are "r" for images resampled to the freesurfer 
T1 space (e.g. same geometry as nu, norm images), and "wr" for images resampled 
to MNI space. All resampling uses nearest neighbor interpolation.

Example for a probtracks output:

fdt_paths.nii.gz       Original probtracks output in DWI space
rfdt_paths.nii.gz      Transformed to T1 space (nu, norm)
wrfdt_paths.nii.gz     Transformed to MNI space
