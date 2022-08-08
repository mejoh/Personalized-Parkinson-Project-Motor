%%%%% motor_scrubtremregs.m %%%%%
% Description: Scrubs button presses from the acc signal.
% This should be done after the ChangeMarkersAllSubs script has been run.
% The scrubbing only alters the .eeg file. It removes a window around
% button presses and then fills in those windows with a linear
% interpolation.

emgdatdir = '/project/3024006.02/Data/EMG';
emganalysisdir = '/project/3024006.02/Analyses/EMG/motor';
bidsdir = '/project/3022026.01/pep/bids';
Sub = cellstr(spm_select('FPList', bidsdir, 'dir', 'sub-POM.*'));
% DATA PREPARATION
% 1. Copy eeg data from bids
% Sub = [Sub(91,1); Sub(53,1); Sub(318,1); Sub(225,1); Sub(86,1)];
for n = 1:numel(Sub)
    
    s = Sub{n};
    
%     Visit = cellstr(spm_select('FPList', s, 'dir', 'ses-Visit[0-9]'));
    Visit = cellstr(spm_select('FPList', s, 'dir', 'ses-POMVisit3'));
    for v = 1:numel(Visit)
        
        t = Visit{v};
        eegfiles = cellstr(spm_select('FPList', fullfile(t, 'eeg'), '.*task-motor.*'));
        eegfiles = eegfiles(~contains(eegfiles,'ehst2'),1);
        eegfiles = eegfiles(~contains(eegfiles,'hfinf2'),1);
        if sum(contains(eegfiles,'.eeg')) ~= 1 && sum(contains(eegfiles,'.vmrk')) ~= 1 && sum(contains(eegfiles,'.vhdr')) ~= 1
            fprintf('Skipping %s %s: no data \n', s, t)
            continue
        end
        
        new_eegfiles = strrep(eegfiles, bidsdir, emgdatdir);
        new_folder = fileparts(new_eegfiles{1});
        if exist(new_folder, 'dir')
            delete(fullfile(new_folder,'*.*'))
        else
            mkdir(new_folder)
        end
        
        for f = 1:numel(eegfiles)
            copyfile(eegfiles{f}, new_eegfiles{f})
        end
        
    end
end

% SCRUBBING PROCEDURE - Removes button presses from raw acc signal and generates a cleaner tremor regressors
% 1. Load raw acc signal
% 2. Create markers for button presses
% 3. Define a window of -100 to 500 ms around each buton press
% 4. For x y and z axes of ACC signal, set all values in the defined windows to NaN
% 5. Interpolate missing values
% 6. Downsample the acc signal (i.e. turn samples to scans) <- NOT NECESSARY NOW
% 7. Convolve with the HRF to generate a regressor <- NOT NECESSARY NOW
Sub = cellstr(spm_select('FPList', emgdatdir, 'dir', 'sub-POM.*'));
ms_around_bp = [-50, 700];

for n = 1:numel(Sub)
    
    s = Sub{n};
    
%     Visit = cellstr(spm_select('FPList', s, 'dir', 'ses-Visit[0-9]'));
    Visit = cellstr(spm_select('FPList', s, 'dir', 'ses-POMVisit3'));
    for v = 1:numel(Visit)
        
        % Find data
        t = Visit{v};
        eeg = spm_select('FPList', fullfile(t, 'eeg'), '.*task-motor_eeg.eeg');
        vhdr = spm_select('FPList', fullfile(t, 'eeg'), '.*task-motor_eeg.vhdr');
        vmrk = spm_select('FPList', fullfile(t, 'eeg'), '.*task-motor_eeg.vmrk');
        
        % Load data
        eegdata = ft_read_data(eeg);
        vhdrdata = ft_read_header(vhdr);
        vmrkdata = ft_read_event(vmrk);
%         % Remove 'Sync On' markers
%         synconid = [];
%         for i = 1:length(vmrkdata)
%             s = vmrkdata(i).value;
%             if contains(s, 'Sync On')
%                 synconid = [synconid; i];
%             end
%         end
%         vmrkdata(synconid) = [];
%         ft_write_event(vmrk, vmrkdata);
        
        % Set parameters
        acc_chans = find(contains(vhdrdata.label, 'accelerometer'));
        samples_per_ms = vhdrdata.Fs / 1000;
        samples_around_bp = [ms_around_bp(1)*samples_per_ms, ms_around_bp(2)*samples_per_ms];
        
        % Find sample corresponding to recording of button presses
        bp_samples = [];
        for p = 1:length(vmrkdata)
            if strcmp(vmrkdata(p).value, 'S  1') || strcmp(vmrkdata(p).value, 'S  2') || strcmp(vmrkdata(p).value, 'S  3') || strcmp(vmrkdata(p).value, 'S  4')
                bp_samples = [bp_samples; vmrkdata(p).sample];
            end
        end
        % Find upper and lower boundaries around button presses
        bp_lower = bp_samples + samples_around_bp(1);
        bp_upper = bp_samples + samples_around_bp(2);
        
        % Cut acc signal inside boundaries defined by button presses then interpolate
        for c = 1:length(acc_chans)
            newrow_eegdata = eegdata(acc_chans(c),:);
            for bp = 1:length(bp_samples)
                newrow_eegdata(bp_lower(bp):bp_upper(bp)) = NaN;
            end
            ind = 1:length(newrow_eegdata);
            ix = ~isnan(newrow_eegdata);
            newrow_eegdata = interp1(ind(ix),newrow_eegdata(ix),ind,'linear');
            if length(eegdata(acc_chans(c),:)) == length(newrow_eegdata)
                eegdata(acc_chans(c),:) = newrow_eegdata;
            else
                eegdata(acc_chans(c),:) = newrow_eegdata(1:length(eegdata(acc_chans(c),:)));
            end
        end
        
        ft_write_data(eeg, eegdata, 'header', vhdrdata, 'event', vmrkdata)
        
        [~, new_eeg.name, new_eeg.ext] = fileparts(eeg);
        copyfile(eeg, fullfile(emganalysisdir, [new_eeg.name new_eeg.ext]))
        
    end
    
