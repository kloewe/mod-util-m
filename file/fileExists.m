function res = fileExists(pathstr)
%FILEEXISTS Check if a given file exists.
%
%   fileExists(pathstr)
%
%   Author: Kristian Loewe

if iscell(pathstr)
  res = cellfun(@exist, pathstr) == 2;
else
  % res = exist(pathstr, 'file') && ~exist(pathstr, 'dir');
  res = exist(pathstr, 'file') == 2;
end

end
