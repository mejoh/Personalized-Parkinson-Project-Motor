function [ext, int2, int3, cat, fixtocue, cuetoresp] = motor_powerbycondition(seltremor, chan, freq, vmrkfile, events, logpower)

if ~isnumeric(freq)
    freq = str2double(freq);
end

if isempty(logpower)
    logpower = false;
end

% Load powerspectrum
load(seltremor);
chanid = contains(data.label, ['acc_' chan]);
freqid = round(data.freq, 1) == freq;
powrspctrm = squeeze(data.powspctrm(chanid,freqid,:));
if logpower
    powrspctrm = log(powrspctrm);
end
time = data.time';

% Load vmrk and remove potential sync on markers
vmrk = ft_read_event(vmrkfile);
stimulusids = zeros(length(vmrk),1);
for e = 1:length(vmrk)
    eventtype = vmrk(e).type;
    if strcmp(eventtype, 'Stimulus') || strcmp(eventtype, 'Response')
        stimulusids(e) = 1;
    end
end
stimulusids = logical(stimulusids);
vmrk = vmrk(stimulusids);

% Cut out the end of the powerspectrum to make length correspond to vmrk file
% Note that powerspectrum starts at the 6th scanner pulse given that we specified 5 dummyscans
r1counter = 0;                                                % Find the index of the 6th consecutive pulse
startid = 0;
while r1counter < 6
    startid = startid+1;
    if startid == 1 && strcmp(vmrk(startid).value, 'R  1')
        r1counter = r1counter+1;
    elseif startid ~= 1 && strcmp(vmrk(startid).value, 'R  1') && ~strcmp(vmrk(startid-1).value, 'R  1')    % Restart counter if previous type is not R  1
        r1counter = 0;
        r1counter = r1counter+1;
    elseif startid ~= 1 && strcmp(vmrk(startid).value, 'R  1') && strcmp(vmrk(startid-1).value, 'R  1') % Continue counting if previous type is R  1
        r1counter = r1counter+1;
    elseif strcmp(vmrk(startid).value, 'S  6')
        fprintf('Warning: S  6 marker was reached before R  1 counter reached 5. Cannot compute start. Exiting...\n')
        ext = NaN;
        int2 = NaN;
        int3 = NaN;
        cat = NaN;
        fixtocue = NaN;
        cuetoresp = NaN;
        return
    end
end
start = round(vmrk(startid).timestamp,3) * 1000;            % Sixth pulse (pulse where powerspectrum starts)
ending = round(vmrk(length(vmrk)).timestamp,3) * 1000;      % Last pulse (anything after this is unnecessary)
duration = (ending - start);                                % Duration of interest in powerspectrum
powrspctrm = powrspctrm(1:duration,:);                      % Cut irrelevant data from end of powerspectrum
time = time(1:duration,:);                                  % and time

% Remove R  1 marker events from vmrk
stimulusids = zeros(length(vmrk),1);
for e = 1:length(vmrk)
    eventtype = vmrk(e).type;
    if strcmp(eventtype, 'Stimulus')
        stimulusids(e) = 1;
    end
end
stimulusids = logical(stimulusids);
vmrk = vmrk(stimulusids);

% Extract time intervals corresponding to baseline (S  8 > S  9) and task (S  9 > S  1-4) 
% Calculate the average power spectrum within those intervals
power.fixtocue = [];
power.cuetoresp = [];
for s = 1:length(vmrk)-2
    
    intervals.fixtocue = false(1, length(time));        % Baseline
    intervals.cuetoresp = false(1, length(time));       % Task
    first_sample = [];
    last_sample = [];
    
