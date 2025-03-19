function mj_DCM_replicate_model(subject,conf)

%--------------------------------------------------------------------------
% mj_DCM_replicate_model
% 20241121 - Martin E. Johansson
% Replicates a DCM template  model, typically a fully connected DCM, across
% all subjects and sessions in a cohort.
%--------------------------------------------------------------------------

fprintf('>>> Processing %s\n',subject)

visits = cellstr(spm_select('List', fullfile(conf.firstleveldir, subject), 'dir', 'ses-.*'));

for i = 1:size(visits,1)
    
    fprintf('>>> >>> Processing %s\n',visits{i,1})
    
    matlabbatch = [];
    % Specifications
    matlabbatch{1}.spm.dcm.spec.fmri.group.output.dir = conf.replicate.outputdir;
    matlabbatch{1}.spm.dcm.spec.fmri.group.output.name = conf.replicate.model_name;
    matlabbatch{1}.spm.dcm.spec.fmri.group.template.fulldcm = conf.replicate.fulldcm;
    matlabbatch{1}.spm.dcm.spec.fmri.group.template.altdcm = conf.replicate.altdcm;
    % 1st-level SPM
    idx = contains(conf.replicate.spmmats, subject) .* contains(conf.replicate.spmmats, visits{i,1});
    SPMmat = conf.replicate.spmmats{find(idx),1};
    matlabbatch{1}.spm.dcm.spec.fmri.group.data.spmmats = {SPMmat};
    matlabbatch{1}.spm.dcm.spec.fmri.group.data.session = 1;
    % Select hemisphere contralateral to the responding side, where
    % activation is most likely
    idx = strcmp(conf.replicate.resphand.pseudonym, subject) .* strcmp(conf.replicate.resphand.Timepoint, visits{i,1});
    resp_hand = conf.replicate.resphand.RespondingHand{find(idx),1};
    if strcmp(resp_hand,'Right')
        contralateral_side = 'L';
        ipsilateral_side = 'R';
    else
        contralateral_side = 'R';
        ipsilateral_side = 'L';
    end
    % VOIs
    dcm_regions = cell(size(conf.replicate.VOI_labs));
    voi_exist = zeros(size(conf.replicate.VOI_labs));
    for j = 1:size(conf.replicate.VOI_labs,1)

        if strcmp(conf.replicate.VOI_labs{j},'CB')
            voiname = ['VOI_', ipsilateral_side,'_', conf.replicate.VOI_labs{j,1}, '_1.mat'];
        else
            voiname = ['VOI_', contralateral_side,'_', conf.replicate.VOI_labs{j,1}, '_1.mat'];
        end
        voi = cellstr(spm_select('FPListRec', fullfile(conf.firstleveldir,subject,visits{i,1}), voiname));
        dcm_regions(j) = {voi};
        voi_exist(j) = exist(char(voi),'file');
        
    end
    matlabbatch{1}.spm.dcm.spec.fmri.group.data.region = dcm_regions;
    
    % Skip DCM replication if there are too few VOIs available
    if nnz(voi_exist) < size(conf.replicate.VOI_labs,1)
        msg = 'Missing VOIs. Skipping DCM replication!';
        warning(msg)
        continue
    else
        % Run job
        spm_jobman('run',matlabbatch);
    end
    
end
