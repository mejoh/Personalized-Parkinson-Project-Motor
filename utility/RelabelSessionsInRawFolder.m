dRaw = '/project/3024006.01/raw/';
% dRaw = '/project/3022026.01/raw/';
Sub = cellstr(spm_select('List', fullfile(dRaw), 'dir', '^sub-PIT2.*'));
% Sub = cellstr(spm_select('List', fullfile(dRaw), 'dir', '^sub-POM3.*'));
before = 'ses-';
old = 'mri0';
new = 'PITVisit';
% new = 'POMVisit';;

for n = 1:numel(Sub)
    d = fullfile(dRaw, Sub{n});     % Subject-specific directory
    dInfo = dir(fullfile(d, [before 'mri0' '*']));      % Find folders for sessions 
    if ~isempty(dInfo)      % Empty dInfo indicates that sessions have been renamed
        fprintf('Renaming sessions for %s... \n', Sub{n})
        for s = 1:length(dInfo)
            if contains(dInfo(s).name, [before old])
                dInfo(s).newname = replace(dInfo(s).name, old, new);     % Rename session
                OldFolder = fullfile(dInfo(s).folder, dInfo(s).name);                   % Name of old folder
                NewFolder = fullfile(dInfo(s).folder, dInfo(s).newname);                % Name of new folder
                movefile(OldFolder, NewFolder)                                          % Rename folder
            end
        end
    else
        fprintf('Sessions for %s has already been renamed \n', Sub{n})
    end
end