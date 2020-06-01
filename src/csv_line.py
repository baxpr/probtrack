#!/usr/local/fsl6/fslpython/envs/fslpython/bin/python
#
# Compute streamline destination fractions - helper for make_csvs.sh

import sys
import nibabel
import numpy

track_dir         = sys.argv[1]
source_name       = sys.argv[2]
target_name       = sys.argv[3]
source_niigz      = sys.argv[4]
target_niigz      = sys.argv[5]
seedtarget_niigz  = sys.argv[6]
seedall_niigz     = sys.argv[7]
segtarget_niigz   = sys.argv[8]
segall_niigz      = sys.argv[9]

source_img      = nibabel.load(source_niigz)
target_img      = nibabel.load(target_niigz)
seedtarget_img  = nibabel.load(seedtarget_niigz)
seedall_img     = nibabel.load(seedall_niigz)
segtarget_img   = nibabel.load(segtarget_niigz)
segall_img      = nibabel.load(segall_niigz)

source_data      = source_img.get_fdata()
target_data      = target_img.get_fdata()
seedtarget_data  = seedtarget_img.get_fdata()
seedall_data     = seedall_img.get_fdata()
segtarget_data   = segtarget_img.get_fdata()
segall_data      = segall_img.get_fdata()

# Verify that image geometry affines match
if numpy.any(source_img.affine != seedall_img.affine):
    raise Exception('Affine mismatch between source and seeds')

# Voxel volume
voxvol_mm3 = numpy.prod(source_img.header.get_zooms())

# Source and target region voxel indices
insource = source_data > 0
intarget = target_data > 0

# Source and target volumes, mm^3
source_vox = numpy.sum(insource)
source_mm3 = source_vox * voxvol_mm3
target_vox = numpy.sum(intarget)
target_mm3 = target_vox * voxvol_mm3

# Total and target-specific streamline counts in source region
seedtargetcount = numpy.sum(seedtarget_data[insource])
seedallcount = numpy.sum(seedall_data[insource])
seedfrac = numpy.round(seedtargetcount/seedallcount,4)

# Total and target-specific counts of voxels with assigned segmentation
segtargetcount = numpy.sum(segtarget_data[insource]>0)
segallcount = numpy.sum(segall_data[insource]>0)
segfrac = numpy.round(segtargetcount/segallcount,4)

print("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}".format(
    track_dir,
    source_name,
    source_vox,
    source_mm3,
    target_name,
    target_vox,
    target_mm3,
    seedtargetcount,
    seedallcount,
    seedfrac,
    segtargetcount,
    segallcount,
    segfrac
    ))
