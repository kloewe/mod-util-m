function writeImgData(data,fname,hdr)
%WRITEIMGDATA Write neuroimaging data to a NIFTI file.
%
%   WRITEIMGDATA(I, FILENAME, H)
%
%   This function depends on SPM, which can be obtained
%   from http://www.fil.ion.ucl.ac.uk/spm/.
%
%   See also: READIMGHDR, READIMGDATA.
%
%   Author: Kristian Loewe

if iscell(fname) && isscalar(fname)
  fname = fname{1};
end

assert(ischar(fname), ...
  'Unexpected input type: ''fname'' must be of type char.');

doCompress = 0;

outdir = fileGetDir(fname);
if isempty(outdir)
  outdir = pwd;
end

fname = fileGetName(fname);

ext = fileGetExt(fname);
if strcmp(ext, '.gz')
  assert(isunix || ismac, '.*.gz is not supported on this OS.');
  doCompress = 1;
  ext = fileGetExt(fileGetName(fname,0));
end
assert(strcmp(ext,'.nii'), ...
  'Unsupported filename extension: %s%s', ext, '.gz');

nhdr = struct();
if doCompress
  nhdr.fname = fname(1:end-3);
else
  nhdr.fname = fname;
end
nhdr.dim = size(data);
assert(isequal(nhdr.dim, hdr.dim), 'Dimension mismatch');
nhdr.mat = hdr.mat;
nhdr.pinfo = [1 0 0]';

if islogical(data)
  data = uint8(data);
end
dtype = class(data);
switch dtype
  case {'uint8', 'int16', 'int32', 'int8', 'uint16', 'uint32'}
    dtype = spm_type(dtype);
  case 'single'
    dtype = spm_type('float32');
  case 'double'
    dtype = spm_type('float64');
  otherwise
    error('Unsupported data type.');
end
nhdr.dt = [dtype 0];

thisdir = pwd;
cd(outdir);
spm_write_vol(nhdr, data);
cd(thisdir);
if doCompress
  [s,r] = system(['gzip -f ', fullfile(outdir,fname(1:end-3))]);
end

end
