function pngcolorbar(rgb,width,fname)
%PNGCOLORBAR Save a colorbar in png format.
%
%   pngcolorbar(rgb,width,fname)
%
%   rgb    array of rgb-values between 0 and 1
%          size [n x 3] -> vertical colorbar
%          size [3 x n] -> horizontal colorbar
%   width  width/height of output image in pixels
%   fname  output filename
%
%   Examples:
%     pngcolorbar(winter(256),  32, 'winter_vert.png');
%     pngcolorbar(winter(256)', 32, 'winter_horz.ng');
%
%   Author: Kristian Loewe

assert(ndims(rgb) == 2);
assert(size(rgb,1) > 0 && size(rgb,2) > 0 ...
  && (size(rgb,1) == 3 || size(rgb,2) == 3) );

if size(rgb,2) == 3
  img = zeros(size(rgb,1), width, 3);
  img(:,:,:) = permute(repmat(rgb,[1 1 width]),[1 3 2]);
elseif size(rgb,1) == 3
  img = zeros(width, size(rgb,2), 3);
  img(:,:,:) = permute(repmat(rgb,[1 1 width]),[3 2 1]);
else
  error('Input has unexpected dimensions.');
end

if ~isdir(fileGetDir(fname)) && ~isempty(fileGetDir(fname))
  error('Target folder doesn''t exist.');
end

imwrite(flipdim(img,1),fname,'png');

end
