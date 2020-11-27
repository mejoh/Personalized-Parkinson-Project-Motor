% Select last run
% Check if run number corresponds with events

% Example inputs:
% bidsdir = '/project/3022026.01/pep/bids_PIT';
% sub = 'sub-POMU0A6DB3C02691EDC8';
% session = 'ses-Visit1';
% task = 'motor';
% scan= 'MB6';

function LastRun = FindLastRun(bidsdir, sub, session, task, scan)

dFunc = fullfile(bidsdir, sub, session, 'func');
imgFunc = cellstr(spm_select('List', dFunc, ['.*task-' task '_acq-' scan '.*bold.nii.*']));
beforeFunc = {'run-'};
afterFunc = {'_bold'};
runsFunc = cellfun(@(x) extractBetween(x, beforeFunc, afterFunc), imgFunc); % Extract run number for each scan
runsFunc = str2num(cell2mat(runsFunc));

dBeh = fullfile(bidsdir, sub, session, 'beh');
tsvBeh = cellstr(spm_select('List', dBeh, ['.*task-' task '_acq-' scan '.*events.tsv']));
beforeBeh = {'run-'};
afterBeh = {'_events'};
runsBeh = cellfun(@(x) extractBetween(x, beforeBeh, afterBeh), tsvBeh); % Extract run number for each tsv
runsBeh = str2num(cell2mat(runsBeh));

FuncRun = max(runsFunc);
BehRun = max(runsBeh);

if (FuncRun == BehRun)
    LastRun = FuncRun;
else
    fprintf('%s: Last run of scan does not correspond to last run of events.tsv \n', sub)
    LastRun = NaN;
end

end