function pf_dcm_batch(conf,varargin)
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
% varargin{1} = 'creGCM'; % Create a GCM storage file defining which models to include for your model space
end

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

if nargin < 1       

tic; close all; clc;
    
% --- Directories --- %

conf.dir.root          = '/home/action/micdir/data/DRDR_MRI/fMRI';                                 % Main directory containing all subfolders    

%- creVOI dirs -%
conf.dir.firstlevel    = fullfile(conf.dir.root,'analysis','model_OFFON_origmethod41r','RS'); % Directory of your first level analysis + VOI time courses 
conf.dir.ROImasks      = '/home/action/micdir/MATLAB/ROI_MD';                                      % Directory of your ROI masks, this will be used if you make VOI's and use a mask for it
conf.dir.saveVOI       = fullfile(conf.dir.firstlevel,'VOIs');

%- creDSMTX dirs -%
conf.dir.scans_main    = conf.dir.root;                                  % Main folder where your scans are stored
conf.dir.scans_sub     = {'func/OF/RS/preproc/smooth';};                % Subfolder (for every subject) where the (preprocessed) scans are stored
conf.dir.EMG           = '/home/action/micdir/data/EMG/Cohort 2/EMG_results (orig; pre; final)/Regressor unconvolve';           % Directory of all your EMG files (which will be used for your design matrix)

