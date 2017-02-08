function d = readImgData(fname)
%READIMGDATA Read neuroimaging data.
%
%   I = READIMGDATA(FILENAME)
%
%   This function depends on SPM, which can be obtained
%   from http://www.fil.ion.ucl.ac.uk/spm/.
%
%   See also: READIMGHDR, WRITEIMGDATA.
%
%   Author: Kristian Loewe

% expand potential wildcards
fnameExp = dir(fullfile(fileGetDir(fname), fileGetName(fname)));
assert(~isempty(fnameExp), 'File not found: %s\n', fname);
fname = fullfile(fileGetDir(fname), fnameExp.name);

if fileExists(fname)
  if strcmp(fileGetExt(fname), '.gz') ...     % .nii.gz
      && strcmp(fileGetExt(fileGetName(fname,0)), '.nii')
    tmpfilename = ['/tmp/kl_',num2str(round(rand(1)*100000)),'.nii'];
    system(['gzip -cd ', fname, ' > ', tmpfilename]);
    d = spm_read_vols(spm_vol(tmpfilename));
    system(['rm ', tmpfilename]);
  else
    switch fileGetExt(fname)
      case '.mat'                            % .mat
        tmp = load(fname);
        fieldsOfStruct = fieldnames(tmp);
        d = tmp.(fieldsOfStruct{1});
      case {'.img','.hdr','.nii'}            % .img | .hdr | .nii
        d = spm_read_vols(spm_vol(fname));
      otherwise
        error(['Unsupported filename extension: ', fileGetExt(fname)]);
    end
  end
else
  error(['File not found: ', fname]);
end
end
