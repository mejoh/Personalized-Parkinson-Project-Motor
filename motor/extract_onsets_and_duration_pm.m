function StimulusEvents = extract_onsets_and_duration_pm(EventsTsvFile, TR)

% Extracts names, onsets, durations, and pmod (optional)
% Note that onsets are shifted back 1/TR to account for slice time
% correction

%%% Testing
% EventsTsvFile   = '/project/3022026.01/pep/bids/sub-POMUBC2FF1B37472E0BC/ses-POMVisit1/beh/sub-POMUBC2FF1B37472E0BC_ses-POMVisit1_task-motor_acq-MB6_run-1_events.tsv';
% MatFile         = spm_file(EventsTsvFile, 'path', '/project/3024006.01/users/marjoh/test/extract_onsets_and_duration', 'ext', 'mat');
% TR              = 1;
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
Onsets          = Trials{1,1} - TR/2;
ResponseTimes   = Trials{1,6};

% Labels
Cues            = strcmp(Trials{1,4}, 'cue');
Ext             = strcmp(Trials{1,5}, 'Ext');
IntTwo          = strcmp(Trials{1,5}, 'Int2');
IntThree        = strcmp(Trials{1,5}, 'Int3');
Catch           = strcmp(Trials{1,5}, 'Catch');
Responses       = strcmp(Trials{1,4}, 'response');
Hits            = strcmp(Trials{1,9}, 'Hit');
Incorrects      = strcmp(Trials{1,9}, 'Incorrect');
FalseAlarms     = strcmp(Trials{1,9}, 'False Alarm');

%% Define parameters to be included in 1st-level analysis
names	  = {'Catch' 'Ext' 'Int2' 'Int3'};				% Regressors of the SPM model (Int2 & Int3 can be combined with a SPM contrast)
% names	  = {'Catch' 'Ext' 'Int2' 'Int3' 'ButtonPress'};
onsets	  = cell(size(names));
durations = cell(size(names));
pmod      = struct('name',{''}, 'param', {}, 'poly', {});   % Parametric modulation: Task regressors are modulated by mean centered RTs

idx = logical(Responses .* (Ext+IntTwo+IntThree) .* Hits);
MeanAcrossConds = mean(ResponseTimes(idx));
%% Generate a model of relevant task events
for n = 1:length(names)
    switch names{n}
        case 'Catch'
                idx = logical(Cues .* Catch .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = MeanAcrossConds;
        case 'Ext'
                idx = logical(Responses .* Ext .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* Ext .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = MeanAcrossConds;
                  pmod(2).name{1} = 'Ext';
                  pmod(2).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(2).poly{1} = 1;
        case 'Int2'
                idx = logical(Responses .* IntTwo .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* IntTwo .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = MeanAcrossConds;
                  pmod(3).name{1} = 'Int2';
                  pmod(3).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(3).poly{1} = 1;
        case 'Int3'
                idx = logical(Responses .* IntThree .* Hits);
                RT = ResponseTimes(idx)';
                idx = logical(Cues .* IntThree .* Hits);
                onsets{n}	 = Onsets(idx)';
                durations{n} = MeanAcrossConds;
                  pmod(4).name{1} = 'Int3';
                  pmod(4).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(4).poly{1} = 1;
%         Comment out section if you dont want button presses
%         case 'ButtonPress'
%                 idx = logical(Responses .* ~Catch .* Hits);
%                 onsets{n}	 = Onsets(idx)';
%                 durations{n} = 0;   % Does not makes sense to have PMOD here
%         Comment out section if you dont want button presses
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
    durations{index} = MeanAcrossConds;
end

idx = logical(Responses .* FalseAlarms);
if sum(idx) >0
    index = length(names) + 1;
    names{index} = 'FalseAlarm';
    onsets{index}    = Onsets(idx)';
    durations{index} = MeanAcrossConds;
end

%% Organize outputs
StimulusEvents.names        = names;
StimulusEvents.onsets       = onsets;
StimulusEvents.durations    = durations;
StimulusEvents.pmod         = pmod;
