% Specify directories
bidsdir='/project/3022026.01/pep/bids';
FirstLevelDir='/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
sub = cellstr(spm_select('List', bidsdir, 'dir', '^sub-POMU.*'));

% Skip subjects without htmlfile
Sel=true(length(sub),1);
for n=1:length(sub)
    secondses = spm_select('FPList', fullfile(FirstLevelDir, sub{n}), 'dir', 'ses-PITVisit2');
    if ~exist(secondses, 'dir')
        Sel(n)=false;
    end
end
sub=sub(Sel);

for n=1:length(sub)
    
    FirstLevelSubDir = spm_select('FPList', FirstLevelDir, 'dir', sub{n});
    fprintf('Removing %s \n', FirstLevelSubDir)
    rmdir(FirstLevelSubDir, 's');
    
end