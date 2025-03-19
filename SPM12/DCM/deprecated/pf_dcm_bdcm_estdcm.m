function pf_dcm_bdcm_estdcm(conf)
% pf_dcm_bdcm_estdcm(conf) is part of the pf_dcm_bdcm_batch. Specifically,
% it will invert DCM models specified with conf
%
% See pf_dcm_bdcm_batch
% © Michiel Dirkx, 2018
% ParkFunC, version 20181220

%--------------------------------------------------------------------------

%% Initialization
%--------------------------------------------------------------------------

nSub    = length(conf.sub.name);
y_fmri  = [];

%--------------------------------------------------------------------------

%% Function
%--------------------------------------------------------------------------

for a = 1:nSub

    CurSub      = conf.sub.name{a};
    CurSess1    = conf.sub.sess1{a};
    fprintf('\n%s\n',['Working on ' CurSub])
    
    % --- Loop through VOIs --- %
    
    fprintf('\n%s\n','- Specifying VOIs')
    nVoi    = length(conf.dcm.voi.name);
    voiname = cell(nVoi,1);
    
    for b = 1:nVoi
        
        CurVoi = conf.dcm.voi.name{b};
        CurVoi = pf_findfile(conf.dcm.voi.dir,CurVoi,'conf',conf,'CurSub',a);
        
        VOI = load(fullfile(conf.dcm.voi.dir,CurVoi));
        
        % --- Store all VOIs in y_fmri --- %
        
        y_fmri = [y_fmri VOI.Y];
        disp(['-- Added ' CurVoi]);
        voiname{b}  =   VOI.xY.name;
        
    end
    
    y_fmri = y_fmri';
    
    % --- Specify input --- %
   
    fprintf('%s\n','- Specifying inputs')
    nInp   = length(conf.dcm.input.name);
    unames = cell(nInp);
    
    for b = 1:length(nInp)
        
        % --- Retrieve current file / direct strings --- %
        
        CurInp   =   conf.dcm.input.name{b};
        CurDir   =   conf.dcm.input.dir{b};
        CurIdx   =   conf.dcm.input.idx{b};
        
        % --- Deal with subject specific folder if specified --- %
        
        if iscell(CurDir)
            for c = 1:length(CurDir)
                CurStr = CurDir{c};
                if strcmp(CurStr,'CurSub')
                    CurDir{c} = CurSub;
                elseif strcmp(CurStr,'OFF')
                    if strcmp(CurSess1,'OFF')
                        CurDir{c} = 'SESS1';
                    else
                        CurDir{c} = 'SESS2';
                    end
                elseif strcmp(CurStr,'ON')
                    if strcmp(CurSess1,'ON')
                        CurDir{c} = 'SESS1';
                    else
                        CurDir{c} = 'SESS2';
                    end
                end
                if c==1
                    d = CurDir{c};
                else
                    d = fullfile(d,CurDir{c});
                end
            end
            CurDir = d;
        end
        
        % --- Load files --- %
        
        CurInp  = pf_findfile(CurDir,CurInp,'conf',conf,'CurSub',a);
        inp     = load(fullfile(CurDir,CurInp));
        fn      = fieldnames(inp);
        
        % -- Select appropriate vector --- %
        
        if any(cellfun(@any,strfind(fn,'R')))
            CurU    =   inp.R(:,CurIdx);
            CurN    =   inp.names{CurIdx};
        elseif any(cellfun(@any,strfind(fn,'onsets')))
            on     = round(inp.onsets{1});
            dur    = round(inp.durations{1});
            CurU   = zeros(1,size(y_fmri,2));
            nOn    = length(on);
            for c = 1:nOn
               CurU(1,on(c):on(c)+dur(c))    =   1; 
            end
            CurN   = inp.names{1};
        else
            warning('bdcm:estdcm','Don"t know how to handle input data format. Entering debug mode...')
            keyboard
        end
        
        % --- And store in u --- %
        
        u(b,:)      =   CurU;
        unames{b}   =   CurN;
        disp(['-- Added ' CurInp ' (' CurN ')'])
        
    end
    
    % --- Use behavioural DCM if specified --- %
    
    if conf.dcm.opt.behav
        
        fprintf('%s\n','- Adding outputs')
        nOut        =    length(conf.dcm.output.name);
        y_behaviour =    [];
        
        for b = 1:nOut
            
            CurOut = conf.dcm.output.name{b};
            CurI   = conf.dcm.output.idx{b};
            CurOut = pf_findfile(conf.dcm.output.dir,CurOut,'conf',conf,'CurSub',a,'CurOFF',a);
            
            OUT = load(fullfile(conf.dcm.output.dir,CurOut));
            
            
            % --- Select current regressor --- %
            
            CurO    =   OUT.R(:,CurI);
            CurN    =   OUT.names{CurI};
            
            % --- Store all VOIs in y_fmri --- %
            
            y_behaviour = [y_behaviour CurO];
            disp(['-- Added ' CurOut]);
            
        end
        
        y_behaviour = y_behaviour';
        
    end
    
    % --- Prepare full DCM (options) --- %
    
    A    =   conf.dcm.par.a;
    B    =   conf.dcm.par.b;
    C    =   conf.dcm.par.c;
    D    =   conf.dcm.par.d;
    nreg =   size(y_fmri,1);              % number of network nodes
    n_t  =   size(y_fmri,2);              % number of fMRI time samples
    
    if conf.dcm.opt.behav
        Ar  =   conf.dcm.output.ar;
        Br  =   conf.dcm.output.br;
        Cr  =   conf.dcm.output.cr;
        Dr  =   conf.dcm.output.dr;
        
        sources(1) = struct('out',1:size(y_fmri,1),'type',0);  % two BOLD timeseries (gaussian)
        sources(2) = struct('out',size(y_fmri,1)+1:size(y_fmri,1)+size(y_behaviour,1),  'type',0);  % and a motor response(gaussian)
        
        options         =  prepare_fullDCM(A,B,C,D,conf.dcm.opt.tr,conf.dcm.opt.microdt,conf.dcm.opt.homogeneous,Ar,Br,Cr,Dr,sources);
        options.priors  =  getPriors(nreg,n_t,options,conf.dcm.opt.reduced_f,conf.dcm.opt.stochastic);
    else
        options         =  prepare_fullDCM(A,B,C,D,conf.dcm.opt.tr,conf.dcm.opt.microdt,conf.dcm.opt.homogeneous);
        options.priors  =  getPriors(nreg,n_t,options,conf.dcm.opt.reduced_f,conf.dcm.opt.stochastic);
    end
    
    options.inG.TE  =   conf.dcm.opt.te;
    
    % --- Plot illustration if specified --- %
    
    if conf.dcm.opt.illus.plot
        pf_dcm_illus_models([conf.dcm.par.name '_' conf.dcm.opt.name],options.inF.A,options.inF.C,options.inF.B{:},voiname,{''},unames,[]);
    end
    
    % --- Call the VBA inversion routine --- %
    
    if conf.dcm.opt.behav
        g_fname =   @g_DCMwHRFext;         % DCM observation function, behav
        y       =   [y_fmri;y_behaviour];  % fmri and behav
    else
        g_fname =   @g_HRF3;               % DCM observation function, standard
        y       =   y_fmri;
    end
    
    f_fname =   @f_DCMwHRF;  % DCM evolution function
    
    dim     =   options.dim;
    [posterior,out] =   VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);
    
    % --- Save output --- %
    
    savedir = fullfile(conf.dcm.save.dir,conf.dcm.par.name,conf.dcm.opt.name);
    if ~exist(savedir,'dir'); mkdir(savedir); end
    nm      = ['DCM_' CurSub '_' conf.dcm.opt.name '.mat'];
    save(fullfile(savedir,nm),'posterior','out');
    
    disp(['Saved DCM to ' fullfile(savedir,nm)]);
    
end













