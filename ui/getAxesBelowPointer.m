function ha = getAxesBelowPointer(varargin)
%GETAXESBELOWPOINTER Get axes below the mouse pointer.
%   
%   HA = GETAXESBELOWPOINTER returns the axes below the mouse pointer in the
%   current figure. If no such axes exist, GETAXESBELOWPOINTER returns [].
%
%   HA = GETAXESBELOWPOINTER(HF) looks for the axis below the mouse pointer
%   in the figure with handle F.
%
%   HA = GETAXESBELOWPOINTER(HF,B) considers only the axes specified by B,
%   where B is an array of axis handles.
%
%   Note that this function uses the figure's CurrentPoint property. Thus,
%   for this function to work as expected a WindowButtonMotionFcn callback
%   needs to be defined for the relevant figure, so that the coordinates
%   returned by the CurrentPoint property reflect the current position of
%   the mouse pointer rather than the location of the last mouse click.
%   If there is no WindowButtonMotionFcn callback already defined, then a 
%   dummy callback could be defined for the figure HF like so:
%     set(HF, 'WindowButtonMotionFcn', @(~,~) []);
%   Alternatively, this function could be modified to use the root object's
%   PointerLocation property, which doesn't depend on any additional
%   callbacks to be defined, but is measured with respect to the screen
%   rather than the figure.
%
%   Author: Kristian Loewe

hf = [];                              % figure handle
ha = [];                              % axes handle

if     nargin == 0
  hf = gcf;                           % use current figure
elseif nargin <= 2
  hf = varargin{1};                   % use user-specified figure
else
  error('Unexpected number of input arguments.');
end
if nargin == 2
  axHndls = varargin{2};              % check all axes
else
  axHndls = findobj('type', 'axes');  % check user-specified axes only
end
if isempty(axHndls)
  return;
end

% get current mouse pointer position
pu = get(hf, 'Units');
set(hf, 'Units', 'pixels');
if ~strcmp(pu, 'pixels')
  set(hf, 'Units', pu);
end
mpp = get(hf, 'CurrentPoint');        % the mpp is given wrt the figure HF

% get rid of those axes that HF doesn't contain
remidx = false(size(axHndls));        % reduce axes to those that are in the 
for i = 1:numel(axHndls)              % that an axes may be a child of a
  h = findparentfig(axHndls(i));      % panel that is a child of the
  if ~isequal(h,hf)                   % relevant figure etc.
    remidx(i) = true;
  end
end
axHndls(remidx) = [];

% find the axes below the mouse pointer position (if any)
found = false;
for i = 1:numel(axHndls)
  ha = axHndls(i);                    % axes handle
  apos = getpixelposition(ha);        % axes position
  hp = get(ha, 'Parent');             % parent
  
  while get(hp, 'Parent') ~= 0        % 0 indicates the root object
    ppos = getpixelposition(hp);      % get parent position to recursively
    apos(1) = apos(1) + ppos(1);      % compute the axes position wrt the
    apos(2) = apos(2) + ppos(2);      % parent figure
    hp = get(hp, 'Parent');           % get parent of the parent etc.
  end
  
  found = ...                         % is the mouse pointer within the
    mpp(1) > apos(1) && ...           % boundaries of HA?
    mpp(1) < apos(1)+apos(3) && ...
    mpp(2) > apos(2) && ...
    mpp(2) < apos(2)+apos(4);
  if found
    break;
  end
end

if ~found
  ha = [];
end

end


function h = findparentfig(h)
% find parent figure

  while h ~= 0
    ph = h;
    h = get(h, 'Parent');
  end
  h = ph;
end
