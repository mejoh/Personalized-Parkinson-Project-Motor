function pf_dcm_qsubbatch
%
% pf_dcm_qsubbatch is a function that will use qsubcellfun to execute
% multiple pf_dcm_batch at the same time using Torque. You will have to
% specify one 'template' pf_dcm_batch configuration and subsequently alter 
% the configuration to your interest to create multiple batch configurations, 
% each representing one batch.
%
% NB2!!: in contrast to the usual function of the ParkFunC toolbox, you have
% to specify every cell of this script, even the loop might not be useful 
% to you. 
%
% see also pf_dcm_batch, qsubcellfun

% © Michiel Dirkx, 2014
% $ParkFunC
%--------------------------------------------------------------------------       

%% Warming Up

addpath /home/common/matlab/fieldtrip/qsub/ % Add the qsub directory to your path

%--------------------------------------------------------------------------

%% Template pf_dcm_batch configuration
%--------------------------------------------------------------------------       
% Version 20150706: TremorDCM (paper1) configurations, type GPe4GPi

%=========================================================================%
%===============================COHORT 1==================================%
%=========================================================================%

tic; close all; clc;

% --- Directories --- %

conf.dir.root          = '/home/action/micdir/data/fMRI/Cohort_1';                                 % Main directory containing all subfolders    

%- creVOI dirs -%
conf.dir.firstlevel    = fullfile(conf.dir.root,'First level - regressor GLM + VOI time courses','model1','RS'); % Directory of your first level analysis + VOI time courses 
conf.dir.ROImasks      = '/home/action/micdir/MATLAB/ROI_MD';                                      % Directory of your ROI masks, this will be used if you make VOI's and use a mask for it
conf.dir.saveVOI       = fullfile(conf.dir.firstlevel,'VOIs');

%- creDSMTX dirs -%
conf.dir.scans_main    = fullfile(conf.dir.root,'Original Data');                                  % Main folder where your scans are stored
conf.dir.scans_sub     = {'resting_state/preproc/smooth';};                % Subfolder (for every subject) where the (preprocessed) scans are stored
conf.dir.EMG           = '/home/action/micdir/data/EMG/Cohort 1/unconvolved_regressors';           % Directory of all your EMG files (which will be used for your design matrix)

%- DCM dirs -%
conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none');                               % Directory of your VOI files                 
conf.dir.save          = '/home/action/micdir/data/fMRI/Cohort_1/DCM Models/SPM12b/TremorDCM_OFF_C1C2_GPe4GPi ';      % Directory where your DCM models will be stored (if it doesn't exist, this script will make them)
conf.dir.DCMtempl      = '/home/action/micdir/data/fMRI/Cohort_1/Template DCM files';              % Directory of your template DCM.mat file (specified DCM), this might be any specified DCM.mat file, we will replace everything
conf.dir.BMS           = fullfile(conf.dir.save,'Bayesian Model Selection');                       % Directory of your Bayesian Model Selection

% --- Subjects --- %

conf.sub.name      =  {'p06'   ;'p08'   ;'p10'   ;'p11'   ;'p13';     % Cohort 1                            % Include all your subjects, then choose which one you want to select
                       'p14'   ;'p15'   ;'p16'   ;'p18'   ;'p20';     
                       'p21'   ;'p22'   ;'p23'   ;'p26'   ;'p27';         
                       'p28'   ;'p30'   ;'p41'   ;'p47'   ;             
                       'p07'   ;'p10'   ;'p17'   ;'p26'   ;'p28';     % Cohort 2 (TRS>=2)
                       'p31'   ;'p32'   ;'p37'   ;'p39'   ;'p41';
                       'S07'   ;'S14'   ;'S18'   ;'S24'   ;'S31';
                       'S41'   ;'S44'   ;'S46'   ;'S47'   ;'S50';
                       'S56'   ;'S70'   ; 
                       'c1-p06';'c1-p08';'c1-p10';'c1-p11';'c1-p13';     % Cohort 1                                    % Include all your subjects, then choose which one you want to select
                       'c1-p14';'c1-p15';'c1-p16';'c1-p18';'c1-p20';     
                       'c1-p21';'c1-p22';'c1-p23';'c1-p26';'c1-p27';         
                       'c1-p28';'c1-p30';'c1-p41';'c1-p47';             
                       'c2-p07';'c2-p10';'c2-p17';'c2-p26';'c2-p28';     % Cohort 2 (TRS>=2)
                       'c2-p31';'c2-p32';'c2-p37';'c2-p39';'c2-p41';
                       'c2-S07';'c2-S14';'c2-S18';'c2-S24';'c2-S31';
                       'c2-S41';'c2-S44';'c2-S46';'c2-S47';'c2-S50';
                       'c2-S56';'c2-S70'; }; 

conf.sub.hand      = [1 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 1       ...           % Cohort 1
                      1 0 1 1 0 1 1 0 1 0 1 1 1 0 0 0 1 0 0 1 0 0 ...           % Cohort 2
                      1 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 1       ...           % Cohort 1
                      1 0 1 1 0 1 1 0 1 0 1 1 1 0 0 0 1 0 0 1 0 0];           % Cohort 2];             % Cohort 2  % Affected side of patients, is important if some of your name files contain L (=0) or R (=1).];             % Cohort 2  % Affected side of patients, is important if some of your name files contain L (=0) or R (=1).
                  
