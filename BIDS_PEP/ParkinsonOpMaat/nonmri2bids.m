function nonmri2bids(force, verbose, POMids)

% Adding fieldtrip and spm
addpath(fullfile("/home", "common", "matlab", "spm12"));
addpath(fullfile("/home", "common", "matlab", "fieldtrip"));
ft_defaults();

% spm12
rawpath  = '/project/3022026.01/raw';
bidspath = '/project/3022026.01/bids2';

if nargin<1
    force = false;
end
if nargin<2 || isempty(POMids)
    verbose = true;
end
if nargin<3 || isempty(POMids)
    POMDirs = spm_select('List', rawpath, 'dir', '^sub-POM.*');
    POMids  = cellstr(POMDirs(:,5:end));
end
bidsdirs = spm_select('List', bidspath, 'dir', '^sub-POM.*');
bidsids  = cellstr(bidsdirs(:,5:end));

% Sel = true(numel(POMids),1);
% for n = 1:numel(POMids)
%     d = spm_select('FPList', fullfile(bidspath, ['sub-' POMids{n}]), 'dir', 'ses-POMVisit*');
%     beh = cellstr(spm_select('List', fullfile(d, 'beh'), '.*acq-smi.*'));
%     eeg = cellstr(spm_select('List', fullfile(d, 'eeg'), '.*events.*'));
%     if numel(beh) < 6 || numel(eeg) < 2
%         Sel(n) = false;
%     end
% end
% POMids = POMids(Sel);
% bidsids = bidsids(Sel);

%% General

general = [];
general.InstitutionName                        = 'Radboud University';
general.InstitutionalDepartmentName            = 'Donders Institute for Brain, Cognition and Behaviour';
general.InstitutionAddress                     = 'Kapittelweg 29, 6525 EN, Nijmegen, The Netherlands';

% required for dataset_description.json
general.dataset_description.Name               = 'POM - Parkinson op maat (a.k.a. Personalized Parkinson Project)';

% optional for dataset_description.json
general.dataset_description.ReferencesAndLinks = {'https://www.parkinsonopmaat.nl'};

h = waitbar(0, 'Converting non-MRI data to BIDS');
for n = 1:numel(POMids)
    
    waitbar(n / numel(POMids))
    visit = dir(fullfile(bidspath, ['sub-' POMids{n}], 'ses-*'));
    if isempty(visit) || ~startsWith(visit.name, 'ses-POMVisit')
        warning('Unknown visit found for: %s/%s', POMids{n}, visit.name)
        continue
    elseif ~any(strcmp(POMids{n}, bidsids))
        warning('%s/%s not in BIDS directory', POMids{n}, visit.name)
        continue
    else
        visit = visit.name(5:end);
    end
    funclist = spm_select('List', fullfile(bidspath, ['sub-' POMids{n}], ['ses-' visit], 'func'));
    if any(contains(cellstr(funclist), 'reward', 'IgnoreCase',true))
        task = 'reward';
    elseif any(contains(cellstr(funclist), 'motor', 'IgnoreCase',true))
        task = 'motor';
    else
        task = 'unknown';
    end
    if verbose
        fprintf('\n--> %s (%i/%i): %s\n', POMids{n}, n, numel(POMids), task)
    end
    
    %% EMG
    emg2bids(general, POMids{n}, rawpath, bidspath, task, visit, force, verbose)
    
    %% NB: Obsolete: Presentation text logfiles
    % prestxt2bids(general, POMids{n}, rawpath, bidspath)
    % preslog2bids(general, POMids{n}, rawpath, bidspath)
    
    %% SMI Eyetracker data
    eye2bids(general, POMids{n}, rawpath, bidspath, task, visit, force, verbose)
    
end
if ishandle(h), close(h), end


function emg2bids(general, POMid, rawpath, bidspath, task, visit, force, verbose)

filenames = cellstr(spm_select('List', fullfile(rawpath, ['sub-' POMid], ['ses-' visit], 'emg'), ['^' POMid '.*\.vhdr$']));

