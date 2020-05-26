#!/usr/local/fsl6/fslpython/envs/fslpython/bin/python
#
# Compute streamline destination fractions - helper for make_csvs.sh

import sys
import nibabel
import numpy

total_niigz = "seedtotal.nii.gz"
seed_niigz = sys.argv[1]

total = nibabel.load(total_niigz)
seed = nibabel.load(seed_niigz)

totalcount = numpy.sum(total.get_fdata())
seedcount = numpy.sum(seed.get_fdata())

print("{0},{1},{2}".format(seedcount,totalcount,numpy.round(seedcount/totalcount,4)))
