function ZipOrUnzip()

% BIDSDir = '/project/3022026.01/pep/bids';
% FMRIPREP = fullfile(BIDSDir, 'derivatives', 'fmriprep');
dAna = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
Sub = cellstr(spm_select('List', fullfile(dAna), 'dir', '^sub-POM.*'));
fprintf('Number of subjects found: %i\n', numel(Sub))

for n = 1:numel(Sub)
%     Visit = cellstr(spm_select('List', fullfile(FMRIPREP, Sub{n}), 'dir', 'ses-Visit*'));
    Visit = cellstr(spm_select('List', fullfile(dAna, Sub{n}), 'dir', 'ses-.*Visit.*'));
    for v = 1:numel(Visit)
%         dFunc = fullfile(FMRIPREP, Sub{n}, Visit{v}, 'func');
        dFunc = fullfile(dAna, Sub{n}, Visit{v});
        img = spm_select('FPList', dFunc, '^ssub.*task-motor_acq-MB6.*preproc_bold.nii.*');
%         if exist(img, 'file') && contains(img, 'nii.gz')
        if exist(img, 'file') && endsWith(img, 'nii')
%             disp(['Unzipping: ' img])
%             gunzip(img, fileparts(img))
            disp(['Zipping: ' img])
            gzip(img, fileparts(img))
            delete(img)
        else
%             fprintf('Skipping %s: No image or already unzipped \n', Sub{n})
            fprintf('Skipping %s: No image or already zipped \n', Sub{n})
        end
    end
end

end