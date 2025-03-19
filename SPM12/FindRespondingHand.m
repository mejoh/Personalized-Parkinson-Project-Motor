function Hand = FindRespondingHand()
% Find responding hand of a given participant


%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

POMBIDSDir = '/project/3022026.01/bids';
Sub = spm_BIDS(POMBIDSDir, 'subjects', 'task', 'motor');
fprintf('Number of subjects found: %i\n', numel(Sub))

%% Selection of which participants to process

% POM contains multiple runs of the motor task.
% We want to use the last run for each participant if we're analzying POM data.
Run = num2str(ones(numel(Sub),1));
for MultRunSub = spm_BIDS(POMBIDSDir, 'subjects', 'run','2', 'task','motor')
    if ~isempty(MultRunSub)
        fprintf('Altering run-number for sub-%s with run-2 data\n', char(MultRunSub))
        index = strcmp(Sub,MultRunSub);
        Run(index,1) = '2';
    else
        fprintf('No subjects with run-2 data\n')
    end
end
for MultRunSub = spm_BIDS(POMBIDSDir, 'subjects', 'run','3', 'task','motor')
    if ~isempty(MultRunSub)
        fprintf('Altering run-number for sub-%s with run-3 data\n', char(MultRunSub))
        index = strcmp(Sub,MultRunSub);
        Run(index,1) = '3';
    else
        fprintf('No subjects with run-3 data\n')
    end
end

% Skip subs with missing events.json files
Sel = true(size(Sub));
for n = 1:numel(Sub)
    
    TaskDir = fullfile(POMBIDSDir, ['sub-' Sub{n}], 'func');
    EventsJSONFile = spm_select('FPList', TaskDir, ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run(n) '_events.json']);
	
    if size(EventsJSONFile,1) ~= 1
		fprintf('Skipping sub-%s with %i events.json files:\n', Sub{n}, size(EventsJSONFile,1))
		disp(EventsJSONFile)
		Sel(n) = false;
    end
    
end

%% Final selection of participants

Sub = Sub(Sel);
Run = Run(Sel);

%% Collect events.json files

JsonFiles = cell(size(Sub));
for n = 1:numel(Sub)
     JsonFiles{n} = spm_select('FPList', fullfile(POMBIDSDir, ['sub-', Sub{n}], 'func'), ['.*task-motor_acq-MB6_run-' Run(n) '_events\.json$']);
end

%% Decode responding hand

RespondingHand = strings(size(Sub));
for n = 1:numel(Sub)
    Json = fileread(JsonFiles{n});
    DecodedJson = jsondecode(Json);
    RespondingHand(n) = DecodedJson.RespondingHand.Value;
end


Hand = [Sub; RespondingHand]';

end