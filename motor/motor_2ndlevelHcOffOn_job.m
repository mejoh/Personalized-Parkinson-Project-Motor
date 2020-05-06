%-----------------------------------------------------------------------
% Job saved on 18-Jul-2019 12:55:46 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Condition';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 3;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [3
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [3
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [1
                                                                    3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [2
                                                                    3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(9).levels = [3
                                                                    3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(9).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
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
matlabbatch{3}.spm.tools.tfce_estimate.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.tools.tfce_estimate.mask = '';
matlabbatch{3}.spm.tools.tfce_estimate.conspec.titlestr = '';
matlabbatch{3}.spm.tools.tfce_estimate.conspec.contrasts = [2 3 4];
matlabbatch{3}.spm.tools.tfce_estimate.conspec.n_perm = 5000;
matlabbatch{3}.spm.tools.tfce_estimate.nuisance_method = 2;
matlabbatch{3}.spm.tools.tfce_estimate.tbss = 0;
matlabbatch{3}.spm.tools.tfce_estimate.E_weight = 0.5;
matlabbatch{3}.spm.tools.tfce_estimate.singlethreaded = 0;
