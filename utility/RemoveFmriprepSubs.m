% Specify directories
bidsdir='/project/3022026.01/pep/bids';
fmriprepdir='/project/3022026.01/pep/bids/derivatives/fmriprep';
sub = cellstr(spm_select('List', bidsdir, 'dir', '^sub-POMU.*'));

% Skip subjects without htmlfile
Sel=true(length(sub),1);
for n=1:length(sub)
    htmlfile = spm_select('FPList', fmriprepdir, ['^' sub{n} '.html']);
    if ~exist(htmlfile, 'file')
        Sel(n)=false;
    end
end
sub=sub(Sel);

% Select all subjects with multiple sessions
s1 = 'ses-PITVisit1';
s2 = 'ses-PITVisit2';
Sel=false(length(sub),1);
for n=1:length(sub)
    
    session1 = spm_select('FPList', fullfile(fmriprepdir, sub{n}), 'dir', s1);
    session2 = spm_select('FPList', fullfile(fmriprepdir, sub{n}), 'dir', s2);
    
    if exist(session1, 'dir') && exist(session2, 'dir')
        Sel(n) = true;
    end
    
end
sub = sub(Sel);

% Delete fmriprep outputs
for n=1:length(sub)
    
    htmlfile = spm_select('FPList', fmriprepdir, ['^' sub{n} '.html']);
    delete(htmlfile);
    
    subprepdir = spm_select('FPList', fmriprepdir, 'dir', sub{n});
    rmdir(subprepdir, 's');
    
end