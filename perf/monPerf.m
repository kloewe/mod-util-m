function varargout = monPerf(op,event)
%MONPERF Monitor performance based on event counters using perf stat.
%
%   MONPERF('start', E) starts counting events of the type specified by the
%   string E. Subsequently, C = MONPERF('stop') terminates the counting of
%   events and returns the obtained count in C.
%
%   A list of events supported on your system can be obtained using
%     $perf list
%   in a terminal.
%
%   Example:
%   monPerf('start','cache-misses');
%   % insert code here
%   c = monPerf('stop');
%
%   References:
%   https://perf.wiki.kernel.org/
%
%   Author: Kristian Loewe

persistent evt;     % event type
persistent pidm;    % Matlab's pid
persistent pidp;    % perf's pid
persistent fname;   % filename

switch op
  case 'start'
    assert(isunix, 'OS not supported.');
    assert(nargin == 2, 'Unexpected number of input arguments.');
    assert(ischar(event));
    [rc,~] = system('which perf');
    assert(~rc, 'perf not found.');

    pidm = feature('getpid');
    fname = ['/tmp/monPerf_',sprintf('%d',pidm),'_perf-stats'];
    assert(~fileExists(fname), 'The file %s already exists.', fname);
    evt = event;

    % start monitoring
    [rc,~] = system([...
      'perf stat -e ' evt ' -p ' sprintf('%d', pidm) ...
      ' > ' fname ' 2>&1 & echo $! > ' fname '-pid']);
    assert(~rc, 'Could not start perf.');
    pidp = importdata([fname '-pid']);
    delete([fname '-pid']);
    assert(~isempty(pidp), 'Could not retrieve perf''s pid');
    assert(isscalar(pidp) && ~isnan(pidp), 'Could not retrieve perf''s pid.');
    
  case 'stop'
    assert(nargin == 1, 'Unexpected number of input arguments.');
    assert(~isempty(evt) && ~isempty(pidm) && ~isempty(pidp), ...
      'Monitoring needs to be started first.');
    assert(fileExists(fname));

    % stop monitoring
    [rc,msg] = system(['kill -SIGINT ',num2str(pidp)]);
    assert(~rc, '%s', msg);
    pause(0.5);

    % read gathered data
    [rc,~] = system(['cat ' fname ' | grep "not counted"']);
    assert(rc == 1, 'Not counted.');
    [rc,c] = system(['cat ' fname ' | grep "' evt '" | awk ''{print $1}''']);
    assert(~rc, 'Could not read data from file %s', fname);
    delete(fname);
    c = str2double(c);
    assert(~isnan(c));
    varargout{1} = c;
    
    % clear persistent variables
    clear evt pidm pidp fname;
    
  otherwise
    error('Unexpected input argument.');
end

end
