#!/bin/bash
#
# find_the_biggest hard segmentation

# Supply INDIV or MULTI to use the individual probtrack results, or the single
# multi-target probtrack result, respectively
bigtag="${1}"


# Info output
echo "Running ${0} for ${bigtag}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Segmentation for all targets, for each combo of source+hemisphere. We build a
# command line (bigstr) for find_the_biggest one target region at a time, 
# then we call it.
cd "${track_dir}"
for source in ${source_regions} ; do
	mkdir "BIGGEST_${bigtag}_${source}"
	for LR in L R ; do
		bigstr=""
		for target in ${target_regions} ; do
			case ${bigtag} in
				INDIV)
					bigstr="${bigstr} ${source}_${LR}_to_${target}_${LR}/seeds_to_${target}_${LR}" ;;
				MULTI)
					bigstr="${bigstr} ${source}_${LR}_to_TARGETS_${LR}/seeds_to_${target}_${LR}" ;;
				*)
					echo "Unknown bigtag ${bigtag}"
					exit 1
					;;
			esac
		done
		find_the_biggest ${bigstr} "BIGGEST_${bigtag}_${source}"/seg_all_${LR}
	done
done

# Make separate binary ROI images for each target from the segmentation.
# Also make a text file mapping the numbers in seg_all*.nii.gz to regions.
for source in ${source_regions} ; do
	csv_file="BIGGEST_${bigtag}_${source}/seg_all-label.csv"
	let ind=0
	> "${csv_file}"
	for target in ${target_regions} ; do
		let ind+=1
		echo "${ind},${target}" >> "${csv_file}"
		for LR in L R ; do
			fslmaths \
				"BIGGEST_${bigtag}_${source}"/seg_all_${LR} \
				-thr ${ind} -uthr ${ind} -bin \
				"BIGGEST_${bigtag}_${source}/seg_${target}_${LR}"
		done
	done
done

# Combine left and right segs for each source into a single L+R image.
for source in ${source_regions} ; do
	cd "${track_dir}/BIGGEST_${bigtag}_${source}"
	fslmaths seg_all_L -add seg_all_R seg_all_LR
done

