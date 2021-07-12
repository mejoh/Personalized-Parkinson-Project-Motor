matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Baseline severity';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
% matlabbatch{1}.spm.stats.factorial_design.cov(2).c = '<UNDEFINED>';   % Unclear whether age has anything to do with progression. Maybe if you consider late-onset PD and relation to diffuse-malignant subtype?
% matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'Age';
% matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
% matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = '<UNDEFINED>';     % Mollenhauer et al. 2019
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'Gender';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
% matlabbatch{1}.spm.stats.factorial_design.cov(2).c = '<UNDEFINED>';       % FD is correlated with BA severity. We trust that motion has been adequately corrected for. So dont include.
% matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'FD';
% matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
% matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '+BA';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '-BA';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = 'BA';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
% matlabbatch{4}.spm.tools.tfce_estimate.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
% matlabbatch{4}.spm.tools.tfce_estimate.mask = {'/project/3024006.02/Analyses/Masks/standard/group_mask.nii,1'};
% matlabbatch{4}.spm.tools.tfce_estimate.conspec.titlestr = '';
% matlabbatch{4}.spm.tools.tfce_estimate.conspec.contrasts = [1 2];
% matlabbatch{4}.spm.tools.tfce_estimate.conspec.n_perm = 5000;
% matlabbatch{4}.spm.tools.tfce_estimate.nuisance_method = 2;