%- DCM dirs -%
conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none');                               % Directory of your VOI files                 
conf.dir.save          = '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/DCM_Models/COCO/NET';      % Directory where your DCM models will be stored (if it doesn't exist, this script will make them)
conf.dir.DCMtempl      = '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/DCM_Models/template_dcm/';              % Directory of your template DCM.mat file (specified DCM), this might be any specified DCM.mat file, we will replace everything
conf.dir.BMS           = fullfile(conf.dir.save,'Bayesian Model Selection');                       % Directory of your Bayesian Model Selection

% ---   Subjects   --- %

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


% sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83]; % DOPARESISTANT - confirmed doubts (14, 62, 47, 80, 82)
% sel =   [18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % DOPARESPONSIVE - confirmed doubts (24)
     
% sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ... 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts     
     
% sel =   [30 08 11 27 42 50 72 75 74 73 78 81 83 ... 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts  -p28   

%  sel = [
%          2 8 11 18 21 27 28 29 30 36 38 40 42 47 48 49 50 59 60 62 70 71 72 74 75 77 81 83 ... %Definitely tremor
%          14 ...                                                                              %maybe tremor
%          33 56 64 76 ...                                                                         %Tremor but noisy EMG
%       ]; %TREMOR I

sel = [
         2 8 18 21 27 28 29 30 36 38 40 42 47 48 49 59 60 62 70 71 72 75 81 83 ... %Definitely tremor
         33 56 64 76 ...                                                                       %Tremor but noisy EMG
                  14 ...                                                                       %maybe tremor
      ]; %all3 minus beta blockers (4)    
  
  
% sel = [
%          2 8 18 21 27 28 29 30 36 38 40 42 47 48 49 50 59 60 62 70 71 72 75 77 81 83 ... %Definitely tremor
%          14 ...                                                                              %maybe tremor
%          33 56 64 76 ...                                                                         %Tremor but noisy EMG
%       ]; %TREMOR I

  
  
% sel = [71 72 74 75 77 81 83 14 33 56 64 76];
sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

% --- VOI time series Parameters --- %

conf.voi.roi.name  = {
%                       'GPi';                            % Name of regions you want to extract
                      'GPe';
                      'MC';
                      'VLT';
                      'CBLM';
                      };                 
conf.voi.side      = [1 1  1 0];                         % Take contralateral (=1) or ipsilateral (=0) side of VOI 
conf.voi.roi.sc    = '/CurSide^_^/&/CurROI/&/.nii/';
conf.voi.conT      = {
                      'OF_Regr_Log_deriv1';                % T contrasts you're using for your data (use one row for every VOI).                          
%                       'OF_Regr_Log_deriv1';
%                       'OF_Regr_Log';        
%                       'OF_Regr_Log';        
%                       'OF_Regr_Log';        
                      };
conf.voi.conF      =  'Effects_of_Interest';            % F contrast (usually effects_of_interest).
conf.voi.P         =  'none';                           % Specify uncorrected ('none') or corrected ('FWE') p values
conf.voi.Pthresh   =   1;                               % P-threshold, every suprathreshold value will be included
conf.voi.method    =  'Mask';                           % Use a mask ('Mask') for extracting VOI's or sphere around coordinates ('Sphere');

% Settings if you're using a sphere %
% conf.voi.sphere.cent    =  {[-22   -10    -4];        % Center coordinates of the sphere, use one row for every VOI;
%                             [-34   -22    44];
%                             [ -14   -12   -14];
%                             [ 14   -56   -20];};
conf.voi.sphere.cent    =  fullfile(conf.dir.saveVOI,'xyz_PALL-MC-VLT-CBLM.mat');                        
conf.voi.sphere.rad     =  6;                          % Radius of your sphere in mm            
conf.voi.sphere.global  =  0;                          % If =1, then the global maximum threshold will be taken as center coordinates (and center coordinates specified above will be ignored)
conf.voi.sess           =  1;

% --- Create Design Matrix --- %                              
                              
% Scan Settings (creDSMTX)

conf.dsmtx.scan.tr      =  1.820;                               % TR of scans
conf.dsmtx.scan.te      =  0.03;                                % TE (echo time) of scans, necessary for DCM 
conf.dsmtx.scan.nScan   =  269;                                 % nScans
conf.dsmtx.scan.nDummy  =  0;                                   % Remove the first nDummy scans (check your folder and count which is the first actual scan (ascending order); it will select CurScan(conf.dsmtx.scan.nDummy+1:end), where CurScan is based on your search criteria in your scan folder
conf.dsmtx.scan.name    =  '/swa/&/.nii/';                      % Generic name of your scans in folder  (make sure your fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub) directory contains these scans

% General condition Settings (creDSMTX) 

conf.dsmtx.cond.name  = {
                         'EMGRegr';                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
%                          'Dopa'   ;
                         };                           
conf.dsmtx.cond.ons   = {
                         1:1:conf.dsmtx.scan.nScan  ;           % Onset corresponding to condition specified above (so again new row for every condition)    
%                          (conf.dsmtx.scan.nScan/2)+1; 
                         };
conf.dsmtx.cond.dur   = {
                         0                          ;           % Duration corresponding to condition specified above (so again new row for every condition)
%                          (conf.dsmtx.scan.nScan/2);
                         };
conf.dsmtx.cond.unit  = 'scans';                                % Units of time ('scans' or 'seconds')  
                     
% Condition specific settings (creDSMTX)                         
                          
conf.dsmtx.cond.emg   =  '/CurSub/&/_RS_OF_Regr_Log_unconvolved/';   % Name of EMG file located in conf.dir.EMG (if you specified 'EMGRegr' as a condition)

% --- Specify DCM --- %

conf.specdcm.cond.temp   =  'DCM_Specified_template_Coh2a_input';        % The filename of your template specified DCM.mat file. uses pf_findfile

% ---   DCM parameters   --- %

conf.DCMpar.modelname     = 'TMP';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
conf.DCMpar.GLMmethod     = '12-Deriv1_ParamMod_Stoch-twostate-inh';      % For every different design matrix you use you can use a different name
conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
conf.DCMpar.sess          = {1};                                        % Amount of Sessions (? Not sure if works, I only use one session)
conf.DCMpar.VOIname       = {'/VOI_/&/CurROI/&/CurSub/&/.mat/'};        % File name of VOIs for your DCM. See pf_findfile for entering search criteria
conf.DCMpar.fixconnect    = [1 1 0 0;              % Fill in your fixed connection. Every row represents the corresponding VOI (as in your conf.DCMpar.VOI) 
                             1 1 1 0;              % as a target VOI (1 means connection to this target reagion, 0 not). There is always a fixed connection with itself
                             0 1 1 1;              % (so column one of VOI 1  = 1, column 2 of VOI 2 = 1, column 3 of VOI 3 = 1 etc) This is DCM.a
                             0 1 0 1];
conf.DCMpar.modcon(:,:,1) = [0 0 0 0;              % Fill in your modulated connection (in the same way as the fixed connections). 
                             0 0 0 0;              % Note that there aren't any intrinsic connections as was the case with the fixed ones
                             0 0 0 0;              % (so this matrix can contain nVOI x nVOI zeros). This is DCM.b
                             0 0 0 0];
conf.DCMpar.inputconnect  = [1;
                             0;
                             0;
                             0];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
conf.DCMpar.d             = double.empty(4,4,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
conf.DCMpar.TA            = [0;0;0;0];                % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
conf.DCMpar.twostate      = 1;                        % 0 for one state nodes, 1 for two state
conf.DCMpar.stochastic    = 1;                        % 0 for deterministic DCM, 1 for stochastic effects
conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
conf.DCMpar.endogenous    = 0;                        % 0 for endogenous???
conf.DCMpar.hiddennode    = 2;                        % Indices of nodes which are to be considered hidden; (use [] if not used);

% -- DCM-Bayesian Model Selection settings --%
                       
conf.DCMpar.BMS.models     = {
%                              'MB1_GPe-GPe'   ;'MB2_MC-GPe'  ;
%                              'MB3_CBLM-GPe'  ;'MB4_GPe-STN' ;
%                              'MB5_MC-STN'    ;'MB6_STN-GPi' ;
%                              'MB7_GPi-GPi'   ;'MB8_MC-GPi'  ;
%                              'MB9_CBLM-GPi'  ;'MB10_GPi-MC' ;
%                              'MB11_MC-MC'    ;'MB12_VIM-MC' ;
%                              'MB13_MC-VIM'   ;
%                              'MB14_VIM-VIM';
%                              'MB15_CBLM-VIM' ;'MB16_MC-CBLM';
%                              'MB17_CBLM-CBLM';
%                              'MB18_NoMod'  ;
%                              'MB19_STN-STN';
%                              'MEX1_OP4_nodirect';
%                              'MEX2_OP4_direct';
%                              'MEX3_CBLM2_nodirect';
%                              'MEX4_CBLM2_direct';
%                              'MEX5_OP4-MUSC';
%                              'MEX6_MUSC-OP4';
%                              'MEX7_CBLM2-MUSC';
%                              'MEX8_MUSC-CBLM2';
%                              'MEX9_MC-MUSC';
%                              'MEX91_MUSC-MC';

%                              'M1_GPe-GPe'   ;'M2_MC-GPe'    ;
%                              'M3_CBLM-GPe'  ;'M4_STN-STN'   ;
%                              'M5_GPe-STN'   ;'M6_MC-STN'    ;
%                              'M7_STN-GPi'   ;'M8_GPi-GPi'   ;
%                              'M9_MC-GPi'    ;'M10_CBLM-GPi' ;
%                              'M11_GPi-MC'   ;'M12_MC-MC'    ;
%                              'M13_VIM-MC'   ;'M14_MC-VIM'   ;
%                              'M15_VIM-VIM'  ;'M16_CBLM-VIM' ;
%                              'M17_MC-CBLM'  ;'M18_CBLM-CBLM';
%                              'M19_NoMod'    ;
                             
%                              'M1_inMC'        ;'M2_inVLpv'    ;
%                              'M3_inCBLM'      ;'M4_inCEN'     ;
%                              'M5_inCENandVLpv';
%                              'M6_noIN'

                               'MA1_inC_C-M'    ;'MA2_inC_C-C';
                               'MA3_inC_C-V'    ;'MA4_inC_C-MV';
                               'MA5_inC_C-MC'   ;'MA6_inC_C-VC';
                               'MA7_inC_C-MVC'  ;                 %inCOCO
                               
                               'MA8_inCV_C-M'   ;'MA9_inCV_C-C';
                               'MA10_inCV_C-V'  ;'MA11_inCV_C-MV';
                               'MA12_inCV_C-MC' ;'MA13_inCV_C-VC';
                               'MA14_inCV_C-MVC';'MA15_inCV';        %in COCO+VLpv
                               
                               'MA16_inCM_C-M'  ;'MA17_inCM_C-C';
                               'MA18_inCM_C-V'  ;'MA19_inCM_C-MV';
                               'MA20_inCM_C-MC' ;'MA21_inCM_C-VC';
                               'MA22_inCM_C-MVC';'MA23_inCM';        %in COCO+MC
                               
                               'MA24_inCC_C-M'  ;'MA25_inCC_C-C';
                               'MA26_inCC_C-V'  ;'MA27_inCC_C-MV';
                               'MA28_inCC_C-MC' ;'MA29_inCC_C-VC';
                               'MA30_inCC_C-MVC';'MA31_inCC';        %in COCO+CBLM
                               
%                                'MA32_inCCM_C-M'  ;'MA33_inCCM_C-C';
%                                'MA34_inCCM_C-V'  ;'MA35_inCCM_C-MV';
%                                'MA36_inCCM_C-MC' ;'MA37_inCCM_C-VC';
%                                'MA38_inCCM_C-MVC';'MA39_inCCM';        %in COCO+CBLM+MC
%                                
%                                'MA40_inCCV_C-M'  ;'MA41_inCCV_C-C';
%                                'MA42_inCCV_C-V'  ;'MA43_inCCV_C-MV';
%                                'MA44_inCCV_C-MC' ;'MA45_inCCV_C-VC';
%                                'MA46_inCCV_C-MVC';'MA47_inCCV';        %in COCO+CBLM+VLpv
%                                
%                                'MA48_inCMV_C-M'  ;'MA49_inCMV_C-C';
%                                'MA50_inCMV_C-V'  ;'MA51_inCMV_C-MV';
%                                'MA52_inCMV_C-MC' ;'MA53_inCMV_VC-VC';
%                                'MA54_inCMV_C-MVC';'MA55_inCMV';        %in COCO+MC+VLpv
%                                
%                                'MA56_inCMVC_C-M'  ;'MA57_inCMVC_C-C';
%                                'MA58_inCMVC_C-V'  ;'MA59_inCMVC_C-MV';
%                                'MA60_inCMVC_C-MC' ;'MA61_inCMVC_VC-VC';
%                                'MA62_inCMVC_C-MVC';'MA63_inCMVC';        %in COCO+MC+VLpv+CBLM
                             };                                                   
                          
conf.DCMpar.BMS.GLMmethods = {
                              '|2_';
                              };                        % Pick a new row for every model (if you choose one GLMmethod, this will be used for all models)
                          
% sel =   [7 14 22 30];
% conf.DCMpar.BMS.models =   conf.DCMpar.BMS.models(sel);

% BMS Families %
conf.DCMpar.BMS.fam.name    =   {
%                                  'inCNET';
%                                  'inCNET-VLpv';
%                                  'inCNET-MC';
%                                  'inCNET-CBLM';
%                                  'inCNET-CBLM-MC';
%                                  'inCNET-CBLM-VLpv';
%                                  'inCNET-MC-VLpv';
%                                  'inCNET-MC-VLpv-CBLM';
                                 'no';
                                 'C-M';
                                 'C-C';
                                 'C-V';
                                 'C-MV';
                                 'C-MC';
                                 'C-VC';
                                 'C-MVC';
                                 };

conf.DCMpar.BMS.fam.models  =   {
%                                   1:7;
%                                   8:15;
%                                   16:23;
%                                   24:31;
%                                   32:39;
%                                   40:47;
%                                   48:55;
%                                   56:63;
                                  [15 23 31];
                                  [1 8   16 24];
                                  [2 9   17 25];
                                  [3 10  18 26];
                                  [4 11  19 27];
                                  [5 12  20 28];
                                  [6 13  21 29];
                                  [7 14  22 30];
%                                   
%                                   [15 23 31 39 47 55 63];
%                                   [1 8   16 24 32 40 48 56];
%                                   [2 9   17 25 33 41 49 57];
%                                   [3 10  18 26 34 42 50 58];
%                                   [4 11  19 27 35 43 51 59];
%                                   [5 12  20 28 36 44 52 60];
%                                   [6 13  21 29 37 45 53 61];
%                                   [7 14  22 30 38 46 54 62];
                                 };

conf.DCMpar.BMS.name       = 'tmp';               % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)
                            
conf.DCMpar.BMS.method     = 'RFX';                                  % Choose RFX or FFX for your Bayesian Model Selection
conf.DCMpar.BMS.verifID    =  0;                                     % Verify ID options for BMS (1 means it will check if all models are based on same data).
conf.DCMpar.BMS.bma        = 'win';                               % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on

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

% H = strfind(varargin,'creGCM');
% if ~isempty([H{:}]) 
%     pf_dcm_cregcm(conf);         % Estimate your DCM
% end

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