for i = 1:numel(filenames)
    
    if isempty(filenames{i})
        warning('No EMG data found for: %s/emg/sub-%s*.vhdr', ['ses-' visit],POMid)
        continue
    end
    
    % start by including the general metadata, type and target location
    cfg          = general;
    cfg.method   = 'convert';
    cfg.bidsroot = bidspath;
    cfg.datatype = 'eeg';
    cfg.sub      = POMid;
    cfg.ses      = visit;
    if contains(filenames{i}, 'rest', 'IgnoreCase',true)
        cfg.task = 'rest';
    elseif strcmp(task, 'unknown')
        warning('Unknown task found for: %s', POMid)
        cfg.task = task;
    else
        cfg.task = task;
    end
    
    % specify the channels of the tsv-file
    cfg.channels.type               = {'EMG', 'EMG', 'EMG', 'EMG', 'OTHER', 'RESP', 'OTHER', 'OTHER', 'OTHER'}';
    cfg.channels.units              = repmat({'microV'}, size(cfg.channels.type));
    cfg.channels.sampling_frequency = repmat({5000}, size(cfg.channels.type));
    cfg.channels.description        = repmat({NaN},  size(cfg.channels.type));
    cfg.channels.low_cutoff         = {10, 10, 10, 10, 'DC', 'DC', 'DC', 'DC', 'DC'}';
    cfg.channels.high_cutoff        = {250, 250, 250, 250, 1000, 1000, 1000, 1000, 1000}';
    cfg.channels.notch              = repmat({NaN},  size(cfg.channels.type));
    cfg.channels.software_filters   = repmat({NaN},  size(cfg.channels.type));
    cfg.channels.status             = repmat({NaN},  size(cfg.channels.type));
    cfg.channels.status_description = repmat({NaN},  size(cfg.channels.type));
    
    % specify the json file
    cfg.eeg.EMGChannelCount         = sum(strcmpi(cfg.channels.type, 'EMG'));
    cfg.eeg.MiscChannelCount        = numel(cfg.channels.type) - cfg.eeg.EMGChannelCount;
    cfg.PowerLineFrequency          = 50;
    cfg.EEGReference                = 'wrist_right_arm';
    cfg.SoftwareFilters             = 'n/a';
    
    % See if we already have output data
    events = fullfile(bidspath, ['sub-' cfg.sub], ['ses-' cfg.ses], cfg.datatype, sprintf('sub-%s_ses-%s_task-%s_events.tsv', cfg.sub, cfg.ses, cfg.task));
    if isfile(events)
        if force
            if verbose
                fprintf('Deleting existing files in folder: %s\n', fileparts(events))
            end
            delete(fullfile(fileparts(events), '*'))
        else
            if verbose
                fprintf('Skipping processed subject: %s\n', events)
            end
            continue
        end
    end
    
    % Change channel names
    cfg_                  = [];
    cfg_.dataset          = fullfile(rawpath, ['sub-' POMid], ['ses-' visit], 'emg', filenames{i});
    cfg_.event            = ft_read_event(cfg_.dataset);
    cfg_.montage.labelold = {'1', '2', '3', '4', '9', '10', '11', '12', '13'};
    cfg_.montage.labelnew = {'extensor_right_arm', 'flexor_right_arm', 'extensor_left_arm', 'flexor_left_arm', 'pulse_sensor', 'respiration_sensor', 'accelerometer_x', 'accelerometer_y', 'accelerometer_z'}';
    cfg_.montage.tra      = eye(numel(cfg_.montage.labelold));
    data                  = ft_preprocessing(cfg_);
    
    cfg.channels.name     = data.label;
    
    disp(cfg)
    data2bids(cfg, data);
    
end


function eye2bids(general, POMid, rawpath, bidspath, task, visit, force, verbose)
%% SMI eye tracker data

filenames = cellstr(spm_select('List', fullfile(rawpath, ['sub-' POMid], ['ses-' visit], 'eye'), ['^' POMid '.*\Samples.txt$']));

