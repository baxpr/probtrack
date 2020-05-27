# Diffusion tractography with whole-thalamus seeds

Entrypoint is `src/pipeline.sh`. Pipeline is:

- Rigid body registration of the mean b=0 image to the Freesurfer T1 (norm) image.

- Generation of lobar source/target ROIs from Freesurfer segmentation, and network ROIs from Yeo segmentation, in the diffusion image geometry.

- Probabilistic tractography with probtrackx2, from the specified source ROI to the specified target ROIs. This is done two ways: INDIV, with a separate run of probtrackx2 for each source/target pair; and MULTI, with a single run of probtrackx2 for each source to all targets. All tractography is performed in a single hemisphere. "Target", "Stop", and "Waypoint" masks are all set to the target ROI(s). The "Exclude" mask consists of white matter plus all source and target ROIs in the opposite hemisphere; plus cerebellum, brainstem, ventricles, CSF, hippocampus, amygdala, accumbens, ventral DC, caudate, putamen, and pallidum in the same hemisphere; plus any non-used target ROIs in the same hemisphere (for INDIV runs).

- Transformation of all output images to Freesurfer subject geometry using the above rigid body transform, and to MNI space using the supplied forward warp.


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
        PROBMAPS_MULTI_<source>           Fraction of streamlines to each target (proj_thresh), multi-target run
        PROBMAPS_INDIV_<source>           Same, but from combined single-target runs
        <source>_to_<target>              Tractography from source to target
        <source>_to_TARGETS_<LR>          Tractography from source to all targets (multi-target run)
        TRACKMASKS                        Masks used during tractography
        TARGETS_<LR>.txt                  List of target regions
    STATS_MULTI                       Statistics, fractional volumes for each target (multi-target run)
    STATS_INDIV                       Same, but from combined single-target runs
    COREG_MAT                         Transforms between Freesurfer and diffusion native spaces
    B0_MEAN                           Mean b=0 image from diffusion images
    NORM                              Freesurfer "norm" image (preprocessed T1)
    
