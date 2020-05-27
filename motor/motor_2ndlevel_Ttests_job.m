%-----------------------------------------------------------------------
% Job saved on 18-Jul-2019 12:55:46 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov.c = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'mean(FD)';
matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Hc > Pd';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Hc < Pd';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = 'Group';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = [1 0
                                                        0 -1];
matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = 'none';
% matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Hc';
% matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 0];
% matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
% matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Pd';
% matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 1];
% matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;
matlabbatch{4}.spm.tools.tfce_estimate.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.tools.tfce_estimate.mask = '';
matlabbatch{4}.spm.tools.tfce_estimate.conspec.titlestr = '';
matlabbatch{4}.spm.tools.tfce_estimate.conspec.contrasts = [1 2 3];
matlabbatch{4}.spm.tools.tfce_estimate.conspec.n_perm = 5;
matlabbatch{4}.spm.tools.tfce_estimate.nuisance_method = 2;
matlabbatch{4}.spm.tools.tfce_estimate.tbss = 0;
matlabbatch{4}.spm.tools.tfce_estimate.E_weight = 0.5;
matlabbatch{4}.spm.tools.tfce_estimate.singlethreaded = 0;
