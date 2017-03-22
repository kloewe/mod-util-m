function jfcw = getJavaWindow(hf)
%GETJAVAWINDOW Get the figure window's underlying Java reference.
%
%  Author: Kristian Loewe

if ~exist('hf', 'var')
  hf = gcf;
end

% get java frame
ws = warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jh = get(hf, 'JavaFrame');
warning(ws);                         % restore previous warning state

% get figure client
if verLessThan('matlab', '7.13')     % 7.13 = R2011b
  jfc = jh.fFigureClient;
elseif verLessThan('matlab', '8.4')  % 8.4  = R2014b
  jfc = jh.fHG1Client;
else
  jfc = jh.fHG2Client;
end

% get window
jfcw = jfc.getWindow;
k = 0;                               % retry a few times if unsuccessful
while isempty(jfcw) && k < 10
  drawnow;
  pause(0.02);
  jfcw = jfc.getWindow;
  k = k + 1;
end

end
