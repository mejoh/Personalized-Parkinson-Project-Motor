function pf_ana_VOI(conf,varargin)
%
% PF_ana_VOI(conf, varargin) is a tool for performing different types of 
% analyses  on your created VOI timeseries. Specifically, these are useful 
% if you use VOI timeseries for Dynamic Causal Modeling. 
%
% Specify which analyses you would like to perform:
%     -   'plotCoord': this will plot the X, Y and Z coordinates of all
%          your subjects + mean, 25th and 75th percentile.
%     -   'plotEuclDist': this will plot the euclidian distance between
%          your VOI coordinates and some predefined reference coordinates 
%          (e.g. group maximum) + mean, 25th and 75th percentile.
%     -   'plotNvoxels'; this will plot the amount of voxels for every VOI
%          + the mean, 25th and 75th percentile
%     -   'concatTS': 

% For all functions of the ParkFunC toolbox you only have to change
% the configuration to your corresponding dataset and change the nargin if
% you don't use this script as a function. The rest should work.

% Created by Michiel Dirkx (2014)  
% Contact: michieldirkx@gmail.com
% $ParkFunC

%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

tic

if nargin < 2   % Use this to define varargin if you don't use this script as a function
%     varargin{1}  =   'plotCoord';
%     varargin{1}  =   'plotEuclDist';
%     varargin{1}  =   'plotNvoxels';
    varargin{1}     =   'concatVOI';
end

%--------------------------------------------------------------------------

%% Configuration (enter your settings here)
%--------------------------------------------------------------------------

if nargin < 1

close all

% ---- Directories ---- %

conf.dir.root   =  '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/M43_ICA-AROMAnonaggr_spmthrsh0c25_FARM1_han2s_EMG-log_broadband_retroicor18r-exclsub/RS/VOIs/Mask_P=1-none'; % root directory of your VOI timeseries (contains all the subject subfolders)


conf.dir.sub    = {'OFF';'ON'}; %{'Sphere_P=05-none';};                                                       % Subfolders of root directory (seperated by semicolon). If you only have a root -> use ''
conf.dir.save   = fullfile(conf.dir.root,'OFFON');

% ----- Subjects   -----%

conf.sub.name   =   {
                     'p30';'p08';'p11';'p28';'p14'; %5
                     'p18';'p27';'p02';'p60';'p59'; %10
                     'p62';'p38';'p49';'p40';'p19'; %15
                     'p29';'p36';'p42';'p33';'p71'; %20
                     'p21';'p70';'p64';'p50';'p72'; %25
                     'p47';'p56';'p24';'p48';'p43'; %30
                     'p63';'p75';'p74';'p76';'p77'; %35
                     'p78';'p73';'p80';'p81';'p82'; %40
                     'p83';                         %41
                     };     
conf.sub.hand   =   {
                     'R'  ;'R'  ;'R'  ;'L'  ;'R'  ;
                     'L'  ;'R'  ;'R'  ;'L'  ;'L'  ;
                     'L'  ;'L'  ;'L'  ;'R'  ;'L'  ;
                     'L'  ;'R'  ;'L'  ;'R'  ;'L'  ;
                     'L'  ;'R'  ;'L'  ;'L'  ;'L'  ;
                     'L'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                     'L'  ;'L'  ;'R'  ;'R'  ;'R'  ;
                     'R'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                     'L'  ;
                     };
                 
conf.sub.sess1  =   {
                     'OFF';'OFF';'ON' ;'OFF';'OFF';
                     'OFF';'ON' ;'OFF';'ON' ;'OFF';
                     'ON' ;'ON' ;'ON' ;'OFF';'OFF';
                     'ON' ;'OFF';'OFF';'ON' ;'ON' ;
                     'OFF';'OFF';'ON' ;'ON' ;'ON' ;
                     'OFF';'ON' ;'ON' ;'OFF';'ON' ; 
                     'OFF';'ON' ;'OFF';'ON' ;'OFF';
                     'ON' ;'ON' ;'OFF';'ON' ;'ON' ;
                     'OFF';
                     }; % Define if first session was OFF (placebo) or ON (madopar)


% sel =   [30 08 11 28 14 27 62 42 50 72 47 75 74 73 78 80 81 82 83 ...     % ALL 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 24 48 43 76 77];                                           

sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ...   
         18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL minus confirmed doubts

sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);


% ----- VOI settings ----%