for i = 1:numel(filenames)
    
    if isempty(filenames{i})
        warning('No eye-tracker data found for: %s/eye/sub-%s*Samples.txt', ['ses-' visit], POMid)
        continue
    end
    
    % start by including the general metadata
    cfg = general;
    
    % the ascii file will be converted to TSV
    cfg.dataset = fullfile(rawpath, ['sub-' POMid], ['ses-' visit], 'eye', filenames{i});
    
    % specify the type and target location
    cfg.bidsroot = bidspath;
    cfg.datatype = 'eyetracker';
    cfg.sub      = POMid;
    cfg.ses      = visit;
    cfg.acq      = 'smi'; % this is needed to distinguish the different recordings of the events
    if contains(filenames{i}, 'rest', 'IgnoreCase',true)
        cfg.task = 'rest';
    elseif strcmp(task, 'unknown')
        warning('Unknown task found for: %s', POMid)
        cfg.task = task;
    else
        cfg.task = task;
    end
    
    % See if we already have output data
    events = fullfile(bidspath, ['sub-' cfg.sub], ['ses-' cfg.ses], 'beh', sprintf('sub-%s_ses-%s_task-%s_acq-%s_events.tsv', cfg.sub, cfg.ses, cfg.task, cfg.acq));
    if isfile(events)
        if force
            if verbose
                fprintf('Deleting existing smi-files in folder: %s\n', fileparts(events))
            end
            delete(fullfile(fileparts(events), '*_acq-smi_*'))
        else
            if verbose
                fprintf('Skipping processed subject: %s\n', events)
            end
            continue
        end
    end
    
    disp(cfg)
    data2bids(cfg);
    
end


%% ------------------------ The functions below are obsolete ------------------------
%%

function prestxt2bids(general, POMid, rawpath, bidspath)

session   = ['ses-Visit' POMid(4)];
filenames = cellstr(spm_select('List', fullfile(rawpath,['sub-' POMid], session, 'beh'), ['^' POMid '.*\.txt$']));

for i = 1:numel(filenames)
    
    if isempty(filenames{i})
        warning('No presentation txt data found for: %s/beh/sub-%s*.txt', session, POMid)
        continue
    end
    [p, f, x] = fileparts(filenames{i});
    piece     = split(f, '_');
    task      = piece{2};
    
    % start by including the general metadata and specify the type and target location
    cfg          = general;
    cfg.bidsroot = bidspath;
    cfg.datatype = 'events';
    cfg.sub = POMid;
    switch task(1:4)
        case 'prac'
            cfg.task = 'prac';
        case 'task'
            cfg.task = 'motor';
        otherwise
            error('Unknown task: %s', filenames{i})
    end
    cfg.acq = 'MB6'; % this is needed to distinguish the different recordings of the events
    
    cfg.writetsv = 'replace';
    
    % read the ascii log file
    log = readtable(fullfile(rawpath, 'task', filenames{i}));
    
    % add the onset and duration (both in seconds)
    % the Presentation software uses time stamps of 0.1 milliseconds
    % but these log files appear to be in 1 millisecond steps
    log.onset = (log.Fixation_Time)/1e3;
    log.duration = (log.Response_Time - log.Fixation_Time)/1e3;
    log.duration(log.Response_Time==0) = nan;
    
    cfg.events = log;
    
    % See if we already have output data
    events = fullfile(bidspath, ['sub-' cfg.sub], cfg.datatype, sprintf('sub-%s_acq-%s_events.tsv', cfg.sub, cfg.acq));
    if isfile(events)
        fprintf('Skipping processed subject: %s\n', events)
        continue
    end
    
    disp(cfg)
    data2bids(cfg);
    
end


function preslog2bids(general, POMid, rawpath, bidspath)

session   = ['ses-Visit' POMid(4)];
filenames = cellstr(spm_select('List', fullfile(rawpath,['sub-' POMid], session, 'beh'), ['^' POMid '.*\.log$']));

for i = 1:numel(filenames)
    
    if isempty(filenames{i})
        warning('No presentation log data found for: %s/beh/sub-%s*.log', session, POMid)
        continue
    end
    
    % start by including the general metadata
    cfg = general;
    
    cfg.dataset = fullfile(rawpath, 'task', filenames{i});
    
    % specify the type and target location
    cfg.bidsroot = bidspath;
    cfg.datatype = 'events';
    cfg.sub      = POMid;
    cfg.task     = 'motor';
    cfg.acq      = 'log'; % this is needed to distinguish the different recordings of the events
    
    % See if we already have output data
    events = fullfile(bidspath, ['sub-' cfg.sub], 'beh', sprintf('sub-%s_task-%s_acq-%s_events.tsv', cfg.sub, cfg.task, cfg.acq));
    if isfile(events)
        fprintf('Skipping processed subject: %s\n', events)
        continue
    end
    
    disp(cfg)
    data2bids(cfg);
    
end
