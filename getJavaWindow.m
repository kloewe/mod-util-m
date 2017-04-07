function jfcw = getJavaWindow(hf)
%GETJAVAWINDOW Get the figure window's underlying Java reference.
%
%  Author: Kristian Loewe

if ~exist('hf', 'var')
  hf = gcf;
end

% get figure client
jfc = getJavaFigureClient(hf);

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
