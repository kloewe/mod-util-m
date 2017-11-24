function offscreenHist(data,fname,varargin)
%OFFSCREENHIST Plot a histogram off screen.
%
%   offscreenHist(data, fname)
%   offscreenHist(data, fname, ...)
%   offscreenHist(data, fname, nbins)
%   offscreenHist(data, fname, nbins, ...)
%   offscreenHist(data, fname, edges)
%   offscreenHist(data, fname, edges, ...)
%
%   Example:
%   offscreenHist(normrnd(0,1,1000,1), 'hist.png');
%
%   Author: Kristian Loewe

optargs = [];

if nargin == 2                   % offscreenHist(data, fname);
  nbins = 100;
elseif nargin == 3 || (nargin >= 5 && mod(numel(varargin),2)==1)
  if     numel(varargin{1}) == 1 % offscreenHist(data, fname, nbins)
    nbins = varargin{1};
    if nargin > 3                % offscreenHist(data, fname, nbins, ...)
      optargs = varargin(2:end);
    end
  else                           % offscreenHist(data, fname, edges)
    e = varargin{1};
    if nargin > 3                % offscreenHist(data, fname, edges, ...)
      optargs = varargin(2:end);
    end
  end
else
  error('Unexpected number of input arguments.');
end

if ~exist('e','var')
  l = min(data(:));
  h = max(data(:));
  % if sign(l) == -1 && sign(h) == 1
  %   l = -max(abs([l h]));
  %   h = -l;
  % end
  e = linspace(l, h, nbins+1);
end

assert(nbins > 1, 'Number of bins must be > 1.');

if verLessThan('matlab', '8.4');  % 8.4 = R2014b)
  n = histc(data(:), e);          % use histc to compute histogram
  n(end-1) = n(end-1) + n(end);   % make output consistent with histcounts
else
  n = histcounts(data(:), e);     % use histcounts to compute histogram
end

ec = e(2:end) - (e(2)-e(1))/2;

hf = figure('Visible', 'off');    % plot histogram
ha = axes('Parent', hf);
bar(ha, ec, n, ... %  'BarWidth', 0.5, ...
  'FaceColor', [0.7 0.7 0.7], ...
  'EdgeColor', [0.7 0.7 0.7], ...
  'EdgeAlpha', 0);
title(ha, 'histogram');
ylabel(ha, 'frequency');

set(ha, ...
  'FontName', 'Helvetica', ...
  'Box', 'off', ...
  'TickDir', 'out', ...
  'TickLength', [0.015 0.015] , ...
  'XMinorTick', 'off', ...
  'YMinorTick', 'off', ...
  'Layer', 'top');

axis(ha, 'square');
grid(ha, 'on');

if ~isempty(optargs)
  set(gca, optargs{:});
end

saveas(hf,fname);

end
