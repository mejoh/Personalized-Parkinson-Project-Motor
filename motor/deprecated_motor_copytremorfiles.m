session = 'ses-PITVisit1';
Root = '/project/3022026.01';
BIDSDir  = fullfile(Root, 'pep', 'bids');
EMGDir   = '/project/3024006.02/Analyses/EMG/motor_PIT';
Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-POMU.*'));
fprintf('Found %i subjects \n', numel(Sub))

% Exclusions
% 1. Take only PIT participants
Sel = true(numel(Sub),1);
for n = 1:numel(Sub)
    checkdir = spm_select('FPList', fullfile(BIDSDir, Sub{n}), 'dir', session);
    if isempty(checkdir)
        Sel(n) = false;
    end
end
Sub = Sub(Sel);
Sel = true(numel(Sub),1);
% 2. Take only PD patients
for n = 1:numel(Sub)
    eventsjsonfile = spm_select('FPList', fullfile(BIDSDir, Sub{n}, session, 'beh'), '.*task-motor.*events.json');
    eventsjson = fileread(eventsjsonfile);
    decodedjson = jsondecode(eventsjson);
    group = decodedjson.Group.Value;
    if ~strcmp(group, 'PD_PIT')
        Sel(n) = false;
    end
end
Sub = Sub(Sel);

% Find files and copy to EMG folder
for n = 1:numel(Sub)
    
    source = fullfile(BIDSDir, Sub{n}, session, 'eeg');
    eeg = spm_select('FPList', source, '.*task-motor.*_eeg.eeg');
    vhdr = spm_select('FPList', source, '.*task-motor.*_eeg.vhdr');
    vmrk = spm_select('FPList', source, '.*task-motor.*_eeg.vmrk');
    
    copyfile(eeg, EMGDir)
    copyfile(vhdr, EMGDir)
    copyfile(vmrk, EMGDir)
    
end




