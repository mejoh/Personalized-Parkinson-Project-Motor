%% [taskregs] = generate_task_regressors(EventsTsvFile)
% Convolves task design with a canonical hrf
% Relies on extract_onsets_and_duration_pm() for generating design
% Convolution has been adapted from spm_fMRI_design
% bidsdir = /project/3022026.01/pep/bids
% subject = sub-POMUC2917FBF8466577F
% session = ses-PITVisit1

function [taskregs] = generate_task_regressors(bidsdir, subject, session)

EventsTsvFile = cellstr(spm_select('FPList', fullfile(bidsdir, subject, session, 'beh'), [subject '_' session '_task-motor_acq-MB6_run-.*_events.tsv']));
if numel(EventsTsvFile) > 1
    fprintf('WARNING: %s %s has %i tsv files. Selecting the last run! \n', subject, session, numel(EventsTsvFile))
end
EventsTsvFile = EventsTsvFile{numel(EventsTsvFile)};
TR = 1;
StimulusEvents = extract_onsets_and_duration_pm(EventsTsvFile, TR);
% load(MatFile);
% load('/project/3024006.01/users/marjoh/test/extract_onsets_and_duration/sub-POMUBC2FF1B37472E0BC_ses-POMVisit1_task-motor_acq-MB6_run-1_events.mat');
% refMat = load('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/sub-POMUBC2FF1B37472E0BC/ses-POMVisit1/sub-POMUBC2FF1B37472E0BC_ses-POMVisit1_task-motor_acq-MB6_run-1_events.mat');
% refSpm = load('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/sub-POMUBC2FF1B37472E0BC/ses-POMVisit1/1st_level/SPM.mat');
%% Define basis functions
SPM.xY.RT = TR;                                      %repetition time (TR)
SPM.xBF.UNITS = 'secs'; 
fMRI_T = 72;
fMRI_T0 = 36;
SPM.xBF.T  = fMRI_T;                                %microtime resolution (number of time bins per scan) - number of slices
SPM.xBF.T0 = fMRI_T0;                               %microtime onset (reference time bin, see slice timing) - reference slice for slice time correction
SPM.xBF.name = 'hrf';                               %description of basis functions specified
SPM.xBF.Volterra = 1;
SPM.xBF.dt = SPM.xY.RT/SPM.xBF.T;                   %time bin length {seconds}
SPM.xBF = spm_get_bf(SPM.xBF);

%% Define inputs
% Scans
run = char(extractBetween(EventsTsvFile, 'run-', '_events.tsv'));
funcdat = spm_select('FPList', fullfile(bidsdir, 'derivatives/fmriprep', subject, session, 'func'), [subject '_' session '_task-motor_acq-MB6_run-' run '_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz']);
volinfo = ft_read_mri(funcdat);
SPM.nscan = volinfo.dim(4);
% Stimulus input structure
SPM.Sess.U = [];
P.name = 'none';
P.h = 0;
P.i = 1;
for i=1:numel(StimulusEvents.names)
    SPM.Sess.U(i).name = StimulusEvents.names(i);
    SPM.Sess.U(i).ons = StimulusEvents.onsets{i};
    SPM.Sess.U(i).dur = StimulusEvents.durations{i};
    SPM.Sess.U(i).orth = true;
    SPM.Sess.U(i).P = P;
    SPM.Sess.U(i).dt = SPM.xBF.dt;
end
U = spm_get_ons(SPM,1);

%% Convolve
[X,~,Fc] = spm_Volterra(U, SPM.xBF.bf, SPM.xBF.Volterra);

% Resample regressors at acquisition times (32 bin offset)
if ~isempty(X)
    X = X((0:(SPM.nscan - 1))*fMRI_T + fMRI_T0 + 32,:);
end
% Orthogonalise (within trial type)    
for i = 1:length(Fc)
    if i<= numel(U) && ... % for Volterra kernels
            (~isfield(U(i),'orth') || U(i).orth)
        p = ones(size(Fc(i).i));
    else
        p = Fc(i).p;
    end
    for j = 1:max(p)
        X(:,Fc(i).i(p==j)) = spm_orth(X(:,Fc(i).i(p==j)));
    end
end

%% Output
taskregs.X = X;
taskregs.names = StimulusEvents.names;
