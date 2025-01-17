% Compress contrast images in 1st-level analyses

function ZipOrUnzip()

dAna = '/project/3024006.02/Analyses/motor_task_dcm_03';
Sub = cellstr(spm_select('List', fullfile(dAna), 'dir', '^sub-POM.*'));
% pat = '^ssub.*task-motor_acq-MB6.*preproc_bold.nii.*';
pat = '^beta_0.*.nii.*';
fprintf('Number of subjects found: %i\n', numel(Sub))

for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(dAna, Sub{n}), 'dir', 'ses-.*Visit.*'));
    for v = 1:numel(Visit)
%         dFunc = fullfile(dAna, Sub{n}, Visit{v});
        dFunc = fullfile(dAna, Sub{n}, Visit{v}, '1st_level');
        img = cellstr(spm_select('FPList', dFunc, pat));
%         img = img(16:numel(img));       % Remove 1-15 from list since these might be useful
        for i = 1:numel(img)
            if exist(img{i}, 'file') && endsWith(img{i}, 'nii')
                disp(['Zipping: ' img{i}])
                gzip(img{i}, fileparts(img{i}))
                delete(img{i})
%             else
%                 fprintf('Skipping %s: No image or already zipped \n', Sub{n})
            end
        end
    end
end

end