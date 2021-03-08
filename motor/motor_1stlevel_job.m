%-----------------------------------------------------------------------
% Job saved on 21-Jan-2019 12:12:30 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_cd.dir = '<UNDEFINED>';
matlabbatch{2}.spm.spatial.smooth.data = '<UNDEFINED>';
matlabbatch{2}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';
matlabbatch{3}.spm.stats.fmri_spec.dir = '<UNDEFINED>';
matlabbatch{3}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{3}.spm.stats.fmri_spec.timing.RT = '<UNDEFINED>';
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t = 72;
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t0 = 36;
matlabbatch{3}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{3}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi = '<UNDEFINED>';
matlabbatch{3}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi_reg = '<UNDEFINED>';
matlabbatch{3}.spm.stats.fmri_spec.sess.hpf = Inf;
matlabbatch{3}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{3}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{3}.spm.stats.fmri_spec.volt = 1;
matlabbatch{3}.spm.stats.fmri_spec.global = 'None';
matlabbatch{3}.spm.stats.fmri_spec.mthresh = 0.25;
matlabbatch{3}.spm.stats.fmri_spec.mask = {'/home/common/matlab/spm12_r7487_20181114/tpm/mask_ICV.nii,1'};
matlabbatch{3}.spm.stats.fmri_spec.cvi = 'FAST';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{5}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'ext > 0';
matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [0 0 1];
matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{2}.tcon.name = 'int2 > 0';
matlabbatch{5}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{3}.tcon.name = 'int3 > 0';
matlabbatch{5}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{4}.tcon.name = 'Catch > 0';
matlabbatch{5}.spm.stats.con.consess{4}.tcon.weights = [1 0];
matlabbatch{5}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{5}.tcon.name = 'int > 0';
matlabbatch{5}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{6}.tcon.name = 'ext > int';
matlabbatch{5}.spm.stats.con.consess{6}.tcon.weights = [0 0 2 0 0 0 -1 0 0 0 -1];
matlabbatch{5}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{7}.tcon.name = 'int > ext';
matlabbatch{5}.spm.stats.con.consess{7}.tcon.weights = [0 0 -2 0 0 0 1 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{8}.tcon.name = 'int3 > int2';
matlabbatch{5}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 -1 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{9}.tcon.name = 'int2 > int3';
matlabbatch{5}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 -1];
matlabbatch{5}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{10}.tcon.name = 'Mean (ExtInt)';
matlabbatch{5}.spm.stats.con.consess{10}.tcon.weights = [0 0 1 0 0 0 1 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{11}.fcon.name = 'EOI';
matlabbatch{5}.spm.stats.con.consess{11}.fcon.weights = [0 0 1 0 0 0 0 0 0 0 0
                                                         0 0 0 0 0 0 1 0 0 0 0
                                                         0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{5}.spm.stats.con.consess{11}.fcon.sessrep = 'none';
% Contrasts for NoPMOD BRreg analyses
% matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'ext > 0';
% matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [0 0 1];
% matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
% matlabbatch{5}.spm.stats.con.consess{2}.tcon.name = 'int2 > 0';
% matlabbatch{5}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 1];
% matlabbatch{5}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
% matlabbatch{5}.spm.stats.con.consess{3}.tcon.name = 'int3 > 0';
% matlabbatch{5}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 0 0 1];
% matlabbatch{5}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
% matlabbatch{5}.spm.stats.con.consess{4}.tcon.name = 'Catch > 0';
% matlabbatch{5}.spm.stats.con.consess{4}.tcon.weights = [1 0];
% matlabbatch{5}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
% matlabbatch{5}.spm.stats.con.consess{5}.tcon.name = 'int > 0';
% matlabbatch{5}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1 0 1];
% matlabbatch{5}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
% matlabbatch{5}.spm.stats.con.consess{6}.tcon.name = 'Button press';
% matlabbatch{5}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 0 0 0 1];
% matlabbatch{5}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
% matlabbatch{5}.spm.stats.con.consess{7}.fcon.name = 'EOI';
% matlabbatch{5}.spm.stats.con.consess{7}.fcon.weights = [0 0 1 0 0 0 0
%                                                         0 0 0 0 1 0 0
%                                                         0 0 0 0 0 0 1];
% matlabbatch{5}.spm.stats.con.consess{7}.fcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.delete = 0;
