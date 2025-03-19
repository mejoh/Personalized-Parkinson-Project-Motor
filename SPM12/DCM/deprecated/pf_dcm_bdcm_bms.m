function pf_dcm_bdcm_bms(conf)
% pf_dcm_bdcm_bms(conf) is part of the pf_dcm_bdcm batch. Specifically it
% will perform a Bayesian Model Selection after you have performed model
% estimation of a model space. Specify the correct configuration
%
% See also pf_dcm_bdcm

%©Michiel Dirkx, 2018 

%--------------------------------------------------------------------------

%% Initialization
%--------------------------------------------------------------------------

nMod    =   length(conf.bms.models);
nSub    =   length(conf.sub.name);
modname =   cell(nMod,1);
L       =   nan(nMod,nSub);     % to store model evidence

%--------------------------------------------------------------------------

%% Function
%--------------------------------------------------------------------------

for a = 1:nMod
    
    CurMod      = conf.bms.models{a};
    CurDir      = pf_findfile(conf.bms.dir.models,CurMod);
    modname{a}  =   CurDir;
    disp(['Working on model "' CurDir '"'])
    CurDir      = pf_findfile(fullfile(conf.bms.dir.models,CurDir),conf.bms.dir.opt,'fullfile');
    
    for b = 1:nSub
        
        CurSub  = conf.sub.name{b};
        CurFile = pf_findfile(CurDir,conf.bms.filename,'conf',conf,'CurSub',b);
        
        % --- Load DCM file --- %
        
        dcm = load(fullfile(CurDir,CurFile));
        
        % --- Store model evidence --- %
        
        L(a,b)  =   dcm.out.F;
        
        disp(['- Added ' CurFile])
        
    end
end

% --- Run the BMS --- %

options.modelNames  =   modname;
[posterior,out]     =   VBA_groupBMC(L,options);
keyboard

