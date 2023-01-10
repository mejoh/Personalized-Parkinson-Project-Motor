function ZipOrUnzip2(zip)

if nargin<1
    zip=false;
end

dAna = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/';
cons={'con_0001' 'con_0002' 'con_0003' 'con_0004'};
visits={'ses-Visit1' 'ses-Visit2'};
for c=1:numel(cons)
    for v=1:numel(visits)
        imgs=cellstr(spm_select('FPList',fullfile(dAna,cons{c},visits{v}),'.*sub-POM.*'));
        for i=1:numel(imgs)
            if exist(imgs{i}, 'file') && endsWith(imgs{i}, 'nii') && zip
                disp(['Zipping: ' imgs{i}])
                gzip(imgs{i}, fileparts(imgs{i}))
                delete(imgs{i})
            elseif exist(imgs{i}, 'file') && endsWith(imgs{i}, 'nii.gz') && ~zip
                disp(['Unzipping: ' imgs{i}])
                gunzip(imgs{i}, fileparts(imgs{i}))
                delete(imgs{i})
            end
        end
    end
end
end