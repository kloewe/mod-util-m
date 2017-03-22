function genCircosConf(chrLbl,chrSiz,lnks,outdir,varargin)
%GENCIRCOSCONF Generate a Circos configuration.
%
%   GENCIRCOSCONF(C,S,L,D) generates a Circos configuration file (and other
%   dependent files) in the output directory D based on the chromosome
%   labels C, the chromosome lengths S, and the links L.
%
%   L is a numeric array defining the links. Each link represents an
%   (undirected) connection between to chromosomal locations (loc. #1
%   and loc. #2). Links can be specified using one of the following formats.
%
%     --- format 1 ---
%     L is an array of size [2 2 n], where n is the total number of links and
%     the i-th link is specified as follows.
%       L(1,1,i) - chr. id      loc. #1
%       L(2,1,i) - pos. on chr. loc. #1
%       L(1,2,i) - chr. id      loc. #2
%       L(2,2,i) - pos. on chr. loc. #2
%
%     --- format 2 ---
%     L is an array of size [4 n], where n is the total number of links and
%     the i-th link is specified as follows.
%       L(1,i)   - chr. id      loc. #1
%       L(2,i)   - pos. on chr. loc. #1
%       L(3,i)   - chr. id      loc. #2
%       L(4,i)   - pos. on chr. loc. #2
%
%   GENCIRCOSCONF(C,S,L,D,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies
%   additional parameters and their values.
%
%     Parameter          Value
%     ---------          -----
%     'ChrColor'         Chromosome colors.
%                        Colors are specified based on their names. Valid
%                        color names can be found in the corresponding
%                        configuration file, e.g., /etc/circos/colors.conf.
%                          Single string         - one color for all chr.
%                          Cell array of strings - indiv. chromosome colors
%
%     'ChrOrder'         Chromosome order.
%
%     'ChrGroup'         Chromosome grouping.
%
%     'ChrGroupSpacing'  Chromosome group spacing.
%
%     'LinkColor'        Link color.
%                        (1) Colors can be specified based on their names.
%                        Valid color names can be found in the corresponding
%                        configuration file, e.g., /etc/circos/colors.conf.
%                          Single string         - one color for all links
%                          Cell array of strings - indiv. link colors
%                        (2) Index into color map
%                          Single index          - one color for all links
%                          Vector of indices     - indiv. link colors
%
%     'LinkColorMap'     N x 3 array of RGB values.
%
%     'LinkAlpha'        Link opacity (1-100).
%
%     'LinkLayer'        Link layer.
%
%     'CallCircos'       Call circos to generate the plot.
%                        'yes' or 'no'                        default: 'no'
%
%   Circos is a Perl-based software package developed by Martin Krzywinski
%   and can be obtained from http://circos.ca/software/download/.
%
%   On Ubuntu, you can install Circos using apt-get:
%   $ sudo apt-get install circos libsvg-perl
%
%   Examples:
%      nChr = 20;
%      chrLbl = strcat('label',{' '},num2str((1:nChr)'));
%      chrSiz = 100 + randi(20, [nChr 1]) - 10;
% 
%      nL = 2;
%      lnks = zeros(4,nL);
%      lnks(1:4,1) = [1 1 3 1];
%      lnks(1:4,2) = [2 5 3 7];
% 
%      genCircosConf(chrLbl, chrSiz, lnks, '/tmp/circos_ex1a', ...
%        'CallCircos', 'yes');
% 
%      genCircosConf(chrLbl, chrSiz, lnks, '/tmp/circos_ex1b', ...
%        'ChrColor', 'red', 'CallCircos', 'yes');
% 
%      chrGrp = [1 1 1 1 1 2 2 2 3 3 4.*ones(1, nChr-10)];
%      genCircosConf(chrLbl, chrSiz, lnks, '/tmp/circos_ex1c', ...
%        'ChrGroup', chrGrp, 'CallCircos', 'yes');
%
%   See also RGB2COLORDEF.
%
%   Author: Kristian Loewe

%% default opts (extended options for this wrapper-program)
chrClr         = 'vlgrey';
chrGrpSpacing  = '20u';
linkClrMapName = 'cmap';
linkClrMap     = [];
linkClr        = 'black';
linkLayer      = [];
linkAlpha      = [];
callCircos     = 'no';

%% default opts (original circos options)
opts.karyotype                        = 'karyotype.conf';
opts.chromosome_units                 = '20';
opts.chromosome_display_default       = 'yes';
opts.show_ticks                       = 'no';
opts.show_tick_labels                 = 'no';

% image
opts.image.dir                        = '.';
opts.image.file                       = 'circos';
opts.image.png                        = 'no';
opts.image.svg                        = 'yes';
opts.image.radius                     = '1000p';
opts.image.angle_offset               = '-90';
opts.image.auto_alpha_colors          = 'yes';
opts.image.auto_alpha_steps           = '100';
opts.image.background                 = 'white'; %'transparent';

% ideogram
opts.ideogram.spacing.default         = '4u';
opts.ideogram.thickness               = '0.01r';
opts.ideogram.stroke_thickness        = '1';
opts.ideogram.stroke_color            = 'black';
opts.ideogram.fill                    = 'yes';
opts.ideogram.fill_color              = 'black_a5';
opts.ideogram.radius                  = '0.9r';
opts.ideogram.show_label              = 'yes';
opts.ideogram.label_font              = 'condensedbold';
opts.ideogram.label_radius            = 'dims(ideogram,radius) + 0.01r';
opts.ideogram.label_size              = '20';
opts.ideogram.label_color             = 'black';
opts.ideogram.label_parallel          = 'no';
opts.ideogram.band_stroke_thickness   = '1';
opts.ideogram.show_bands              = 'yes';
opts.ideogram.fill_bands              = 'yes';
opts.ideogram.band_transparency       = '1';

% ticks
opts.ticks.grid_start                 = 'dims(ideogram,radius_inner)-0.5r';
opts.ticks.grid_end                   = 'dims(ideogram,radius_outer)+100';
opts.ticks.skip_first_label           = 'no';
opts.ticks.skip_last_label            = 'no';
opts.ticks.radius                     = 'dims(ideogram,radius_outer)';
opts.ticks.tick_separation            = '2p';
opts.ticks.min_label_distance_to_edge = '0p';
opts.ticks.label_separation           = '5p';
opts.ticks.label_offset               = '2p';
opts.ticks.label_size                 = '8p';
opts.ticks.multiplier                 = '1e-6';
opts.ticks.color                      = 'black';
opts.ticks.tick{1}.spacing            = '5u';
opts.ticks.tick{1}.size               = '5p';
opts.ticks.tick{1}.thickness          = '2p';
opts.ticks.tick{1}.color              = 'black_a5';
opts.ticks.tick{1}.show_label         = 'no';
opts.ticks.tick{1}.label_size         = '8p';
opts.ticks.tick{1}.label_offset       = '0p';
opts.ticks.tick{1}.format             = '%d';
opts.ticks.tick{1}.grid               = 'yes';
opts.ticks.tick{1}.grid_color         = 'grey';
opts.ticks.tick{1}.grid_thickness     = '1p';
opts.ticks.tick{2}.spacing            = '10u';
opts.ticks.tick{2}.size               = '8p';
opts.ticks.tick{2}.thickness          = '2p';
opts.ticks.tick{2}.color              = 'black_a5';
opts.ticks.tick{2}.show_label         = 'yes';
opts.ticks.tick{2}.label_size         = '12p';
opts.ticks.tick{2}.label_offset       = '0p';
opts.ticks.tick{2}.format             = '%d';
opts.ticks.tick{2}.grid               = 'yes';
opts.ticks.tick{2}.grid_color         = 'dgrey';
opts.ticks.tick{2}.grid_thickness     = '1p';

% links
opts.links.link{1}.file               = 'links.dat';
opts.links.link{1}.radius             = '0.99r';
opts.links.link{1}.bezier_radius      = '0.5r';
opts.links.link{1}.color              = linkClr;
opts.links.link{1}.thickness          = '1';

%%
if isnumeric(chrLbl)
  chrLbl = strtrim(cellstr(num2str(chrLbl(:))));
else
  assert(iscell(chrLbl));
end
assert(isvector(chrSiz) && numel(chrLbl) == numel(chrSiz));

nChr = numel(chrLbl);
chrOrd = 1:nChr;
chrGrp = ones(nChr, 1);

if ndims(lnks) == 2                                           %#ok<ISMAT>
  lnks = reshape(lnks, [2 2 size(lnks, 2)]);
end
nLnk = size(lnks, 3);

%% varargs
for i=1:2:size(varargin,2)

  pn = varargin{i};
  pv = varargin{i+1};

  switch pn
    case 'ChrColor'
      assert(isvector(pv));
      chrClr = pv;
    case 'ChrOrder'
      assert(isvector(pv) && numel(pv) == nChr);
      chrOrd = pv;
    case 'ChrGroup'
      assert(isvector(pv) && numel(pv) == nChr);
      chrGrp = pv;
    case 'ChrGroupSpacing'
      assert(ischar(pv) && pv(end) == 'u');
      chrGrpSpacing = pv;
    case 'LinkColor'
      assert(isvector(pv));
      if ischar(pv)
        linkClr = pv;
        opts.links.link{1}.color = linkClr;
      elseif isnumeric(pv) && numel(pv) == nLnk
        linkClr = pv;
      end
    case 'LinkColorMap'
      linkClrMap = pv;
    case 'LinkAlpha'
      assert(isnumeric(pv) && all(pv <= 100 & pv >= 1));
      assert(isscalar(pv) || (isvector(pv) && numel(pv) == nLnk));
      linkAlpha = 100 - pv + 1;
      if isscalar(linkAlpha)
        linkAlpha = num2str(linkAlpha);
      end
    case 'LinkLayer'
      assert(isscalar(pv) ...
        || (isvector(pv) && isnumeric(pv) && numel(pv) == nLnk));
      linkLayer = pv;
    case 'CallCircos'
      assert(ismember(pv, {'yes','no'}));
      callCircos = pv;
    otherwise
      error('Unexpected parameter identifier found.');
  end
end

if ischar(linkClr) && ~isempty(linkAlpha) && ischar(linkAlpha)
  opts.links.link{1}.color = [linkClr,'_a',linkAlpha];
end

if ~exist('chrGrpLbl','var') && numel(unique(chrGrp)) == 1
  chrGrpLbl = {''};
else
  chrGrpLbl = cellstr(num2str(flat(unique(chrGrp))));
end
assert(numel(chrGrpLbl) == numel(unique(chrGrp)));

if ischar(chrClr)
  chrClr = repmat({chrClr},nChr,1);
else
  assert(iscell(chrClr) && all(cellfun(@ischar, chrClr)) ...
    && numel(chrClr) == nChr);
end

%% create output directory
if ~isdir(outdir); mkdir(outdir); end

%% write karyotype.conf
fid = fopen(fullfile(outdir,opts.karyotype), 'w');
for iChr = 1:nChr
lbl = chrLbl{iChr};
  fprintf(fid, 'chr\t-\tr%d\t%s\t0\t%d\t%s\n', ...
    iChr, lbl, chrSiz(iChr), chrClr{iChr});
end
fclose(fid);

%% write ideogram.conf
fid = fopen(fullfile(outdir,'ideogram.conf'), 'w');

fprintf(fid, '%s\n', '<ideogram>');

fprintf(fid, '%s\n', '<spacing>');
fprintf(fid, '%s\n', ['default = ',opts.ideogram.spacing.default]);

% gaps between groups of chromosomes
grpSwitchIdx = find(diff(chrGrp(chrOrd))~=0);
if numel(grpSwitchIdx) > 0
  if numel(grpSwitchIdx) == numel(chrGrpLbl) - 1
    for iSwitch = 1:numel(grpSwitchIdx)
      id1 = num2str(chrOrd(grpSwitchIdx(iSwitch)));
      id2 = num2str(chrOrd(grpSwitchIdx(iSwitch) + 1));
      fprintf(fid, '%s\n', ['<pairwise r',id1,';r',id2,'>']);
      fprintf(fid, '%s\n', ['spacing = ',chrGrpSpacing]);
      fprintf(fid, '%s\n', '</pairwise>');
    end
  end
  idLast = num2str(chrOrd(end));
  idFirst = num2str(chrOrd(1));
  fprintf(fid, '%s\n', ['<pairwise r',idLast,';r',idFirst,'>']);
  fprintf(fid, '%s\n', ['spacing = ',chrGrpSpacing]);
  fprintf(fid, '%s\n', '</pairwise>');
end

fprintf(fid, '%s\n',  '</spacing>');

writeFields(fid, opts.ideogram);

fprintf(fid, '%s\n', '</ideogram>');
fclose(fid);

%% write colors.conf
if ~isempty(linkClrMap)
  rgb2colordef(linkClrMap, linkClrMapName, fullfile(outdir,'colors.conf'));
end

%% write ticks.conf
fid = fopen(fullfile(outdir,'ticks.conf'), 'w');
fprintf(fid, '%s\n', ['show_ticks = ', opts.show_ticks]);
fprintf(fid, '%s\n', ['show_tick_labels = ', opts.show_tick_labels]);
fprintf(fid, '\n');
writeFields(fid, opts.ticks, 'ticks');
fclose(fid);

%% write links.dat
fid = fopen(fullfile(outdir,'links.dat'), 'w');

for iLnk = 1:nLnk

  % valid chr id?
  assert(ismember(lnks(1,1,iLnk), 1:nChr) ...
    && ismember(lnks(1,2,iLnk), 1:nChr));
  
  % link-specific color and/or alpha
  colorstr = '';
  if ~isempty(linkClr) && ~ischar(linkClr)
    colorstr = ['color=',linkClrMapName,num2str(linkClr(iLnk))];
    if ~isempty(linkAlpha) && ~ischar(linkAlpha)
      colorstr = [colorstr '_a' num2str(linkAlpha(iLnk))];
    else
      colorstr = [colorstr '_a' linkAlpha];
    end
  elseif ~isempty(linkAlpha) && ~ischar(linkAlpha)
    colorstr = ['color=' linkClr '_a' num2str(linkAlpha(iLnk))];
  end
  
  % link-specific z-level
  zstr = '';
  if ~isempty(linkLayer) && ~ischar(linkLayer)
    zstr = ['z=' num2str(linkLayer(iLnk))];
  end
  
  % concatenate options
  optstr = [colorstr ',' zstr];
  if optstr(1) == ','
    optstr = optstr(2:end);
  elseif optstr(end) == ','
    optstr = optstr(1:end-1);
  end
  
  roiA = lnks(1,1,iLnk);
  roiB = lnks(1,2,iLnk);
  
  l = sprintf('r%d\t%d\t%d\tr%d\t%d\t%d\t%s', ...
    roiA, ...              % region A
    lnks(2,1,iLnk), ...    % start pos wrt A
    lnks(2,1,iLnk)+1, ...  % end pos wrt A
    roiB, ...              % region B
    lnks(2,2,iLnk), ...    % start pos wrt B
    lnks(2,2,iLnk)+1, ...  % end pos wrt B
    optstr);          % additional options

  fprintf(fid, '%s\n', l);
end

fclose(fid);

%% write links.conf
fprintf('%d links.\n',nLnk);
fid = fopen(fullfile(outdir,'links.conf'), 'w');
writeFields(fid, opts.links, 'links');
fclose(fid);

%% write image.conf
fid = fopen(fullfile(outdir,'image.conf'), 'w');
writeFields(fid, opts.image, 'image');
fclose(fid);

%% work around problem in ubuntu
[rc,distro] = system('awk -F= ''/^NAME/{print $2}'' /etc/os-release');
assert(~rc);
distro = strrep(distro, sprintf('\n'), '');
if strcmp(distro, '"Ubuntu"')
  [rc,pc] = system('which circos');
  assert(~rc);
  pc = strrep(pc, sprintf('\n'), '');
  if strcmp(pc, '/usr/bin/circos') ...
      && fileExists('/etc/circos/housekeeping.conf')
    rc = system(['ln -sfn /etc/circos ',outdir,'/etc']);
    assert(~rc, 'Could not create symlink.');
  end
end
% See: https://bugs.launchpad.net/ubuntu/+source/circos/+bug/1547519

%% write main.conf
fid = fopen(fullfile(outdir,'main.conf'), 'w');
fprintf(fid, '%s\n\n', ['karyotype = ', opts.karyotype]);
fprintf(fid, '%s\n',   ['chromosomes_units = ', opts.chromosome_units]);
fprintf(fid, '%s\n',   ['chromosomes_display_default = ', ...
  opts.chromosome_display_default]);
if exist('chrOrd', 'var')
  fprintf(fid, '%s',   'chromosomes_order = ');
  for iChr = 1:nChr-1
    fprintf(fid, '%s', ['r',num2str(chrOrd(iChr)),',']);
  end
  fprintf(fid, '%s\n\n', ['r',num2str(chrOrd(nChr))]);
end
fprintf(fid, '%s\n',   '<colors>');
fprintf(fid, '%s\n',   '<<include etc/colors.conf>>');
if ~isempty(linkClrMap)
  fprintf(fid, '%s\n', '<<include colors.conf>>');
end
fprintf(fid, '%s\n\n', '</colors>');
fprintf(fid, '%s\n',   '<fonts>');
fprintf(fid, '%s\n',   '<<include etc/fonts.conf>>');
fprintf(fid, '%s\n\n', '</fonts>');
fprintf(fid, '%s\n',   '<patterns>');
fprintf(fid, '%s\n',   '<<include etc/patterns.conf>>');
fprintf(fid, '%s\n\n', '</patterns>');
fprintf(fid, '%s\n\n', '<<include etc/housekeeping.conf>>');
fprintf(fid, '%s\n\n', 'file_delim* = \t');
fprintf(fid, '%s\n\n', '<<include ideogram.conf>>');
fprintf(fid, '%s\n\n', '<<include ticks.conf>>');
fprintf(fid, '%s\n\n', '<<include links.conf>>');
fprintf(fid, '%s\n',   '<<include image.conf>>');

fclose(fid);

%% call circos to generate output image(s)
if strcmp(callCircos,'yes')
  cdir = pwd;
  cd(outdir);
  !circos -conf main.conf > circos.log
  cd(cdir);
end
end

function writeFields(fid,S,name)
if exist('name','var')
  fprintf(fid, '<%s>\n', name);
end
f = fieldnames(S);
for iF = 1:numel(f)
  switch class(S.(f{iF}))
    case 'struct'
      % writeFields(fid, S.(f{iF}));
    case 'cell'
      for iC = 1:numel(S.(f{iF}))
        writeFields(fid, S.(f{iF}){iC}, f{iF});
      end
    otherwise
      fprintf(fid, '%s = %s\n', f{iF}, S.(f{iF}));
  end
end
if exist('name','var')
  fprintf(fid, '</%s>\n', name);
end
end
