function pf_dcm_bdcm_batch(conf,varargin)
% pf_ bdcm_batch(conf,varargin) is a batch for applying Dynamic Causal 
% Modeling via Daunizeau's VBA toolbox to your dataset. This was especially
% done for applying behavioural DCM to your dataset, which is not posssible
% through the SPM toolbox of DCM. Specify the following inputs: 
%       - conf: this is a structure defining the configuration of
%         your specific dataset. 
%       - varargin, which can be:
%          - estDCM: inversion of DCM 
%
% If you don't use this script as a function, the script defaults (i.e.
% for my dataset) will be used. This also means you can change these
% defaults (under Warming Up and Configuration) and run this script without
% specifying inputs.
%
% See also https://mbb-team.github.io/VBA-toolbox/ for more information

% Created by Michiel Dirkx, 2018
% Contact: michieldirkx@gmail.com
% $ParkFunC, version 20181220
%
%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

% --- bDCM batch options --- %

if nargin < 2      
%     varargin{1} = 'illmod'; 
%     varargin{1} = 'estDCM'; 
    varargin{1} = 'bms'; 
end

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

if nargin < 1       

tic;    
    
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
                     'OFF';'OFF';'ON' ;'OFF';'OFF';%5
                     'OFF';'ON' ;'OFF';'ON' ;'OFF';%10
                     'ON' ;'ON' ;'ON' ;'OFF';'OFF';%15
                     'ON' ;'OFF';'OFF';'ON' ;'ON' ;%20
                     'OFF';'OFF';'ON' ;'ON' ;'ON' ;%25
                     'OFF';'ON' ;'ON' ;'OFF';'ON' ;%30 
                     'OFF';'ON' ;'OFF';'ON' ;'OFF';%35
                     'ON' ;'ON' ;'OFF';'ON' ;'ON' ;%40
                     'OFF';                        %41
                     }; % Define if first session was OFF (placebo) or ON (madopar)
%                  
sel = [
         2 8 11 18 21 27 28 29 30 36 38 40 42 47 48 49 50 59 60 62 70 71 72 74 75 77 81 83 ... %Definitely tremor
         14 ...                                                                              %maybe tremor
         33 56 64 76                                                                         %Tremor but noisy EMG
      ]; %TREMOR IN OFF - incl. doubt
  
% sel = [
%          2 8 11 18 21 27 28 29 30 36 40 42 47 48 49 50 59 60 62 71 72 74 75 77 81 83 ... %Definitely tremor
%          14 ...                                                                              %maybe tremor
%          33 56 64 76                                                                         %Tremor but noisy EMG
%       ]; %TREMOR IN OFF - incl. doubt  
  
sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

%==========================================================================
% --- DCM options (estDCM) --- %
%==========================================================================

% --- Load VOIs in observation matrix y_fmri --- %

conf.dcm.voi.name = {
                     '/MC/&/VOI/&/CurSub/&/.mat/';
                     '/VLpv/&/VOI/&/CurSub/&/.mat/';
                     '/CBLM/&/VOI/&/CurSub/&/.mat/';
                     '/COCO/&/VOI/&/CurSub/&/.mat/';
                    };             % VOI .mat files you want to include (uses pf_findfile)
conf.dcm.voi.dir  =  '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/M48_reclasICA-AROMA_spmthrsh0c2_FARM1_han2s_EMG-log_broadband/COCO/COCO/VOIs/Mask_P=1-none/OFF'; % Directory in which files are located

% --- Load inputs in matrix u --- %

conf.dcm.input.name =   {'/COCO/&/condition.mat/'};                                        % Files you want to include (uses pf_findfile)
conf.dcm.input.dir  =   {{'/home/action/micdir/data/DRDR_MRI/fMRI' 'CurSub' 'func' 'OFF' 'COCO/info/condition'}};
conf.dcm.input.idx  =   {1;};                                                                           % Index of regressor stored in file (1 if only 1 vector)        

% --- Connectivity parameters --- %

conf.dcm.par.name   =   'M1_COCO2VLpv'; % Model name
                     
conf.dcm.par.a      =   [
                         1 1 0 1
                         1 1 1 1
                         1 0 1 1
                         1 1 1 1
                         ]; % DCM.A
                     
