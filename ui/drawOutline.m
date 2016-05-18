function varargout = drawOutline(mask,varargin)
%DRAWOUTLINE Draw 2D outline.
%
%   DRAWOUTLINE(MASK) draws 2D outlines of the connected components found in
%   the specified mask on the current axes using the patch function.
%
%   DRAWOUTLINE(MASK,'PARAM1',VAL1,'PARAM2',VAL2,...) can be used to specify
%   additional parameters and their values. In principle, all parameter
%   names that are supported by the patch function can be used, e.g.,
%   'Parent', 'LineWidth', 'EdgeColor', 'EdgeAlpha', 'FaceColor', and
%   'FaceAlpha'.
%
%   H = DRAWOUTLINE(...) returns the created patch object(s).
%
%   Example
%   -------
%   n1 = hist3(mvnrnd([7 1], [1 0.95; 0.95 1], 100000), [100 100]);
%   n2 = hist3(mvnrnd([1 7], [1 -0.95; -0.95 1], 100000), [100 100]);
%   n = n1+n2;
%   figure;
%   colormap gray;
%   imagesc(n);
%   drawOutline(n > mean(n(:)) + 2*std(n(:)), ...
%     'FaceColor', [0 0 1], 'FaceAlpha', 0.3);
%   axis image;
%
%   See also patch.
%
%   Author: Kristian Loewe

assert(nargout <= 1);
assert(mod(nargin,2) == 1);
assert(islogical(mask));

defaults = {'EdgeColor', [1 0 0], 'FaceColor', 'none', 'HitTest', 'off'};

npix = sum(mask(:));

if npix == 0
  return;

elseif npix == 1
  [I,J] = find(mask);
  h = patch(...
    'XData', [J+0.5 J+0.5 J-0.5 J-0.5], ...
    'YData', [I+0.5 I-0.5 I-0.5 I+0.5], ...
    defaults{:}, ...
    varargin{:});

else
  cc = bwconncomp(mask, 4);
  for i = 1:cc.NumObjects
    selcc = false(size(mask));
    selcc(cc.PixelIdxList{i}) = true;
    selcc10 = imresize(selcc', 10, 'method', 'nearest');
    [I2,J2] = find(selcc10);
    b = bwtraceboundary(selcc10, [I2(1) J2(1)], 'W', 4);
    h(i) = patch(...
      'XData', 0.5+b(:,1)./10, ...
      'YData', 0.5+b(:,2)./10, ...
      defaults{:}, ...
      varargin{:});
  end
end

if nargout == 1
  varargout{1} = h(:);
end

end