sel                = 1:19;                              % Cohort 1                  
% sel                = 20:41;                             % Cohort 2
% sel                = 20:29; %coh2a
% sel                = 30:41; %coh2b
% sel                = [20 21 22 24 25 28 29 30 31 32 34 35 36 39 41];  %(p32=26; p37=27; p41=29;  S24=33; S47=38;  S50=39; S56=40)
% sel             = [20:26 28:41];
% sel                = [42:61 63 65:69 71:82];          % Double subjects from cohort 2 excluded (C1C2)
% sel                = [31 40]; %31
conf.sub.name      = conf.sub.name(sel);
conf.sub.hand      = conf.sub.hand(sel); 

% --- VOI time series Parameters --- %

conf.voi.roi.name  = {
%                       'GPi';                            % Name of regions you want to extract
                      'GPe';
                      'MC';
                      'VLT';
                      'CBLM';
                      };                 
conf.voi.side      = [1 1 1 0];                         % Take contralateral (=1) or ipsilateral (=0) side of VOI 
conf.voi.roi.sc    = '/CurSide^_^/&/CurROI/&/.nii/';
conf.voi.conT      = {
                      'Regr_Log_deriv1';                % T contrasts you're using for your data (use one row for every VOI).                          
                      'Regr_Log';        
                      'Regr_Log';        
                      'Regr_Log';        
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

conf.dsmtx.scan.tr      =  1.45;                               % TR of scans
conf.dsmtx.scan.te      =  0.03;                                % TE (echo time) of scans, necessary for DCM 
conf.dsmtx.scan.nScan   =  259;                                 % nScans
conf.dsmtx.scan.nDummy  =  3;                                   % Remove the first nDummy scans (check your folder and count which is the first actual scan (ascending order), it will select CurScan(conf.dsmtx.scan.nDummy+1:end), where CurScan is based on your search criteria in your scan folder
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
                          
conf.dsmtx.cond.emg   =  '/CurSub/&/_Regr_log_unconvolved/';   % Name of EMG file located in conf.dir.EMG (if you specified 'EMGRegr' as a condition)

% --- Specify DCM --- %

conf.specdcm.cond.temp   =  'DCM_Specified_template_chrt1_input-1*';        % The filename of your template specified DCM.mat file. Uses pf_findfile

% ---   DCM parameters   --- %

conf.DCMpar.modelname     = 'something went wrong';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
conf.DCMpar.GLMmethod     = '12c1-Deriv1_ParamMod_Stoch-twostate-inh';      % For every different design matrix you use you can use a different name
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
conf.DCMpar.endogenous    = 0;

% -- DCM-Bayesian Model Selection settings --%

conf.DCMpar.BMS.models     = {'|1_*' ;'|2_*';'|3_*';'|4_*';'|5_*' ;
                              '|6_*' ;'|7_*';'|8_*';'|9_*';'|10_*';
                              '|11_*';
                             };                          
                          
conf.DCMpar.BMS.GLMmethods = {
                              '12-'
                              };                        % Pick a new row for every model (if you choose one GLMmethod, this will be used for all models)
                          
sel =   1:11;
conf.DCMpar.BMS.models =   conf.DCMpar.BMS.models(sel);
                          
conf.DCMpar.BMS.name       = 'tmp';               % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)
                            
conf.DCMpar.BMS.method     = 'RFX';                                  % Choose RFX or FFX for your Bayesian Model Selection
conf.DCMpar.BMS.verifID    =  1;                                     % Verify ID options for BMS (1 means it will check if all models are based on same data).
conf.DCMpar.BMS.bma        = 'no';                               % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on


% %=========================================================================%
% %===============================COHORT 2==================================%
% %=========================================================================%
%     
% % --- Directories --- %
% 
% conf.dir.root          = '/home/action/micdir/data/fMRI/Cohort_2';                                 % Main directory containing all subfolders    
% 
% %- creVOI dirs -%
% conf.dir.firstlevel    = fullfile(conf.dir.root,'analysis','model_OFFON_origmethod41r','RS'); % Directory of your first level analysis + VOI time courses 
% conf.dir.ROImasks      = '/home/action/micdir/MATLAB/ROI_MD';                                      % Directory of your ROI masks, this will be used if you make VOI's and use a mask for it
% conf.dir.saveVOI       = fullfile(conf.dir.firstlevel,'VOIs');
% 
% %- creDSMTX dirs -%
% conf.dir.scans_main    = conf.dir.root;                                  % Main folder where your scans are stored
% conf.dir.scans_sub     = {'func/OF/RS/preproc/smooth';};                % Subfolder (for every subject) where the (preprocessed) scans are stored
% conf.dir.EMG           = '/home/action/micdir/data/EMG/Cohort 2/EMG_results (orig; pre; final)/Regressor unconvolve';           % Directory of all your EMG files (which will be used for your design matrix)
% 
% %- DCM dirs -%
% conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none');                               % Directory of your VOI files                 
% conf.dir.save          = '/home/action/micdir/data/fMRI/Cohort_1/DCM Models/SPM12b/TremorDCM_OFF_C1C2_GPe4GPi ';      % Directory where your DCM models will be stored (if it doesn't exist, this script will make them)
% conf.dir.DCMtempl      = '/home/action/micdir/data/fMRI/Cohort_1/Template DCM files';              % Directory of your template DCM.mat file (specified DCM), this might be any specified DCM.mat file, we will replace everything
% conf.dir.BMS           = fullfile(conf.dir.save,'Bayesian Model Selection');                       % Directory of your Bayesian Model Selection
% 
% % ---   Subjects   --- %
% 
% conf.sub.name      =  {'p06'   ;'p08'   ;'p10'   ;'p11'   ;'p13';     % Cohort 1                            % Include all your subjects, then choose which one you want to select
%                        'p14'   ;'p15'   ;'p16'   ;'p18'   ;'p20';     
%                        'p21'   ;'p22'   ;'p23'   ;'p26'   ;'p27';         
%                        'p28'   ;'p30'   ;'p41'   ;'p47'   ;             
%                        'p07'   ;'p10'   ;'p17'   ;'p26'   ;'p28';     % Cohort 2 (TRS>=2)
%                        'p31'   ;'p32'   ;'p37'   ;'p39'   ;'p41';
%                        'S07'   ;'S14'   ;'S18'   ;'S24'   ;'S31';
%                        'S41'   ;'S44'   ;'S46'   ;'S47'   ;'S50';
%                        'S56'   ;'S70'   ; 
%                        'c1-p06';'c1-p08';'c1-p10';'c1-p11';'c1-p13';     % Cohort 1                                    % Include all your subjects, then choose which one you want to select
%                        'c1-p14';'c1-p15';'c1-p16';'c1-p18';'c1-p20';     
%                        'c1-p21';'c1-p22';'c1-p23';'c1-p26';'c1-p27';         
%                        'c1-p28';'c1-p30';'c1-p41';'c1-p47';             
%                        'c2-p07';'c2-p10';'c2-p17';'c2-p26';'c2-p28';     % Cohort 2 (TRS>=2)
%                        'c2-p31';'c2-p32';'c2-p37';'c2-p39';'c2-p41';
%                        'c2-S07';'c2-S14';'c2-S18';'c2-S24';'c2-S31';
%                        'c2-S41';'c2-S44';'c2-S46';'c2-S47';'c2-S50';
%                        'c2-S56';'c2-S70'; }; 
% 
% conf.sub.hand      = [1 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 1       ...           % Cohort 1
%                       1 0 1 1 0 1 1 0 1 0 1 1 1 0 0 0 1 0 0 1 0 0 ...           % Cohort 2
%                       1 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 1       ...           % Cohort 1
%                       1 0 1 1 0 1 1 0 1 0 1 1 1 0 0 0 1 0 0 1 0 0];           % Cohort 2];             % Cohort 2  % Affected side of patients, is important if some of your name files contain L (=0) or R (=1).];             % Cohort 2  % Affected side of patients, is important if some of your name files contain L (=0) or R (=1).
%                   
% % sel                = 1:19;                              % Cohort 1                  
% sel                = 20:41;                             % Cohort 2
% % sel                = 20:29; %coh2a
% % sel                = 30:41; %coh2b
% % sel                = [20 21 22 24 25 28 29 30 31 32 34 35 36 39 41];  %(p32=26; p37=27; p41=29;  S24=33; S47=38;  S50=39; S56=40)
% % sel             = [20:26 28:41];
% % sel                = [42:61 63 65:69 71:82];          % Double subjects from cohort 2 excluded (C1C2)
% % sel                = [31 40]; %31
% conf.sub.name      = conf.sub.name(sel);
% conf.sub.hand      = conf.sub.hand(sel); 
% 
% % --- VOI time series Parameters --- %
% 
% conf.voi.roi.name  = {
% %                       'GPi';                            % Name of regions you want to extract
%                       'GPe';
%                       'MC';
%                       'VLT';
%                       'CBLM';
%                       };                 
% conf.voi.side      = [1 1  1 0];                         % Take contralateral (=1) or ipsilateral (=0) side of VOI 
% conf.voi.roi.sc    = '/CurSide^_^/&/CurROI/&/.nii/';
% conf.voi.conT      = {
%                       'OF_Regr_Log_deriv1';                % T contrasts you're using for your data (use one row for every VOI).                          
% %                       'OF_Regr_Log_deriv1';
% %                       'OF_Regr_Log';        
% %                       'OF_Regr_Log';        
% %                       'OF_Regr_Log';        
%                       };
% conf.voi.conF      =  'Effects_of_Interest';            % F contrast (usually effects_of_interest).
% conf.voi.P         =  'none';                           % Specify uncorrected ('none') or corrected ('FWE') p values
% conf.voi.Pthresh   =   1;                               % P-threshold, every suprathreshold value will be included
% conf.voi.method    =  'Mask';                           % Use a mask ('Mask') for extracting VOI's or sphere around coordinates ('Sphere');
% 
% % Settings if you're using a sphere %
% % conf.voi.sphere.cent    =  {[-22   -10    -4];        % Center coordinates of the sphere, use one row for every VOI;
% %                             [-34   -22    44];
% %                             [ -14   -12   -14];
% %                             [ 14   -56   -20];};
% conf.voi.sphere.cent    =  fullfile(conf.dir.saveVOI,'xyz_PALL-MC-VLT-CBLM.mat');                        
% conf.voi.sphere.rad     =  6;                          % Radius of your sphere in mm            
% conf.voi.sphere.global  =  0;                          % If =1, then the global maximum threshold will be taken as center coordinates (and center coordinates specified above will be ignored)
% conf.voi.sess           =  1;
% 
% % --- Create Design Matrix --- %                              
%                               
% % Scan Settings (creDSMTX)
% 
% conf.dsmtx.scan.tr      =  1.820;                               % TR of scans
% conf.dsmtx.scan.te      =  0.03;                                % TE (echo time) of scans, necessary for DCM 
% conf.dsmtx.scan.nScan   =  269;                                 % nScans
% conf.dsmtx.scan.nDummy  =  0;                                   % Remove the first nDummy scans (check your folder and count which is the first actual scan (ascending order)
% conf.dsmtx.scan.name    =  '/swa/&/.nii/';                      % Generic name of your scans in folder  (make sure your fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub) directory contains these scans
% 
% % General condition Settings (creDSMTX) 
% 
% conf.dsmtx.cond.name  = {
%                          'EMGRegr';                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
% %                          'Dopa'   ;
%                          };                           
% conf.dsmtx.cond.ons   = {
%                          1:1:conf.dsmtx.scan.nScan  ;           % Onset corresponding to condition specified above (so again new row for every condition)    
% %                          (conf.dsmtx.scan.nScan/2)+1; 
%                          };
% conf.dsmtx.cond.dur   = {
%                          0                          ;           % Duration corresponding to condition specified above (so again new row for every condition)
% %                          (conf.dsmtx.scan.nScan/2);
%                          };
% conf.dsmtx.cond.unit  = 'scans';                                % Units of time ('scans' or 'seconds')  
%                      
% % Condition specific settings (creDSMTX)                         
%                           
% conf.dsmtx.cond.emg   =  '/CurSub/&/_RS_OF_Regr_Log_unconvolved/';   % Name of EMG file located in conf.dir.EMG (if you specified 'EMGRegr' as a condition)
% 
% % --- Specify DCM --- %
% 
% conf.specdcm.cond.temp   =  'DCM_Specified_template_GPe4GPi_coh2a_1inp.mat';        % The filename of your template specified DCM.mat file. Uses pf_findfile
% 
% % --- DCM parameters --- %
% 
% conf.DCMpar.modelname     = 'TMP';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
% conf.DCMpar.GLMmethod     = '12c2-Deriv1_ParamMod_Stoch-twostate-inh';      % For every different design matrix you use you can use a different name
% conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
% conf.DCMpar.sess          = {1};                                        % Amount of Sessions (? Not sure if works, I only use one session)
% conf.DCMpar.VOIname       = {'/VOI_/&/CurROI/&/CurSub/&/.mat/'};        % File name of VOIs for your DCM. See pf_findfile for entering search criteria
% conf.DCMpar.fixconnect    = [1 1 0 0;              % Fill in your fixed connection. Every row represents the corresponding VOI (as in your conf.DCMpar.VOI) 
%                              1 1 1 0;              % as a target VOI (1 means connection to this target reagion, 0 not). There is always a fixed connection with itself
%                              0 1 1 1;              % (so column one of VOI 1  = 1, column 2 of VOI 2 = 1, column 3 of VOI 3 = 1 etc) This is DCM.a
%                              0 1 0 1];
% conf.DCMpar.modcon(:,:,1) = [0 0 0 0;              % Fill in your modulated connection (in the same way as the fixed connections). 
%                              0 0 0 0;              % Note that there aren't any intrinsic connections as was the case with the fixed ones
%                              0 0 0 0;              % (so this matrix can contain nVOI x nVOI zeros). This is DCM.b
%                              0 0 0 0];
% conf.DCMpar.inputconnect  = [1;
%                              0;
%                              0;
%                              0];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
% conf.DCMpar.d             = double.empty(4,4,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
% conf.DCMpar.TA            = [0;0;0;0];                % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
% conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
% conf.DCMpar.twostate      = 1;                        % 0 for one state nodes, 1 for two state
% conf.DCMpar.stochastic    = 1;                        % 0 for deterministic DCM, 1 for stochastic effects
% conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
% conf.DCMpar.endogenous    = 0;
% 
% % -- DCM-Bayesian Model Selection settings --%
% 
% conf.DCMpar.BMS.models     = {'|1_*' ;'|2_*';'|3_*';'|4_*';'|5_*' ;
%                               '|6_*' ;'|7_*';'|8_*';'|9_*';'|10_*';
%                               '|11_*';
%                              };                          
%                           
% conf.DCMpar.BMS.GLMmethods = {
%                               '12-'
%                               };                        % Pick a new row for every model (if you choose one GLMmethod, this will be used for all models)
%                           
% sel =   1:11;
% conf.DCMpar.BMS.models =   conf.DCMpar.BMS.models(sel);
%                           
% conf.DCMpar.BMS.name       = 'tmp';               % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)
%                             
% conf.DCMpar.BMS.method     = 'RFX';                                  % Choose RFX or FFX for your Bayesian Model Selection
% conf.DCMpar.BMS.verifID    =  1;                                     % Verify ID options for BMS (1 means it will check if all models are based on same data).
% conf.DCMpar.BMS.bma        = 'no';                               % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on

%--------------------------------------------------------------------------   

%% Create individual batches (edit your arguments of interest here)
%--------------------------------------------------------------------------       
    
cfg.DCMpar.modelname      = {'19_inputPALL=MC-CBLM-VIM=MC'         ;'23_inputPALL-CBLM-VIM=MC=PALL^-CBLM' ; % 1 input
                             '27_inputPALL=MC-CBLM-PALL^-VIM=MC'   ;'28_inputPALL=CBLM-VIM=MC-CBLM'       ;
                             '29_inputPALL=CBLM^-MC-VIM^-CBLM=MC'  ;'30_inputPALL=CBLM-VIM=MC-PALL^-CBLM' ;
                             '31_inputPALL=CBLM^=MC=VIM'           ;'35_inputMC=PALL^-CBLM-VIM=MC'        ; 
                             '39_inputMC=PALL^-CBLM-CBLM^-VIM=MC'  ;'43_inputMC=PALL^-CBLM-PALL^-VIM=MC'  ;
                             '44_inputMC-CBLM=PALL^-VIM=MC'        ;'45_inputMC-CBLM=PALL^-VIM-MC^=MC'    ;
                             '46_inputMC-PALL^-CBLM=PALL^-VIM=MC'  ;'47_inputMC=PALL^-CBLM=PALL^-VIM=MC'  ;
                             '51_inputVIM=MC=PALL^-CBLM-VIM'       ;'55_inputVIM=MC=PALL^-CBLM-PALL^-VIM' ;
                             '59_inputVIM=MC=PALL^-CBLM-VIM^-PALL' ;'60_inputVIM=MC-CBLM=PALL^-VIM'       ;
                             '61_inputVIM=MC-CBLM=PALL^-VIM^-MC'   ;'62_inputVIM=MC-PALL^-CBLM=PALL6-VIM' ;
                             '63_inputVIM=MC=PALL^-CBLM=PALL-VIM'  ;'67_inputCBLM-VIM=MC=PALL^-CBLM'      ;
                             '71_inputCBLM-VIM=MC=PALL^-CBLM'      ;'75_inputCBLM-PALL^-VIM=MC^=MC-CBLM'  ;
                             '76_inputCBLM=PALL^-VIM=MC-CBLM'      ;'77_inputCBLM=PALL^-VIM-MC^=MC-CBLM'  ;
                             '78_inputCBLM=PALL^-VIM=MC-PALL^-CBLM';'79_inputCBLM=PALL^-VIM=MC^=MC-CBLM'  ;
                             '80_PALL=MC-CBLM-VIM=MC'              ;'81_PALL-CBLM-VIM=MC=PALL^-CBLM'      ;
                             '82_PALL=MC-CBLM-PALL^-VIM=MC'        ;'83_PALL=CBLM-VIM=MC-CBLM'            ;
                             '84_PALL=CBLM^-MC-VIM^-CBLM=MC'       ;'85_PALL=CBLM-VIM=MC-PALL^-CBLM'      ;
                             
                             '86_PALL=CBLM^=MC=VIM'                ;                                        % 0 input
                             
                             '87_inPALL=inMC^=CBLM-CBLM-VIM=MC'    ;'88_inPALL=MC^=CBLM-CBLM-inVIM=MC'    ; % 2 input
                             '89_inPALL=MC^=inCBLM-CBLM^-VIM=MC'   ;'90_PALL=inMC^=CBLM-CBLM-inVIM=MC'    ;
                             '91_PALL=inMC^=inCBLM-CBLM^-VIM=MC'   ;'92_PALL=MC^=inCBLM-CBLM^-inVIM=MC'   ;
                             
                             '93_inPALL=inMC^=CBLM-CBLM^-inVIM=MC' ;'94_inPALL=inMC^=inCBLM-CBLM^-VIM=MC' ; % 3 input
                             '95_inPALL=MC^=inCBLM-CBLM^-inVIM=MC' ;'96_PALL=inMC^=inCBLM-CBLM^-inVIM=MC' ;
                             
                             '97_inPALL=inMC^=inCBLM-CBLM-inVIM=MC';                                        % 4 input
                             
                             
                             
                             
                             
                                                                                                            };

cfg.DCMpar.fixconnect     = {[1 1 0 0;              
                              1 1 1 0;              
                              0 1 1 1;              
                              0 1 0 1];
                             [1 1 0 0;              
                              1 1 1 0;              
                              0 1 1 1;              
                              1 1 0 1];
                             [1 1 0 1;              
                              1 1 1 0;              
                              0 1 1 1;              
                              0 1 0 1];
                             [1 0 0 1;              
                              0 1 1 0;              
                              0 1 1 1;              
                              1 1 0 1];
                             [1 0 0 1;              
                              1 1 1 0;              
                              0 1 1 1;              
                              1 1 0 1];
                             [1 1 0 1;
                              0 1 1 0;
                              0 1 1 1;
                              1 1 0 1];
                             [1 1 0 1;
                              1 1 1 0;
                              0 1 1 1;
                              1 1 0 1];
                                          };

cfg.DCMpar.inputconnect   = {[ 1 ;      %inPALL
                               0 ;
                               0 ;
                               0  ];
                             [ 0 ;      %inMC
                               1 ;
                               0 ;
                               0  ];
                             [ 0 ;      %inVIM
                               0 ;
                               1 ;
                               0  ];
                             [ 0 ;      %inCBLM
                               0 ;
                               0 ;
                               1  ];
                             [ 0 ;      %noINPUT
                               0 ;
                               0 ;
                               0 ;] 
                             [ 1 ;      %inPALLinMC
                               1 ;
                               0 ;
                               0  ];
                             [ 1 ;      %inPALLinVIM
                               0 ;
                               1 ;
                               0  ];
                             [ 1 ;      %inPALLinCBLM
                               0 ;
                               0 ;
                               1  ];
                             [ 0 ;      %inMCinVIM
                               1 ;
                               1 ;
                               0  ];
                             [ 0 ;      %inMCinCBLM
                               1 ;
                               0 ;
                               1 ;];
                             [ 0 ;      %inVIMinCBLM
                               0 ;
                               1 ;
                               1 ;];
                             [ 1 ;      %inPALLinMCinVIM
                               1 ;
                               1 ;
                               0 ;] 
                             [ 1 ;      %inPALLinMCinCBLM
                               1 ;
                               0 ;
                               1 ;]
                             [ 1 ;      %inPALLinVIMinCBLM
                               0 ;
                               1 ;
                               1 ;]
                             [ 0 ;      %inMCinVIMinCBLM
                               1 ;
                               1 ;
                               1 ;];
                             [ 1        %inPALLinMCinVIMinCBLM
                               1
                               1
                               1  ]; };
                           
% --- Create all Configurations --- %

cntBCH   =   1; % Counter for the batch cell
cntC     =   6; % Counter for inputconnect, will start at model 36 (then every model has different input).

for a = 1:length(cfg.DCMpar.modelname)
    
    % --- Set the dcm.c (input) --- %
    
    if     a < 8
        conf.DCMpar.inputconnect = cfg.DCMpar.inputconnect{1};     % inPALL
    elseif a > 7  && a < 15
        conf.DCMpar.inputconnect = cfg.DCMpar.inputconnect{2};     % inMC
    elseif a > 14 && a < 22
        conf.DCMpar.inputconnect = cfg.DCMpar.inputconnect{3};     % inVIM
    elseif a > 21 && a < 29
        conf.DCMpar.inputconnect = cfg.DCMpar.inputconnect{4};     % inCBLM
    elseif a > 28 && a < 36
        conf.DCMpar.inputconnect = cfg.DCMpar.inputconnect{5};     % noIN
    elseif a > 35
        conf.DCMpar.inputconnect = cfg.DCMpar.inputconnect{cntC};  % MultiInput
        cntC    =   cntC + 1;
    end
    
    % --- Set the dcm.a (fixed connection) --- %
    
    if a == 1 || a == 8 || a == 15 || a == 22 || a == 29           % Until 34 it the fixed connections changes with every model
        cnt = 1;
    elseif a > 34
        cnt = 7;                                                   % After 34 there are only double=double models
    end
    
    conf.DCMpar.fixconnect = cfg.DCMpar.fixconnect{cnt};
    cnt = cnt + 1;
    
    % --- create the batch configuration --- %
    
    conf.DCMpar.modelname             =   cfg.DCMpar.modelname{a};
    bch_conf{cntBCH} =   conf;
    
    cntBCH    =   cntBCH + 1;
    
end

%--------------------------------------------------------------------------       

%% Run the batch
%--------------------------------------------------------------------------       

% --- Run the batch using qsubcellfun --- %

pwd     =   cd;

logdir  =   '/home/action/micdir/Torque-log/DCM_gpe4gpi/cohort2/estDCM';

if ~exist(logdir,'dir'); mkdir(logdir); end

cd(logdir)
keyboard
bch_conf = bch_conf(1:28);
% cd /home/action/micdir

for i = 1:length(bch_conf)
    
    qsubfeval('pf_dcm_batch',bch_conf{i},'estDCM','timreq',12*60*60,'memreq',6144*1000*1000,'diary','always');
%     qsubfeval('pf_dcm_batch',bch_conf{i},'illMod','timreq',1*60,'memreq',3072*1000*1000,'diary','always');
%     qsubfeval('pf_dcm_batch',bch_conf{i},'creDSMTX','timreq',10*60,'memreq',3072*1000*1000,'diary','always');
%       pf_dcm_batch(bch_conf{i},'specDCM');

end

cd(pwd)

%--------------------------------------------------------------------------       

