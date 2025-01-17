function StimulusEvents = extract_onsets_and_duration_pm(EventsTsvFile, TR, stime, dcm)

% Extracts names, onsets, durations, and pmod (optional)
% Note that onsets are shifted back 1/TR to account for slice time
% correction

%%% Testing
% EventsTsvFile   = '/project/3022026.01/pep/bids/sub-POMUBC2FF1B37472E0BC/ses-POMVisit1/beh/sub-POMUBC2FF1B37472E0BC_ses-POMVisit1_task-motor_acq-MB6_run-1_events.tsv';
% MatFile         = spm_file(EventsTsvFile, 'path', '/project/3024006.01/users/marjoh/test/extract_onsets_and_duration', 'ext', 'mat');
% TR              = 1;
% stime           = 0.449
%%%

% if nargin<2 || isempty(MatFile)
% 	MatFile = spm_file(EventsTsvFile, 'ext','.mat');
% end

%% Parse file containing mri events
fileID = EventsTsvFile;
fID = fopen(fileID, 'r');
Trials = textscan(fID, '%f%f%d%s%s%f%s%s%s%*s%*s%*s', 'HeaderLines', 1, 'Delimiter', '\t', 'TreatAsEmpty', 'n/a');
fclose(fID);

%% Separate task events

% Data
% Onsets          = Trials{1,1} - TR/2; % Onsets at middle of TR
Onsets          = Trials{1,1} - stime;  % Middle of TR defined exactly
ResponseTimes   = Trials{1,6};

% Labels
Cues            = strcmp(Trials{1,4}, 'cue');
NChoice1        = strcmp(Trials{1,5}, 'NChoice1');
NChoice2        = strcmp(Trials{1,5}, 'NChoice2');
NChoice3        = strcmp(Trials{1,5}, 'NChoice3');
Catch           = strcmp(Trials{1,5}, 'Catch');
Responses       = strcmp(Trials{1,4}, 'response');
Hits            = strcmp(Trials{1,9}, 'Hit');
Incorrects      = strcmp(Trials{1,9}, 'Incorrect');
FalseAlarms     = strcmp(Trials{1,9}, 'False Alarm');
Misses          = strcmp(Trials{1,9}, 'Miss');

%% Define parameters to be included in 1st-level analysis
if ~dcm
    names	  = {'Catch' 'NChoice1' 'NChoice2' 'NChoice3'};				% Regressors of the SPM model (Int2 & Int3 can be combined with a SPM contrast)
elseif dcm
    names	  = {'Cue' 'Selection' 'Catch'};
end
onsets	  = cell(size(names));
durations = cell(size(names));
pmod      = struct('name',{''}, 'param', {}, 'poly', {});   % Parametric modulation: Task regressors are modulated by mean centered RTs

idx = logical(Responses .* (NChoice1+NChoice2+NChoice3) .* Hits);
if ~dcm
    dur = mean(ResponseTimes(idx));
else
    dur = 0;
end
%% Generate a model of relevant task events
for n = 1:length(names)
    switch names{n}
        % Task-based fMRI conditions
        case 'Catch'
                idx = logical(Cues .* Catch .* Hits);
                % In case no catch hits are found, take the first cue
                % only, as a replacement, so that we can still use 
                % this regressor. Dirty fix, but it should allow modelling
                % of individuals who had all false alarms
                if sum(idx)==0
                    idx = logical(Cues .* Catch .* FalseAlarms);
                    f = find(idx);
                    idx(f(3:length(f))) = 0;
                end
                onsets{n}	 = Onsets(idx)';
                durations{n} = dur;
        case 'NChoice1'
                idx = logical(Responses .* NChoice1 .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* NChoice1 .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = dur;
                  pmod(2).name{1} = 'NChoice1';
                  pmod(2).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(2).poly{1} = 1;
        case 'NChoice2'
                idx = logical(Responses .* NChoice2 .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* NChoice2 .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = dur;
                  pmod(3).name{1} = 'NChoice2';
                  pmod(3).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(3).poly{1} = 1;
        case 'NChoice3'
                idx = logical(Responses .* NChoice3 .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* NChoice3 .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = dur;
                  pmod(4).name{1} = 'NChoice3';
                  pmod(4).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(4).poly{1} = 1;
       % DCM conditions
       case 'Cue'
                idx = logical(Responses .* (NChoice1 + NChoice2 + NChoice3) .* Hits);
                RT = ResponseTimes(idx)';     
                idx = logical(Cues .* (NChoice1 + NChoice2 + NChoice3) .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = dur;   
                pmod(1).name{1} = 'Cue';
                pmod(1).param{1} = (RT - mean(RT)); %/ std(RT);
                pmod(1).poly{1} = 1;
       case 'Selection'
                idx = logical(Responses .* (NChoice2 + NChoice3) .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* (NChoice2 + NChoice3) .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = dur;
                pmod(2).name{1} = 'Selection';
                pmod(2).param{1} = (RT - mean(RT)); %/ std(RT);
                pmod(2).poly{1} = 1;
        otherwise
                error('Uknown condition: %s', names{n})
    end
end

%% Also model task errors
idx = logical(Cues .* Incorrects);
if sum(idx) >0
    index = length(names) + 1;
    names{index} = 'Incorrect';
    onsets{index}    = Onsets(idx)';
    durations{index} = dur;
end

idx = logical(Responses .* FalseAlarms);
if sum(idx) >0
    index = length(names) + 1;
    names{index} = 'FalseAlarm';
    onsets{index}    = Onsets(idx)';
    durations{index} = dur;
end

idx = logical(Cues .* Misses);
if sum(idx) >0
    index = length(names) + 1;
    names{index} = 'Miss';
    onsets{index}    = Onsets(idx)';
    durations{index} = dur;
end

%% Organize outputs
StimulusEvents.names        = names;
StimulusEvents.onsets       = onsets;
StimulusEvents.durations    = durations;
StimulusEvents.pmod         = pmod;
