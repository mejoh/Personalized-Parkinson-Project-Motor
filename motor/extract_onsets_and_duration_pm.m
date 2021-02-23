function MatFile = extract_onsets_and_duration_pm(EventsTsvFile, MatFile, TR)

% Extracts names, onsets, durations, and pmod (optional)
% Note that onsets are shifted back 1/TR to account for slice time
% correction

%%% Testing
%EventsTsvFile = '/project/3024006.01/bids/sub-PIT1MR5637672/func/sub-PIT1MR5637672_task-motor_events.tsv';
%MatFile = spm_file(EventsTsvFile, 'path', '/project/3024006.01/users/marjoh/test/extract_onsets_and_duration', 'ext', 'mat');
%TR = 1;
%%%

if nargin<2 || isempty(MatFile)
	MatFile = spm_file(EventsTsvFile, 'ext','.mat');
end

fileID = EventsTsvFile;
fID = fopen(fileID, 'r');
Trials = textscan(fID, '%f%f%d%s%s%f%s%s%s%*s%*s%*s', 'HeaderLines', 1, 'Delimiter', '\t', 'TreatAsEmpty', 'n/a');
fclose(fID);

names	  = {'Catch' 'Ext' 'Int2' 'Int3'};				% Regressors of the SPM model (Int2 & Int3 can be combined with a SPM contrast)
% names	  = {'Catch' 'Ext' 'Int2' 'Int3' 'ButtonPress'};
onsets	  = cell(size(names));
durations = cell(size(names));
pmod      = struct('name',{''}, 'param', {}, 'poly', {});   % Parametric modulation: Task regressors are modulated by mean centered RTs
MeanAcrossConds = mean(Trials{1,6}(logical(strcmp(Trials{1,4}, 'response') .* ismember(Trials{1,5}, {'Ext', 'Int2', 'Int3'}) .* strcmp(Trials{1,9}, 'Hit'))));
for n = 1:length(names)
    switch names{n}
        case 'Catch'
                onsets{n}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Catch') .* strcmp(Trials{1,9}, 'Hit')))' - TR/2;
                durations{n} = MeanAcrossConds;
        case 'Ext'
                RT = Trials{1,6}(logical(strcmp(Trials{1,4}, 'response') .* strcmp(Trials{1,5}, 'Ext') .* strcmp(Trials{1,9}, 'Hit')))';
                onsets{n}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Ext') .* strcmp(Trials{1,9}, 'Hit')))' - TR/2;
                durations{n} = MeanAcrossConds;
                  pmod(2).name{1} = 'Ext';
                  pmod(2).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(2).poly{1} = 1;
        case 'Int2'
                RT = Trials{1,6}(logical(strcmp(Trials{1,4}, 'response') .* strcmp(Trials{1,5}, 'Int2') .* strcmp(Trials{1,9}, 'Hit')))';
                onsets{n}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Int2') .* strcmp(Trials{1,9}, 'Hit')))' - TR/2;
                durations{n} = MeanAcrossConds;
                  pmod(3).name{1} = 'Int2';
                  pmod(3).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(3).poly{1} = 1;
        case 'Int3'
                RT = Trials{1,6}(logical(strcmp(Trials{1,4}, 'response') .* strcmp(Trials{1,5}, 'Int3') .* strcmp(Trials{1,9}, 'Hit')))';
                onsets{n}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Int3') .* strcmp(Trials{1,9}, 'Hit')))' - TR/2;
                durations{n} = MeanAcrossConds;
                  pmod(4).name{1} = 'Int3';
                  pmod(4).param{1} = (RT - mean(RT)); %/ std(RT);
                  pmod(4).poly{1} = 1;
%         Comment out section if you dont want button presses
%         case 'ButtonPress'
%                 onsets{n}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'response') .* strcmp(Trials{1,9}, 'Hit') .* ~strcmp(Trials{1,5}, 'Catch')))' - TR/2;
%                 durations{n} = 0;   % Does not makes sense to have PMOD here
%         Comment out section if you dont want button presses
        otherwise
                error('Uknown condition: %s', names{n})
    end
end

Incorrect = sum(logical(strcmp(Trials{1,4}, 'response') .* strcmp(Trials{1,9}, 'Incorrect')));
if sum(Incorrect) >0
    index = length(names) + 1;
    names{index} = 'Incorrect';
    onsets{index}    = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,9}, 'Incorrect')))' - TR/2;
    durations{index} = MeanAcrossConds;
end

FalseAlarms = sum(logical(strcmp(Trials{1,4}, 'response') .* strcmp(Trials{1,9}, 'False Alarm')));
if sum(FalseAlarms) >0
    index = length(names) + 1;
    names{index} = 'FalseAlarm';
    onsets{index}    = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Catch') .* strcmp(Trials{1,9}, 'False Alarm')))' - TR/2;
    durations{index} = MeanAcrossConds;
end

% Save the results to disk for SPM
disp(['Saving stimulus / response events in: ' MatFile])
save(MatFile, 'names', 'onsets', 'durations', 'pmod')
