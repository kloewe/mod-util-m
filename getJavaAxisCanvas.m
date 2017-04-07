function jfcac = getJavaAxisCanvas(hf)
%GETJAVAAXISCANVAS Get the figure window's Java-based axis canvas.
%
%  Author: Kristian Loewe

if ~exist('hf', 'var')
  hf = gcf;
end

% get figure client
jfc = getJavaFigureClient(hf);

% get axis canvas
jfcac = jfc.getAxisComponent;

end
