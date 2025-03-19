function pf_dcm_batch_kelsey(conf,varargin)
% 
% pf_ dcm_batch(conf,varargin) is a batch for applying Dynamic Causal 
% Modeling (DCM12; SPM12b) to your dataset. For DCM, you need a 
% Design Matrix (where you specify input, this may be different from your 
% GLM) and the Volumes of Interest (VOI) time series. This scripts needs
% the following inputs: 
%       - conf: this is a structure defining the configuration of
%         your specific dataset. I.e. if you change this appropriately, all
%         the functions below will work on your dataset (if not, please
%         contact me). See below for an example configuration.
%
% Specify the batch options using one or more of these varargin inputs:
%       - 'illMod':     Illustrate (and save figure) the DCM model you specified
%       - 'creVOI':     Create the VOI's of your regions of interest
%       - 'creDSMTX':   Create your DCM model Design Matrix
%       - 'specDCM':    Specify your DCM models
%       - 'estDCM':     Estimate your DCM models
%       - 'exeBMS':     Execute Bayesian Model Selection
%
% If you don't use this script as a function, the script defaults (i.e.
% for my dataset) will be used. This also means you can change these
% defaults (under Warming Up and Configuration) and run this script without
% specifying inputs.
%
% Note that all the options in this batch are accessible through the 
% original SPM12b GUI. However, sometimes it's just nice that you can sit and
% watch how the computer does all the busy work, so you can get a well 
% deserved coffee :)

% Created by Michiel Dirkx, 2014
% Contact: michieldirkx@gmail.com
% $ParkFunC

%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

% --- DCM batch options --- %

if nargin < 2      
% varargin{1} = 'illMod'; 
% varargin{1} = 'creVOI'; 
% varargin{2} = 'creDSMTX'; 
% varargin{1} = 'specDCM'; 
% varargin{1} = 'estDCM'; 
varargin{1} = 'exeBMS'; 
end

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

if nargin < 1       

tic; close all; clc;

%==========================================================================    
% --- Directories --- %
%==========================================================================

conf.dir.root          = '/home/action/micdir/data/DRDR_MRI/fMRI';                                 % Main directory containing all subfolders    

% --- creVOI --- %

conf.dir.firstlevel    = fullfile(conf.dir.root,'analysis','M48_reclasICA-AROMA_spmthrsh0c2_FARM1_han2s_EMG-log_broadband','COCO','COCO');                                                  % Directory of your first level analysis + VOI time courses 
conf.dir.ROImasks      = '/home/action/micdir/MATLAB/ROI_MD/';                                      % Directory of your ROI masks, this will be used if you make VOI's and use a mask for it
conf.dir.saveVOI       = fullfile(conf.dir.firstlevel,'VOIs');

% --- creDSMTX --- %

conf.dir.scans_main    = conf.dir.root;                                                            % Main folder where your scans are stored
conf.dir.scans_sub     = {
                          'OFF';
%                         'ON';  
                          };                % Subfolder (for every subject) where the (preprocessed) scans are stored
conf.dir.EMG           = '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/COCO/ZSCORED'; % Directory of all your EMG files (which will be used for your design matrix)
% conf.dir.EMG           = '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_ACC-PC1_BP1-40/Regressors/broadband_PB1Hz/COCO/ZSCORED/';
conf.dir.cond          = {'rootdir' 'CurSub' 'func' 'CurSess' 'COCO/info/condition'}; % cell with strings defining directory. 'rootdir', 'CurSub', 'CurSess' will be replaced accordingly.

% --- DCM dirs --- %

conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none','OFF');         % Directory of your VOI files                 
conf.dir.save          = fullfile(conf.dir.root,'analysis/DCM_Models/COCO');                 % Directory where your DCM models will be stored (if it doesn't exist, this script will make them)
% conf.dir.DCMtempl      = fullfile(conf.dir.root,'analysis/DCM_Models/template_dcm_coco');          % Directory of your template DCM.mat file (specified DCM), this might be any specified DCM.mat file, we will replace everything
conf.dir.BMS           = fullfile(conf.dir.save,'Bayesian Model Selection');        % Directory of your Bayesian Model Selection

%==========================================================================
% --- Subjects --- %
%==========================================================================

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
% 
sel = [
         2 8 11 18 21 27 28 29 30 36 38 40 42 47 48 49 50 59 60 62 70 71 72 74 75 77 81 83 ... %Definitely tremor
         14 ...                                                                              %maybe tremor
         33 56 64 76 ...                                                                         %Tremor but noisy EMG
      ]; %TREMOR IN OFF - incl. doubt

% sel = [2 8 11 18 21 27 28 29 30 36 38]; % first 1/3
% sel = [40 42 47 48 49 50 59 60 62 70 71]; % second 1/3
% sel = [72 74 75 77 81 83 14 33 56 64 76]; % third 1/3
% sel = [81 83 14 33 56 64 76];
% sel = 70;
sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

%==========================================================================
% --- VOI parameters (creVOI) --- %
%==========================================================================

conf.voi.roi.name  = {
                      'GPe';                            % Name of regions you want to extract
                      'STN';
                      'GPi';
                      'MC';
                      'VLpv';
                      'CBLM';
                      };                 
conf.voi.side      = [1 1 1 1 1 0];                         % Take contralateral (=1) or ipsilateral (=0) side of VOI 
conf.voi.roi.sc    = '/CurSide^_^/&/CurROI/&/.nii/';
conf.voi.conT      = {
                      {'Tremorlog_deriv1 - OFF','OFF','Tremorlog_deriv1 - Session 1','Tremorlog_deriv1 - Session 2'}
                      {'Tremorlog_deriv1 - OFF','OFF','Tremorlog_deriv1 - Session 1','Tremorlog_deriv1 - Session 2'}
                      {'Tremorlog_deriv1 - OFF','OFF','Tremorlog_deriv1 - Session 1','Tremorlog_deriv1 - Session 2'}
                      {'Tremorlog - OFF','OFF','Tremorlog - Session 1','Tremorlog - Session 2'}
                      {'Tremorlog - OFF','OFF','Tremorlog - Session 1','Tremorlog - Session 2'}
                      {'Tremorlog - OFF','OFF','Tremorlog - Session 1','Tremorlog - Session 2'}
                     };
conf.voi.conF      =  {'Effects_of_interest - OFF','OFF','Effects_of_interest - Session 1','Effects_of_interest - Session 2'};            % F contrast (usually effects_of_interest).
conf.voi.P         =  'none';                           % Specify uncorrected ('none') or corrected ('FWE') p values
conf.voi.Pthresh   =   1;                               % P-threshold, every suprathreshold value will be included
conf.voi.method    =  'Mask';                           % Use a mask ('Mask') for extracting VOI's or sphere around coordinates ('Sphere');
conf.voi.sess      =  {'OFF','OFF',1,2};                % Indicate which session (e.g. {'OFF','OFF',1,2} means you want OFF, and if conf.sub.sess1 = 'OFF' then take session 1, otherwise 2)

% --- If using a sphere --- %
% conf.voi.sphere.cent    =  {[-22   -10    -4];        % Center coordinates of the sphere, use one row for every VOI;
%                             [-34   -22    44];
%                             [ -14   -12   -14];
%                             [ 14   -56   -20];};
conf.voi.sphere.cent    =  {fullfile(conf.dir.saveVOI,'xyz_PALL-MC-VLT-CBLM.mat')};                        
conf.voi.sphere.rad     =  6;                          % Radius of your sphere in mm            
conf.voi.sphere.global  =  0;                          % If =1, then the global maximum threshold will be taken as center coordinates (and center coordinates specified above will be ignored)
                     
%==========================================================================
% --- Create Design Matrix (creDSMTX) --- %
%==========================================================================
                              
% --- Scan Settings (creDSMTX) --- %

conf.dsmtx.scan.tr      =  0.859;                              % TR of scans
conf.dsmtx.scan.te      =  0.034;                              % TE (echo time) of scans, necessary for DCM 
conf.dsmtx.scan.nDummy  =  0;                                  % Remove the first nDummy scans (check your folder and count which is the first actual scan (ascending order)
conf.dsmtx.scan.name    =  '/sw/&/.nii/';                      % Generic name of your scans in folder  (make sure your fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub) directory contains these scans

% --- General condition Settings (creDSMTX) -- %

conf.dsmtx.cond.name  = {
                           'EMGRegr';                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
%                            'COCO'   ;
                        };                           
conf.dsmtx.cond.ons   = {
                           'nScan';                                 % nScan will use 1:1:conf.dsmtx.scan.nScan (but detect the amount of scans)
%                            'COCO';                                  % COCO will load the condition file and use these onsets
                        };
conf.dsmtx.cond.dur   = {
                           0     ;         % Duration corresponding to condition specified above (so again new row for every condition)
%                            'COCO';         % COCOC will determine duration based on condfile
                         };
conf.dsmtx.cond.unit  = 'scans';                                % Units of time ('scans' or 'seconds')  
                     
% --- Condition specific settings (creDSMTX) --- %                        

conf.dsmtx.cond.sess       =  {'SESS1'};          % Indicate session for condition files (nb, only 1 possible)
conf.dsmtx.cond.emg.file   =  '/CurSub/&/CurSess/&/MA-/&/log.mat/';   % Name of EMG file located in conf.dir.EMG (if you specified 'EMGRegr' as a condition)
conf.dsmtx.cond.emg.idx    =  3;                                      % Index of column in EMG file you want to use (typically deriv1 unconvolved)
% conf.dsmtx.cond.cond.file  =  '/CurSub/&/CurSess/&/condition.mat/';   % name of condition file (used by 'COCO')

%==========================================================================
% --- DCM parameters (specDCM, estDCM, illMod) --- %
%==========================================================================

conf.DCMpar.modelname     = 'model1';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
conf.DCMpar.GLMmethod     = '12-Deriv1_ParamMod_Stoch-twostate-inh';      % For every different design matrix you use you can use a different name
conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
conf.DCMpar.sess          = {1};                                        % Session index, so far only use one session in the specDCM models (have previously tricked SPM into thinking there was only one session to account for dopaminergic effects);
conf.DCMpar.VOIname       = {'/VOI_/&/CurROI/&/CurSub/&/.mat/'};        % File name of VOIs for your DCM. See pf_findfile for entering search criteria
conf.DCMpar.fixconnect    = [
                                1   0   0   1   0   1; % GPe 
                                1   1   0   1   0   0; % STN 
                                0   1   1   1   0   1; % GPi              
                                0   0   1   1   1   0; % MC             
                                0   0   0   1   1   1; % VIM
                                0   0   0   1   0   1; % CBLM
                                ];
conf.DCMpar.modcon(:,:,1) = [0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                             0 0 0 0 0 0;               
                             0 0 0 0 0 0;               
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;];            
conf.DCMpar.inputconnect  = [ 0;      %inGPi (dopamod no input)
                              0;
                              1;
                              0;
                              0;
                              0];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
conf.DCMpar.d             = double.empty(4,4,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
conf.DCMpar.TA            = [0.4295;0.4295;0.4295;0.4295;0.4295;0.4295];                % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
conf.DCMpar.twostate      = 1;                        % 0 for one state nodes, 1 for two state
conf.DCMpar.stochastic    = 1;                        % 0 for deterministic DCM, 1 for stochastic effects
conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
conf.DCMpar.hiddennode    = [];                       % Index of the node which is to be hidden
conf.DCMpar.endogenous    = 0;

%==========================================================================
% --- Bayesian Model Selection (exeBMS) --- %
%==========================================================================
                       
conf.DCMpar.BMS.models     = {
                             'MB1_GPe-GPe'   ;'MB2_MC-GPe'  ;
                             'MB3_CBLM-GPe'  ;'MB4_GPe-STN' ;
                             'MB5_MC-STN'    ;'MB6_STN-GPi' ;
                             'MB7_GPi-GPi'   ;'MB8_MC-GPi'  ;
                             'MB9_CBLM-GPi'  ;'MB10_GPi-MC' ;
                             'MB11_MC-MC'    ;'MB12_VIM-MC' ;
                             'MB13_MC-VIM'   ;
                             'MB14_VIM-VIM';
                             'MB15_CBLM-VIM' ;'MB16_MC-CBLM';
                             'MB17_CBLM-CBLM';
                             'MB18_NoMod'  ;
                             };                                                   
                          
conf.DCMpar.BMS.GLMmethods = {
                              '12-';
                              };                        % Pick a new row for every model (if you choose one GLMmethod, this will be used for all models)                                                   

conf.DCMpar.BMS.name       = 'tmp';               % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)
                            
conf.DCMpar.BMS.method     = 'RFX';                                  % Choose RFX or FFX for your Bayesian Model Selection
conf.DCMpar.BMS.verifID    =  1;                                     % Verify ID options for BMS (1 means it will check if all models are based on same data).
conf.DCMpar.BMS.bma        = 'no';                               % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on

%--------------------------------------------------------------------------         
end

%-------------------------------------------------------------------------- 

%% Model Visualization
%--------------------------------------------------------------------------

H = strfind(varargin,'illMod');
if ~isempty([H{:}])
    pf_dcm_addillus(conf)              % Plots your DCM model
end

%--------------------------------------------------------------------------

%% DCM preprocessing 
%--------------------------------------------------------------------------

H = strfind(varargin,'creVOI');
if ~isempty([H{:}])
    pf_dcm_create_VOI(conf)            % Make you Volumes of Interest (VOI time series)
end

H = strfind(varargin,'creDSMTX');
if ~isempty([H{:}]) 
    pf_dcm_create_designmtx(conf);     % Specify your design matrix using the right parameters. 
end

%--------------------------------------------------------------------------

%% DCM Model Specfication and Estimation 
%--------------------------------------------------------------------------

H = strfind(varargin,'specDCM');
if ~isempty([H{:}])
    pf_dcm_specify_DCM(conf);          % Specify your DCM.mat files 
end

H = strfind(varargin,'estDCM');
if ~isempty([H{:}]) 
    pf_dcm_estimate_DCM(conf);         % Estimate your DCM
end

%--------------------------------------------------------------------------

%% Bayesian Model Selection
%--------------------------------------------------------------------------

H = strfind(varargin,'exeBMS');
if ~isempty([H{:}])
    pf_dcm_exec_BMS(conf);             % Do a Bayesian Model Selection for the estimated DCM models
end

%--------------------------------------------------------------------------

%% Cooling Down
%--------------------------------------------------------------------------

if nargin < 1
    
T = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])

end

%--------------------------------------------------------------------------
