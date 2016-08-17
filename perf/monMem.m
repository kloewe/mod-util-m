function varargout = monMem(op,unit)
%MONMEM Monitor memory usage (resident set size) using the proc filesystem.
%
%   MONMEM('start') starts monitoring memory usage (resident set size).
%   Subsequently, M = MONMEM('stop') terminates the monitoring and returns
%   an array of measurements collected in sequence since the monitoring was
%   started. Note that these values are normalized to the first value in
%   the sense that the initial resident set size is subtracted so that M(1)
%   is always zero. M = MONMEM('stop',U) also specifies the unit (default:
%   byte) using one of the following identifiers:
%   
%      Identifier  Unit
%      ----------  ----
%      'b'         byte
%      'k'         kilobyte
%      'm'         megabyte
%      'g'         gigabyte
%
%   Example:
%   momMem('start');
%   % insert code here
%   m = monMem('stop');
%   figure; plot(m);
%
%   See also GETPAGESIZE, MONPERF.
%
%   Author: Kristian Loewe

persistent pidm;
persistent fname;

switch op
  case 'start'
    assert(isunix, 'OS not supported.');
    assert(nargin == 1, 'Too many input arguments.');
    assert(nargout == 0, 'Too many output arguments.');
    
    pidm = feature('getpid');
    fname = ['/tmp/monMem_',sprintf('%d',pidm)];
    assert(~fileExists(fname), 'The file %s already exists.', fname);
    
    [rc,msg] = system(['touch ' fname]);
    assert(~rc, 'Could not create file %s\n%s', fname, msg);
    
    % start monitoring
    [rc,msg] = system([...
      'while [ -f /tmp/monMem_',sprintf('%d',pidm),' ] ; do', ...
      '  cat /proc/', sprintf('%d',pidm), '/stat ', ...
      '| awk ''{printf "%s\n",$24}'' >> ', [fname '_mem-stats'], ';' ...
      'done &']);
    assert(~rc, 'Could not start monitoring.\n%s', msg);
    
    % wait until the output file has been created
    k = 0;
    while ~fileExists([fname '_mem-stats']) && k < 10
      pause(0.01);
      k = k + 1;
    end
    assert(fileExists([fname '_mem-stats']), 'Could not start monitoring.');
    
  case 'stop'
    assert(~isempty(pidm) && ~isempty(fname), ...
      'Monitoring needs to be started first.');
    assert(fileExists(fname), 'File not found: %s', fname);
    
    % stop monitoring
    delete(fname);
    
    % read gathered data
    fname = [fname '_mem-stats'];
    assert(fileExists(fname), 'File not found: %s', fname);
    fid = fopen(fname);
    data = textscan(fid, '%f');
    npages = data{1};
    fclose(fid);
    delete(fname);
    
    % compute memory usage relative to first measurement
    mem = npages.*getPageSize();
    mem = mem - mem(1);
    
    % determine unit
    if ~exist('unit', 'var')
      unit = 'b';
    end
    switch unit
      case 'b'                      % bytes

      case 'k'                      % kilobytes
        mem = mem./1024;
      case 'm'                      % megabytes
        mem = mem./1024^2;
      case 'g'                      % gigabytes
        mem = mem./1024^3;
      otherwise
        error('Unexpected input argument');
    end
    
    % assign output
    varargout{1} = mem;
    
    % clear persistent variables
    clear pidm fname;
    
  otherwise
    error('Unexpected input argument.');
end


end
