function [varargout] = pf_dcm_ana(conf,varargin)
%
% Analysis script for your estimated DCM.mat files. You can use the 
% following functions (which you have to enter as varargin):
%   -   'sModPar': look at the inter-subject variability of winning models.
%                  UNDER CONSTRUCTION
%   -   'ModPar' : plot the model parameters of all subjects in a boxplot
%                  and perform a ttest.
%   -   'AvgPar' : Average the model parameters of one model for all
%                  subject and execute spm_dcm_explore (explain variance)
%   -   'CorrPar': Correlate specified model parameters with other
%                  subject-specific parameters stored in a .mat file
%
%

% �Michiel Dirkx, 2014
% $ParkFunC

%% Warming Up

if nargin < 2
%     varargin{1}     =   'sModVar';        % Subject Model Variability (not finished yet)
%     varargin{1}     =   'ModPar';         % Plot Model parameters of all subjects
    varargin{1}     =   'AvgPar';         % Plot average parameters and explained variance 
%     varargin{1}     =   'CorrPar';         % Correlations on parameters
end

%% Configuration

if nargin < 1

clc; close all; tic;
    
% --- Directories (all) --- %

% conf.dir.root       =   '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/DCM_Models/SPM12';        % Directory containing all your root DCM analyses
conf.dir.root       =   '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/DCM_Models/COCO/NET/';

% - CorrPar - %

conf.dir.par        =   fullfile(conf.dir.root,'Subject Parameters (Cohort 1 and 2)');              % Subject parameters
conf.dir.corr.save  =   fullfile(conf.dir.par,'Correlation figures');                               % Directory where you want to save you correlation figures
                 
% --- Subjects (all) --- %

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


% sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ... 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts     

sel = [
         2 8 11 18 21 27 28 29 30 36 38 40 42 47 48 49 50 59 60 62 70 71 72 74 75 77 81 83 ... %Definitely tremor
         14 ...                                                                              %maybe tremor
         33 56 64 76 ...                                                                         %Tremor but noisy EMG
      ]; %TREMOR      
     
sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

% --- DCM files (all) --- %

conf.mod.name.main  =   {
                             '|MA12_*';
                       };    
                       
sel                    =    1;
% sel                      =  [3:9];
% sel                    =       31:37;       % No Input
% sel                    =    38;%36:41;       % 2 input
% sel                    =    46; %42:45;       % 3 input
conf.mod.name.main     =   conf.mod.name.main(sel);
conf.mod.name.sub      =   {'1_s*'};                         % If your model folders contain subfolders, you can speficy it here (enter '' if not applicable)
conf.mod.dcm           =   '|DCM_*';                          % Name of your DCM.mat file (will use pf_findfile)   

% --- Model Parameters (ModPar) --- %

conf.mod.options.est   =   {'Ep'};                               % Specify estimated parameters: 'Ep': will analyse the mean Estimated posterior of subjects; 'Pp': posterior probiliaty; 'Vp': variance of posterior probability; 'all': all options
conf.mod.options.coup  =   {'c'};                        % Specify coupling parameters: 'A': fixed connectivity parameters; 'B': modulatory; 'C': input;
conf.mod.plot          =   1;
conf.mod.save          =   0;
conf.mod.axe           =   'maxplot';                         % Choose your y-axis. 'maxall': adjust to maximum of all values. 'maxplot': adjust to maximum of current plot. []: choose your own range

% --- Subject (clinical) Parameters (CorrPar) --- %

conf.par.mod.est        =   {'Ep'};                    % Specify estimated parameters for correlation: 1) 'Ep' 2) 'Pp' 3) 'Vp'                            
conf.par.mod.coup       =   {'A'};                     % Specify coupling parameters: 'A': fixed connectivity parameters; 'B': modulatory; 'C': input;                                                                        
conf.par.mod.con        =   [1 1 1 1;                  % The connections of the model you want to correlate
                             1 1 1 1;
                             1 1 1 1;
                             1 1 1 1 ];


