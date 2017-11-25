function data = rescaleData(data,rout,varargin)
%RESCALEDATA Rescale (linearly transform) data to the specified range.
%
%   Usage: out = rescaleData(data,rout)
%   Transforms data according to
%                                 rout(2) - rout(1)
%     out = (data - min_data) * --------------------- + rout(1), where
%                                max_data - min_data
%
%   min_data and max_data are computed using nanmin and nanmax, respectively.
%
%   Usage: out = rescaleData(data,rout,rin)
%   Transforms data according to
%                                rout(2) - rout(1)
%     out = (data - rin(1))   * -------------------   + rout(1)
%                                 rin(2) - rin(1)
%   If rin(1) or rin(2) are set to NaN, they are replaced by min_data and
%   max_data, respectively. As mentioned above, min_data and max_data are
%   computed using nanmin and nanmax, respectively.
%
%   Author: Kristian Loewe

assert(~isscalar(data), 'Cannot rescale: more than one value is needed.');
assert(numel(rout) == 2);
dtype = class(data);
assert(ismember(dtype, {'single','double'}));

skipChecks = false;

if mod(numel(varargin),2) == 1
  rin = varargin{1};
  varargin = varargin(2:end);
end

for iParam = 1:2:numel(varargin)
  pn = varargin{iParam};   % parameter name
  assert(ischar(pn), 'Parameter names must be of type char.');
  pv = varargin{iParam+1}; % parameter value
   switch pn
    case 'SkipChecks'
      skipChecks = logical(pv);
    otherwise
      error('Unexpected parameter name %s.', pn);
  end
end

if ~skipChecks && all(isnan(data(:)))
  warning('No non-NaN values found.');
  return;
end

if ~skipChecks && any(isinf(data(:)))
  error('Cannot rescale with -Inf or Inf values present.');
end


if strcmp(dtype, 'single')
  rout = single(rout);
end

if ~exist('rin', 'var')
  rin = [nanmin(data(:)) nanmax(data(:))];
else
  assert(numel(rin) == 2);
  if strcmp(dtype, 'single')
    rin = single(rin);
  end
  
  if isnan(rin(1))
    rin(1) = nanmin(data(:));
  else
    if ~skipChecks
      assert(rin(1) <= nanmin(data(:)));
    end
  end
  if isnan(rin(2))
    rin(2) = nanmax(data(:));
  else
    if ~skipChecks
      assert(rin(2) >= nanmax(data(:)));
    end
  end
end

data = (data - rin(1)) * (rout(2) - rout(1)) ./ (rin(2) - rin(1)) + rout(1);

end
