#!/usr/local/fsl6/fslpython/envs/fslpython/bin/python
#
# Compute streamline destination fractions - helper for make_csvs.sh

import sys
import nibabel
import numpy

source_niigz      = sys.argv[1]
seedtarget_niigz  = sys.argv[2]
seedall_niigz     = sys.argv[3]
segtarget_niigz   = sys.argv[4]
segall_niigz      = sys.argv[5]

source_img      = nibabel.load(source_niigz)
seedtarget_img  = nibabel.load(seedtarget_niigz)
seedall_img     = nibabel.load(seedall_niigz)
segtarget_img   = nibabel.load(segtarget_niigz)
segall_img      = nibabel.load(segall_niigz)

source_data      = source_img.get_fdata()
seedtarget_data  = seedtarget_img.get_fdata()
seedall_data     = seedall_img.get_fdata()
segtarget_data   = segtarget_img.get_fdata()
segall_data      = segall_img.get_fdata()

# Source region voxel indices
insource = source_data > 0

# Total and target-specific streamline counts in source region
seedallcount = numpy.sum(seedall_data[insource])
seedtargetcount = numpy.sum(seedtarget_data[insource])
seedfrac = numpy.round(seedtargetcount/seedallcount,4)

# Total and target-specific counts of voxels with assigned segmentation
segallcount = numpy.sum(segall_data[insource]>0)
segtargetcount = numpy.sum(segtarget_data[insource]>0)
segfrac = numpy.round(segtargetcount/segallcount,4)

print("{0},{1},{2},{3},{4},{5}".format(seedtargetcount,seedallcount,seedfrac,
    segtargetcount,segallcount,segfrac))

