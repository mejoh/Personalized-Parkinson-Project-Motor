function pf_dcm_bdcm_illmod(conf)
% pf_dcm_bdcm addillus adds a DCM model illustration to your save directory.
% 
% � Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Make SaveDir
%--------------------------------------------------------------------------

if conf.dcm.opt.illus.save
    modelfolder =  fullfile(conf.dcm.save.dir,conf.dcm.par.name,conf.dcm.opt.name); 
    if ~exist(modelfolder,'dir'); mkdir(modelfolder); end
end

%--------------------------------------------------------------------------

%% Plot Models
%--------------------------------------------------------------------------

% --- Check if vois are findfile strings and then replace --- %

nVoi = length(conf.dcm.voi.name);
VOI  = cell(nVoi,1);
cnt  = 1;

for a=1:nVoi
    CurVoi  = conf.dcm.voi.name{a};  
    if strcmp(CurVoi(1),'/')
        sep      = strfind(CurVoi,'/');
        VOI{cnt} = CurVoi(sep(1)+1:sep(2)-1);
        cnt      = cnt+1;
    end
end

% --- Same for inputs --- %

nInp = length(conf.dcm.input.name);
Inp  = cell(nInp,1);
cnt  = 1;

for a=1:nInp
    CurInp  = conf.dcm.input.name{a};  
    if strcmp(CurInp(1),'/')
        sep      = strfind(CurInp,'/');
        Inp{cnt} = CurInp(sep(1)+1:sep(2)-1);
        cnt      = cnt+1;
    end
end

% --- Now plot the models --- %

pf_dcm_illus_models([conf.dcm.par.name '_' conf.dcm.opt.name],conf.dcm.par.a,conf.dcm.par.c,...
                     conf.dcm.par.b{:},VOI,{''},Inp,modelfolder)
