ClinVars = readtable('/project/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-02-23.csv');
dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_NoPMOD_TimeDer_BPCtrl';
Sub = cellstr(spm_select('List', fullfile(dAnalysis), 'dir', '^sub-POM.*'));
dat.Sub = string();
dat.BP_Trem_corr = [];
dat.TremSev = [];
dat.BP_Ext_corr = [];
dat.BP_Int2_corr = [];
dat.BP_Int3_corr = [];
dat.BP_MeanExtInt_corr = [];
dat.Trem_Ext_corr = [];
dat.Trem_Int2_corr = [];
dat.Trem_Int3_corr = [];
dat.Trem_MeanExtInt_corr = [];
for n = 1:numel(Sub)
    
    clear MatFile SPM
    clear BPid Tremid pID EXTid INT2id INT3id
    clear BP Trem BP_Trem_corr TremSev Ext Int2 Int3 MeanExtInt BP_Ext_corr BP_Int2_corr BP_Int3_corr BP_MeanExtInt_corr Trem_Ext_corr Trem_Int2_corr Trem_Int3_corr Trem_MeanExtInt_corr
    
    dV1 = fullfile(dAnalysis, Sub{n}, 'ses-Visit1');
    if exist(dV1, 'dir')
        MatFile = fullfile(dV1, '1st_level', 'SPM.mat');
        load(MatFile)
    else
        BP_Trem_corr = nan;
        TremSev = nan;
        BP_Ext_corr = nan;
        BP_Int2_corr = nan;
        BP_Int3_corr = nan;
        BP_MeanExtInt_corr = nan;
        Trem_Ext_corr = nan;
        Trem_Int2_corr = nan;
        Trem_Int3_corr = nan;
        Trem_MeanExtInt_corr = nan;
        dat.Sub(n,1) = string(Sub{n});
        dat.BP_Trem_corr(n,1) = BP_Trem_corr;
        dat.TremSev(n,1) = TremSev;
        dat.BP_Ext_corr(n,1) = BP_Ext_corr;
        dat.BP_Int2_corr(n,1) = BP_Int2_corr;
        dat.BP_Int3_corr(n,1) = BP_Int3_corr;
        dat.BP_MeanExtInt_corr(n,1) = BP_MeanExtInt_corr;
        dat.Trem_Ext_corr(n,1) = Trem_Ext_corr;
        dat.Trem_Int2_corr(n,1) = Trem_Int2_corr;
        dat.Trem_Int3_corr(n,1) = Trem_Int3_corr;
        dat.Trem_MeanExtInt_corr(n,1) = Trem_MeanExtInt_corr;
        continue
    end
    
    BPid = find(contains(SPM.xX.name, 'Sn(1) ButtonPress*bf(1)'));
    BP = SPM.xX.X(:,BPid);
    Tremid = find(contains(SPM.xX.name, 'Sn(1) TremorLog_lin'));
    if ~isempty(BPid) && ~isempty(Tremid)
        Trem = SPM.xX.X(:,Tremid);
        BP_Trem_corr = corr(BP, Trem);
    else
        BP_Trem_corr = nan;
    end
    
    EXTid = find(contains(SPM.xX.name, 'Sn(1) Ext*bf(1)'));
    INT2id = find(contains(SPM.xX.name, 'Sn(1) Int2*bf(1)'));
    INT3id = find(contains(SPM.xX.name, 'Sn(1) Int3*bf(1)'));
    if ~isempty(BPid) && ~isempty(EXTid) && ~isempty(INT2id) &&  ~isempty(INT3id)
        Ext = SPM.xX.X(:,EXTid);
        Int2 = SPM.xX.X(:,INT2id);
        Int3 = SPM.xX.X(:,INT3id);
        MeanExtInt = (Ext + Int2 + Int3)./3;
        BP_Ext_corr = corr(BP,Ext);
        BP_Int2_corr = corr(BP,Int2);
        BP_Int3_corr = corr(BP,Int3);
        BP_MeanExtInt_corr = corr(BP, MeanExtInt);
    else
        BP_Ext_corr = nan;
        BP_Int2_corr = nan;
        BP_Int3_corr = nan;
        BP_MeanExtInt_corr = nan;
    end
    
    if ~isempty(Tremid) && ~isempty(EXTid) && ~isempty(INT2id) &&  ~isempty(INT3id)
        Trem = SPM.xX.X(:,Tremid);
        Ext = SPM.xX.X(:,EXTid);
        Int2 = SPM.xX.X(:,INT2id);
        Int3 = SPM.xX.X(:,INT3id);
        MeanExtInt = (Ext + Int2 + Int3)./3;
        Trem_Ext_corr = corr(Trem,Ext);
        Trem_Int2_corr = corr(Trem,Int2);
        Trem_Int3_corr = corr(Trem,Int3);
        Trem_MeanExtInt_corr = corr(Trem,MeanExtInt);
    else
        Trem_Ext_corr = nan;
        Trem_Int2_corr = nan;
        Trem_Int3_corr = nan;
        Trem_MeanExtInt_corr = nan;
    end    
    
    pID = find(contains(ClinVars.pseudonym, Sub{n}));
    if ~isempty(pID)
        TremSev = ClinVars.Up3OfRestTremAmpSum(pID(1));
    else
        TremSev = nan;
    end
    
    dat.Sub(n,1) = string(Sub{n});
    dat.BP_Trem_corr(n,1) = BP_Trem_corr;
    dat.TremSev(n,1) = TremSev;
    dat.BP_Ext_corr(n,1) = BP_Ext_corr;
    dat.BP_Int2_corr(n,1) = BP_Int2_corr;
    dat.BP_Int3_corr(n,1) = BP_Int3_corr;
    dat.BP_MeanExtInt_corr(n,1) = BP_MeanExtInt_corr;
    dat.BP_Ext_corr(n,1) = BP_Ext_corr;
    dat.BP_Int2_corr(n,1) = BP_Int2_corr;
    dat.BP_Int3_corr(n,1) = BP_Int3_corr;
    dat.BP_MeanExtInt_corr(n,1) = BP_MeanExtInt_corr;
    dat.Trem_Ext_corr(n,1) = Trem_Ext_corr;
    dat.Trem_Int2_corr(n,1) = Trem_Int2_corr;
    dat.Trem_Int3_corr(n,1) = Trem_Int3_corr;
    dat.Trem_MeanExtInt_corr(n,1) = Trem_MeanExtInt_corr;
    
