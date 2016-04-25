function ret = fileExists(pathstr)
%FILEEXISTS Check if a given file exists.
%
%   fileExists(pathstr)
%
%   Author: Kristian Loewe

% ret = exist(pathstr, 'file') && ~exist(pathstr, 'dir');
ret = exist(pathstr, 'file') == 2;

end
