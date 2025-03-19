function [DCM,mVar] = pf_dcm_ana_avgpar(conf)
%
% pf_dcm_ana_avgpar calculates, displayes 
%
%
% 
%
%

%% Initiate Loop Parameters 

                                        nSub                 =   length(conf.sub.name);
                                        nMod                 =   length(conf.mod.name.main);
if ~isempty(conf.mod.name.sub);         nMods                =   length(conf.mod.name.sub);     end
                                        
                                        Est                  =   {'Ep';'Pp';'Vp'};             
                                        nEst                 =   length(Est);
                                        
                                        Par                  =  {'A';'B';'C'};
                                        nPar                 =  length(Par);
                                        ExpVar               =  nan(1,nSub);

%% Figure Options

Xb  =   2;

%% Analyze

disp('%----------- Averaging Ep/Pp/Vp A-B-C parameters -----------%')

for a = 1:nMod
    
    % --- Find Current Model --- %
    
    CurMod      =   pf_findfile(conf.dir.root,conf.mod.name.main{a},'fullfile');
    [~,Mod]     =   fileparts(CurMod);
    
    for b = 1:nMods
        
        % --- Find Current SubModel --- %
        
        CurMods     =   pf_findfile(CurMod,conf.mod.name.sub{b},'fullfile');
        [~,Mods] =   fileparts(CurMods);   
        
        fprintf('\n%s\n',['- Working on ' Mod '  ||  ' Mods])
        
        for c = 1:nSub
            
            clear DCM
            CurSub  =   conf.sub.name{c};
            CurDCM  =   pf_findfile(fullfile(CurMods,CurSub),conf.mod.dcm,'fullfile');
            
            % --- Load DCM.mat file --- %
            
            load(CurDCM)
            
            par.Ep.A{c}  =   DCM.Ep.A;
            par.Ep.B{c}  =   DCM.Ep.B;
            par.Ep.C{c}  =   DCM.Ep.C;
            
            par.Pp.A{c}  =   DCM.Pp.A;
            par.Pp.B{c}  =   DCM.Pp.B;
            par.Pp.C{c}  =   DCM.Pp.C;
            
            par.Vp.A{c}  =   DCM.Vp.A;
            par.Vp.B{c}  =   DCM.Vp.B;
            par.Vp.C{c}  =   DCM.Vp.C;
            
            for h = 1:DCM.n
                
                pss             = sum(sum(full(DCM.y(:,h).^2)));
                rss             = sum(sum(DCM.R(:,h).^2));
                ExpVarR(c,h)    = 100*pss/(pss + rss);   
                
            end
            
            PSS        = sum(sum(DCM.y.^2));
            RSS        = sum(sum(DCM.R.^2));
            ExpVar(c)  = 100*PSS/(PSS + RSS);
            
        end
        
        for f = 1:nEst
            
            CurEst  =   Est{f};
            
            for d = 1:nPar
                
                % --- Choose connectivity parameter --- %
                
                switch Par{d}
                    case 'A'
                        CurPar  =   par.(CurEst).A;
                        iC      =   repmat(1:DCM.n,1,DCM.n);
                    case 'B'
                        CurPar  =   par.(CurEst).B;
                        iC      =   repmat(1:DCM.n,1,DCM.n);
                    case 'C'
                        CurPar  =   par.(CurEst).C;
                        iC      =   ones(1,size(CurPar{1},1)*size(CurPar{1},2));
                end
                
                % --- Plot all the boxplots --- %
                
                iR    = 0;

                for e = 1:(size(CurPar{1},1)*size(CurPar{1},2))
                    
                    if mod(e-1,DCM.n) == 0 || strcmp(Par{d},'C')
                        iR = iR + 1;
                    end
                    
                    % --- Calculate Mean of Parameter and store in DCM --- % 
                    
%                     CurDat                          =   nanmean(cellfun(@(x) x(iR,iC(e)),CurPar));
%                     DCM.(CurEst).(Par{d})(iR,iC(e)) =   CurDat;   
                    
                end
                    
            end
        end
        
        % --- Explained Variance Analysis --- %
        
        DCM.warn        =   ['WARNING: Only Ep/Pp/Vp ABC parameters have been changed in DCM.mat file. All other parameters are specific for ' CurSub];
        DCM.mExplVar    =   mean(ExpVar);
        DCM.sExplVar    =   std(ExpVar);
        
        figure
        for i = 1:DCM.n
            
            [Xe,Xc]     =   pf_boxplot(ExpVarR(:,i),Xb);
            
            Xb          =   Xe + 2;
            Xce(i)      =   Xc;
            
        end
        
        title(['Explained Variance per subject per ROI of ' Mod '  ||  ' Mods],'interpreter','none','fontweight','b','fontsize',11)
        set(gca,'xtick',Xce,'xticklabel',DCM.Y.name)
        axis([0 Xb 0 max(ExpVar)*1.1])
        xlabel('Region Of Interest','fontweight','b','fontsize',11)
        ylabel('Explained Variance (%)','fontweight','b','fontsize',11)
        text(1,max(ExpVar),['mean explained variance = ' num2str(DCM.mExplVar) ' (std = ' num2str(DCM.sExplVar) ')']) 
        
        % --- Save DCM.mat --- %
        
        if conf.mod.save == 1
        
        
        if ~exist(savedir,'dir'); mkdir(savedir); end
        savedir         =   fullfile(CurMods,'AveragedDCM');
        save(fullfile(savedir,'DCM_avg.mat'),'DCM')
        disp(['- Done. Saved to ' fullfile(savedir,'DCM_avg.mat')])
        end
        
        disp(['- Now exploring DCM.mat. ' DCM.warn])
        
        fprintf('\n%s\n',['- Mean explained variance = ' num2str(DCM.mExplVar) ' percent. (Std = ' num2str(DCM.sExplVar) ')'])
        mVar        =   DCM.mExplVar;
        
        % --- Explore DCM.mat --- %
        
        spm_dcm_explore(DCM);
%         spm_dcm_fmri_check(DCM);
        
        % === END === %
    end
end




