function r = poolmgr(cmd,psiz)
%POOLMGR Unified parallel pool management across Matlab versions.
%
%   poolmgr('open')
%   poolmgr('open',psiz)
%
%   poolmgr('close')
%
%   n = poolmgr('size')
%
%   Author: Kristian Loewe

switch cmd

  case 'open'
    assert(nargin > 0 && nargin <= 2);

    if ~exist('psiz', 'var')
      psiz = feature('numcores');
    else
      psiz = min(psiz, feature('numcores'));
    end

    if verLessThan('matlab', '7.8')
      psiz = min(psiz, 4);
    elseif verLessThan('matlab', '7.13')
      psiz = min(psiz, 8);
    elseif verLessThan('matlab', '8.3')
      psiz = min(psiz, 12);
    end

    if verLessThan('matlab', '8.2')
      matlabpool('open', psiz);
    else
      r = parpool('local', psiz);
    end

  case 'size'
    assert(nargin == 1);

    if verLessThan('matlab', '8.2')
      r = matlabpool('size');
    else
      p = gcp('nocreate');
      if isempty(p)
        r = 0;
      else
        r = p.NumWorkers;
      end
    end

  case 'close'
    assert(nargin == 1);

    if poolmgr('size') > 0
      if verLessThan('matlab', '8.2')
        matlabpool('close');
      else
        delete(gcp('nocreate'));
      end
    end
end

end