end




% % OLD %
% % SCRUBBING PROCEDURE - Removes button presses from raw acc signal and generates a cleaner tremor regressors
% % 1. Load raw acc signal corresponding to axis where tremor was strongest
% % 2. Create markers for button presses
% % 3. Define a window of -100 to 500 ms around each buton press
% % 4. Set all values in the defined windows to NaN
% % 5. Interpolate missing values
% % 6. Downsample the acc signal (i.e. turn samples to scans)
% % 7. Convolve with the HRF to generate a regressor
% visit = 'ses-Visit1';
% bidsdir = '/project/3022026.01/pep/bids/';
% root = '/project/3024006.02/Analyses/EMG/motor';
% prepemgdir = fullfile(root, 'processing', 'prepemg');
% regdir = fullfile(prepemgdir, 'Regressors', 'ZSCORED');
% SubInfo.Rawfiles = cellstr(spm_select('FPList', prepemgdir, ['sub-POM.*' visit '.*seltremor.mat']));
% SubInfo.Regfiles = cellstr(spm_select('FPList', regdir, ['sub-POM.*' visit '.*log.mat']));
% SubInfo.Sub = extractBetween(SubInfo.Regfiles, 'ZSCORED/', '-ses');
% SubInfo.TremAxis = extractBetween(SubInfo.Regfiles, 'acc_', '_');
% outputdir = fullfile(prepemgdir, 'Regressors', 'Scrubbed');
% if ~exist(outputdir,'dir')
%  	mkdir(outputdir)
% else
%     delete(fullfile(outputdir,'*.*'))
% end
% 
% % Create a table to store relevant info
% tremcheck = load(fullfile(root, 'manually_checked', 'Martin', 'Tremor_check-16-Mar-2021.mat'));
% peakcheck = load(fullfile(root, 'manually_checked', 'Martin', 'Peak_check-16-Mar-2021.mat'));
% checktable = table(extractBetween(tremcheck.Tremor_check.cName, 'Martin/', '-ses'), tremcheck.Tremor_check.cVal, peakcheck.Peak_check.cVal, 'VariableNames', {'Sub', 'TremorPresent', 'PeakCorrect',});
% % Add columns
% newcol1 = table(cell(size(checktable,1),1), 'VariableNames', {'CertainTremor'});
% newcol2 = table(cell(size(checktable,1),1), 'VariableNames', {'TremAxis'});
% newcol3 = table(cell(size(checktable,1),1), 'VariableNames', {'Rawfile'});
% newcol4 = table(cell(size(checktable,1),1), 'VariableNames', {'Vmrkfile'});
% checktable = [checktable, newcol1, newcol2, newcol3];
% for n = 1:numel(checktable.Sub)
%     
%     % Check so that tremor is present and peak is correct
%     s = checktable.Sub{n};
%     t = checktable.TremorPresent(n);
%     p = checktable.PeakCorrect(n);
%     if t == 1 && p == 1
%         checktable.CertainTremor{n} = 1;
%     else
%         checktable.CertainTremor{n} = 0;
%     end
%     
%     % Append tremor axis to table
%     tid = find(contains(SubInfo.Sub, s));
%     checktable.TremAxis{n} = SubInfo.TremAxis{tid};
%     
%     % Append rawfile to table
%     rawfileid = find(contains(SubInfo.Rawfiles, s));
%     checktable.Rawfile{n} = SubInfo.Rawfiles{rawfileid};
%     
%     % Append vmrkfile to table
%     vmrkdir = fullfile(bidsdir, s, visit, 'eeg');
%     checktable.Vmrkfile{n} = spm_select('FPList', vmrkdir, '.*motor_eeg.vmrk');
%     
% end
% 
% % I need to find button press markers...
% 
% seltremor = load(checktable.Rawfile{1});
% vmrkdat = readtable(checktable.Vmrkfile{1}, ...
%     'FileType', 'text', ...
%     'ReadVariableNames', false, ...
%     'Delimiter', {'=', ','}, ...
%     'HeaderLines', 11);