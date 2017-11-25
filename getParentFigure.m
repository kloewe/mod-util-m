function h = getParentFigure(h)
%GETPARENTFIGURE Get the parent figure of a graphics object.
%
%   HP = getParentFigure(H)
%
%   Author: Kristian Loewe

if verLessThan('matlab', '8.4')
  assert(ishghandle(h), 'Unexpected input argument.');
else
  assert(isgraphics(h), 'Unexpected input argument.');
end

while h ~= 0
  ph = h;
  h = get(h, 'Parent');
end
h = ph;

end
