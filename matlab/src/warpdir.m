function warpdir(warp_dir,out_dir)

gzs = dir(fullfile(warp_dir,'r*.nii.gz'));
gzs = cellstr(char(gzs.name));

for g = 1:numel(gzs)
	system(['cd ' warp_dir ' && gunzip ' gzs{g}]);
	towarp = gzs{g}(1:end-3);
	warp(fullfile(out_dir,'y_fwddef.nii'),fullfile(warp_dir,towarp));
	system(['gzip -f ' fullfile(warp_dir,['w' towarp])]);
end

