function warpdir(warp_dir,fwddef_nii,interp,prefix)

if nargin<4
	prefix = '';
end

if nargin<3
	interp = 0;
end

gzs = dir(fullfile(warp_dir,[prefix '*.nii.gz']));
gzs = cellstr(char(gzs.name));

for g = 1:numel(gzs)
	system(['gunzip ' fullfile(warp_dir,gzs{g})]);
	towarpnii = gzs{g}(1:end-3);
	warp(fwddef_nii,fullfile(warp_dir,towarpnii),interp);
	system(['gzip -f ' fullfile(warp_dir,towarpnii)]);
	system(['gzip -f ' fullfile(warp_dir,['w' towarpnii])]);
end
