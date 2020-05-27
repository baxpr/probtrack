# Diffusion tractography with whole-thalamus seeds


## Inputs

    fs_subject_dir            Freesurfer SUBJECT directory:       SUBJECT resource of freesurfer_dev
    fs_nii_thalamus_niigz     Freesurfer thalamus segmentation:   NII_THALAMUS resource of freesurfer_dev
    b0mean_niigz              Mean b=0 image from DWI scan:       B0_MEAN resource of dwipre
    bedpost_dir               BEDPOSTX directory:                 BEDPOSTX resource of ybedpostx
    fwddef_niigz              Fordward deformation to MNI space:  DEF_FWD resource of cat12
    invdef_niigz              Inverse deformation:                DEF_INV resource of cat12
    probtrack_samples         Number of streamlines to seed per voxel
    probtrack_options         Any desired of --loopcheck --onewaycondition --verbose=0 --modeuler --pd

    project                   Labels for use with XNAT. Only used on the report pages.
    subject
    session

    out_dir                   Output directory in the container (defaults to /OUTPUTS)

    src_dir                   (optional) Location of codebase and matlab installation in the 
    matlab_dir                    container, if a different codebase is to be used. Only used
    mcr_dir                       for testing purposes.



## Outputs

    PDF
	ROIS
	PROBTRACKS
	    BIGGEST_MULTI_<source>
	    BIGGEST_INDIV_<source>
		PROBMAPS_MULTI_<source>
		PROBMAPS_INDIV_<source>
		<source>_to_<target>
		<source>_to_TARGETS_<LR>
		TRACKMASKS
		TARGETS_<LR>.txt
	COREG_MAT
	B0_MEAN
	NORM
	