end

datTable = struct2table(dat);
datTable_BPnTrem = rmmissing(table(dat.Sub, datTable.BP_Trem_corr, datTable.TremSev, 'VariableNames', {'Sub', 'BP_Trem_corr', 'TremSev'}));
datTable_BPnTask = rmmissing(table(dat.Sub, datTable.BP_Ext_corr, datTable.BP_Int2_corr, datTable.BP_Int3_corr, datTable.BP_MeanExtInt_corr, 'VariableNames', {'Sub', 'BP_Ext_corr', 'BP_Int2_corr', 'BP_Int3_corr', 'BP_MeanExtInt_corr'}));
datTable_TremnTask = rmmissing(table(dat.Sub, datTable.Trem_Ext_corr, datTable.Trem_Int2_corr, datTable.Trem_Int3_corr, datTable.Trem_MeanExtInt_corr, 'VariableNames', {'Sub', 'Trem_Ext_corr', 'Trem_Int2_corr', 'Trem_Int3_corr', 'Trem_MeanExtInt_corr'}));
% Plot correlation between BP and tremor regressors
% Also as a function of tremor severity
tiledlayout(2,2)
x = datTable_BPnTrem.BP_Trem_corr;
y = datTable_BPnTrem.TremSev;
nexttile
boxplot(x)
nexttile
scatter(x,y,15)
[c,p] = corr(x,y);
fprintf('r = %i, p = %i \n', c, p)
    % Do the same after removing non-tremor patients
nonzeros = datTable_BPnTrem.TremSev > 0;
x = datTable_BPnTrem.BP_Trem_corr(nonzeros);
y = datTable_BPnTrem.TremSev(nonzeros);
nexttile
boxplot(x)
nexttile
boxplot(x)
scatter(x,y,15)
[c,p] = corr(x,y);
fprintf('r = %i, p = %i \n', c, p)

% Plot correlation between button press and task regressors
x1 = datTable_BPnTask.BP_Ext_corr;
x2 = datTable_BPnTask.BP_Int2_corr;
x3 = datTable_BPnTask.BP_Int3_corr;
x4 = datTable_BPnTask.BP_MeanExtInt_corr;
x = [x1;x2;x3;x4];
y1 = repmat("Ext", length(x1),1);
y2 = repmat("Int2", length(x2),1);
y3 = repmat("Int3", length(x3),1);
y4 = repmat("MeanExtInt", length(x4),1);
y = [y1;y2;y3;y4];
datTable_BPnTask2 = table(x,y, 'VariableNames', {'Coef', 'Condition'});
boxplot(x,y)

% Plot correlation between tremor and task regressors
x1 = datTable_TremnTask.Trem_Ext_corr;
x2 = datTable_TremnTask.Trem_Int2_corr;
x3 = datTable_TremnTask.Trem_Int3_corr;
x4 = datTable_TremnTask.Trem_MeanExtInt_corr;
x = [x1;x2;x3;x4];
y1 = repmat("Ext", length(x1),1);
y2 = repmat("Int2", length(x2),1);
y3 = repmat("Int3", length(x3),1);
y4 = repmat("MeanExtInt", length(x4),1);
y = [y1;y2;y3;y4];
datTable_TremnTask2 = table(x,y, 'VariableNames', {'Coef', 'Condition'});
boxplot(x,y)

