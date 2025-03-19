function dcm_qsubbatch_drdr_restingstate(conf)
%
% qsubbatch of the dopamod paper.
%
%
% � Michiel Dirkx, 2014
% $ParkFunC
%--------------------------------------------------------------------------       

%% Warming Up

addpath /home/common/matlab/fieldtrip/qsub/ % Add the qsub directory to your path

%--------------------------------------------------------------------------

%% Template pf_dcm_batch configuration
%--------------------------------------------------------------------------       

%==========================================================================    
% --- Directories --- %
%==========================================================================

conf.dir.root          = '/home/action/micdir/data/DRDR_MRI/fMRI';                                 % Main directory containing all subfolders    

% --- creVOI --- %

conf.dir.firstlevel    = fullfile(conf.dir.root,'analysis','M43_ICA-AROMAnonaggr_spmthrsh0c25_FARM1_han2s_EMG-log_broadband_retroicor18r-exclsub','RS');                                                  % Directory of your first level analysis + VOI time courses 
conf.dir.ROImasks      = '/home/action/micdir/MATLAB/ROI_MD/DRDR-MRI-RS';                                      % Directory of your ROI masks, this will be used if you make VOI's and use a mask for it
conf.dir.saveVOI       = fullfile(conf.dir.firstlevel,'VOIs');

% --- creDSMTX --- %

conf.dir.scans_main    = conf.dir.root;                                                            % Main folder where your scans are stored
conf.dir.scans_sub     = {
                          {'OFF','OFF','func/SESS1/RS/preproc/ICA-AROMA_smooth','func/SESS2/RS/preproc/ICA-AROMA_smooth';}
                          {'ON','ON','func/SESS1/RS/preproc/ICA-AROMA_smooth','func/SESS2/RS/preproc/ICA-AROMA_smooth';}
%                           'func/SESS1/RS/preproc/ICA-AROMA_smooth';
%                           'func/SESS2/RS/preproc/ICA-AROMA_smooth';
                          };                % Subfolder (for every subject) where the (preprocessed) scans are stored
conf.dir.EMG           = '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/ZSCORED/OFFON_concat/';           % Directory of all your EMG files (which will be used for your design matrix)

% --- DCM dirs --- %

conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none','OFFON');         % Directory of your VOI files                 
conf.dir.save          = fullfile(conf.dir.root,'analysis/DCM_Models/SPM12');                 % Directory where your DCM models will be stored (if it doesn't exist, this script will make them)
conf.dir.DCMtempl      = fullfile(conf.dir.root,'analysis/DCM_Models/template_dcm');          % Directory of your template DCM.mat file (specified DCM), this might be any specified DCM.mat file, we will replace everything
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


% sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83]; % DOPARESISTANT - confirmed doubts (14, 62, 47, 80, 82)
% sel =   [18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % DOPARESPONSIVE - confirmed doubts (24)
%      
% sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ... 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts     
% 
% sel =   [30 08 11 28 27 42 50 72 75 74 78 81 83 ... 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % MINUS p73     

% sel = [8 11 27 28 30 42 43 50 72 74 75 78 81 83 ... % NEW RESIST
%        14 47 80 82 ...                              % NEW RESIST under review
%        2 18 21 29 33 36 38 40 49 60 70 71 77];      % NEW RESP NEW CLASSIFICATION Elble 3 cluster

% sel = pf_subidx(sel,conf.sub.name);
sel=1;
conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

%==========================================================================
% --- VOI parameters (creVOI) --- %
%==========================================================================

conf.voi.roi.name  = {
%                       'GPe';                            % Name of regions you want to extract
%                       'STN';
%                       'GPi';
%                       'MC';
%                       'VLT';
%                       'CBLM';
%                       'OP4';
%                       'MA';                      
%                       'CBLM2';
%                         'INandRESI-CBLM'; 
                        'SPC';
                      };                 
% conf.voi.side      = [1 1 1 1 1 0];                         % Take contralateral (=1) or ipsilateral (=0) side of VOI 
conf.voi.side      = [1];                         % Take contralateral (=1) or ipsilateral (=0) side of VOI 
conf.voi.roi.sc    = '/CurSide^_^/&/CurROI/&/.nii/';
conf.voi.conT      = {
%                       {'Tremorlog_deriv1 - OFF','OFF','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog_deriv1 - OFF','OFF','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog_deriv1 - OFF','OFF','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog - OFF','OFF','Tremorlog - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog - OFF','OFF','Tremorlog - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog - OFF','OFF','Tremorlog - Session 1','Tremorlog - Session 2'}
                      
%                       {'Tremorlog_deriv1 - ON','ON','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog_deriv1 - ON','ON','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog_deriv1 - ON','ON','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog - ON','ON','Tremorlog - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog - ON','ON','Tremorlog - Session 1','Tremorlog - Session 2'}
%                       {'Tremorlog - ON','ON','Tremorlog - Session 1','Tremorlog - Session 2'}
                      {'Tremorlog_deriv1 - ON','ON','Tremorlog_deriv1 - Session 1','Tremorlog - Session 2'}
                      };
conf.voi.conF      =  {'Effects_of_interest - OFF','OFF','Effects_of_interest - Session 1','Effects_of_interest - Session 2'};            % F contrast (usually effects_of_interest).
% conf.voi.conF      =  {'Effects_of_interest - ON','ON','Effects_of_interest - Session 1','Effects_of_interest - Session 2'};            % F contrast (usually effects_of_interest).
conf.voi.P         =  'none';                           % Specify uncorrected ('none') or corrected ('FWE') p values
conf.voi.Pthresh   =   1;                               % P-threshold, every suprathreshold value will be included
conf.voi.method    =  'Mask';                           % Use a mask ('Mask') for extracting VOI's or sphere around coordinates ('Sphere');
conf.voi.sess      =  {'OFF','OFF',1,2};                % Indicate which session (e.g. {'OFF','OFF',1,2} means you want OFF, and if conf.sub.sess1 = 'OFF' then take session 1, otherwise 2)
% conf.voi.sess      =  {'ON','ON',1,2};                % Indicate which session (e.g. {'OFF','OFF',1,2} means you want OFF, and if conf.sub.sess1 = 'OFF' then take session 1, otherwise 2)

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

conf.dsmtx.scan.tr      =  0.859;                               % TR of scans
conf.dsmtx.scan.te      =  0.034;                                % TE (echo time) of scans, necessary for DCM 
conf.dsmtx.scan.nDummy  =  0;                                   % Remove the first nDummy scans (check your folder and count which is the first actual scan (ascending order)
conf.dsmtx.scan.name    =  '/sw/&/.nii/';                      % Generic name of your scans in folder  (make sure your fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub) directory contains these scans

% --- General condition Settings (creDSMTX) --- %

conf.dsmtx.cond.name  = {
                           'EMGRegr';                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
                           'Dopa'   ;
                        };                           
conf.dsmtx.cond.ons   = {
%                          1:1:1390;           % Onset corresponding to condition specified above (so again new row for every condition)    
%                            696;       % normal dataset
                        1:1:1389 % nScan p73
                           695;    % onset p73   
                        };
conf.dsmtx.cond.dur   = {
                           0;           % Duration corresponding to condition specified above (so again new row for every condition)
                           695;         % normal data
                         };
conf.dsmtx.cond.unit  = 'scans';                                % Units of time ('scans' or 'seconds')  
                     
% --- Condition specific settings (creDSMTX) --- %                        
                          
conf.dsmtx.cond.emg        =  '/CurSub/&/Log_deriv1_unconvolved.mat/';   % Name of EMG file located in conf.dir.EMG (if you specified 'EMGRegr' as a condition)

conf.dsmtx.cond.sess       =  {'OFF','OFF','SESS1','SESS2'};          % Indicate session for condition files (nb, only 1 possible)
% conf.dsmtx.cond.emg.file   =  '/CurSub/&/Log_deriv1_unconvolved.mat/';   % Name of EMG file located in conf.dir.EMG (if you specified 'EMGRegr' as a condition)
% conf.dsmtx.cond.emg.idx    =  1;                                      % Index of column in EMG file you want to use (typically deriv1 unconvolved)
% conf.dsmtx.cond.cond.file  =  '/CurSub/&/CurSess/&/condition.mat/';   % name of condition file (used by 'COCO')

%==========================================================================
% --- DCM parameters (specDCM, estDCM, illMod) --- %
%==========================================================================

conf.DCMpar.modelname     = 'something went wrong';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
conf.DCMpar.GLMmethod     = '12-Deriv1_ParamMod_Stoch-twostate-inh';      % For every different design matrix you use you can use a different name
conf.DCMpar.input         = {[0 1],1};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
% conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
conf.DCMpar.sess          = {1};                                        % Amount of Sessions (? Not sure if works, I only use one session)
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
conf.DCMpar.modcon(:,:,2) = [0 0 0 0 0 0;              % Input 2 (dopamod, this will modulate the VIM>VIM)
                             0 0 0 0 0 0;               
                             0 0 0 0 0 0;               
                             0 0 0 0 0 0;
                             0 0 0 0 1 0;
                             0 0 0 0 0 0;];            
conf.DCMpar.inputconnect  = [ 0 0;      %inGPi (dopamod no input)
                              0 0;
                              1 0;
                              0 0;
                              0 0;
                              0 0;];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
% conf.DCMpar.inputconnect  = [ 0;      %inGPi
%                               0;
%                               1;
%                               0;
%                               0;
%                               0;];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c                          
conf.DCMpar.d             = double.empty(4,4,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
conf.DCMpar.TA            = [0.4295;0.4295;0.4295;0.4295;0.4295;0.4295];                % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
conf.DCMpar.twostate      = 1;                        % 0 for one state nodes, 1 for two state
conf.DCMpar.stochastic    = 1;                        % 0 for deterministic DCM, 1 for stochastic effects
conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
conf.DCMpar.hiddennode    = [];                       % Index of the node which is to be hidden
conf.DCMpar.endogenous    = 0;

%--------------------------------------------------------------------------   

%% Create individual batches (edit your arguments of interest here)
%--------------------------------------------------------------------------       


cfg.DCMpar.modelname      = {
%                              'M1_brain';
%                              'M2_brainOFF';
%                              'M3_brainON';
%                              'M4_allcondopa';
%                              'M5_brain_plusdopaGPi';
%                              'M6_onlyGPimod';
%                              'M7_nomod';
%                              'M8_nodopa';
% 
%                              'MB1_GPe-GPe'   ;'MB2_MC-GPe'  ;
%                              'MB3_CBLM-GPe'  ;'MB4_GPe-STN' ;
%                              'MB5_MC-STN'    ;'MB6_STN-GPi' ;
%                              'MB7_GPi-GPi'   ;'MB8_MC-GPi'  ;
%                              'MB9_CBLM-GPi'  ;'MB10_GPi-MC' ;
%                              'MB11_MC-MC'    ;'MB12_VIM-MC' ;
%                              'MB13_MC-VIM'   ;'MB14_VIM-VIM';
%                              'MB15_CBLM-VIM' ;'MB16_MC-CBLM';
%                              'MB17_CBLM-CBLM';'MB18_NoMod'  ;
                             'MB19_STN-STN';
                             
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

%                                'MIN1_INandCBLM2';
                            };
                        
cfg.DCMpar.modcon      =  {
                             [
                                1   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   1   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   1; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                1   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   1   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   1   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   1   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   1   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   1; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   1   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   1   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   1   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   1   0   0; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   1   0; % VIM        
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   1; % VIM
                                0   0   0   0   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   1   0   0; % CBLM
                              ];
                              [
                                0   0   0   0   0   0; % GPe 
                                0   0   0   0   0   0; % STN 
                                0   0   0   0   0   0; % GPi              
                                0   0   0   0   0   0; % MC             
                                0   0   0   0   0   0; % VIM
                                0   0   0   0   0   1; % CBLM
                              ];
                              [
                               0   0   0   0   0   0; % GPe 
                               0   0   0   0   0   0; % STN 
                               0   0   0   0   0   0; % GPi              
                               0   0   0   0   0   0; % MC             
                               0   0   0   0   0   0; % VIM
                               0   0   0   0   0   0; % CBLM
                              ];
                              [
                               0   0   0   0   0   0; % GPe 
                               0   1   0   0   0   0; % STN 
                               0   0   0   0   0   0; % GPi              
                               0   0   0   0   0   0; % MC             
                               0   0   0   0   0   0; % VIM
                               0   0   0   0   0   0; % CBLM
                              ];
                         };                                                
                                                
% --- Create all Configurations --- %

cntBCH   =   1; % Counter for the batch cell

for a = 1:length(cfg.DCMpar.modelname)   
    
    conf.DCMpar.modelname     =  cfg.DCMpar.modelname{a};
    
    if strcmp(conf.DCMpar.modelname(1:2),'MB')
        
        conf.DCMpar.modcon(:,:,2) =  cfg.DCMpar.modcon{a};
        
    elseif strcmp(conf.DCMpar.modelname(1:3),'MEX') && str2double(conf.DCMpar.modelname(4))<5

        conf.DCMpar.fixconnect    = [
                                  % GPe  STN GPi MC VIM CBLM MUSC   OP4/CBLM2 
                                     1   0   0   1   0   1    0       0;  % GPe 
                                     1   1   0   1   0   0    0       0;  % STN 
                                     0   1   1   1   0   1    0       0;  % GPi              
                                     0   0   1   1   1   0    0       0;  % MC             
                                     0   0   0   1   1   1    0       0;  % VIM
                                     0   0   0   1   0   1    0       0;  % CBLM
                                     0   0   0   0   0   0    0       0;  % MUSC
                                     0   0   0   0   0   0    0       0;  % OP4/CBLM2
                                    ];
        conf.DCMpar.modcon        = [0 0 0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                     0 0 0 0 0 0 0 0;               
                                     0 0 0 0 0 0 0 0;               
                                     0 0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0 0;
                                     ];            
        conf.DCMpar.inputconnect  = [ 0;      %inGPi
                                      0;
                                      1;
                                      0;
                                      0;
                                      0;                                      
                                      0;
                                      0;
                                     ];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c                          
        conf.DCMpar.d             = double.empty(8,8,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
        conf.DCMpar.TA            = [0.4295;0.4295;0.4295;0.4295;0.4295;0.4295;0.4295;0.4295];               
        
        if strcmp(conf.DCMpar.modelname,'MEX1_OP4_nodirect')
               
               conf.DCMpar.fixconnect    = [
                                  % GPe  STN GPi MC VIM CBLM MUSC    OP4 
                                     1   0   0   1   0   1    0       0;  % GPe 
                                     1   1   0   1   0   0    0       0;  % STN 
                                     0   1   1   1   0   1    0       0;  % GPi              
                                     0   0   1   1   1   0    0       1;  % MC             
                                     0   0   0   1   1   1    1       1;  % VIM
                                     0   0   0   1   0   1    1       1;  % CBLM
                                     0   0   0   1   0   0    1       0;  % MUSC
                                     0   0   0   1   1   1    0       1;  % OP4
                                    ];
               conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'MA';'OP4';};                 
        
        elseif strcmp(conf.DCMpar.modelname,'MEX2_OP4_direct')
            
               conf.DCMpar.fixconnect    = [
                                  % GPe  STN GPi MC VIM CBLM MUSC    OP4 
                                     1   0   0   1   0   1    0       0;  % GPe 
                                     1   1   0   1   0   0    0       0;  % STN 
                                     0   1   1   1   0   1    0       0;  % GPi              
                                     0   0   1   1   1   0    0       1;  % MC             
                                     0   0   0   1   1   1    1       1;  % VIM
                                     0   0   0   1   0   1    1       1;  % CBLM
                                     0   0   0   1   0   0    1       0;  % MUSC
                                     0   0   0   1   1   1    1       1;  % OP4
                                    ];
                                       
               conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'MA';'OP4';};                 
                             
        elseif strcmp(conf.DCMpar.modelname,'MEX3_CBLM2_nodirect')
            
              conf.DCMpar.fixconnect    = [
                                  % GPe  STN GPi MC VIM CBLM MUSC   CBLM2 
                                     1   0   0   1   0   1    0       0;  % GPe 
                                     1   1   0   1   0   0    0       0;  % STN 
                                     0   1   1   1   0   1    0       0;  % GPi              
                                     0   0   1   1   1   0    0       0;  % MC             
                                     0   0   0   1   1   1    1       0;  % VIM
                                     0   0   0   1   0   1    1       1;  % CBLM
                                     0   0   0   1   0   0    1       0;  % MUSC
                                     0   0   0   0   0   1    0       1;  % CBLM2
                                    ];
                                conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'MA';'CBLM2'};
        elseif strcmp(conf.DCMpar.modelname,'MEX4_CBLM2_direct')
            
            conf.DCMpar.fixconnect    = [
                % GPe  STN GPi MC VIM CBLM MUSC   CBLM2
                1   0   0   1   0   1    0       0;  % GPe
                1   1   0   1   0   0    0       0;  % STN
                0   1   1   1   0   1    0       0;  % GPi
                0   0   1   1   1   0    0       0;  % MC
                0   0   0   1   1   1    1       0;  % VIM
                0   0   0   1   0   1    1       1;  % CBLM
                0   0   0   1   0   0    1       0;  % MUSC
                0   0   0   0   0   1    1       1;  % CBLM2
                ];
            conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'MA';'CBLM2'};
        
        elseif strcmp(conf.DCMpar.modelname,'MEX34-1_CBLM2_direct2MUSC')
            
            conf.DCMpar.fixconnect    = [
                % GPe  STN GPi MC VIM CBLM MUSC   CBLM2
                1   0   0   1   0   1      0       0;  % GPe
                1   1   0   1   0   0      0       0;  % STN
                0   1   1   1   0   1      0       0;  % GPi
                0   0   1   1   1   0      0       0;  % MC
                0   0   0   1   1   1      1       0;  % VIM
                0   0   0   1   0   1      1       1;  % CBLM
                0   0   0   1   0   0      1       1;  % MUSC
                0   0   0   0   0   1      0       1;  % CBLM2
                ];
            conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'MA';'CBLM2'};
        
        elseif strcmp(conf.DCMpar.modelname,'MEX12-1_OP4_direct2MUSC')
               
               conf.DCMpar.fixconnect    = [
                                  % GPe  STN GPi MC VIM CBLM MUSC    OP4 
                                     1   0   0   1   0   1    0       0;  % GPe 
                                     1   1   0   1   0   0    0       0;  % STN 
                                     0   1   1   1   0   1    0       0;  % GPi              
                                     0   0   1   1   1   0    0       1;  % MC             
                                     0   0   0   1   1   1    1       1;  % VIM
                                     0   0   0   1   0   1    1       1;  % CBLM
                                     0   0   0   1   0   0    1       1;  % MUSC
                                     0   0   0   1   1   1    0       1;  % OP4
                                    ];
               conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'MA';'OP4';};                 
        end
        
    elseif strcmp(conf.DCMpar.modelname(1:3),'MEX') && str2double(conf.DCMpar.modelname(4))>4
        
        conf.DCMpar.fixconnect    = [%MUSCLE    OP4/CBLM2
                                       0          0; 
                                       0          0;
                                    ];
        conf.DCMpar.modcon        = [0 0;              % Input 1 (on/offset, no input)
                                     0 0;               
                                     ];            
        conf.DCMpar.inputconnect  = [ 0;%muscle      
                                      1;%op4/cblm2
                                     ];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c                          
        conf.DCMpar.d             = double.empty(2,2,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
        conf.DCMpar.TA            = [0.4295;0.4295];   

        if strcmp(conf.DCMpar.modelname,'MEX5_OP4-MUSC')
              
            conf.voi.roi.name  = {'MA';'OP4';};                 
            conf.DCMpar.fixconnect    = [%MUSCLE      OP4
                                            1          1; %Muscle
                                            0          1; %OP4
                                        ];
        elseif strcmp(conf.DCMpar.modelname,'MEX6_MUSC-OP4')
              
            conf.voi.roi.name  = {'MA';'OP4';};                 
            conf.DCMpar.fixconnect    = [%MUSCLE      OP4
                                            1          0; %Muscle
                                            1          1; %OP4
                                        ];
        elseif strcmp(conf.DCMpar.modelname,'MEX7_CBLM2-MUSC')
              
            conf.voi.roi.name  = {'MA';'CBLM2';};                 
            conf.DCMpar.fixconnect    = [%MUSCLE      CBLM2
                                            1          1; %Muscle
                                            0          1; %CBLM2
                                        ];
        elseif strcmp(conf.DCMpar.modelname,'MEX8_MUSC-CBLM2')
              
            conf.voi.roi.name  = {'MA';'CBLM2';};                 
            conf.DCMpar.fixconnect    = [%MUSCLE      CBLM2
                                            1          0; %Muscle
                                            1          1; %CBLM2
                                        ];
        elseif strcmp(conf.DCMpar.modelname,'MEX9_MC-MUSC')
              
            conf.voi.roi.name  = {'MA';'MC';};                 
            conf.DCMpar.fixconnect    = [%MUSCLE      MC
                                            1          1; %Muscle
                                            0          1; %MC
                                        ];
                                    
        elseif strcmp(conf.DCMpar.modelname,'MEX91_MUSC-MC')
              
            conf.voi.roi.name  = {'MA';'MC';};                 
            conf.DCMpar.fixconnect    = [%MUSCLE      MC
                                            1          0; %Muscle
                                            1          1; %MC
                                        ];                                    
                                    
        end 
        
    elseif strcmp(conf.DCMpar.modelname,'M2_brainOFF')
       
       % --- Directory --- %
        
       conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none','OFF');         % Directory of your VOI files                 
       conf.dir.scans_sub     = {
                                 {'OFF','OFF','func/SESS1/RS/preproc/ICA-AROMA_smooth','func/SESS2/RS/preproc/ICA-AROMA_smooth'}; % I want OFF, and if conf.sub.sess1=OFF then take SESS1 folder, otherwise SESS2
                                 };                % Subfolder (for every subject) where the (preprocessed) scans are stored        
       conf.dir.EMG           = '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/ZSCORED/OFF';           % Directory of all your EMG files (which will be used for your design matrix)
       
       % --- CREDSMTX --- %
       conf.dsmtx.scan.nScan   =  695;                                 % nScans for p73 (yes, very annoying)
       conf.dsmtx.cond.name  = {'EMGRegr'};                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
       conf.dsmtx.cond.ons   = {1:1:conf.dsmtx.scan.nScan};           % Onset corresponding to condition specified above (so again new row for every condition)    
       conf.dsmtx.cond.dur   = {0};
       
       % --- SPECDCM --- %
       
       conf.specdcm.cond.temp   =  'DCM_template_M2_brainOFF.mat';        % The filename of your template specified DCM.mat file. It will be extended with nInput, so make sure your file ends with '1' for one input or '2' for two inputs and so forth 
       
       % --- MODEL --- %
       
       conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
       conf.DCMpar.modcon        = conf.DCMpar.modcon(:,:,1);
       conf.DCMpar.inputconnect  = [0; 0; 1; 0; 0; 0;];         % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
    elseif strcmp(conf.DCMpar.modelname,'M3_brainON')
        
        % --- Directory --- %
        
       conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none','ON');         % Directory of your VOI files                 
       conf.dir.scans_sub     = {
                                 {'ON','ON','func/SESS1/RS/preproc/ICA-AROMA_smooth','func/SESS2/RS/preproc/ICA-AROMA_smooth'}; % I want ON, and if conf.sub.sess1=ON then take SESS1 folder, otherwise SESS2
                                 };                % Subfolder (for every subject) where the (preprocessed) scans are stored        
       conf.dir.EMG           = '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/ZSCORED/ON';           % Directory of all your EMG files (which will be used for your design matrix)
       
       % --- CREDSMTX --- %
%        conf.dsmtx.scan.nScan   =  694;                                 % nScans for p73 (yes, very annoying)
       conf.dsmtx.scan.nScan   =  695;                                 %nScans for rest
       conf.dsmtx.cond.name  = {'EMGRegr'};                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
       conf.dsmtx.cond.ons   = {1:1:conf.dsmtx.scan.nScan};           % Onset corresponding to condition specified above (so again new row for every condition)    
       conf.dsmtx.cond.dur   = {0};
       
       % --- SPECDCM --- %
       
       conf.specdcm.cond.temp   =  'DCM_template_M3_brainON.mat';        % The filename of your template specified DCM.mat file. It will be extended with nInput, so make sure your file ends with '1' for one input or '2' for two inputs and so forth 
%        conf.specdcm.cond.temp   =  'DCM_template_M3_brainON_p73.mat';        % The filename of your template specified DCM.mat file. It will be extended with nInput, so make sure your file ends with '1' for one input or '2' for two inputs and so forth 
       
       % --- MODEL --- %
       
       conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
       conf.DCMpar.modcon        = conf.DCMpar.modcon(:,:,1);
       conf.DCMpar.inputconnect  = [0; 0; 1; 0; 0; 0;];         % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
       
       elseif strcmp(conf.DCMpar.modelname,'M4_allcondopa')
           
           % --- Directory --- %
           
           conf.dir.voi           = fullfile(conf.dir.saveVOI,'Mask_P=1-none','OFFON');         % Directory of your VOI files
           conf.dir.scans_sub     = {
                                     {'OFF','OFF','func/SESS1/RS/preproc/ICA-AROMA_smooth','func/SESS2/RS/preproc/ICA-AROMA_smooth'}; % I want ON, and if conf.sub.sess1=ON then take SESS1 folder, otherwise SESS2
                                     {'ON','ON','func/SESS1/RS/preproc/ICA-AROMA_smooth','func/SESS2/RS/preproc/ICA-AROMA_smooth'}; % I want ON, and if conf.sub.sess1=ON then take SESS1 folder, otherwise SESS2
                                    };  % Subfolder (for every subject) where the (preprocessed) scans are stored
           conf.dir.EMG           = '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/ZSCORED/OFFON_concat';           % Directory of all your EMG files (which will be used for your design matrix)
           
           % --- CREDSMTX --- %
           
           conf.DCMpar.modcon(:,:,2) = conf.DCMpar.fixconnect; % modulate all connections
       
    elseif strcmp(conf.DCMpar.modelname,'M5_brain_plusdopaGPi')
           
           conf.DCMpar.modcon(:,:,1) = [0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;];            
           conf.DCMpar.modcon(:,:,2) = [0 0 0 0 0 0;              % Input 2 (dopamod, this will modulate the VIM>VIM)
                                        0 0 0 0 0 0;               
                                        0 0 1 0 0 0;               
                                        0 0 0 0 0 0;
                                        0 0 0 0 1 0;
                                        0 0 0 0 0 0;];            
           
    elseif strcmp(conf.DCMpar.modelname,'M6_onlyGPimod')
           
           conf.DCMpar.modcon(:,:,1) = [0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;];            
           conf.DCMpar.modcon(:,:,2) = [0 0 0 0 0 0;              % Input 2 (dopamod, this will modulate the VIM>VIM)
                                        0 0 0 0 0 0;               
                                        0 0 1 0 0 0;               
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;];            
                                    
    elseif strcmp(conf.DCMpar.modelname,'M7_nomod')
           
           conf.DCMpar.modcon(:,:,1) = [0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;];            
           conf.DCMpar.modcon(:,:,2) = [0 0 0 0 0 0;              % Input 2 (dopamod, nothing in this case)
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;               
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;
                                        0 0 0 0 0 0;];                                                
                                    
     elseif strcmp(conf.DCMpar.modelname,'M8_nodopa')                           
                                    
        %General condition Settings (creDSMTX) 

        conf.dsmtx.cond.name  = {
                                   'EMGRegr';                             % Name of your conditions, use a new row for every condition (conditions are implemented a priori, if you want your specific condition to be added, contact me). 
                                };                           
        conf.dsmtx.cond.ons   = {
                                   1:1:conf.dsmtx.scan.nScan  ;           % Onset corresponding to condition specified above (so again new row for every condition)    
                                };
        conf.dsmtx.cond.dur   = {
                                   0                        ;           % Duration corresponding to condition specified above (so again new row for every condition)
                                 };                                    
        conf.DCMpar.input         = {[0 1]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
        conf.DCMpar = rmfield(conf.DCMpar,'modcon');                     
        conf.DCMpar = rmfield(conf.DCMpar,'inputconnect');                     
        conf.DCMpar.modcon(:,:,1) = [0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                     0 0 0 0 0 0;               
                                     0 0 0 0 0 0;               
                                     0 0 0 0 0 0;
                                     0 0 0 0 0 0;
                                     0 0 0 0 0 0;];            
        conf.DCMpar.inputconnect  = [ 0 ;      %inGPi (dopamod no input)
                                      0 ;
                                      1 ;
                                      0 ;
                                      0 ;
                                      0 ;];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
    
    elseif strcmp(conf.DCMpar.modelname,'MIN1_INandCBLM2')                           
    
        conf.DCMpar.fixconnect    = [
                                  % GPe  STN GPi MC VIM CBLM CBLM2 
                                     1   0   0   1   0   1    0;  % GPe 
                                     1   1   0   1   0   0    0;  % STN 
                                     0   1   1   1   0   1    0;  % GPi              
                                     0   0   1   1   1   0    0;  % MC             
                                     0   0   0   1   1   0    1;  % VIM
                                     0   0   0   1   0   1    0;  % CBLM
                                     0   0   0   0   0   1    1;  % CBLM2
                                    ];
        conf.voi.roi.name  = {'GPe';'STN';'GPi';'MC';'VLT';'CBLM_';'INandRESI-CBLM'};
%         conf.voi.roi.name  = {'INandRESI-CBLM'};
        conf.DCMpar = rmfield(conf.DCMpar,'modcon');
        conf.DCMpar.modcon(:,:,1) = [0 0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                     0 0 0 0 0 0 0;               
                                     0 0 0 0 0 0 0;               
                                     0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0;];            
        conf.DCMpar.modcon(:,:,2) = [0 0 0 0 0 0 0;              % Input 1 (on/offset, no input)
                                     0 0 0 0 0 0 0;               
                                     0 0 0 0 0 0 0;               
                                     0 0 0 0 0 0 0;
                                     0 0 0 0 1 0 0;
                                     0 0 0 0 0 0 0;
                                     0 0 0 0 0 0 0;];            
        conf.DCMpar.inputconnect  = [ 0 0;      %inGPi (dopamod no input)
                                      0 0;
                                      1 0;
                                      0 0;
                                      0 0;
                                      0 0;
                                      0 0];                     % Specify to which VOI your input goes (1 is input to this region, 0 is nothing). This is DCM.c
        conf.DCMpar.d             = double.empty(7,7,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
        conf.DCMpar.TA            = [0.4295;0.4295;0.4295;0.4295;0.4295;0.4295;0.4295];                % Fill in your slice time acquisition for every VOI. Note that i
    
    end
    
    bch_conf{cntBCH}    =   conf;
    cntBCH              =   cntBCH + 1;
    
end

%--------------------------------------------------------------------------       

%% Run the batch
%--------------------------------------------------------------------------       

% --- Run the batch using qsubcellfun --- %

logdir  =   '/home/action/micdir/Torque-log/creVOI_ON';

if ~exist(logdir,'dir'); mkdir(logdir); end

cd(logdir)
keyboard

% --- Create Subject Batches --- %

bch = bch_conf;
clear bch_conf
cnt = 1;

for a = 1:length(bch)
    
    nSub    =   length(bch{a}.sub.name);
    sub     =   bch{a}.sub.name;
    hand    =   bch{a}.sub.hand;
    sess1   =   bch{a}.sub.sess1;
    for b=1:nSub
        bch{a}.sub.name  = sub(b);
        bch{a}.sub.hand  = hand(b);
        bch{a}.sub.sess1 = sess1(b);
        
        bch_conf{cnt}   = bch{a};
        cnt = cnt+1;
    end
    
end

% --- End subject batches --- %

for i = 1:length(bch_conf)
    qsubfeval('pf_dcm_batch',bch_conf{i},'creVOI','timreq',0.5*60*60,'memreq',8*1024*1000*1000,'diary','always');
%     qsubfeval('pf_dcm_batch',bch_conf{i},'estDCM','timreq',45*60*60,'memreq',8*1024*1000*1000,'diary','always');
%     qsubfeval('pf_dcm_batch',bch_conf{i},'estDCM','timreq',20*60*60,'memreq',8*1024*1000*1000,'diary','always');
%     qsubfeval('pf_dcm_batch',bch_conf{i},'creDSMTX','timreq',20*60*60,'memreq',3072*1000*1000,'diary','always');
%     qsubfeval('pf_dcm_batch',bch_conf{i},'creDSMTX','timreq',20*60,'memreq',3072*1000*1000,'diary','always');
%     pf_dcm_batch(bch_conf{i},'specDCM');
%     pf_dcm_batch(bch_conf{i},'illMod');
%     pf_dcm_batch(bch_conf{i},'creDSMTX');
%     pf_dcm_batch(bch_conf{i},'creVOI');
end

% cd(pwd)

%--------------------------------------------------------------------------       

