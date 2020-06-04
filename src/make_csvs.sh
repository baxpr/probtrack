#!/bin/bash
#
# Whole-ROI summary of tract destinations from source ROIs. Compute the fraction 
# of seeds reaching each target, over whole source ROI. Native space only, where 
# these statistics are probably most accurate. Outputs CSV in format for REDCap.

bigtag="${1}"     # INDIV or MULTI to choose source data

# Info output
echo "Running ${0}"
echo "   Sources: ${source_regions}"
echo "   Targets: ${target_regions}"
echo "   Dir:     ${track_dir}"


# Set up output CSV
mkdir -p "${out_dir}"/STATS_"${bigtag}"
csv_file="${out_dir}"/STATS_"${bigtag}"/seed_fractions_"${bigtag}".csv
echo $(csv_line.py header) > "${csv_file}"


# Make a new csv line for every source/target pair
for source in ${source_regions} ; do
	for LR in L R ; do

		cd ${out_dir}

		# Total voxelwise streamline count and ROI voxel count
		fslmaths "${rois_fs_dir}"/FS_WM_LR -mul 0 tmp_emptymask

		addstr=""
		case ${bigtag} in
			INDIV)
				for target in ${target_regions} ; do
					addstr="${addstr} -add ${track_dir}/${source}_${LR}_to_${target}_${LR}/seeds_to_${target}_${LR}"
				done ;;
			MULTI)
				for target in ${target_regions} ; do
					addstr="${addstr} -add ${track_dir}/${source}_${LR}_to_TARGETS_${LR}/seeds_to_${target}_${LR}"
				done ;;	
			*)
				echo "Unknown bigtag ${bigtag}"
				exit 1 ;;
		esac
				
		fslmaths tmp_emptymask ${addstr} tmp_total_${source}_${LR}
		
		nvox="$(fslstats ${rois_fs_dir}/${source}_${LR} -V | awk '{print $1}')"
		
		# Per region ratios of seed counts. Build a line for the CSV file with a combo
		# of shell script and python
		for target in ${target_regions} ; do

			case ${bigtag} in
				INDIV)
					tdir="${source}_${LR}_to_${target}_${LR}" ;;
				MULTI)
					tdir="${source}_${LR}_to_TARGETS_${LR}" ;;
			esac
			
			csv_line="$(csv_line.py \
				${tdir} \
				${source}_${LR} \
				${target}_${LR} \
				${rois_fs_dir}/${source}_${LR}.nii.gz \
				${rois_fs_dir}/${target}_${LR}.nii.gz \
				${track_dir}/${tdir}/seeds_to_${target}_${LR}.nii.gz \
				${out_dir}/tmp_total_${source}_${LR}.nii.gz \
				${track_dir}/BIGGEST_${bigtag}_${source}/seg_${target}_${LR}.nii.gz \
				${track_dir}/BIGGEST_${bigtag}_${source}/seg_all_${LR}.nii.gz)"
			echo ${csv_line} >> "${csv_file}"
		done
		
		rm tmp_emptymask.nii.gz tmp_total_${source}_${LR}.nii.gz
		
	done
done
