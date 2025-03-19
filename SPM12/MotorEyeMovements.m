addpath('/project/3024006.01/users/marjoh/scripts/interpol/interpol')
addpath('/home/common/matlab/spm12');

Root='/project/3024006.01/users/marjoh/test/EyeTracking';
cd(Root)
Sub='PIT1MR0069775';

%% Extract onsets and durations to form trial-by-trial windows for the eye-tracking data
LogFile = fullfile(Root, [Sub '_task1_logfile.txt']);
TimeScale = 1e-3;											% Time unit is 1/1000 sec

% Parse the behavioral data from the rest of the logfile
fileID = fopen(LogFile, 'r');
Trials = textscan(fileID, '%f%s%f%f%f%f%f%f%s', 'Delimiter','\t', 'HeaderLines',2, 'ReturnOnError',false);
fclose(fileID);

% Find the events for the different conditions
Int2      = logical(strcmp('Int2', Trials{2}) .* strcmp('Hit', Trials{9}));
Int3      = logical(strcmp('Int3', Trials{2}) .* strcmp('Hit', Trials{9}));
IntAll    = Int2 | Int3;

% Extract the reaction times
Reaction_Time = Trials{6} * TimeScale;

% Get the reaction times for the different conditions
% names	  = {'Int2' 'Int3'};
% durations = cell(size(names));
% for n = 1:length(names)
%     switch names{n}
%         case 'Int2'
%             durations{n} = Reaction_Time(Int2);
%         case 'Int3'
%             durations{n} = Reaction_Time(Int3);
%         otherwise
%             error('Uknown condition: %s', names{n})
%    end
%end

% Get reaction times for all Internal trials
durations = Reaction_Time(IntAll);

%% Convert eye-tracking txt file and import data
EyeTrackFile = fullfile(Root, [Sub '_task1 Samples.txt']);
MatFile = spm_file(EyeTrackFile, 'path', Root, 'ext', '.mat');
trialwindow = [0,2];           % Trial windows are not used, set to max RT
trialcoderange = 1:200;        % Codes are the same as Presentation
%pupdat = interpol_convert_IDF_TXT(EyeTrackFile,trialwindow,trialcoderange);         % TO DO: Use interpolated rather than raw data.

% Open .mat file in gui and save
% Load interpolated data
load(MatFile)

% Extract data points corresponding to cue onset
Cue_events = logical(pupdat.trialcodes{1,1}==8);
Cue_onsets = pupdat.trialonsets{1,1}(Cue_events);

% Get cue onsets for the different conditions
% onsets = cell(size(names));
% for n = 1:length(names)
%     switch names{n}
%         case 'Int2'
%             onsets{n} = Cue_onsets(Int2);
%         case 'Int3'
%             onsets{n} = Cue_onsets(Int3);
%         otherwise
%             error('Unknown condition: %s', names{n})
%     end
% end

%Get onsets for all Internal trials
onsets = Cue_onsets(IntAll);

%% Extract trial-by-trial segments of eye-tracking data, starting from cue onset and ending at reaction time

% Convert RTs from seconds to samples
SampleRate = 50;
durations = round(durations * SampleRate);

% Create trial-by-trial windows of eye-tracking data for each condition
WindowedEye = struct();
WindowedEye.LRawX = cell(size(onsets));
WindowedEye.LRawY = cell(size(onsets));
WindowedEye.LDiaX = cell(size(onsets));
WindowedEye.LDiaY = cell(size(onsets));

for n = 1:length(onsets)
    t0 = onsets(n);
    t1 = onsets(n) + durations(n);
    WindowedEye.LRawX{n} = interpoldat.autointerpoldat{1}(t0:t1,:);
    WindowedEye.LRawY{n} = interpoldat.autointerpoldat{2}(t0:t1,:);
    WindowedEye.LDiaX{n} = interpoldat.autointerpoldat{3}(t0:t1,:);
    WindowedEye.LDiaY{n} = interpoldat.autointerpoldat{4}(t0:t1,:);
end

WindowedEye.LRawXstd = cellfun(@std, WindowedEye.LRawX);
WindowedEye.LRawYstd = cellfun(@std, WindowedEye.LRawY);
WindowedEye.LDiaXstd = cellfun(@std, WindowedEye.LDiaX);
WindowedEye.LDiaYstd = cellfun(@std, WindowedEye.LDiaY);