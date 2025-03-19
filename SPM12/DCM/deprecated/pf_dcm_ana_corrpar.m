function [sig,nsig] = pf_dcm_ana_corrpar(conf)
%
% pf_dcm_ana_corrpar will search for correlations between your specified 
% estimated parameters of your specified model and other subject parameters 
% (e.g. clinical, neurophysiological etc.). It will return the cells 'sig'
% and 'nsig' containing strings saying which parameter couples were
% significant (sig) and which weren't (nsig). See corrplot for options on  
% correlation types.
%
% Use pf_dcm_ana for conf specification

% ©Michiel Dirkx,2014 
% $ParkFunC, DCM

%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

disp('%---------- Executing Parameter Correlations ----------%')

%--------------------------------------------------------------------------

%% Load model/subject parameters
%--------------------------------------------------------------------------

fprintf('\n%s\n','- Loading model parameters...')
mPar = pf_dcm_ana_modpar(conf);

fprintf('%s\n\n',['- Loading subject parameters from file (' conf.par.file ')...' ])
ld   =   load(pf_findfile(conf.dir.par,conf.par.file,'fullfile'));
sp   =   fieldnames(ld);

if length(sp) > 1; error('ParCorr:sPar','Found multiple fieldnames in your subject parameter files. Please specify one field with multiple subfields in your .mat file'); end;

sPar =   ld.(sp{1});

%--------------------------------------------------------------------------

%% Initiate Loop Parameters
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nmPar   =   length(conf.par.mod.est);
nCoup   =   length(conf.par.mod.coup);
nsPar   =   length(conf.par.field);

sig     =   cell(1);
cnts    =   1;

nsig    =   cell(1);
cntn    =   1;

%--------------------------------------------------------------------------

%% Loop through all parameters
%--------------------------------------------------------------------------

for a = 1:nmPar
    
    % --- Current Estimated Parameter --- %
    
    CurFn     =   conf.par.mod.est{a};
    
    for b = 1:nCoup
        
        % --- Current Coupling Parameter --- %
        
        CurCoup  =  conf.par.mod.coup{b};
        fprintf('%s\n',['- Current Estimated Parameter: "' CurFn '.' CurCoup '"'])
        
        CurParM  =  mPar.(CurFn).(CurCoup);
        
        % --- Select conditions --- %
        
        nMat     =  size(CurParM{1});
        if length(nMat) == 3;
            fprintf('%s\n',' -- Found the following conditions: ')
            fprintf('  - "%s"\n',mPar.cond{:})
            fprintf('\n')
            cond    =   input('Which conditions do you want to include? \n');
        else
            cond    = 1;
        end
        
        % --- Retrieve matrix parameters --- %
        
        for q = 1:length(cond);
            
            for e = 1:nMat(1)
                
                for f = 1:nMat(2)
                    
                    if conf.par.mod.con(e,f) == 1
                        
                        CurParm     =   cellfun(@(x) x(e,f,cond(q)),CurParM);
                        
                        % --- Get Connection String --- %
                        
                        if strcmp(CurCoup,'A') || strcmp(CurCoup,'B')
                            CurConn     =   [mPar.voi{f} '>' mPar.voi{e}];
                        elseif strcmp(CurCoup,'C')
                            CurConn     =   ['Input-' mPar.voi{e}];
                        else
                            CurConn     =   'No connection specified';
                        end
                        
                        % --- Check if model parameter was specified --- %
                        
                        if mean(CurParm) == -32 || mean(CurParm) == 0;
                            disp(['-- Skipping ' CurConn '. Parameter was probably not specified.' ])
                            continue;
                        end;
                        
                        % === Got Current Model Parameter === %
                        
                    else
                        continue
                    end
                    
                    % --- Loop through all Subject Parameters --- %
                    
                    for c = 1:nsPar
                        
                        % --- Current Fieldname of mPar --- %
                        
                        CurFns  =   conf.par.field{c};
                        
                        % --- Loop through all the field name to get CurParm --- %
                        
                        for d = 1:length(CurFns)
                            if d == 1
                                CurPars =   sPar.(CurFns{d});
                                CurParS =   CurFns{d};
                            else
                                CurPars =   CurPars.(CurFns{d});
                                CurParS =   [CurParS '-' CurFns{d}];
                            end
                        end
                        
                        CurPars     =   CurPars(conf.par.sub);
                        
                        % === Got CurParm and CurPars === %
                        
                        % -- Correlation plot ---%
                        
                        [R,P]     =   corr(CurPars,CurParm','type',conf.par.meth);
                        figure
                        scatter(CurPars,CurParm,'marker','s')
                        ylabel(CurConn); xlabel(CurParS);title('Correlation');
                        lsline;
                        xl = xlim; yl = ylim;
                        text(xl(1)+0.006,yl(2)-0.0025,['r = ' num2str(R)])
                        text(xl(1)+0.006,yl(2)-0.005,['p = ' num2str(P)])
                        if P < 0.05
                            disp(['-- Significant correlation: ' CurConn ' & ' CurParS ' (r = ' num2str(R,'%3.2f') ' | p = '  num2str(P,'%3.2f') ')'])
                            sig{cnts}    =   [CurConn ' & ' CurParS ' (r = ' num2str(R,'%3.2f') ' | p = '  num2str(P,'%3.2f') ')'];
                            cnts = cnts + 1;
                        else P > 0.05;
                            disp(['-- No significant correlation: ' CurConn ' & ' CurParS ' (r = ' num2str(R,'%3.2f') ' | p = '  num2str(P,'%3.2f') ')'])
                            nsig{cntn}   =   [CurConn ' & ' CurParS ' (r = ' num2str(R,'%3.2f') ' | p = '  num2str(P,'%3.2f') ')'];
                            cntn = cntn + 1;
                        end
                        if conf.par.save == 1
                            if ~exist(conf.dir.corr.save,'dir'); mkdir(conf.dir.corr.save); end
                            saveas(gcf,fullfile(conf.dir.corr.save,['Corr_' CurConn '-' CurParS '.jpg']),'jpg')
                        end
                    end
                end
            end
        end
    end
end



%==========================================================================
