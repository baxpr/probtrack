# Diffusion tractography with whole-thalamus seeds


## Inputs

    fs_subject_dir            Freesurfer SUBJECT directory: SUBJECT resource of freesurfer_dev
    fs_nii_thalamus_niigz     Freesurfer thalamus segmentation: NII_THALAMUS resource of freesurfer_dev
    b0mean_niigz              Mean b=0 image from DWI scan: B0_MEAN resource of dwipre
    bedpost_dir               BEDPOSTX directory: BEDPOSTX resource of ybedpostx
    fwddef_niigz              Fordward deformation to MNI space: DEF_FWD resource of cat12
    invdef_niigz              Inverse deformation: DEF_INV resource of cat12
    probtrack_samples         Number of streamlines to seed per voxel
    out_dir                   Output directory

    project                   Labels for use with XNAT. Only used on the report pages.
    subject
    session

    src_dir                  (optional) Location of codebase and matlab installation in the 
    matlab_dir                  container, if a different codebase is to be used.
    mcr_dir                     Only for testing purposes.

