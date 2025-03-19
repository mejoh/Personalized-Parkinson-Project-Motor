function mjfn_DCM_createVOI(subject,conf)

%% Extract VOI for DCM
% Some help:
% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;27a25589.06
% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;c2a4426b.1501

if ~exist('spm')
    addpath(conf.spmdir);
    spm fmri
    addpath(conf.additionalsdir);
end

for VOI = 1:numel(conf.VOI.VOInames)
    
    fprintf(['\n ----------  Working on ' conf.VOI.VOInames{VOI} ' VOI: Subject ' subject '\n']);
    
    % Get subject specific settings
    DCMdir = fullfile(conf.firstlevel_rootdir,conf.VOI.DCMname,subject);
    if ~exist(DCMdir);mkdir(DCMdir);end
    if strcmp(conf.subjects(strcmp(conf.subjects,subject),2),'R') %adjust ROI name if left-sided tremor.
        ROIname = conf.VOI.ROInames{VOI,1};
    else
        ROIname = conf.VOI.ROInames{VOI,2};
    end
    
    voi_name = [subject '_' conf.VOI.VOInames{VOI}];
    matlabbatch = [];
    matlabbatch{1}.spm.util.voi.spmmat = {fullfile(conf.firstlevel_rootdir,'1st_level_concat',[subject '_concat'],'SPM.mat')};
    matlabbatch{1}.spm.util.voi.adjust = conf.VOI.DCM_correct;
    matlabbatch{1}.spm.util.voi.session = 1;
    matlabbatch{1}.spm.util.voi.name = voi_name;
    matlabbatch{1}.spm.util.voi.roi{1}.mask.image = {fullfile(conf.VOI.ROIdir,ROIname)};
    matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {fullfile(conf.firstlevel_rootdir,'1st_level_concat',[subject '_concat'],'mask.nii')};
    matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.expression = 'i1&i2';
    save(fullfile(DCMdir,['batch_VOI_' voi_name]),'matlabbatch');
    spm_jobman('run',matlabbatch);
    movefile(fullfile(conf.firstlevel_rootdir,'1st_level_concat',[subject '_concat'],'VOI_*'),DCMdir);
end

fprintf(['\n All done for subject ' subject '\n']);

end
