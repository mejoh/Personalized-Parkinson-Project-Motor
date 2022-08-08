function motor_cat12_extractroi(matfile)

% Load data
ROIdat = load(matfile);

% Check whether its VBM or DBM
if contains(ROIdat.info.VY(1).fname,'smwp1')
    prefix='smwp1';
else
    prefix='swj';
end

% Assemble subject information
scan = {ROIdat.info.VY.fname}';
[~, scan, ext] = fileparts(scan);
scan = strcat(scan, ext);
pseudonym = extractBetween(scan, '_sub-', '_ses');
pseudonym = insertBefore(pseudonym, 1, 'sub-');
group = extractBetween(scan, prefix, '_sub-');

% Determine whether functional images had to be flipped or not
d1stlevel = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/con_0001/ses-Visit1';
L2Rflip = zeros(numel(scan),1);
for n = 1:numel(scan)
    s = char(extractBetween(scan{n}, 'sub-', '_ses-'));
    v = char(extractBetween(scan{n}, 'ses-', '_acq'));
    check = spm_select('FPList', d1stlevel, ['.*' s '_ses-' v '_con_0001.*.nii']);
    if contains(check, 'L2Rswap')
        L2Rflip(n,1) = 1;
    end
end

subs = table(pseudonym, group, scan, L2Rflip);

% Assemble values per roi
val = zeros(numel(scan), numel(ROIdat.regions));
region = cell(numel(ROIdat.regions),1);
for v = 1:numel(ROIdat.regions)
    
    % Load info from SPM.mat and ROI data file
    region{v} = ROIdat.regions{1,v}.name;
    val(:,v) = ROIdat.Y(:,v);
    val(:,v) = round(val(:,v), 8);
    
end
stats = array2table(val, 'VariableNames', region);

% Retrieve covariates
d = dir(matfile);
covars = readtable(fullfile(d.folder,'Covars.csv'));

% Concatenate
dat = [subs covars stats];

% Write table to csv file for use in R
d = dir(matfile);
OutputName = fullfile(d.folder, strrep(d.name, '.mat', '.csv'));
writetable(dat, OutputName, 'WriteMode', 'overwrite');

end