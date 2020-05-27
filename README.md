# Diffusion tractography with whole-thalamus seeds

Entrypoint is `src/pipeline.sh`. Pipeline is:

- Generate lobar source/target ROIs from Freesurfer segmentation, and network ROIs from Yeo segmentation.

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

    PDF                               Summary and QA reference
	ROIS                              Regions of interest from Freesurfer and Yeo segmentations
	PROBTRACKS                        Tractography results
	    BIGGEST_MULTI_<source>            Segmentation from find_the_biggest, multi-target run
	    BIGGEST_INDIV_<source>            Same, but from combined single-target runs
		PROBMAPS_MULTI_<source>           Voxlewise fraction of streamlines to each target, multi-target run
		PROBMAPS_INDIV_<source>           Same, but from combined single-target runs
		<source>_to_<target>              Tractography from source to target
		<source>_to_TARGETS_<LR>          Tractography from source to all targets (multi-target run)
		TRACKMASKS                        Masks used during tractography
		TARGETS_<LR>.txt                  List of target regions
	STATS_MULTI                           Statistics, fractional volumes for each target (multi-target run)
	STATS_INDIV                           Same, but from combined single-target runs
	COREG_MAT                             Transforms between Freesurfer and diffusion native spaces
	B0_MEAN                               Mean b=0 image from diffusion images
	NORM                                  Freesurfer "norm" image (preprocessed T1)
	
