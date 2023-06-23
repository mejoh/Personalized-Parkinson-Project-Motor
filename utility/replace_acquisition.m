% REPLACE_ACQUISITION replaces files in one bidsfolder with the files of
% another bidsfolder. 

% Example: QSM data were incorrectly defaced and need to be restored,
% preferably without re-running the entire bidscoin procedure. A new
% bidscoin folder was created containing only the QSM data (bidscoin
% version matches the one that was used for the old data). The new data is
% used to overwrite the old data.

function replace_acquisition()

bids_old = '/project/3024006.01/bids';
bids_new = '/project/3024006.01/bids_qsm';
acquisition = '.*acq-GRE.*run-1_T2star.*';

% substr = 'PIT1MR';
substr = 'PIT2MR';

sub_new = cellstr(spm_select('List', bids_new, 'dir', ['^sub-' substr '.*']));

for n = 1:numel(sub_new)
    
    tab = table();
    clear c1 c2 anat_old anat_new
    
    % Define target and source directories
    if(contains(sub_new{n},'POM1FM'))
        anat_old = fullfile(bids_old, sub_new{n}, 'ses-POMVisit1', 'anat');
        anat_new = fullfile(bids_new, sub_new{n}, 'ses-POMVisit1', 'anat');
    elseif (contains(sub_new{n},'POM3FM'))
        anat_old = fullfile(bids_old, sub_new{n}, 'ses-POMVisit3', 'anat');
        anat_new = fullfile(bids_new, sub_new{n}, 'ses-POMVisit3', 'anat');
    elseif(contains(sub_new{n},'PIT1MR'))
        anat_old = fullfile(bids_old, sub_new{n}, 'ses-PITVisit1', 'anat');
        anat_new = fullfile(bids_new, sub_new{n}, 'ses-PITVisit1', 'anat');
    elseif(contains(sub_new{n},'PIT2MR'))
        anat_old = fullfile(bids_old, sub_new{n}, 'ses-PITVisit2', 'anat');
        anat_new = fullfile(bids_new, sub_new{n}, 'ses-PITVisit2', 'anat');
    end
    % Does both directories exist?
    c1 = exist(anat_old,'dir');
    c2 = exist(anat_new,'dir');
    if ~c1 || ~c2
        fprintf('Skipping subject: Directory not found %s Old = %i. New = %i \n', sub_new{n}, c1, c2)
        continue
    end
    
    % Retrieve filenames
    tab.old = cellstr(spm_select('FPList', fullfile(anat_old), acquisition));
    tab.new = cellstr(spm_select('FPList', fullfile(anat_new), acquisition));
    c1 = numel(tab.old);
    c2 = numel(tab.new);
    % Are there files to begin with?
    if c1 < 2
        fprintf('Skipping subject: no scans %s \n', sub_new{n})
        continue
    end
    % Does the number of files match?
    if c1 ~= c2
        fprintf('Skipping subject: Non-matching number of files %s Nr old = %i. Nr new = %i \n', sub_new{n}, c1, c2)
        continue
    end
    
    % Match old and new
    tab.matching_basename = strcmp(cellfun(@basename, tab.old, 'UniformOutput', false),...
        cellfun(@basename, tab.new, 'UniformOutput', false));
    % Do old and new basenames match?
    if sum(tab.matching_basename) ~= size(tab,1)
        fprintf('Skipping subject: Non-matching files found %s Matches = %i. Total = %i \n',...
            sub_new{n}, sum(tab.matching_basename), size(tab,1))
        continue
    end

    tab.copied = zeros(size(tab,1),1);
    for i = 1:numel(tab.new)
        
        % Define source
        source = tab.new{i};
        
        % Define target
        ptn = basename(source);
        ptn = extractAfter(ptn, '_ses-');
        idx = contains(tab.old, ptn);
        target = tab.old{idx};
        
        % Replace
        [tab.copied(i), msg, ~] = copyfile(source, target);
        
    end
    
    fprintf('%s\n', sub_new{n})
    fprintf('Nr copied %i out of %i\n', sum(tab.copied), size(tab,1))
    
end

end