%     if strcmp(vmrk(s).value,'S  8') && strcmp(vmrk(s+1).value,'S  9')   % When fixation is followed by cue
%         first = (round(vmrk(s).timestamp,3) * 1000) - start;            % Time of fixation in ms. Shift backwards by 5 tr to match length of powerspectrum
%         second = (round(vmrk(s+1).timestamp,3) * 1000) - start;         % Time of cue in ms. Shift backwards by 5 tr to match length of powerspectrum
%         intervals.fixtocue(1,first:1:second) = true;                    % Define segment to take mean from
%         power.fixtocue = [power.fixtocue; mean(powrspctrm(intervals.fixtocue))];
    if strcmp(vmrk(s).value,'S  6') && strcmp(vmrk(s+1).value,'S  7') && strcmp(vmrk(s+3).value,'S  8')   % When a response is followed by a break
        first_sample = floor((round(vmrk(s).timestamp,3) * 1000) - start);                                % Time of start of break
        last_sample = floor((round(vmrk(s+3).timestamp,3) * 1000) - start);                               % Time of end of break
        intervals.fixtocue(1,first_sample:1:last_sample) = true;
        power.fixtocue = [power.fixtocue; mean(powrspctrm(intervals.fixtocue))];
    elseif strcmp(vmrk(s).value,'S  8') && (strcmp(vmrk(s+2).value,'S  1') || strcmp(vmrk(s+2).value,'S  2') || strcmp(vmrk(s+2).value,'S  3') || strcmp(vmrk(s+2).value,'S  4'))      % When cue is followed by response
        first_sample = (round(vmrk(s).timestamp,3) * 1000) - start;     % Time of fixation
        last_sample = (round(vmrk(s+2).timestamp,3) * 1000) - start;    % Time of bp
        intervals.cuetoresp(1,first_sample:1:last_sample) = true;
        power.cuetoresp = [power.cuetoresp; mean(powrspctrm(intervals.cuetoresp))];
%     elseif strcmp(vmrk(s).value,'S  9') && (strcmp(vmrk(s+1).value,'S  1') || strcmp(vmrk(s+1).value,'S  2') || strcmp(vmrk(s+1).value,'S  3') || strcmp(vmrk(s+1).value,'S  4'))      % When cue is followed by response
%         first = (round(vmrk(s).timestamp,3) * 1000) - start;          % Time of cue
%         second = (round(vmrk(s+1).timestamp,3) * 1000) - start;       % Time of bp
%         intervals.cuetoresp(1,first:1:second) = true;
%         power.cuetoresp = [power.cuetoresp; mean(powrspctrm(intervals.cuetoresp))];
    end
    
end

% Calculate mean power for baseline and task
power.MeanBaseline = mean(power.fixtocue);      % Baseline
power.MeanTask = mean(power.cuetoresp);         % Task

% Load events to calculate power per condition
fileID = events;
fID = fopen(fileID, 'r');
Trials = textscan(fID, '%f%f%d%s%s%f%s%s%s%*s%*s%*s', 'HeaderLines', 1, 'Delimiter', '\t', 'TreatAsEmpty', 'n/a');
fclose(fID);
fixid = strcmp(Trials{4}, 'fixation');

% Find trials where a button was pressed and calculate mean power for Ext Int2 and Int3
Condition = Trials{5};
Condition = Condition(fixid);
Correctness = Trials{9};
Correctness = Correctness(fixid);
bpid = true(length(Condition),1);
for t = 1:length(Condition)
    if (strcmp(Condition{t}, 'Catch') && strcmp(Correctness{t}, 'Hit')) || strcmp(Correctness{t}, 'Miss')
        bpid(t) = false;
    end
end
Condition_pressed = Condition(bpid);
if length(Condition_pressed) > length(power.cuetoresp)
    Condition_pressed = Condition_pressed(1:length(power.cuetoresp),1);
elseif length(Condition_pressed) < length(power.cuetoresp)
    power.cuetoresp = power.cuetoresp(1:length(Condition_pressed),1);
end
power.MeanExt = mean(power.cuetoresp(strcmp(Condition_pressed, 'Ext')));
power.MeanInt2 = mean(power.cuetoresp(strcmp(Condition_pressed, 'Int2')));
power.MeanInt3 = mean(power.cuetoresp(strcmp(Condition_pressed, 'Int3')));

% Find catch trials where a button was not pressed and calculate mean power for Catch
bpid = false(length(Condition),1);
for t = 1:length(Condition)
    if (strcmp(Condition{t}, 'Catch') && strcmp(Correctness{t}, 'Hit'))
        bpid(t) = true;
    end
end
Condition_notpressed = Condition(bpid);
power.MeanCatch = mean(power.cuetoresp(strcmp(Condition_notpressed, 'Catch')));

% Define average power gor output
ext = power.MeanExt;
int2 = power.MeanInt2;
int3 = power.MeanInt3;
cat = power.MeanCatch;
fixtocue = power.MeanBaseline;
cuetoresp = power.MeanTask;

end