conf.dcm.par.b{1}   =   [
                         0 0 0 0
                         0 0 0 0
                         0 0 0 0
                         0 0 0 0
                         ]; % DCM.B

conf.dcm.par.c      =   [
                         0 
                         0 
                         0
                         0
                         ]; % DCM.C
conf.dcm.par.d      = {};

% --- Other DCM options --- %                  

conf.dcm.opt.name           = '1_dsDCM'; % Arbitrary label for your specific model options
conf.dcm.opt.tr             = 0.859;    % TR
conf.dcm.opt.te             = 0.034;    % TE
conf.dcm.opt.microdt        = 1/16;     % micro_resolution, not sure actually but think 1/16 (as used by SPM). 
conf.dcm.opt.homogeneous    = 0;        % enforces identical hemodynamic params across ROIs                  
conf.dcm.opt.reduced_f      = 1;        % simplified HRF model
conf.dcm.opt.stochastic     = 1;        % Stochastic
conf.dcm.opt.behav          = 0;        % Behavioural (if 1 then specify behavioural options)
conf.dcm.opt.illus.plot     = 0;        % Illustrate model (uses pf_dcm_addillus)
conf.dcm.opt.illus.save     = 1;        % Specify is illustration should be saved (the model save directory will be used)
                  
% --- Behavioural DCM options --- %

conf.dcm.output.name    =  {
                             '/CurSub/&/CurOFF/&/MA-/&/log.mat/';
                            };        % File name located in conf.dcm.output.dir (uses pf_findfile)
conf.dcm.output.dir     =   '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/COCO/ZSCORED'; 
conf.dcm.output.idx     =  {1;};      % First index (unconvolved amplitude regressor)

conf.dcm.output.ar      =  [1 0 0 0]; % Ar matrix, each row corresponding to each output, every column to each node
conf.dcm.output.br      =  {[]};      % Br matrix, each cell corresponding to the nth input. 
conf.dcm.output.cr      =  {};        % Cr matrix
conf.dcm.output.dr      =  {};        % Dr matrix

% --- Save Options --- %

conf.dcm.save.dir       =  '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/BDCM_Models';   % Save directory. A subdirectory with conf.dcm.par.name and conf.dcm.opt.name will be created

%==========================================================================
% --- BMS options (bms) --- %
%==========================================================================
                      
conf.bms.dir.models     =  '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/BDCM_Models'; % root directory of models
conf.bms.dir.opt         = '2_bDCM'; %Option folder located within model folder                       
conf.bms.models         =  {
                            '|M1*';
                            '|M2*';
                            '|M3*';
                            '|M4*';
                            '|M5*';
                           };       % Models you want to include located in conf.bms.dir.models
conf.bms.filename       = '/DCM/&/CurSub/&/.mat/'; % DCM file (uses pf_findfile)                       


end

%--------------------------------------------------------------------------

%% Loop through specified chapters
%--------------------------------------------------------------------------

nVar    =   length(varargin);

for a = 1:nVar
    
   CurVar   =    varargin{a};
   
   switch CurVar
       
       %-------------------------------------------------------------------
       case 'illmod'
       %-------------------------------------------------------------------
    
       fprintf('\n%s\n','% ------------ Illustrating model -------------%')
       pf_dcm_bdcm_illmod(conf)
       
       %-------------------------------------------------------------------
       case 'estDCM'
       %-------------------------------------------------------------------
    
       fprintf('\n%s\n','% ------------- Performing DCM inversion -------------%')
       pf_dcm_bdcm_estdcm(conf)
       
       %-------------------------------------------------------------------
       case 'bms'
       %-------------------------------------------------------------------
    
       fprintf('\n%s\n\n','% ------------- Performing Bayesian Model Comparison -------------%')
       pf_dcm_bdcm_bms(conf)
       
       %-------------------------------------------------------------------
       otherwise
       %-------------------------------------------------------------------
       
       warning('bdcm:varargin',['Could not determine option "' CurVar '"'])
       
   end
    
end

%--------------------------------------------------------------------------

%% Cooling Down
%--------------------------------------------------------------------------

if nargin < 1
    
T = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])

end

%--------------------------------------------------------------------------
