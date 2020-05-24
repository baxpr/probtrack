#!/bin/bash
#
# Snapshots for a specific tract set

wkdir="${out_dir}"/makepdf
mkdir -p "${wkdir}"
cd "${wkdir}"


# Make PDF page for the "biggest" segmentation, multi-target
deltas="-18 -15 -12 -9 -6 -3 +0 +3 +6 +9 +12 +15 +18"
#deltas="-15 -9 -3 +3 +9 +15"
for source in ${source_regions} ; do

	# Get center of seg region
	fslmaths "${track_dir}/BIGGEST_MULTI_${source}/seg_all_LR" -bin tmp
	vx=$(get_com.py x tmp.nii.gz)
	vy=$(get_com.py y tmp.nii.gz)
	vz=$(get_com.py z tmp.nii.gz)
	rm tmp.nii.gz

	# Build slices
	mstr=""
	for delta in ${deltas} ; do

		of="biggest_${dirname_tag}_${source}_${delta}.png"

		fsleyes render --outfile "${of}" \
			--displaySpace world \
			--size 600 600 --hideCursor --hideLabels --hidex --hidez --yzoom 2200 \
			--worldLoc ${vx} $((${vy}+${delta})) ${vz} \
			"${out_dir}/norm_to_DWI" --interpolation none \
			"${track_dir}/BIGGEST_MULTI_${source}/seg_all_LR" --cmap random

		mstr="${mstr} ${of}"

	done

	# Combine onto page
	montage -mode concatenate ${mstr} -tile 4x4 -quality 100 -background white -gravity center \
		-border 10 -bordercolor white -resize 600x "biggest_${dirname_tag}_${source}.png"
	rm ${mstr}
	convert \
		-size 2600x3365 xc:white \
		-gravity center \( "biggest_${dirname_tag}_${source}.png" -resize 2400x \) -geometry +0+0 -composite \
		-gravity North -pointsize 48 -annotate +0+150 "${dirname_tag}: Segmentation (biggest) of ${source}" \
		-gravity SouthEast -pointsize 48 -annotate +50+50 "${thedate}" \
		-gravity NorthWest -pointsize 48 -annotate +50+50 "${project} ${subject} ${session}" \
		"biggest_${dirname_tag}_${source}.png"

done


# Make PDF pages for a set of tracks, coronal slices around the
# center of mass of the target ROIs
vx=$(get_com.py x "${track_dir}"/TRACKMASKS/all_tgt_LR.nii.gz)
vy=$(get_com.py y "${track_dir}"/TRACKMASKS/all_tgt_LR.nii.gz)
vz=$(get_com.py z "${track_dir}"/TRACKMASKS/all_tgt_LR.nii.gz)
deltas="-75 -65 -55 -45 -35 -25 -15 -5 +5 +15 +25 +35 +45 +55 +65 +75"
for source in ${source_regions} ; do
	for target in ${target_regions} ; do

		mstr=""
		for delta in ${deltas} ; do

			of="tracts_${dirname_tag}_${source}_to_${target}_${delta}.png"

			fsleyes render --outfile "${of}" \
				--displaySpace world \
				--size 600 600 --hideCursor --hideLabels --hidex --hidez --yzoom 1200 \
				--worldLoc ${vx} $((${vy}+${delta})) ${vz} \
				"${out_dir}/norm_to_DWI" --interpolation none \
				"${rois_dwi_dir}/${target}_L" --cmap blue \
				"${rois_dwi_dir}/${target}_R" --cmap blue \
				"${track_dir}/${source}_L_to_${target}_L/fdt_paths_75pct" --cmap red-yellow \
				"${track_dir}/${source}_R_to_${target}_R/fdt_paths_75pct" --cmap red-yellow

			mstr="${mstr} ${of}"

		done

		montage -mode concatenate ${mstr} -tile 4x4 -quality 100 -background black -gravity center \
			-resize 600x "tracts_${dirname_tag}_${source}_to_${target}.png"
		rm ${mstr}
		convert \
		  -size 2600x3365 xc:white \
		  -gravity center \( "tracts_${dirname_tag}_${source}_to_${target}.png" -resize 2400x \) -geometry +0+0 -composite \
		  -gravity North -pointsize 48 -annotate +0+150 "${dirname_tag}: ${source} to ${target}" \
		  -gravity SouthEast -pointsize 48 -annotate +50+50 "${thedate}" \
		  -gravity NorthWest -pointsize 48 -annotate +50+50 "${project} ${subject} ${session}" \
		  "tracts_${dirname_tag}_${source}_to_${target}.png"

	  done
done
