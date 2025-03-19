function mj_generate_templatelist()

% Generates a list of subjects to be used in template creation
% The list consists of equal numbers patients and controls,
% all of which have T0 and T1 data.

%%
% available subjects
dBIDS = '/project/3022026.01/pep/bids/';
Subs = cellstr(spm_select('List', dBIDS, 'dir', 'sub-.*'));

%%
% select those with full longitudinal data
SubInfo = struct();
SubInfo.Subs = cell(size(Subs));
SubInfo.Group = cell(size(Subs));
SubInfo.T0 = cell(size(Subs));
SubInfo.T1 = cell(size(Subs));
Sel = false(size(Subs,1),1);
for n = 1:numel(Subs)
    
    SubInfo.Subs{n} = Subs{n};
    
    % define scans to be checked
    x1 = spm_select('FPList', fullfile(dBIDS, Subs{n}, 'ses-POMVisit1', 'anat'), '.*run-1_T1w.nii.gz');
    x2 = spm_select('FPList', fullfile(dBIDS, Subs{n}, 'ses-POMVisit3', 'anat'), '.*run-1_T1w.nii.gz');
    y1 = spm_select('FPList', fullfile(dBIDS, Subs{n}, 'ses-PITVisit1', 'anat'), '.*run-1_T1w.nii.gz');
    y2 = spm_select('FPList', fullfile(dBIDS, Subs{n}, 'ses-PITVisit2', 'anat'), '.*run-1_T1w.nii.gz');
    
    % check for patients and controls with full data, exclude those that
    % don't
    if exist(x1, 'file') && exist(x2, 'file')
        Sel(n) = true;
        SubInfo.Group{n} = 'PD';
        SubInfo.T0{n} = x1;
        SubInfo.T1{n} = x2;
    elseif exist(y1, 'file') && exist(y2, 'file')
        Sel(n) = true;
        SubInfo.Group{n} = 'HC';
        SubInfo.T0{n} = y1;
        SubInfo.T1{n} = y2;
    else
        Sel(n) = false;
        SubInfo.Group{n} = '';
        SubInfo.T0{n} = '';
        SubInfo.T1{n} = '';
    end
    
end
% perform exclusion
SubInfo = subset_subinfo(SubInfo, Sel);

%%
% divide into groups
idx = find(contains(SubInfo.Group, 'PD'));
PD = struct();
PD.Sub = SubInfo.Subs(idx);
PD.T0 = SubInfo.T0(idx);
PD.T1 = SubInfo.T1(idx);

idx = find(contains(SubInfo.Group, 'HC'));
HC = struct();
HC.Sub = SubInfo.Subs(idx);
HC.T0 = SubInfo.T0(idx);
HC.T1 = SubInfo.T1(idx);

% number of controls
nctrl = length(HC.Sub);

% select nctrl patients at random
npd = length(PD.Sub);
idx = randperm(npd, nctrl);

% susbet patient data
PD.Sub_ss = PD.Sub(idx);
PD.T0_ss = PD.T0(idx);
PD.T1_ss = PD.T1(idx);

% write to file
list = [HC.Sub; PD.Sub_ss];
writecell(list, '/project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/list')



end
