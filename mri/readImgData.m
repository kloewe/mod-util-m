function d = readImgData(fname)
%READIMGDATA Read neuroimaging data.
%
%   I = READIMGDATA(FILENAME)
%
%   Optional dependencies:
%
%     SPM      http://www.fil.ion.ucl.ac.uk/spm
%     MRtrix3  http://www.mrtrix.org
%
%   See also: READIMGHDR, WRITEIMGDATA.
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
  d = spm_read_vols(spm_vol(tmpfilename));
  [rc,msg] = system(['rm ', tmpfilename]);
  assert(~rc, '%s', msg);
else
  switch fileGetExt(fname)
    case '.mat'                            % .mat
      tmp = load(fname);
      fieldsOfStruct = fieldnames(tmp);
      d = tmp.(fieldsOfStruct{1});
    case {'.img','.hdr','.nii'}            % .img | .hdr | .nii
      d = spm_read_vols(spm_vol(fname));
    case {'.mif','.mih'}
      d = read_mrtrix(fname);              % .mif | .mih
      d = d.data;
    otherwise
      error('Unsupported filename extension: %s', fileGetExt(fname));
  end
end

end
