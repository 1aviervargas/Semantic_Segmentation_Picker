function x = normy(x)
%This function performs preprocessing of input micrographs including
%normalization to quantiles 2% and 98% for contrast adjustment, clipping 
%values outside the 0-1 range, resize to [640 448]px and add some noise.

[~, ~, ext] = fileparts(x);
if strcmp(ext, “.mrc”)
	x = double(ReadMRC(x));
else
	x = double(imread(x));
end

[sx sy] = size(x);
pmin = 2;
pmax = 98;

median_x = median(x(:));
x = x - median_x;

p_min = prctile(x(:),pmin);
x = (x - p_min);
x(x<0) = 0;
p_max = prctile(x(:),pmax);
x = x/p_max;
x(x>1) =1;

x = imresize(double(x),[640 448]);
imnoise(x,'gaussian',0,0.1);

end
