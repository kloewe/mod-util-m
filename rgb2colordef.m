function rgb2colordef(rgb,cmapname,fname)
%RGB2COLORDEF Create color definitions file for use with Circos.
%
%   RGB2COLORDEF(RGB,CMAPNAME,FNAME) creates the color definitions file FNAME
%   based on the color map name CMAPNAME and the colors defined by the N-by-3
%   array of RGB values (values between 0 and 1).
%
%   Circos is a Perl-based software package developed by Martin Krzywinski
%   and can be obtained from http://circos.ca/software/download/.
%
%   On Ubuntu, you can install Circos using apt-get:
%   $ sudo apt-get install circos libsvg-perl
%
%   Example:
%      rgb2colordef(jet(256), 'jet', 'jet256.conf');
%
%   See also GENCIRCOSCONF.
%
%   Author: Kristian Loewe

assert(ismatrix(rgb) && size(rgb,1) > 0 && size(rgb,2) == 3);

rgb = round(rescaleData(rgb, [0 255], [0 1]));

if ~isempty(fileGetDir(fname))
  assert(isdir(fileGetDir(fname)));
end

[fid,errmsg] = fopen(fname, 'w');
assert(fid >= 0, errmsg);
for iCol = 1:size(rgb,1)
  fprintf(fid, '%s%d = %d,%d,%d\n', ...
    cmapname, iCol, rgb(iCol,1), rgb(iCol,2), rgb(iCol,3));
end
assert(fclose(fid) == 0, 'Could not close file %s.', fname);

end
