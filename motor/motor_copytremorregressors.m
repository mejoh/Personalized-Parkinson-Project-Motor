% Tremor-related brain activity

% Set analysis directory
% Locate participants
% For each participant, read SPM.mat file
% Select participants with tremor based on presence of tremor regressors
% Copy betas for tremor regressors to a single directory
% Use GUI to analyze them

% Example: '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/sub-POMU0A6DB3C02691EDC8/ses-Visit1_PIT/1st_level/SPM.mat'

% Prepare
ses = 'ses-Visit1';
ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
OUTPUTDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/Tremor';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

% Select patients
Sel = false(size(Sub));
for n = 1:numel(Sub)
    if contains(Sub{n}, 'PD_POM')
        Sel(n) = true;
    else
        fprintf('Excluding %s due to group\n', Sub{n})
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

% Find SPM.mat files
SubInfo.SPM = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    SubInfo.SPM{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, ses, '1st_level'), '^SPM.mat$');
end

% Find indices for tremor regressors and exclude participants without tremor regressors
SubInfo.TremNr = cell(size(SubInfo.Sub));
SubInfo.TremDerivNr = cell(size(SubInfo.Sub));
Sel = false(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    f = load(SubInfo.SPM{n});
    names = f.SPM.xX.name;
    if sum(contains(names,'Sn(1) Tremor')) > 0
        Sel(n) = true;
        SubInfo.TremNr{n} = find(string(names) == 'Sn(1) TremorLog_lin');
        SubInfo.TremDerivNr{n} = find(string(names) == 'Sn(1) TremorLog_deriv1');
    else
        SubInfo.TremNr{n} = NaN;
        SubInfo.TremDerivNr{n} = NaN;
    end
end

SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Group = SubInfo.Group(Sel);
SubInfo.SPM = SubInfo.SPM(Sel);
SubInfo.TremNr = SubInfo.TremNr(Sel);
SubInfo.TremDerivNr = SubInfo.TremDerivNr(Sel);

% Exclude participants where tremor was absent
Classification = readtable('/project/3022026.01/analyses/EMG/motor/manually_checked/Martin/Tremor_check-09-Nov-2020.csv');
Classification = Classification(:,[1,9]);
for n = 1:size(Classification,1)
    Classification.Var1(n) = erase(Classification.Var1(n),',');
    Classification.Var9(n) = extractBefore(Classification.Var9(n),'-ses');
end
TremorAbsent = Classification.Var9(~ismember(Classification.Var1,'1'));

Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if sum(contains(TremorAbsent, SubInfo.Sub{n})) > 0
        Sel(n) = false;
    end
end

SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Group = SubInfo.Group(Sel);
SubInfo.SPM = SubInfo.SPM(Sel);
SubInfo.TremNr = SubInfo.TremNr(Sel);
SubInfo.TremDerivNr = SubInfo.TremDerivNr(Sel);

% Start with clean directory
if ~exist(OUTPUTDir, 'dir')
    mkdir(OUTPUTDir)
else
    rmdir(OUTPUTDir, 's')
    mkdir(OUTPUTDir)
end

% Copy files
for n = 1:numel(SubInfo.Sub)
    f_in = fullfile(ANALYSESDir, SubInfo.Sub{n}, ses, '1st_level', ['beta_00', num2str(SubInfo.TremNr{n}), '.nii']);
    f_out = fullfile(OUTPUTDir, [SubInfo.Group{n} '_' SubInfo.Sub{n} '_' 'beta_00' num2str(SubInfo.TremNr{n}) '.nii']);
    copyfile(f_in,f_out)
end





