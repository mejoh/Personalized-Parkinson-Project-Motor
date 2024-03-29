function motor_cat12_designcheck()

% Specify modality
prefix = 'smwp1.*';
% prefix = 'swj.*';
if contains(prefix, 'smwp1')
    measure = 'VBM';
elseif contains(prefix, 'swj')
    measure = 'DBM';
end

% Specify input image structure
dInput = '/project/3024006.02/Analyses/CAT12/processing_cShoot/mri';
fExclusions = '/project/3024006.02/Analyses/CAT12/Exclusions.txt';
dOut = ['/project/3024006.02/Analyses/CAT12/stats/' measure '_shooting-custom'];
SubInfo = [];
SubInfo.images = cellstr(spm_select('FPList', dInput, prefix));
SubInfo.Group = cell(size(SubInfo.images));
for n = 1:numel(SubInfo.images)
    if contains(SubInfo.images{n}, 'HC_sub-')
        SubInfo.Group{n} = 'HC';
    else
        SubInfo.Group{n} = 'PD';
    end  
end

% Specify covariates

% TIV
volumes = table2array(readtable('/project/3024006.02/Analyses/CAT12/processing_cShoot/TIV.txt', 'ReadVariableNames', false));
SubInfo.TIV = volumes(:,1);

% Age, sex, subtype
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_2023-05-31.csv');
g1 = string(ClinicalConfs.ParticipantType) == "HC_PIT";
g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g1 + g2),:);
Sel = true(size(SubInfo.images));
SubInfo.Age = zeros(size(SubInfo.images));
SubInfo.Gender = zeros(size(SubInfo.images));
SubInfo.NpsEducYears = zeros(size(SubInfo.images));
SubInfo.PrefHand = cell(size(SubInfo.images));
SubInfo.PrefHand_num = zeros(size(SubInfo.PrefHand));
SubInfo.Subtype = cell(size(SubInfo.images));
for n = 1:numel(SubInfo.images)
    s = extractBetween(SubInfo.images{n}, 'sub-', '_ses-');
    subid = find(contains(ClinicalConfs.pseudonym, s));
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA') || isnan(ClinicalConfs.NpsEducYears(subid)) || strcmp(ClinicalConfs.PrefHand(subid), 'NA')
        Sel(n) = false;
        fprintf('Excluding %s with missing covariate\n', s{1})
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        SubInfo.NpsEducYears(n) = ClinicalConfs.NpsEducYears(subid);
        SubInfo.PrefHand{n} = ClinicalConfs.PrefHand(subid);
        SubInfo.Subtype{n} = char(ClinicalConfs.Subtype_DiagEx3_DisDurSplit(subid));
    end
end
SubInfo = subset_subinfo(SubInfo, Sel);

for n = 1:numel(SubInfo.PrefHand)
    if strcmp(SubInfo.PrefHand{n}, 'Right')
        SubInfo.PrefHand_num(n) = 0;
    else
        SubInfo.PrefHand_num(n) = 1;
    end
end

% Clean up the subtype variable
for n = 1:numel(SubInfo.images)
    if contains(SubInfo.Group{n}, 'HC') && contains(SubInfo.Subtype{n}, 'NA')
        SubInfo.Subtype{n} = '0_Healthy';
    elseif contains(SubInfo.Group{n}, 'PD') && contains(SubInfo.Subtype{n}, 'NA')
        SubInfo.Subtype{n} = '4_Undefined';
    end
end

% Exclude participants based on QC
Exclusions = table2cell(readtable(fExclusions, 'ReadVariableNames', false));
Exclusions = unique(Exclusions); % Remove duplicates
Sel = true(size(SubInfo.images,1),1);
for n = 1:numel(SubInfo.images)
    if contains(SubInfo.images{n}, Exclusions)
        Sel(n) = false;
    end
end
SubInfo = subset_subinfo(SubInfo, Sel);

