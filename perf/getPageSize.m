function pagesiz = getPageSize
%GETPAGESIZE Get page size.
%
%   See also MONMEMSTART, MONMEMSTOP.
%
%   Author: Kristian Loewe

assert(isunix, 'OS not supported.');

[rc,pagesiz] = system('getconf PAGESIZE');
assert(~rc, 'Could not determine page size.');
pagesiz = str2double(pagesiz);

end
