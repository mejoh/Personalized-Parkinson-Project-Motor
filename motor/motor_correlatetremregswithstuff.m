% Load all necessary data
ses = 'ses-POMVisit1';
logpower = false;
fileoutput = 'P:/3024006.02/Data/matlab';
regdir = 'P:/3024006.02/Analyses/EMG/motor/processing/prepemg/Regressors/ZSCORED';
seltremordir = 'P:/3024006.02/Analyses/EMG/motor/processing/prepemg';
groupdir = 'P:/3024006.02/Analyses/DurAvg_ReAROMA_NoPMOD_TimeDer_BPCtrl';
bidsdir = 'P:/3022026.01/pep/bids';

% Collect data files
Tremor_check = [];
Tremor_check = readtable('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-24-Mar-2021.csv', 'Delimiter', ',');
v1id = contains(Tremor_check.cName, 'ses-Visit1');
Tremor_check = Tremor_check(v1id,:);
certtremid = Tremor_check.cVal == 1;
Tremor_check = Tremor_check(certtremid,:);
Tremor_check.Sub = extractBetween(Tremor_check.cName,'/Martin/','-ses');
Tremor_check.RegFile = cell(size(Tremor_check,1),1);
Tremor_check.seltremor = cell(size(Tremor_check,1),1);
Tremor_check.spmfile = cell(size(Tremor_check,1),1);
Tremor_check.Vmrk = cell(size(Tremor_check,1),1);
Tremor_check.Chan = cell(size(Tremor_check,1),1);
Tremor_check.Freq = cell(size(Tremor_check,1),1);
Tremor_check.Events = cell(size(Tremor_check,1),1);
for n = 1:size(Tremor_check,1)
    Tremor_check.RegFile{n} = spm_select('FPList', regdir, [Tremor_check.Sub{n} '.*ses-Visit1.*_log.mat']);
    Tremor_check.seltremor{n} = spm_select('FPList', seltremordir, [Tremor_check.Sub{n} '.*ses-Visit1.*seltremor.mat']);
    Tremor_check.spmfile{n} = spm_select('FPList', fullfile(groupdir, Tremor_check.Sub{n}, 'ses-Visit1', '1st_level'), 'SPM.mat');
    Tremor_check.Vmrk{n} = spm_select('FPList', fullfile(bidsdir, Tremor_check.Sub{n}, ses, 'eeg'), '.*task-motor_eeg.vmrk');
    ChanFreq = [];
    ChanFreq = char(extractBetween(Tremor_check.RegFile{n}, 'acc_', 'Hz'));
    Tremor_check.Chan{n} = ChanFreq(1);
    Tremor_check.Freq{n} = ChanFreq(3);
    Tremor_check.Events{n} = spm_select('FPList', fullfile(bidsdir, Tremor_check.Sub{n}, ses, 'beh'), '.*acq-MB6.*_events.tsv');
end
Tremor_check = rmmissing(Tremor_check);