conf.voi.roi.name  = {
%                       'GPi';                 % eg. {'VOI_V1','VOI_V5','VOI_PPC'}. Names should be identical to your VOI's. Fill in HAND at places that need to be replaced by R or L 
%                       'MC'  ;                   
%                       'VLT' ;
%                       'CBLM'
%                       'GPe';
%                       'STN';
                      'INandRESI-CBLM';
                      };
conf.voi.name      = '/VOI_/&/CurROI/&/CurSub/&/.mat/'; % Name of your VOI files. You can use wildcards (see PF_find_fullfile). Options: 'CurROI' -> conf.voi.roi | 'CurSub' -> conf.sub.name
% conf.voi.VOIhand   = [1 1 1 0 1 1];                  % fill in if you take the contralateral VOI (=1) or ipsilateral (=0)   
conf.voi.VOIhand   = 0;
conf.voi.RefCoor   = {[];                        % Reference Coordinates (the VOI coordinates will be compared to these, i.e. the euclidian distance will be plotted)
                     [28; -26;  62];
                     [12; -18;   2];
                     [18; -50; -20];};                 

% ---- Analysis Settings ---%

conf.plotCoord.RefVal =  1;                       % If =1, then the function plot_Coord will also plot the reference values in black.

% --- TC Concatenation --- %

conf.conc.save        =  'OFFON';                 % This postfix will replace the session number of the VOI

end

%--------------------------------------------------------------------------

%% Data Analysis
%--------------------------------------------------------------------------

H = strfind(varargin,'plotCoord');      % Plot Coordinates
if isempty([H{:}]) == 0
    plot_Coord(conf);
end

H = strfind(varargin,'plotEuclDist');   % Plot Euclidian Distances
if isempty([H{:}]) == 0
    plot_EuclDist(conf);
end

H = strfind(varargin,'plotNvoxels');   % Plot Euclidian Distances
if isempty([H{:}]) == 0
    plot_nVoxels(conf);
end

H = strfind(varargin,'concatVOI');   % Plot Euclidian Distances
if isempty([H{:}]) == 0
    concatVOI(conf);
end

%--------------------------------------------------------------------------

%% Cooling Down
%--------------------------------------------------------------------------

T        = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T) ' seconds!!'])

%--------------------------------------------------------------------------

%% ------------------------ Analysis Functions ---------------------------%%

function plot_Coord(conf)

nROI    =   length(conf.voi.roi.name);
nSub    =   length(conf.sub.name);
nDirs   =   length(conf.dir.sub);
xS      =   1;                      % initiate x-axis coordinates
cnt     =   1;                      % initiate counter for coordinate matrix

Coor    =   nan(nROI*3,nSub);       % initiate Matrix for storage of all coordinates
xCoor   =   nan(3,nSub);            % initiate Matrix for storage of all figure x-axis values
xLab    =   {'X';'Y';'Z'};          % for Xtick

% -- For every Sub Directory -- %

for h = 1:nDirs
    
    CurDirSub   = conf.dir.sub{h};
    CurDir      = fullfile(conf.dir.root,CurDirSub);

    figure
    
    % -- For every ROI, then for every subject -- %
    
    for i = 1:nROI
        
        x   =   xS;
        
        for j = 1:nSub
            
            clear Y xY
            
            CurFile = pf_findfile(CurDir,conf.voi.name,'conf',conf,'CurSub',j,'CurROI',i);        % Find the right file
            
            load(fullfile(CurDir,CurFile))
            
            CurCoor         =   xY.xyz;
            CurCoor(1)      =   abs(CurCoor(1));    % Don't care about handedness here
            Coor(cnt,j)     =   CurCoor(1);         % Store all x-coordinate
            Coor(cnt+1,j)   =   CurCoor(2);         % Store all y-coordinate
            Coor(cnt+2,j)   =   CurCoor(3);         % Store all z-coordinate
            
            plot(x,CurCoor(1),'.')                  % Plot X coordinate
            hold on
            plot((x+0.1*nSub+1),CurCoor(2),'.')     % Plot Y coordinate
            plot((x+2*(0.1*nSub+1)),CurCoor(3),'.') % Plot Z coordinate
            
            xCoor(1:3,j) = [x;(x+0.1*nSub+1);(x+2*(0.1*nSub+1))]; % Row one: X values; Row two: Y values; Row three: Z values
            x            = x + 0.1;
        end
        
        for k = 1:3     % X; Y;Z patches - Yes, I know this isn't very nice programming, just didn't want to change everything again
            P               = prctile(Coor(cnt,:),[25 75]);
            mP              = mean(Coor(cnt,:));
            plot([xCoor(k,1) xCoor(k,end)],[mP mP],'r-','linewidth',2)
            if isempty(conf.voi.RefCoor{i}) == 0 && conf.plotCoord.RefVal == 1
                plot([xCoor(k,1) xCoor(k,end)],[conf.voi.RefCoor{i}(k) conf.voi.RefCoor{i}(k)],'k-','linewidth',2)
            end
            pat  = patch([xCoor(k,1) xCoor(k,end) xCoor(k,end) xCoor(k,1)],[P(1) P(1) P(2) P(2)],'b');
            set(pat,'EdgeColor','b','FaceColor','none')
            Center(cnt,:)   = [xCoor(k,1) xCoor(k,end)];
            xtick{cnt}      = [conf.voi.roi.name{i} ' ' xLab{k}];
            cnt             = cnt +1;
        end
        
        xS        = (x+2*(0.1*nSub+1)) + 2;
        
    end
    Centers = mean(Center,2);
    title(['MNI Coordinates of VOIs in ' conf.dir.sub{h}],'fontsize',11,'fontweight','b','Interpreter','none')
    set(gca,'Xtick',Centers,'Xticklabel',xtick,'fontsize',11)
    xlabel('Volumes of Interest','fontsize',11,'fontweight','b')
    ylabel('MNI Coordinate (mm)','fontsize',11,'fontweight','b')
    axis([0 (xS - 1) min(min(Coor))*1.2 max(max(Coor))*1.2])
    