% Exclude based on non-PD diagnosis at baseline or follow-up
Sel = true(size(SubInfo.images));
for n = 1:numel(SubInfo.images)
    s = extractBetween(SubInfo.images{n}, 'sub-', '_ses-');
    subid = find(contains(ClinicalConfs.pseudonym, s));
    if contains(SubInfo.Group{n}, 'PD') && ClinicalConfs.Misdiagnosis(subid)
        Sel(n) = false;
    end
end
SubInfo = subset_subinfo(SubInfo, Sel);

% Flip the image of interest according to whether the participant's
% contrast images were flipped during the functional analysis
% mkdir(fullfile(dInput, 'L2Rflip'));
% delete(fullfile(dInput, 'L2Rflip', '*.*'))
% d1stlevel = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/con_0001/ses-Visit1';
% for n = 1:numel(SubInfo.images)
%     s = char(extractBetween(SubInfo.images{n}, 'sub-', '_ses-'));
%     v = char(extractBetween(SubInfo.images{n}, 'ses-', '_acq'));
%     check = spm_select('FPList', d1stlevel, ['.*' s '_ses-' v '_con_0001.*.nii']);
%     if contains(check, 'L2Rswap')
%         Hdr		  = spm_vol(SubInfo.images{n});
%         Vol		  = spm_read_vols(Hdr);
%         Hdr.fname = spm_file(SubInfo.images{n}, 'suffix', 'L2Rswap');
%         spm_write_vol(Hdr, flipdim(Vol,1));		% LR is the first dimension in MNI space
%         movefile(Hdr.fname, fullfile(dInput, 'L2Rflip'));
%     end
% end

%% HC vs PD
% Specify inputs
inputs = cell(7,1);
inputs{1,1} = {fullfile(dOut, 'HCvsPD')};
[~,~,~] = mkdir(char(inputs{1,1}));
inputs{2,1} = SubInfo.images(contains(SubInfo.Group,'HC'));
inputs{3,1} = SubInfo.images(contains(SubInfo.Group,'PD'));
inputs{4,1} = SubInfo.Age;
inputs{5,1} = SubInfo.NpsEducYears;
inputs{6,1} = SubInfo.PrefHand_num;
if contains(measure, 'VBM')
    inputs{7,1} = SubInfo.TIV;
end

% Run job
spm('defaults', 'FMRI');
JobFile = {['/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_cat12_designcheck_' measure '_HCvsPD_job.m']};
current=pwd;
cd(char(inputs{1,1}))
covars = array2table([inputs{4,1},inputs{5,1},inputs{6,1},inputs{7,1}], 'VariableNames', {'Age','NpsEducYears','PrefHand_num','TIV'});
writetable(covars, 'Covars.csv', 'WriteMode', 'overwrite');
spm_jobman('run', JobFile, inputs{:});
cd(current)

