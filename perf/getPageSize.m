function psiz = getPageSize
%GETPAGESIZE Get page size using getconf.
%
%   S = GETPAGESIZE returns the page size in bytes.
%
%   See also MONMEM.
%
%   Author: Kristian Loewe

assert(isunix, 'OS not supported.');
[rc,msg] = system('which getconf');
assert(~rc, 'getconf not found.\n%s', msg);

% For no apparent reason, upon calling [rc,psiz] = system('getconf
% PAGESIZE') below, psiz is occasionally empty even though rc is 0. For
% now, I'm going to try to work around this by trying multiple times.
% Another weird issue is that psiz occasionally contains the full path to
% getconf, for example, /usr/bin/getconf, in addition to the page size (in
% the majority of cases).
psiz = []; k = 0;
while (isempty(psiz) || isnan(psiz)) && k < 10 
  [rc,psiz] = system('getconf PAGESIZE');
  assert(~rc, 'Could not determine page size.');
  psiz = str2double(psiz);
  k = k + 1;
end
assert(isscalar(psiz) && ~isnan(psiz), 'Could not determine page size.');

end
