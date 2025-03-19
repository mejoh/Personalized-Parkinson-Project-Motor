function mjfn_DCM_createdesignmtx(subject,conf)
%% Creates design matrix based on first level model
if ~exist('spm') %add required paths
    addpath(conf.spmdir);
    spm fmri
    addpath(conf.additionalsdir);
end

fprintf(['\n ----------  Creating design matrix for subject ' subject '\n']);

DCMdir = fullfile(conf.dir.save,'Designmatrix',subject);
if ~exist(DCMdir,'dir');mkdir(DCMdir); end
load(pf_findfile(fullfile(conf.firstlevel_rootdir, '1st_level_concat',[subject '_concat']),'/Batch/&/.mat/','fullfile'));
matlabbatch = matlabbatch(1);

matlabbatch{1}.spm.stats.fmri_spec.dir = {DCMdir};
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {''};
if size(matlabbatch{1}.spm.stats.fmri_spec.sess,2) == 2
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {''};
end
save(fullfile(DCMdir,['batch_Designmatrix_' subject]),'matlabbatch');
spm_jobman('run',matlabbatch);

fprintf(['\n Done for subject ' subject '\n']);

end