function varargout = cmapData(data,cmap,varargin)
%CMAPDATA Map data to RGB values using the specified color map.
%
%   rgb = cmapData(data,cmap)
%
%   rgb = cmapData(data,cmap,rin)
%
%   [r,g,b] = cmapData(data,...)
%
%   Author: Kristian Loewe

% rescale data to the range 0 ... n, given that 'cmap' has n RGB values
data = rescaleData(data, [0 size(cmap,1)], varargin{:});

% initialize variables for rgb-channels
r = NaN(size(data), 'like', data);
g = NaN(size(data), 'like', data);
b = NaN(size(data), 'like', data);

% idxNotNan: logical index for exclusion of NaNs
idxNotNan = ~isnan(data);

% idx (same size as data): index into cmap for each non-NaN voxel
idx = ceil(data(idxNotNan));   % bin data, one bin per rgb-value in cmap
                               % 0 <  b1 <= 1 < b2 <= 2 < b3 <= ... < bn <= n
idx(idx==0) = 1;               % adjustment for first bin, resulting in:
                               % 0 <= b1 <= 1 < b2 <= 2 < b3 <= ... < bn <= n
                               %      |         |         |           |
                    % cmap index:     1         2         3           n
% See also: 
% http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/hist.html:
% "If right = TRUE (default), the histogram cells are intervals of the 
% form (a, b], i.e., they include their right-hand endpoint, but not their 
% left one, with the exception of the first cell when include.lowest is TRUE."

idx(data(idxNotNan) == -Inf) = 1;
idx(data(idxNotNan) == +Inf) = size(cmap,1);

% fill rgb-channels with appropriate values from colormap
if isequal(cmap(:,1), cmap(:,2)) && isequal(cmap(:,1), cmap(:,3))
  r(idxNotNan) = cmap(idx,1);
  b = r;
  g = r;
else
  r(idxNotNan) = cmap(idx,1);
  g(idxNotNan) = cmap(idx,2);
  b(idxNotNan) = cmap(idx,3);
end

% output
if nargout <= 1
  varargout{1} = squeeze(cat(ndims(data)+1,r,g,b));
elseif nargout == 3
  varargout{1} = r;
  varargout{2} = g;
  varargout{3} = b;
else
  error('Unexpected number of output arguments.');
end

end
