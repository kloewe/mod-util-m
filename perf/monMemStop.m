function mem = monMemStop(varargin)
%MONMEMSTOP Stop monitoring memory usage.
%
%   Stop monitoring Matlab's resident set size using the proc filesystem.
%
%   See also MONMEMSTART.
%
%   Author: Kristian Loewe

unit = 'b';
assert(nargin <= 1);
if nargin == 1
  unit = varargin{1};
end

pid = feature('getpid');
system(['rm /tmp/monMem_',sprintf('%d',pid)]);

% read data
fname = ['/tmp/monMem_',sprintf('%d',pid),'_dat'];
if(exist(fname,'file'))
  fid = fopen(fname);
  data = textscan(fid, '%f');
  npages = data{1};
  % cpu = data{2};
  fclose(fid);
else
  error(['File not found: ', fname]);
end
system(['rm ', fname]);

mem = npages.*getPageSize();
mem = mem - mem(1);

switch unit
  case 'b'                      % bytes
    return;
  case 'k'                      % kilobytes
    mem = mem./1024;
  case 'm'                      % megabytes
    mem = mem./1024^2;
  case 'g'                      % gigabytes
    mem = mem./1024^3;
end

end
