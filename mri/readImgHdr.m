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
fnameExp = fileGlob(fname);
assert(~isempty(fnameExp), 'File not found: %s', fname);
assert(isscalar(fnameExp), 'More than one file found: %s', fname);
fname = fnameExp{1};

if strcmp(fileGetExt(fname), '.gz') ...    % .nii.gz
    && strcmp(fileGetExt(fileGetName(fname,0)), '.nii')
  tmpfilename = ['/tmp/kl_',num2str(round(rand(1)*100000)),'.nii'];
  [rc,msg] = system(['gzip -cd ', fname, ' > ', tmpfilename]);
  assert(~rc, '%s', msg);
  hdr = spm_vol(tmpfilename);
  hdr.fname = fname;
  [rc,msg] = system(['rm ', tmpfilename]);
  assert(~rc, '%s', msg);
else
  switch fileGetExt(fname)
    case {'.img','.hdr','.nii'}            % .img | .hdr | .nii
      hdr = spm_vol(fname);
    case {'.mif','.mih'}
      hdr = read_mrtrix(fname);            % .mif | .mih
      hdr = rmfield(hdr, 'data');
    otherwise
      error('Unsupported filename extension: %s', fileGetExt(fname));
  end
end

end
