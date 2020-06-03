function warpdir(warp_dir,out_dir,prefix)

if nargin<3
	prefix = '';
end

gzs = dir(fullfile(warp_dir,[prefix '*.nii.gz']));
gzs = cellstr(char(gzs.name));

for g = 1:numel(gzs)
	system(['gunzip ' fullfile(warp_dir,gzs{g})]);
	towarpnii = gzs{g}(1:end-3);
	warp(fullfile(out_dir,'y_fwddef.nii'),fullfile(warp_dir,towarpnii));
	system(['gzip -f ' fullfile(warp_dir,towarpnii)]);
	system(['gzip -f ' fullfile(warp_dir,['w' towarpnii])]);
end
