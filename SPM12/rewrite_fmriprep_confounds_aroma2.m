% Re-label AROMA confound regressors based on correlation with task regressors
% Default threshold for re-labelling is 5% explained variance

% sessions = {'ses-POMVisit1' 'ses-POMVisit3' 'ses-PITVisit1' 'ses-PITVisit2'};
sessions = {'ses-POMVisit1' 'ses-POMVisit3' 'ses-PITVisit1' 'ses-PITVisit2'};
for i = 1:numel(sessions)
    rewrite_fmriprep_confounds_aroma_fun(0.05, sessions{i})
end

function rewrite_fmriprep_confounds_aroma_fun(thr, session)

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');

if nargin<1 || isempty(thr)
    thr = 0.05;
end

%session = 'ses-PITVisit2';
BIDSDir  = '/project/3022026.01/pep/bids';
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep_v23.0.2/motor');
Sub = cellstr(spm_select('List', fullfile(FMRIPrep), 'dir', '^sub-POM.*'));
% Sub = {'sub-POMU00094252BA30B84F'};

% Exclude subjects
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        Confounds2File = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries2.tsv']));
        % Preexisting events file
        EventsFile = spm_select('List', fullfile(BIDSDir, Sub{n}, Visit{v}, 'beh'), [Sub{n} '_' Visit{v} '_task-motor_acq-MB6_run-.*_events.tsv']);
        % Preexisting re-classified timeseries file
        
        % Exclude participants
        if isempty(ConfoundsFile{1}) || isempty(EventsFile)
            fprintf('Excluding %s %s: lacks fmriprep confound regressors and/or events.tsv file \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        
%         if  isempty(EventsFile)
%             fprintf('Excluding %s %s: lacks events tsv file \n', Sub{n}, Visit{v})
%             Sel(n) = false;
%         end

%         if ~isempty(Confounds2File{1})
%             fprintf('Excluding %s %s: has already been re-classified \n', Sub{n}, Visit{v})
%             Sel(n) = false;
%         end

    end
end
Sub = Sub(Sel);
NrSub = numel(Sub);
fprintf('%i participants included for further processing \n', NrSub)

% Re-label AROMA components based on correlation with task regressors
for n = 1:NrSub
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        % Load regressors
        TaskRegs = generate_task_regressors(BIDSDir, Sub{n}, Visit{v});
        TaskRegs = TaskRegs.X;
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries.tsv']));
        if length(ConfoundsFile) > 1
            id = length(ConfoundsFile);
            fprintf('Multiple confound timeseries found for %s (n=%i). Selecting the last...\n', Sub{n}, id)
            ConfoundsFile = cellstr(ConfoundsFile{id});
        end
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        ConfoundsFile2 = cellstr(strrep(ConfoundsFile{1}, '_desc-confounds_timeseries.tsv', '_desc-confounds_timeseries2.tsv'));
        % Load confounds
        confounds      = spm_load(ConfoundsFile{1});    % Load confound file
        fid            = fopen(ConfoundsFile{1}, 'r');
        Header         = strsplit(fgetl(fid), '\t');
        Content        = textscan(fid, '%s', 'Delimiter','\n');
        fclose(fid);

        % Re-label AROMA noise components based on their correlations with task regressors
        % Noise comps above threshold will be re-classified
        fprintf('%s: Estimating correlation between task regressors and motion components\n', Sub{n})
        for m = 1:length(Header)
            if startsWith(Header{m}, 'aroma_')
                Fitted = fitlm(TaskRegs(:,1:4), confounds.(Header{m}));
                if Fitted.Rsquared.Adjusted < thr           % Change name of components with R^2 below thereshold to aroma2_. Use only aroma2_ in your model
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