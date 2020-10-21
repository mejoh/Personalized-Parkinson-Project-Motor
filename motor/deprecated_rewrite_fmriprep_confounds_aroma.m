function rewrite_fmriprep_confounds_aroma(ParkinsonOpMaat)

PIT = '3024006.01';
POM = '3022026.01';

if nargin <1 || isempty(ParkinsonOpMaat)
    Project = PIT;
else
    Project = POM;
end

thr         = 0.05;         % Arbitrary threshold for excluding motion components
Root        = strcat('/project/', Project);
BIDSdir     = fullfile(Root, 'bids');
FMRIPREPdir = fullfile(BIDSdir, 'derivatives/fmriprep');
ANALYSESDir = strcat('/project/', POM, '/analyses/motor/fMRI_EventRelated_Main');
BIDS        = spm_BIDS(BIDSdir);
Sub         = spm_BIDS(BIDS, 'subjects', 'task', 'motor');

SubSel      = false(numel(Sub),1);
% Exclude missing SPM.mat files
for n = 1:numel(Sub)
    if exist(fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level', 'SPM.mat'), 'file')
        SubSel(n) = true;
    else
        fprintf('Skipping sub-%s: does not have a SPM.mat file\n', Sub{n})
    end
end
Sub         = Sub(SubSel);
Files       = spm_BIDS(BIDS, 'data', 'sub', Sub, 'task', 'motor', 'type', 'bold');
NrSub       = numel(Sub);

% Create second confounds file
% Rename aroma components below threshold. Use renamed for re-analysis
for n = 1:NrSub

    SPMfile = fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level', 'SPM.mat');
    SPMvar = load(SPMfile);
    TaskCols = contains(SPMvar.SPM.xX.name, ["Catch*bf(1)", "Ext*bf(1)", "Int2*bf(1)", "Int3*bf(1)"]);
    TaskRegs = SPMvar.SPM.xX.X(:,TaskCols);
    
    covarfile   = strrep(strrep(Files{n}, BIDSdir, FMRIPREPdir), '_bold.nii.gz', '_desc-confounds_regressors.tsv');     % Org confound file
    if ~exist(covarfile, 'file')
        fprintf('Skipping subject sub-%s: Does not have confounds tsv file \n',Sub{n})
        continue
    end
    covarfile2  = strrep(covarfile, '_desc-confounds_regressors.tsv', '_desc-confounds_regressors2.tsv');            % New confound file
    confounds   = spm_load(char(covarfile));    % Load confound file
    fid            = fopen(covarfile, 'r');
    Header         = strsplit(fgetl(fid), '\t');
    Content        = textscan(fid, '%s', 'Delimiter','\n');
    fclose(fid);
    
    fprintf('Sub-%s: Estimating correlation between task regressors and motion components\n', Sub{n})
    for m = 1:length(Header)
        if startsWith(Header{m}, 'aroma_')
            Fitted = fitlm(TaskRegs(:,1:4), confounds.(Header{m}));
            if Fitted.Rsquared.Ordinary < thr           % Change name of components with R^2 below thereshold to aroma2_. Use only aroma2_ in your model
                Header{m} = strrep(Header{m}, 'aroma_', 'aroma2_');
            else
                fprintf('R^2 = %f for %s\n', Fitted.Rsquared.Ordinary, Header{m})
            end
        end
    end
    
    fid = fopen(covarfile2, 'w');
    fprintf(fid, '%s%s\n', sprintf('%s\t', Header{1:end-1}), Header{end});
    for Line = Content{1}'
        fprintf(fid, '%s\n', Line{1});
    end
    fclose(fid);

end

end