%% Subtypes vs Subtypes
% Specify inputs
inputs = cell(8,1);
inputs{1,1} = {fullfile(dOut, 'Subtypes')};
[~,~,~] = mkdir(char(inputs{1,1}));
inputs{2,1} = SubInfo.images(contains(SubInfo.Subtype,'1_Mild-Motor'));
inputs{3,1} = SubInfo.images(contains(SubInfo.Subtype,'2_Intermediate'));
inputs{4,1} = SubInfo.images(contains(SubInfo.Subtype,'3_Diffuse-Malignant'));
inputs{5,1} = [SubInfo.Age(contains(SubInfo.Subtype,'1_Mild-Motor'));...
    SubInfo.Age(contains(SubInfo.Subtype,'2_Intermediate'));...
    SubInfo.Age(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
inputs{6,1} = [SubInfo.NpsEducYears(contains(SubInfo.Subtype,'1_Mild-Motor'));...
    SubInfo.NpsEducYears(contains(SubInfo.Subtype,'2_Intermediate'));...
    SubInfo.NpsEducYears(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
inputs{7,1} = [SubInfo.PrefHand_num(contains(SubInfo.Subtype,'1_Mild-Motor'));...
    SubInfo.PrefHand_num(contains(SubInfo.Subtype,'2_Intermediate'));...
    SubInfo.PrefHand_num(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
if contains(measure, 'VBM')
    inputs{8,1} = [SubInfo.TIV(contains(SubInfo.Subtype,'1_Mild-Motor'));...
        SubInfo.TIV(contains(SubInfo.Subtype,'2_Intermediate'));...
        SubInfo.TIV(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
end

% Run job
spm('defaults', 'FMRI');
JobFile = {['/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_cat12_designcheck_' measure '_Subtypes_job.m']};
current=pwd;
cd(char(inputs{1,1}))
covars = array2table([inputs{5,1},inputs{6,1},inputs{7,1},inputs{8,1}], 'VariableNames', {'Age','NpsEducYears','PrefHand_num','TIV'});
writetable(covars, 'Covars.csv', 'WriteMode', 'overwrite');
spm_jobman('run', JobFile, inputs{:});
cd(current)

%% HC vs Subtypes
% Specify inputs
inputs = cell(9,1);
inputs{1,1} = {fullfile(dOut, 'HcSubtypes')};
[~,~,~] = mkdir(char(inputs{1,1}));
inputs{2,1} = SubInfo.images(contains(SubInfo.Subtype,'0_Healthy'));
inputs{3,1} = SubInfo.images(contains(SubInfo.Subtype,'1_Mild-Motor'));
inputs{4,1} = SubInfo.images(contains(SubInfo.Subtype,'2_Intermediate'));
inputs{5,1} = SubInfo.images(contains(SubInfo.Subtype,'3_Diffuse-Malignant'));
inputs{6,1} = [SubInfo.Age(contains(SubInfo.Subtype,'0_Healthy'));...
    SubInfo.Age(contains(SubInfo.Subtype,'1_Mild-Motor'));...
    SubInfo.Age(contains(SubInfo.Subtype,'2_Intermediate'));...
    SubInfo.Age(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
inputs{7,1} = [SubInfo.NpsEducYears(contains(SubInfo.Subtype,'0_Healthy'));...
    SubInfo.NpsEducYears(contains(SubInfo.Subtype,'1_Mild-Motor'));...
    SubInfo.NpsEducYears(contains(SubInfo.Subtype,'2_Intermediate'));...
    SubInfo.NpsEducYears(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
inputs{8,1} = [SubInfo.PrefHand_num(contains(SubInfo.Subtype,'0_Healthy'));...
    SubInfo.PrefHand_num(contains(SubInfo.Subtype,'1_Mild-Motor'));...
    SubInfo.PrefHand_num(contains(SubInfo.Subtype,'2_Intermediate'));...
    SubInfo.PrefHand_num(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
if contains(measure, 'VBM')
    inputs{9,1} = [SubInfo.TIV(contains(SubInfo.Subtype,'0_Healthy'));...
        SubInfo.TIV(contains(SubInfo.Subtype,'1_Mild-Motor'));...
        SubInfo.TIV(contains(SubInfo.Subtype,'2_Intermediate'));...
        SubInfo.TIV(contains(SubInfo.Subtype,'3_Diffuse-Malignant'))];
end

% Run job
spm('defaults', 'FMRI');
JobFile = {['/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_cat12_designcheck_' measure '_HcSubtypes_job.m']};
current=pwd;
cd(char(inputs{1,1}))
covars = array2table([inputs{6,1},inputs{7,1},inputs{8,1},inputs{9,1}], 'VariableNames', {'Age','NpsEducYears','PrefHand_num','TIV'});
writetable(covars, 'Covars.csv', 'WriteMode', 'overwrite');
spm_jobman('run', JobFile, inputs{:});
cd(current)

end