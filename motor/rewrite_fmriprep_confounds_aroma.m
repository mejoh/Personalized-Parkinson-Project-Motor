% Re-label AROMA confound regressors based on correlation with task regressors
% Default threshold for re-labelling is 5% explained variance

function rewrite_fmriprep_confounds_aroma(thr)

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');

if nargin<1 || isempty(thr)
    thr = 0.05;
end

Project = '3022026.01';
fprintf('Processing data in project: %s\n', Project)
Root = strcat('/project/', Project);
BIDSDir  = fullfile(Root, 'pep', 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
ANALYSESDir   = strcat('/project/', Project, '/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer');  
Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-POM.*'));

% Exclude subjects
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for v = 1:numel(Visit)
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_regressors.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        % Preexisting SPM.mat file
        MatFile = spm_select('List', fullfile(ANALYSESDir, Sub{n}, Visit{v}, '1st_level'), '^SPM.mat$');
        
        % Exclude participants
        if isempty(ConfoundsFile{1})
            fprintf('Excluding %s %s: lacks fmriprep confound regressors \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        if  isempty(MatFile)
            fprintf('Excluding %s %s: lacks SPM.mat \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end

    end
end
Sub = Sub(Sel);
NrSub = numel(Sub);
fprintf('%i participants included for further processing \n', NrSub)

% Re-label AROMA components based on correlation with task regressors
for n = 1:NrSub
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for v = 1:numel(Visit)
        
        % SPM.mat
        dStats = fullfile(ANALYSESDir, Sub{n}, Visit{v}, '1st_level');
        SPMFile = cellstr(spm_select('FPList', dStats, '^SPM.mat$'));
        SPMFile = cellstr(SPMFile{size(SPMFile,1)});
        % Load regressors
        SPMvar = load(SPMFile{1});
        TaskCols = contains(SPMvar.SPM.xX.name, ["Ext*bf(1)", "Int2*bf(1)", "Int3*bf(1)"]);
        TaskRegs = SPMvar.SPM.xX.X(:,TaskCols);
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_regressors.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        ConfoundsFile2 = cellstr(strrep(ConfoundsFile{1}, '_desc-confounds_regressors.tsv', '_desc-confounds_regressors2.tsv'));
        % Load confounds
        confounds      = spm_load(ConfoundsFile{1});    % Load confound file
        fid            = fopen(ConfoundsFile{1}, 'r');
        Header         = strsplit(fgetl(fid), '\t');
        Content        = textscan(fid, '%s', 'Delimiter','\n');
        fclose(fid);

        % Re-label AROMA components based on their correlations with task regressors
        fprintf('%s: Estimating correlation between task regressors and motion components\n', Sub{n})
        for m = 1:length(Header)
            if startsWith(Header{m}, 'aroma_')
                Fitted = fitlm(TaskRegs(:,1:3), confounds.(Header{m}));
                if Fitted.Rsquared.Ordinary < thr           % Change name of components with R^2 below thereshold to aroma2_. Use only aroma2_ in your model
                    Header{m} = strrep(Header{m}, 'aroma_', 'aroma2_');
                else
                    fprintf('R^2 (adjusted) = %f for %s\n', Fitted.Rsquared.Adjusted, Header{m})
                end
            end
        end        
        
        fid = fopen(ConfoundsFile2{1}, 'w');
        fprintf(fid, '%s%s\n', sprintf('%s\t', Header{1:end-1}), Header{end});
        for Line = Content{1}'
            fprintf(fid, '%s\n', Line{1});
        end
        fclose(fid);
        
    end
end

end