% Check correlations between tremor regressors and task conditions
TremorVsTask = [];
TremorVsTask.sub_corrtrem = cell(height(Tremor_check),1);
TremorVsTask.ext_corrtrem = zeros(height(Tremor_check),1);
TremorVsTask.int2_corrtrem = zeros(height(Tremor_check),1);
TremorVsTask.int3_corrtrem = zeros(height(Tremor_check),1);
TremorVsTask.catch_corrtrem = zeros(height(Tremor_check),1);
TremorVsTask.bp_corrtrem = zeros(height(Tremor_check),1);
for n = 1:height(Tremor_check)
    
    spmmat = Tremor_check.spmfile{n};
    tremreg = Tremor_check.RegFile{n};
    TremorVsTask.sub_corrtrem{n} = extractBetween(tremreg, 'ZSCORED\','-ses');
    
    if ~exist(spmmat,'file') || ~exist(tremreg,'file') 
        TremorVsTask.ext_corrtrem(n) = NaN;
        TremorVsTask.int2_corrtrem(n) = NaN;
        TremorVsTask.int3_corrtrem(n) = NaN;
        TremorVsTask.catch_corrtrem(n) = NaN;
        TremorVsTask.bp_corrtrem(n) = NaN;
        continue
    end
    
    clear ext int2 int3 cat bp
    [ext, int2, int3, cat, bp] = motor_tremorvtask(spmmat, tremreg);
    TremorVsTask.ext_corrtrem(n) = ext;
    TremorVsTask.int2_corrtrem(n) = int2;
    TremorVsTask.int3_corrtrem(n) = int3;
    TremorVsTask.catch_corrtrem(n) = cat;
    TremorVsTask.bp_corrtrem(n) = bp;
    
end
figure
tiledlayout(2,3)
nexttile
boxplot(TremorVsTask.ext_corrtrem)
title('Tremor ~ Ext')
nexttile
boxplot(TremorVsTask.int2_corrtrem)
title('Tremor ~ Int2')
nexttile
boxplot(TremorVsTask.int3_corrtrem)
title('Tremor ~ Int3')
nexttile
boxplot(TremorVsTask.catch_corrtrem)
title('Tremor ~ Catch')
nexttile
boxplot(TremorVsTask.bp_corrtrem)
title('Tremor ~ Button press')
saveas(gcf, fullfile(fileoutput, 'TremregTaskregCorrelations.jpg'))
TremorVsTask = struct2table(TremorVsTask);
writetable(TremorVsTask, fullfile(fileoutput, 'TremregTaskregCorrelations.csv'));

% Check power during task and baseline
Power = [];
Power.sub_power = cell(height(Tremor_check),1);
Power.ext_power = zeros(height(Tremor_check),1);
Power.int2_power = zeros(height(Tremor_check),1);
Power.int3_power = zeros(height(Tremor_check),1);
Power.catch_power = zeros(height(Tremor_check),1);
Power.baseline_power = zeros(height(Tremor_check),1);
Power.task_power = zeros(height(Tremor_check),1);
for n = 1:height(Tremor_check)
    
    seltremor = Tremor_check.seltremor{n};
    chan = Tremor_check.Chan{n};
    freq = Tremor_check.Freq{n};
    vmrkfile = Tremor_check.Vmrk{n};
    events = Tremor_check.Events{n};
    Power.sub_power{n} = extractBetween(seltremor, 'prepemg\', '_ses');
    
    if ~exist(seltremor,'file') || ~exist(vmrkfile,'file')  || ~exist(events,'file') || isempty(chan) || isempty(freq)
        Power.ext_power(n) = NaN;
        Power.int2_power(n) = NaN;
        Power.int3_power(n) = NaN;
        Power.catch_power(n) = NaN;
        Power.baseline_power(n) = NaN;
        Power.task_power(n) = NaN;
        continue
    end
    
    clear ext int2 int3 cat fixtocue cuetoresp
    [ext, int2, int3, cat, fixtocue, cuetoresp] = motor_powerbycondition(seltremor, chan, freq, vmrkfile, events, logpower);
    Power.ext_power(n) = ext;
    Power.int2_power(n) = int2;
    Power.int3_power(n) = int3;
    Power.catch_power(n) = cat;
    Power.baseline_power(n) = fixtocue;
    Power.task_power(n) = cuetoresp;
    
end
figure
tiledlayout(3,2)
nexttile
boxplot(Power.ext_power)
title('Tremor power during ext')
nexttile
boxplot(Power.int2_power)
title('Tremor power during int2')
nexttile
boxplot(Power.int3_power)
title('Tremor power during int3')
nexttile
boxplot(Power.catch_power)
title('Tremor power during catch')
nexttile
boxplot(Power.baseline_power)
title('Tremor power during baseline')
nexttile
boxplot(Power.task_power)
title('Tremor power during task')
saveas(gcf, fullfile(fileoutput, 'TremPowerDuringTask.jpg'))
Power = struct2table(Power);
writetable(Power, fullfile(fileoutput, 'TremPowerDuringTask.csv'));

CombinedData = [TremorVsTask, Power(:,2:7)];
writetable(CombinedData, fullfile(fileoutput, 'TaskTremCorr_TaskTremPower.csv'));

%% ------- DEPRECATED ------- %%

% % Raw signal
% dat = [];
% dat.raw.us = ft_read_data('/project/3024006.02/Data/EMG/sub-POMU284B18EB0D0606CF/ses-Visit1/eeg/sub-POMU284B18EB0D0606CF_ses-Visit1_task-motor_eeg.eeg');
% dat.raw.s = ft_read_data('/project/3024006.02/Data/EMG_test/sub-POMU284B18EB0D0606CF/ses-Visit1/eeg/sub-POMU284B18EB0D0606CF_ses-Visit1_task-motor_eeg.eeg');
% figure
% plot(dat.raw.us(7,:))
% hold on
% plot(dat.raw.s(7,:))
% 
% % Regressor
% dat.reg.us = load('/project/3024006.02/Analyses/EMG/motor/processing/prepemg/Regressors/ZSCORED/sub-POMU284B18EB0D0606CF-ses-Visit1-motor_acc_x_4Hz_regressors_log.mat');
% dat.reg.s = load('/project/3024006.02/Analyses/EMG_test/motor/processing/prepemg/Regressors/ZSCORED/sub-POMU284B18EB0D0606CF-ses-Visit1-motor_acc_x_4Hz_regressors_log.mat');
% dat.reg.bp = load('/project/3024006.02/Analyses/DurAvg_ReAROMA_NoPMOD_TimeDer_BPCtrl/sub-POMU284B18EB0D0606CF/ses-Visit1/1st_level/SPM.mat');
% dat.reg.bp = dat.reg.bp.SPM.xX.X(:,9);
% dat.reg.us = [zeros(5,1); dat.reg.us.R(:,2)];
% dat.reg.s = [zeros(5,1); dat.reg.s.R(:,2)];
% [dat.reg.rho_usvs, dat.reg.pval_usvs] = corr(dat.reg.us, dat.reg.s)
% [dat.reg.rho_svbp, dat.reg.pval_svbp] = corr(dat.reg.s, dat.reg.bp)
% figure
% plot(dat.reg.s)
% hold on
% plot(dat.reg.bp)
% 
% dat.reg.us_z = zscore(dat.reg.us);
% dat.reg.s_z = zscore(dat.reg.s);
% dat.reg.bp_z = zscore(dat.reg.bp);
% [dat.reg.rho_svbpZ, dat.reg.pval_svbpZ] = corr(dat.reg.s_z, dat.reg.bp_z);
% figure
% plot(dat.reg.s_z)
% hold on
% plot(dat.reg.bp_z)
% 
% % Regression of bp against s
% params = polyfit(dat.reg.bp_z, dat.reg.s_z, 1);
% sfit = polyval(params, dat.reg.bp_z);
% sresid = dat.reg.s_z - sfit;
% 
% figure
% plot(sresid)
% hold on
% plot(dat.reg.bp_z)
% plot(dat.reg.s_z) 
% [r,p] = corr(sresid,dat.reg.bp_z)
% [r,p] = corr(sresid, dat.reg.s_z)
% 
% 
% tr = 1;
% dummytrs = tr * 5;
% leftpad = dummytrs * 1000;
% sec = (leftpad + 622000) / 1000;
% min = sec / 60;
% 
% d = test.data.powspctrm(5,3,:);
% d = squeeze(d(1,1,:));
% d = [zeros(leftpad,1); d];