end

function plot_EuclDist(conf)

nROI        =   length(conf.voi.roi.name);
nSub        =   length(conf.sub.name);
nDirs       =   length(conf.dir.sub);
EuclDist    =   nan(nROI,nSub);
xS          =   1;

for g = 1:nDirs
    
    CurDirSub   = conf.dir.sub{g};
    CurDir      = fullfile(conf.dir.root,CurDirSub);
    
    figure
    
    for h = 1:nROI
        
        x       =   xS;
        
        for i = 1:nSub
            
            clear Y xY
            
            CurFile = pf_findfile(CurDir,conf.voi.name,'conf',conf,'CurSub',i,'CurROI',h);
            
            load(fullfile(CurDir,CurFile));
            
            CurCoor    =    xY.xyz;
            CurCoor(1) =    abs(CurCoor(1));            % Don't care about left or right side
            CurRefCoor =    conf.voi.RefCoor{h};
            
            if isempty(CurRefCoor) == 0
                diffCoor         =    abs(CurCoor - conf.voi.RefCoor{h});
                EuclDist(h,i)    =    pf_getray(diffCoor(1),diffCoor(2),diffCoor(3));      % Get the Euclidian distance from reference values
            elseif isempty(CurRefCoor) == 1
                EuclDist(h,i)    =    nan(1,1);
            end
            
            plot(x(i),EuclDist(h,i),'.')
            hold on
            
            x(i+1)  = x(i) + 0.1;
        end
        
        P        = prctile(EuclDist(h,:),[25 75]);
        mP       = nanmean(EuclDist(h,:));
        
        plot([x(1) x(end-1)],[mP mP],'r-','linewidth',2)
        pat  = patch([x(1) x(end-1) x(end-1) x(1)],[P(1) P(1) P(2) P(2)],'b');
        set(pat,'EdgeColor','b','FaceColor','none')
        Center(h,:)  = [x(1) x(end-1)];
        
        if isnan(EuclDist(h,:)) == 1
            text(x(1),10,'No reference values available')
        end
        
        xS       = xS + nSub*0.1 + 2;
        
    end
    
    Centers = mean(Center,2);
    axis([0 (x(end)+1) 0 max(max(EuclDist))*1.1])
    title(['Euclidian distances of VOI coordinates compared to reference values for VOIs in ' conf.dir.sub{g}],'fontsize',11,'fontweight','b','Interpreter','none')
    set(gca,'Xtick',Centers,'Xticklabel',conf.voi.roi.name,'fontsize',11)
    xlabel('Volumes of Interest','fontsize',11,'fontweight','b')
    ylabel('Euclidean Distance (mm)','fontsize',11,'fontweight','b')
    
end

function plot_nVoxels(conf)

nROI        =   length(conf.voi.roi.name);
nSub        =   length(conf.sub.name);
nDirs       =   length(conf.dir.sub);
nVoxels     =   nan(nROI,nSub);
xS          =   1;

