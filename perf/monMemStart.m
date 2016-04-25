function monMemStart
%MONMEMSTART Start monitoring memory usage.
%
%   Start monitoring Matlab's resident set size using the proc filesystem.
%
%   See also MONMEMSTOP.
%
%   Author: Kristian Loewe

assert(isunix, 'OS not supported.');

pid = feature('getpid');
system(['touch /tmp/monMem_',sprintf('%d',pid)]);

fname = ['/tmp/monMem_',sprintf('%d',pid),'_dat'];

[a,~] = system([...
  'while [ -f /tmp/monMem_',sprintf('%d',pid),' ] ; do', ...
  '  cat /proc/', sprintf('%d',pid), '/stat ', ...
  '| awk ''{printf "%s\n",$24}'' >> ', fname, ';' ...
  'done &']);
assert(~a);

end
