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

if iscell(fname) && isscalar(fname)
  fname = fname{1};
end

assert(ischar(fname), 'Unexpected input type.');

% expand potential wildcards
fnameExp = fileGlob(fname);
assert(~isempty(fnameExp), 'File not found: %s', fname);
assert(isscalar(fnameExp), 'More than one file found: %s', fname);
fname = fnameExp{1};

if strcmp(fileGetExt(fname), '.gz')        % .nii.gz | .mif.gz
  assert(isunix || ismac, '.*.gz is not supported on this OS.');

  ext = fileGetExt(fileGetName(fname,0));
  assert(ismember(ext, {'.nii','.mif'}), ...
    'Unsupported filename extension: %s%s', ext, '.gz');

  while true
    tmpfilename = [tempname, ext];
    if ~fileExists(tmpfilename)
      break;
    end
  end

  [rc,msg] = system('which pigz');
  if ~rc
    [rc,msg] = system(['pigz -cd ', fname, ' > ', tmpfilename]);
  else
    [rc,msg] = system(['gzip -cd ', fname, ' > ', tmpfilename]);
  end
  assert(~rc, '%s', msg);

  d = readImgData(tmpfilename);

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
