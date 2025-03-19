function par = pf_dcm_ana_modpar(conf,varargin)
%
% pf_dcm_ana_modpar will retrieve all the model parameters of the model
% (and parameters) you specified and store it in par.
% Specify the following varargin:
%   -   'plot':     Will boxplot parameters of every subject

% �Michiel Dirkx, 2014 
% $ParkFunC

% -------------------------------------------------------------------------

%% Deal with Varargin
% -------------------------------------------------------------------------

% --- Defaults --- %

plt         =   1;

% --- Retrieve Varargin options --- %

for a = 1:length(varargin)
    switch varargin{a}
        case 'plot'
            plt     =   1;
    end
end

% -------------------------------------------------------------------------

%% Initiate Loop Parameters
% -------------------------------------------------------------------------

                                        nSub                 =   length(conf.sub.name);
                                        nMod                 =   length(conf.mod.name.main);
                                        nPar                 =   length(conf.mod.options.coup);
if ~isempty(conf.mod.name.sub);         nMods                =   length(conf.mod.name.sub);     end
if strcmpi(conf.mod.options.est,'all'); conf.mod.options.est =   {'Ep';'Pp';'Vp'};              end
                                        nEst                 =   length(conf.mod.options.est);
                                        cnt                  =   1;

% -------------------------------------------------------------------------

%% Retrieve parameters (par)
% -------------------------------------------------------------------------

for a = 1:nMod
    
    % --- Find Current Model --- %
    
    CurMod      =   pf_findfile(conf.dir.root,conf.mod.name.main{a},'fullfile');
    [~,Mod]  =   fileparts(CurMod);
    
    for b = 1:nMods
        
        % --- Find Current SubModel --- %
        
        CurMods     =   pf_findfile(CurMod,conf.mod.name.sub{b},'fullfile');
        [~,Mods] =   fileparts(CurMods);
        
        for c = 1:nSub
            
            clear DCM
            CurSub  =   conf.sub.name{c};
            CurDCM  =   pf_findfile(fullfile(CurMods,CurSub),conf.mod.dcm,'fullfile');
            
            % --- Load DCM.mat file --- %
            
            load(CurDCM)
            
            par.Ep.A{c}  =   DCM.Ep.A;
            par.Ep.B{c}  =   DCM.Ep.B;
            par.Ep.C{c}  =   DCM.Ep.C;
            par.Ep.D{c}  =   DCM.Ep.D;
            
            par.Pp.A{c}  =   DCM.Pp.A;
            par.Pp.B{c}  =   DCM.Pp.B;
            par.Pp.C{c}  =   DCM.Pp.C;
            par.Pp.D{c}  =   DCM.Pp.D;
            
            par.Vp.A{c}  =   DCM.Vp.A;
            par.Vp.B{c}  =   DCM.Vp.B;
            par.Vp.C{c}  =   DCM.Vp.C;
            par.Vp.D{c}  =   DCM.Vp.D;
            par.F{c}     =   DCM.F;
            
        end
        par.voi          =  DCM.Y.name;
        par.cond         =  DCM.U.name;
        
    end
end

% -------------------------------------------------------------------------

%% Plot the parameters
% -------------------------------------------------------------------------
keyboard
if plt == 1
    
% --- Initiate DCM VOI parameters --- %
    
    VOI     =   DCM.Y.name;
    
    % --- Chooose estimated parameter --- %
    
    for f = 1:nEst
        
        CurEst  =   conf.mod.options.est{f};
        
        for d = 1:nPar
            
            CurPara =   conf.mod.options.coup{d};
            
            % --- Choose connectivity parameter --- %
            
            switch CurPara
                case 'A'
                    CurPar  =   par.(CurEst).A;
                    iC      =   repmat(1:DCM.n,1,DCM.n);
                case 'B'
                    CurPar  =   par.(CurEst).B;
                    iC      =   repmat(1:DCM.n,1,DCM.n);
                case 'C'
                    CurPar  =   par.(CurEst).C;
                    iC      =   ones(1,size(CurPar{1},1)*size(CurPar{1},2));
                case 'D'
                    CurPar  =   par.(CurEst).D;
                    iC      =   repmat(1:DCM.n,1,DCM.n);
            end
            
            % --- Plot all the boxplots --- %
            
            Xb    = 1;
            iR    = 0;
            
            figure
            for e = 1:(size(CurPar{1},1)*size(CurPar{1},2))
                
                if mod(e-1,DCM.n) == 0 || strcmp(conf.mod.options.coup{d},'C')
                    iR = iR + 1;
                end
                
                CurDat  =   cellfun(@(x) x(iR,iC(e)),CurPar);
                
%                 subplot(size(CurPar{1},2),size(CurPar{1},1),e)
                [Xe,~,H,p] =   pf_boxplot(CurDat,Xb,'stat','ttest','avg','mean');
                
                
                % --- Only Figure Captions etc. --- %
                
                ylabel(['DCM.' CurEst '.' CurPara ' values'],'fontweight','b','fontsize',14)
                
                if strcmp(CurPara,'C')
                    title(['Input to ' VOI{iR}],'fontweight','b','fontsize',14);
                else
                    title([VOI{iC(e)} ' to ' VOI{iR}]);
                end
                
                if mean(CurDat) == -32 || mean(CurDat) == 0
                    axis auto
                elseif strcmpi(conf.mod.axe,'maxall')
                    
                    
                    
                    Ymax = max(cellfun(@max,cellfun(@max,par.(CurEst).(CurPara),'UniformOutput',0)));
                    Ymin = min(cellfun(@min,cellfun(@min,par.(CurEst).(CurPara),'UniformOutput',0)));
                elseif strcmpi(conf.mod.axe,'maxplot')
                    Ymax = max(CurDat);
                    Ymin = min(CurDat);
                else
                    Ymax = conf.mod.axe(2);
                    Ymin = conf.mod.axe(1);
                end
                
                try
                    axis([Xb-0.3 Xe+0.3 Ymin*0.9 Ymax*1.1])
                catch
                    axis auto
                end
                set(gca,'xticklabel',{[]})
                xlabel('Subjects','fontweight','b','fontsize',14)
                
                if H == 1
                    %                         text(Xb,0.1,['Null hypothesis rejected (p = ' num2str(p) ')'])
                    text(4.8,mean(CurDat),'*','fontsize',20,'fontweight','b')
                elseif H == 0
                    %                         text(Xb,0.1,['Null hypothesis NOT rejected (p = ' num2str(p) ')'])
                end
                
            end
            %                 ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            %                 text(0.5, 1,[Mod '  ||  ' Mods ' ||  DCM.' conf.mod.options.coup{d}   ],'HorizontalAlignment','center','VerticalAlignment', 'top','interpreter','none','fontweight','b')
            
            % --- End Of Boxplot --- %
        end
    end
end

% =========================================================================