conf.par.file           =   'parDCM6.mat';                % File name of your .mat parameter file (in folder conf.dir.par); 
% conf.par.sub           = 1:19; % cohort 1 for sPar
conf.par.sub           = 20:38;  % Cohort 2
% conf.par.sub            = 20:41;                           % Both cohorts subject selection from par file
conf.par.field          =   {                             %  % Choose the fields containing the parameters of your parameter .mat file in conf.dir.par. Use a new row for every subfield (also if you want to select those). Example: conf.par.field = {{'emg' 'fmri'};'select'} will choose fields 'emg' and 'fmri', and will let you interactively select the second layer fields. 
%                              {'emg';'off'; 'totpow'}
%                              {'emg';'off';'logtotpow'}
%                              {'emg';'off';'zlogtotpow'}
%                              {'emg';'off';'stdderiv1'}
%                              {'emg';'on'; 'totpow'}
%                              {'emg';'on';'logtotpow'}
%                              {'emg';'on';'zlogtotpow'}
                             
                             {'fmri';'off';'gpideriv1'}
                             {'fmri';'on';'gpideriv1'}
                             
%                              {'updrs';'off';'rue'}
%                              {'updrs';'off';'rle'}
%                              {'updrs';'off';'lue'}
%                              {'updrs';'off';'lle'}
%                              {'updrs';'off';'affue'}
%                              {'updrs';'off';'unaffue'}
%                              {'updrs';'off';'affle'}
%                              {'updrs';'off';'unaffle'}
%                              {'updrs';'off';'totrest'}
%                              {'updrs';'off';'totrestaff'}
%                              {'updrs';'on';'rue'}
%                              {'updrs';'on';'rle'}
%                              {'updrs';'on';'lue'}
%                              {'updrs';'on';'lle'}
%                              {'updrs';'on';'affue'}
%                              {'updrs';'on';'unaffue'}
%                              {'updrs';'on';'affle'}
%                              {'updrs';'oun';'unaffle'}
%                              {'updrs';'on';'totrest'}
%                              {'updrs';'on';'totrestaff'}
%                              {'updrs';'dopares';'per';'totrest'}
%                              {'updrs';'dopares';'per';'affrest'}
%                              {'updrs';'dopares';'per';'affUErest'}
%                              {'updrs';'dopares';'diff';'totrest'}
%                              {'updrs';'dopares';'diff';'affrest'}
%                              {'updrs';'dopares';'diff';'affUErest'}
                             
%                              {'trs';'off';'rue'}
%                              {'trs';'off';'rle'}
%                              {'trs';'off';'lue'}
%                              {'trs';'off';'lle'}
%                              {'trs';'off';'affue'}
%                              {'trs';'off';'unaffue'}
%                              {'trs';'off';'affle'}
%                              {'trs';'off';'unaffle'}
%                              {'trs';'off';'totrest'}
%                              {'trs';'off';'totrestaff'}
%                              {'trs';'on';'rue'}
%                              {'trs';'on';'rle'}
%                              {'trs';'on';'lue'}
%                              {'trs';'on';'lle'}
%                              {'trs';'on';'affue'}
%                              {'trs';'on';'unaffue'}
%                              {'trs';'on';'affle'}
%                              {'trs';'on';'unaffle'}
%                              {'trs';'on';'totrest'}
%                              {'trs';'on';'totrestaff'}
%                              {'trs';'dopares';'per';'totrest'}
%                              {'trs';'dopares';'per';'affrest'}
%                              {'trs';'dopares';'per';'affUErest'}
%                              {'trs';'dopares';'diff';'totrest'}
%                              {'trs';'dopares';'diff';'affrest'}
%                              {'trs';'dopares';'diff';'affUErest'}
                             };
conf.par.meth           =   'pearson';                 % Choose method of correlation.

conf.par.save           =   1;                            % Choose if you want to save the plots (1=yes)
                                                                             
end

%--------------------------------------------------------------------------

%% Functions
%--------------------------------------------------------------------------

% --- NOT FINISHED!! Model Evidence Variability --- %

H = strfind(varargin,'sModVar');
if find(H{:} == 1)
    pf_dcm_ana_BMS_sModVar(conf)            % Plots subject variability for all models
end

% --- Subject variability of Model Parameters --- %

H = strfind(varargin,'ModPar');
if find(H{:} == 1)
    par = pf_dcm_ana_modpar(conf,conf.mod.plot);          % Plot and return model parameters
end

% --- Average Model Parameters --- %

H = strfind(varargin,'AvgPar');
if find(H{:} == 1)
    [DCM,mVar]  =   pf_dcm_ana_avgpar(conf);                 % Plots subject variability for all models
end

% --- Correlate model parameters with other parameters --- %

H = strfind(varargin,'CorrPar');
if find(H{:} == 1)
    [sig,nsig] = pf_dcm_ana_corrpar(conf);                 % Plots subject variability for all models
end

%% Variable Output Arguments
 
if exist('par','var' );  varargout{1}  = par;  end;
% if exist('DCM','var' );  varargout{2}  = DCM;  end;
% if exist('mVar','var');  varargout{2}  = mVar; end;
% if exist('sig','var' );  varargout{1}  = sig;  end;
% if exist('nsig','var');  varargout{2}  = nsig; end;

%% Benchmark

T = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])















