function names = fileGlob(pattern)
%FILEGLOB Filename expansion.
%
%   fnames = fileGlob(pattern) returns a cell array of expanded filenames.
%
%   Supported wildcards:
%   *  matches any number of any characters including none
%
%   Author: Kristian Loewe

if ~isempty(strfind(pattern, '//'))
  warning('The pattern contains double slashes.');
end

parts = flat(regexp(pattern, '/', 'split'));

if isempty(parts{1}) && strcmp(pattern(1), '/')
  parts{1} = '/';
end

parts(cellfun(@isempty, parts)) = [];

names = {''};
for i = 1:numel(parts)
  newnames = cell(0);
  if isempty(strfind(parts{i}, '*'))
    for k = 1:numel(names)
      newnames = [newnames(:); expand(fullfile(names{k}, parts{i}))];
    end
    names = newnames(cellfun(@(x) exist(x, 'file') > 0, newnames));
  else
    for l = 1:numel(names)
      newnames = [newnames(:); expand(fullfile(names{l}, parts{i}))];
    end
    if i < numel(parts)
      newnames = newnames(cellfun(@(x) exist(x, 'dir') > 0, newnames));
    end
    names = newnames(...
      cellfun(@(x) ~any(strcmp(fileGetName(x), {'.', '..'})), newnames));
  end
end

names = names(:);
end

function names = expand(pattern)
  if ~isempty(strfind(pattern, '*'))
    fdir = fileGetDir(pattern);
    d = dir(pattern);
    names = flat({d.name});
    if ~isempty(fdir) && ~isempty(names)
      names = strcat(fdir, filesep, names);
      names = strrep(names, '//', '/');
    end
  else
    names = {pattern};
  end
end
