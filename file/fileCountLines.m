function nLines = fileCountLines(filename)
%FILECOUNTLINES Count the number of lines in a file.
%
%   N = fileCountLines(fname) returns the number of lines
%   in the specified text file.
%
%   This function just wraps a call to the unix tool wc,
%   it is therefore not platform indepedent.
%
%   Author: Kristian Loewe

assert(isunix, 'OS not supported.');

if fileExists(filename)
  [s,w] = system(['wc -l ',filename]);

  if s == 0
    if ~isempty(w)
      w = textscan(w, '%u64 %s');
      nLines = double(w{1});
    else
      nLines = 0;
    end
  else
    error('An unknown error occured.');
  end
else
  error('File not found.');
end

end
