function mjfnpf_dcm_specify_DCM(conf)
%
% pf_dcm_specify_DCM specifies all the DCM.mat files according to your
% configuration (conf) structure. It will save them to the directorty
% specified by you. In order to do so, you need a blanc DCM_.mat file,
% which can be found in the blancfiles folder of the PF toolbox. Enter the
% fullfile in your conf.dir.DCMtempl field. 
%
% � Michiel Dirkx, 2014
% $ParkFunC
% Updated: 20181012

%--------------------------------------------------------------------------

%% Initiate Parameters
%--------------------------------------------------------------------------

fprintf('\n%s\n',['%----- Specifying DCM.mat files of model ' conf.DCMpar.modelname ' -----%'])

nSub        = length(conf.sub.name);
nROI        = length(conf.VOI.VOInames);                                   % number of VOI's
% nInput      = length(conf.DCMpar.inputconnect(1,:));

% DCMtempl    = pf_findfile(conf.dir.DCMtempl,conf.specdcm.cond.temp,'fullfile');     % Template DCM file

%--------------------------------------------------------------------------

%% Loop through all subjects
%--------------------------------------------------------------------------

for h = 1:nSub
    
    clear DCM SPM p Sess Y xY U u CurVOI_correct
    CurSub      = conf.sub.name{h};
%     CurSess1    = conf.sub.sess1{h};
    fprintf('\n%s\n',['Working on ' CurSub])
    
    CurDir         = fullfile(conf.dir.save,conf.DCMpar.modelname,conf.DCMpar.GLMmethod,CurSub);
    if ~exist(CurDir,'dir');mkdir(CurDir);end
    CurVOI_correct = struct([]);   
    
    % --- Load SPM for nScan --- %
    
    load(fullfile(conf.dir.save,'Designmatrix',CurSub,'SPM.mat'));
    
    %======================================================================
    % VOIs
    %======================================================================
    
    SC  =   conf.DCMpar.VOIname{1};
    
    for k = 1:nROI    
        CurVOI_correct{k}      = pf_findfile(fullfile(conf.firstlevel_rootdir,conf.VOI.DCMname,CurSub),['/|VOI/&/' conf.VOI.VOInames{k} '/&/.mat/'],'fullfile');
        disp(['Added VOI file "' CurVOI_correct{k} '"'])
    end
    
    nVoi = length(CurVOI_correct);
    xY   = [];
    
    for k = 1:nVoi
        p  = load(CurVOI_correct{k},'xY');
        xY = spm_cat_struct(xY,p.xY);    
    end
    
    %======================================================================
    % Inputs
    %======================================================================
    
    % NB!!!!! here it will attempt to match the session of the SPM file 
    % from the session of the VOI. However, i create a new SPM (designmtx), 
    % with often only 1 session so this will fail. So thats why we
    % previously needed conf.DCMpar.sess, which was always '1'. Will use
    % this here now as well.
    
    %     Sess   = SPM.Sess(xY(1).Sess);
    Sess   = SPM.Sess(conf.DCMpar.sess{1});  
    if isempty(Sess.U)

        % spontaneous activity, i.e. no stimuli
        %----------------------------------------------------------------------
        U.u    = zeros(length(xY(1).u),1);
        U.name = {'null'};

    else

        % with stimuli
        %------------------------------------------------------------------
        U.dt   = Sess.U(1).dt;
        u      = length(Sess.U);
        U.name = {};
        U.u    = [];
        for  i = 1:u
            Curu    =   conf.DCMpar.input{i};  %indices of inputs you want to include
            for j = 1:length(Sess.U(i).name)
                if Curu(j)
                    U.u             = [U.u Sess.U(i).u(33:end,j)];   %% MJ: Why 33?
                    U.name{end + 1} = Sess.U(i).name{j};
                end
            end
        end

        % Check for at least one (null) input
        %------------------------------------------------------------------
        if isempty(U.u)
            U.u    = zeros(length(xY(1).u),1);
            U.name = {'null'};
        end    

    end

    nc            = size(U.u,2);
    is_endogenous = (nc == 1) && strcmp(U.name{1},'null');

    %======================================================================
    % Timings
    %======================================================================

    %-VOI timings
    %--------------------------------------------------------------------------
    RT     = SPM.xY.RT;
    t0     = SPM.xBF.T0; %spm_get_defaults('stats.fmri.t0');
    t      = SPM.xBF.T; %spm_get_defaults('stats.fmri.t');
    T0     = RT * t0 / t;

    %-Echo time (TE) of data acquisition
    %--------------------------------------------------------------------------
    TE    = conf.dsmtx.scan.te;
    TE_ok = 0;
    while ~TE_ok
        if ~TE || (TE < 0) || (TE > 0.1)
            str = { 'Extreme value for TE or TE undefined.',...
                'Please re-enter TE (in seconds!)'};
            spm_input(str,'+1','bd','OK',[1],1);
        else
            TE_ok = 1;
        end
    end
    
    %==========================================================================
    % Model options
    %==========================================================================
    
    DCM.options.nonlinear    =   conf.DCMpar.nonlinear;
    DCM.options.two_state    =   conf.DCMpar.twostate;
    DCM.options.stochastic   =   conf.DCMpar.stochastic;
    DCM.options.centre       =   conf.DCMpar.centre;
    DCM.options.endogenous   =   conf.DCMpar.endogenous;
    DCM.options.hidden       =   conf.DCMpar.hiddennode;  % Indices of the nodes which are hidden
    
    if DCM.options.stochastic 
        DCM.options.induced = 0;
    else
%         DCM.options.induced = spm_input('fit timeseries or CSD','+1','b',{'timeseries','CSD'}, [0 1],1);
        DCM.options.induced = 0;
    end
    
    %==========================================================================
    % Response
    %==========================================================================

    %-Response variables & confounds (NB: the data have been whitened)
    %--------------------------------------------------------------------------
    n     = length(xY);                      % number of regions
    v     = length(xY(1).u);                 % number of time points
    Y.dt  = SPM.xY.RT;
    Y.X0  = xY(1).X0;
    for i = 1:n
        Y.y(:,i)  = xY(i).u;
        Y.name{i} = xY(i).name;
    end

    %-Error precision components (one for each region) - i.i.d. (because of W)
    %--------------------------------------------------------------------------
    Y.Q        = spm_Ce(ones(1,n)*v);
    
    %==========================================================================
    % DCM structure
    %==========================================================================

    %-Store all variables in DCM structure
    %--------------------------------------------------------------------------

    DCM.a                    =   conf.DCMpar.fixconnect;
    DCM.b                    =   conf.DCMpar.modcon;
    DCM.c                    =   conf.DCMpar.inputconnect;
    DCM.d                    =   conf.DCMpar.d;
    DCM.U                    =   U;
    DCM.Y                    =   Y;
    DCM.v                    =   v; 
    DCM.n                    =   nROI;           
    DCM.TE                   =   conf.dsmtx.scan.te;
    DCM.delays               =   conf.DCMpar.TA;
    
    % --- Remove time series / voxel to greatly reduce space --- %
    
    xY                       =  rmfield(xY,'y');
    DCM.xY                   =  xY;
    
    % --- Save --- %
    
    disp(['Saving DCM.mat file for ' CurSub])
    save(fullfile(CurDir,['DCM_' conf.DCMpar.GLMmethod '.mat']),'DCM');
        
end

 





