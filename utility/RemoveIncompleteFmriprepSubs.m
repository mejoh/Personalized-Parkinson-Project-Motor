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

% Remove incomplete fmriprep data
for n=1:length(sub)
    compare_bids_and_fmriprep(bidsdir, fmriprepdir, sub{n})
end

function compare_bids_and_fmriprep(bidsdir, fmriprepdir, subject)

% Find relevant files
bidscontents=cellstr(spm_select('FPList', fullfile(bidsdir, subject), 'dir', '^ses.*'));
fmriprepcontents=cellstr(spm_select('FPList', fullfile(fmriprepdir, subject), 'dir', '^ses.*'));
fmriprephtml=cellstr(spm_select('FPList', fmriprepdir, ['^' subject '.*']));

% Report number of files
lb=length(bidscontents);
lf=length(fmriprepcontents);
lfh=length(fmriprephtml);
fprintf('%s, sessions in bids: %i, sessions in fmriprep: %i, html file: %i \n', subject, lb, lf, lfh)

% Check whether there are more sessions in bids than in fmriprep
% If there is, then the subject needs to be re-preprocessed
% Remove fmriprep directory and html file
if lb > lf
    
    fprintf('    %s \n', subject)
    
    fprintf('    Number of bidsfolders (%i) does not match number of fmriprep sessions (%i) \n', lb, lf)
    fprintf('    Removing fmriprep sessions \n')
    rmdir(fullfile(fmriprepdir, subject), 's')
    
    fprintf('    Removing fmriprep html file \n')
    delete(char(fmriprephtml))
    
end

end