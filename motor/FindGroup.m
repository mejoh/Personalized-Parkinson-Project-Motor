% Check group

% Example inputs:
% bidsdir = '/project/3022026.01/pep/bids_PIT';
% sub = 'sub-POMU0A6DB3C02691EDC8';
% session = 'ses-Visit1';
% checkfolder = 'dwi';

function Group = FindGroup(bidsdir, sub, session, checkfolder)

dCheck = fullfile(bidsdir, sub, session, checkfolder);
test = exist(dCheck, 'dir');

if (test == 7)
    Group = 'HC_PIT';
else
    Group = 'PD_PIT';
end

end