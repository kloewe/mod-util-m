function fname = fileGetName(pathstr,varargin)
%FILEGETNAME Get filename from full path.
%
%   fname = fileGetName(pathstr) or fname = fileGetName(pathstr,1)
%     -> returns filename incl. extension but without folder
%
%   fname = fileGetFname(pathstr,0)
%     -> returns filename without extension and without folder
%
%   Author: Kristian Loewe

[~,fname,ext] = fileparts(pathstr);
if nargin == 1 || (nargin == 2 && varargin{1} == 1)
    fname = [fname,ext];
elseif nargin ~= 2
    error('Wrong number of input args.');
elseif varargin{1} ~= 0
    error('Optional input argument must be 0 or 1.');
end

end
