function pf_dcm_ana_BMS_sModVar(conf)
%
% Function to analyze subject variability of models in model space (stored
% in BMS.mat)
%
%
% see also pf_dcm_ana_bms
%
% C Michiel Dirkx, 2014
% $ParkFunC

%% Warming Up
%--------------------------------------------------------------------------

fprintf('\n%s\n\n','%--------- Performing Subject-Specific Model Distribution Analysis---------%')


%% Initiate Loop Parameters
%--------------------------------------------------------------------------

                                        nSub       = length(conf.sub.name);
                                        nMod       = length(conf.mod.name.main);
if ~isempty(conf.mod.name.sub);         nMods      = length(conf.mod.name.sub);     end
                                        
                                        m.Ff       = nan(nSub,nMod*nMods);  % Free energy
                                        m.mod.main = cell(nMod*nMods,1);    % Main model name   
                                        m.mod.sub  = cell(nMod*nMods,1);    % Sub model name
                                        cnt        = 1;                     % Additive model counter

%--------------------------------------------------------------------------

%% Data Storage
%--------------------------------------------------------------------------

fprintf('%\n','1) Data Storage')

for a = 1:nMod
    
    % --- Find Current Model --- %
    
    CurMod  =   pf_findfile(conf.dir.root,conf.mod.name.main{a});
    fprintf('%s\n',[' - Model: "' CurMod '"'])
    
    for b = 1:nMods
        
        % --- Find Current Submodel --- %
        
        CurMods = pf_findfile(fullfile(conf.dir.root,CurMod),conf.mod.name.sub{b});
        fprintf('%s\n',[' -- Method: "' CurMods '"'])
        
        for c = 1:nSub
            
            % --- Get current subject/directory --- %
            
            CurSub  =   conf.sub.name{c};
            CurDir  =   pf_findfile(fullfile(conf.dir.root,CurMod,CurMods),CurSub,'fullfile');
            
            % --- Load DCM --- %
            
            clear DCM Ep F Cp
            load(pf_findfile(CurDir,conf.mod.dcm,'fullfile'))
            
            % --- Store Free Energy --- %
            
            m.Ff(c,cnt)     =   F;
            m.mod.main{cnt} =   CurMod;
            m.mod.sub{cnt}  =   CurMods;
            
        end
    end
    cnt     =   cnt + 1;
end
            
%--------------------------------------------------------------------------

%% Data Analysis
%--------------------------------------------------------------------------

fprintf('%\n','2) Data Analysis')

% --- Distribution of winning models among subjects --- %

for a = 1:length(m.Ff)
    iM(a,1)  =   find(m.Ff(a,:) == max(m.Ff(a,:))); 
end

figure
[a,b] = hist(iM,unique(iM));
bar(b,a);
title('Winning model distribution among subjects');
xlabel('Model#');ylabel('nSubjects');

% --- Subject specific distribution --- %

for a = 1:nSub
    
    CurSub = conf.sub.name{a};
    
    figure
    plot(m.Ff(a,:))
    title(CurSub)
    xlabel('Model#');ylabel('Free Energy');
end

% --- One Plot --- %
keyboard
col = hot(nSub);
figure
for a = 1:nSub
    
    h(a)      = plot(m.Ff(a,:),'color',col(a,:));
    hold on
    
end    
legend(h,conf.sub.name)
title(CurSub)
xlabel('Model#');ylabel('Free Energy');    




            
            
            
            
            
        
        
        

    
    
    