for g = 1:nDirs
    
    CurDirSub   = conf.dir.sub{g};
    CurDir      = fullfile(conf.dir.root,CurDirSub);
    
    figure
    for h = 1:nROI
        
        x       =   xS;
        
        for i = 1:nSub
            
            clear Y xY

            CurFile =   pf_findfile(CurDir,conf.voi.name,'conf',conf,'CurSub',i,'CurROI',h);
            load(fullfile(CurDir,CurFile));
            
            nVoxels(h,i)    =   length(xY.XYZmm);
            
            plot(x(i),nVoxels(h,i),'.')
            hold on
            
            x(i+1)  = x(i) + 0.1;
        end
        
        P        = prctile(nVoxels(h,:),[25 75]);
        mP       = nanmean(nVoxels(h,:));
        
        plot([x(1) x(end-1)],[mP mP],'r-','linewidth',2)
        pat  = patch([x(1) x(end-1) x(end-1) x(1)],[P(1) P(1) P(2) P(2)],'b');
        set(pat,'EdgeColor','b','FaceColor','none')
        Center(h,:)  = [x(1) x(end-1)];
        
        xS       = xS + nSub*0.1 + 2;
        
    end
    
    Centers = mean(Center,2);
    axis([0 (x(end)+1) 0 max(max(nVoxels))*1.1])
    title(['Amount of voxels for every VOI in folder ' conf.dir.sub{g}],'fontsize',11,'fontweight','b','Interpreter','none')
    set(gca,'Xtick',Centers,'Xticklabel',conf.voi.roi.name,'fontsize',11)
    xlabel('Volumes of Interest','fontsize',11,'fontweight','b')
    ylabel('nVoxels','fontsize',11,'fontweight','b')
    
end
        
function concatVOI(conf)

fprintf('%s\n','% -------------- Concatenating VOIs -------------- %')
fprintf('%s\n\n','NB: Only merging Time Series. Voxel activity values (xY.Ic/.v/.s) will be removed')

% --- Initiate Loop parameters --- %

nSub    =   length(conf.sub.name);
nDir    =   length(conf.dir.sub);
nVOI    =   length(conf.voi.roi.name);
TC      =   cell(nDir,1);                   % Storage of TC for concatenation
TS      =   cell(nDir,1);

% --- For every subject --- %

for a = 1:nSub
    
    CurSub  =   conf.sub.name{a};
    
    % --- For every VOI --- %
    
    for b = 1:nVOI
        
        CurVOI  =   conf.voi.roi.name{b};
        
        % --- For every directory (containing equiv TS) --- %
        
        for c = 1:nDir
            
            clear Y xY
            CurDir  =   fullfile(conf.dir.root,conf.dir.sub{c});
            CurTS   =   pf_findfile(CurDir,conf.voi.name,'conf',conf,'CurROI',b,'CurSub',a);
            
            disp(['- Storing ' CurTS])
            
            % --- Load CurVOI --- %
            
            load(fullfile(CurDir,CurTS));
            
            CurTC    =   Y;                        % Remove the VOI label
            CurX0    =   xY.X0;
            Cury     =   xY.y;
            Curu     =   xY.u;
            
            % --- Store TC and TS --- %
            
            if c == 1
                cY   =  CurTC;  % Time course (Y)
                cX0  =  CurX0;  % XO time course (xY)
                cy   =  Cury;   % time course in (xY)
                cu   =  Curu;   % time course (xY)
                cXY  =  CurTS;  % Session name (xY)
            else
                cY   =  vertcat(cY,CurTC);
                cX0  =  vertcat(cX0,CurX0);
                cy   =  vertcat(cy,Cury);
                cu   =  vertcat(cu,Curu);
                cXY  =  [cXY ' & ' CurTS];
            end
            
        end
        
        % --- Concatenate VOI --- %
        
        Y              =   cY;
        xY.SessOrig    =   cXY;
        xY.Sess        =   1;
        xY.X0          =   cX0;
        xY.y           =   cy;
        xY.u           =   cu;
        
        % --- Remove voxel activity fields --- %
        
        fields     =    {'Ic';'v';'s'};
        xY         =    rmfield(xY,fields);
        
        % --- Save Concatenated TC --- %
        
        if ~exist(conf.dir.save,'dir'); mkdir(conf.dir.save); end
        savnam  =   [CurTS(1:end-5) conf.conc.save '.mat'];
        save(fullfile(conf.dir.save,savnam),'xY','Y')
        
        fprintf('%s\n\n','-- These VOIs are now concatenated and saved')
        
    end
    
end
            
            
            
            
    
    


        
    
    








