In general, images are in the Freesurfer T1 space (e.g. same geometry as 
nu, norm images). However, image files with a "w" prefix have been resampled 
to MNI space via trilinear or nearest neighbor interpolation.

Example for a probtracks output (PROBTRACKS resource):

fdt_paths.nii.gz       Original probtracks output in FS 1mm space
wrfdt_paths.nii.gz     Transformed to MNI space (1.5mm "TPM" geometry)



Some image files have corresponding .csv files listing the labels used.

Example for a multi-target probtracks output (ROIS resource):

FS6_targetrois.nii.gz        Multi-ROI image
FS6_targetrois-label.csv     Names corresponding to each numerical label

