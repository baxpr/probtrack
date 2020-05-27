Prefixes of output image files are "r" for images resampled to the Freesurfer 
T1 space (e.g. same geometry as nu, norm images), and "wr" for images resampled 
to MNI space. All resampling uses nearest neighbor interpolation.

Example for a probtracks output (PROBTRACKS resource):

fdt_paths.nii.gz       Original probtracks output in DWI space
rfdt_paths.nii.gz      Transformed to Freesurfer T1 space (nu, norm)
wrfdt_paths.nii.gz     Transformed to MNI space



Some image files have corresponding .csv files listing the labels used.

Example for a multi-target probtracks output (ROIS resource):

FS6_targetrois.nii.gz        Multi-ROI image
FS6_targetrois-label.csv     Names corresponding to each numerical label
