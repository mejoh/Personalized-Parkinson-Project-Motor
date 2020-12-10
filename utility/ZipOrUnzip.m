function ZipOrUnzip()

BIDSDir = '/project/3022026.01/pep/bids';
FMRIPREP = fullfile(BIDSDir, 'derivatives', 'fmriprep');
Sub = cellstr(spm_select('List', fullfile(FMRIPREP), 'dir', '^sub-POM.*'));
fprintf('Number of subjects found: %i\n', numel(Sub))

for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(FMRIPREP, Sub{n}), 'dir', 'ses-Visit*'));
    for v = 1:numel(Visit)
        dFunc = fullfile(FMRIPREP, Sub{n}, Visit{v}, 'func');
        img = spm_select('FPList', dFunc, '.*task-motor_acq-MB6.*preproc_bold.nii.*');
        if exist(img, 'file') && contains(img, 'nii.gz')
            disp(['Unzipping: ' img])
            gunzip(img, fileparts(img))
            delete(img)
        else
            fprintf('Skipping %s: No image or already unzipped \n', Sub{n})
        end
    end
end

end