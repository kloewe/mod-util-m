function hdr = readImgHdr(fname)
%READIMGHDR Read header information for neuroimaging data.
%
%   H = READIMGHDR(FILENAME)
%
%   Optional dependencies:
%
%     SPM      http://www.fil.ion.ucl.ac.uk/spm
%     MRtrix3  http://www.mrtrix.org
%
%   See also: READIMGDATA, WRITEIMGDATA.
%
%   Author: Kristian Loewe

% expand potential wildcards
fnameExp = dir(fullfile(fileGetDir(fname), fileGetName(fname)));
assert(~isempty(fnameExp), 'File not found.');
fname = fullfile(fileGetDir(fname), fnameExp.name);

if exist(fname,'file')
  if strcmp(fileGetExt(fname), '.gz') ...    % .nii.gz
      && strcmp(fileGetExt(fileGetName(fname,0)), '.nii')
    tmpfilename = ['/tmp/kl_',num2str(round(rand(1)*100000)),'.nii'];
    system(['gzip -cd ', fname, ' > ', tmpfilename]);
    hdr = spm_vol(tmpfilename);
    hdr.fname = fname;
    system(['rm ', tmpfilename]);
  else
    switch fileGetExt(fname)
      case {'.img','.hdr','.nii'}            % .img | .hdr | .nii
        hdr = spm_vol(fname);
      case {'.mif','.mih'}
        hdr = read_mrtrix(fname);            % .mif | .mih
        hdr = rmfield(hdr, 'data');
      otherwise
        error(['Unsupported filename extension: ', fileGetExt(fname)]);
    end
  end
else
  error(['File not found: ', fname]);
end
end
