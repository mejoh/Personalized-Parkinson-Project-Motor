% REPLACE_ACQUISITION2 replaces files in one PEP bidsfolder with the files of
% a non-bidsformatted download folder (images and json files). 

% The script finds old SWI images. Each image is matched to, and replaced
% by, a new downloaded version.

function replace_acquisition2()

dDownload = '/project/3022026.01/pep/download_partial-anat/';
dBIDS = '/project/3022026.01/pep/bids/';
Subs = cellstr(spm_select('List',dBIDS,'dir','^sub-POMU.*'));

for n = 1:numel(Subs)
    Visits = cellstr(spm_select('List',fullfile(dBIDS,Subs{n}),'dir','.*Visit.*'));
    for v = 1:numel(Visits)
        fprintf('%s %s\n', Subs{n}, Visits{v})
        Scans = cellstr(spm_select('FPList',fullfile(dBIDS,Subs{n},Visits{v},'anat'),'.*acq-GRE.*.nii.gz'));
        if numel(Scans)<18
            fprintf('No files found for %s %s\n', Subs{n}, Visits{v})
            continue
        end
        tab.copied = zeros(size(Scans,1)*2,1);
        for s = 1:numel(Scans)
            
            [olddir,oldimg,~] = fileparts(Scans{s});         
            oldimg = erase(oldimg,'.nii');
            ptn.pseudo = char(extractBetween(Scans{s},'sub-POMU','/ses'));
            subdir = spm_select('FPList',dDownload,'dir',[ptn.pseudo '.*']);
            
            if strcmp(Visits{v},'ses-POMVisit1')
                ptn.visit = 'Visit1.MRI.Anat';
            elseif strcmp(Visits{v},'ses-POMVisit3')
                ptn.visit = 'Visit3.MRI.Anat';
            elseif strcmp(Visits{v},'ses-PITVisit1')
                ptn.visit = 'Pit.Visit1.MRI.Anat';
            elseif strcmp(Visits{v},'ses-PITVisit2')
                ptn.visit = 'Pit.Visit2.MRI.Anat';
            end
            imgdir = spm_select('FPList',fullfile(subdir,ptn.visit,['sub-POMU' ptn.pseudo],Visits{v}),'dir','anat');
            newimg = spm_select('FPList',fullfile(imgdir),[oldimg '.nii.gz']);
            newjson = spm_select('FPList',fullfile(imgdir),[oldimg '.json']);
            
            [tab.copied(s), msg, ~] = copyfile(newimg, fullfile(olddir,[oldimg '.nii.gz']));
            [tab.copied(s), msg, ~] = copyfile(newjson, fullfile(olddir,[oldimg '.json']));
            
        end
        fprintf('Nr copied %i out of %i\n', sum(tab.copied), size(Scans,1))
    end
end

end