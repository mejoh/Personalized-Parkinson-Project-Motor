%-----------------------------------------------------------------------
% Job saved on 18-Jul-2019 12:55:46 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Condition';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 4;
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
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1
                                                                    3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [2
                                                                    3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [1
                                                                    4];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [2
                                                                    4];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'mean(FD)';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'Age';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(3).c = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'Gender';
matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [1 0 0 0 0 0 0 0
                                                        0 1 0 0 0 0 0 0
                                                        0 0 1 0 0 0 0 0
                                                        0 0 0 1 0 0 0 0
                                                        0 0 0 0 1 0 0 0
                                                        0 0 0 0 0 1 0 0
                                                        0 0 0 0 0 0 1 0
                                                        0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Ext > 0';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 0 0 0 1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Int2 > 0';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1 0 0 0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Int3 > 0';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 1 0 0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Int > 0';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 1 1 0 0 1 1 0];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Catch > 0';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 1 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Ext > Int';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [2 -1 -1 0 2 -1 -1 0];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'Int > Ext';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [-2 1 1 0 -2 1 1 0];
matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'Int3 > Int2';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 -1 1 0 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Catch > ExtInt';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [-1 -1 -1 3 -1 -1 -1 3];
matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'ExtInt > Catch';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [1 1 1 -3 1 1 1 -3];
matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'PD > HC (all)';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [-1 -1 -1 -1 1 1 1 1];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'HC > PD (all)';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [1 1 1 1 -1 -1 -1 -1];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'PD > HC (IntExt)';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [-1 -1 -1 0 1 1 1 0];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'HC > PD (IntExt)';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [1 1 1 0 -1 -1 -1 0];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'PD > HC (Catch)';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 -1 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'HC > PD (Catch)';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 1 0 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'PD > HC (Ext > Int)';      % Identical to HC > PD (Int > Ext)
matlabbatch{3}.spm.stats.con.consess{18}.tcon.weights = [-2 1 1 0 2 -1 -1 0];
matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'HC > PD (Ext > Int)';      % Identical to PD > HC (Int > Ext)
matlabbatch{3}.spm.stats.con.consess{19}.tcon.weights = [2 -1 -1 0 -2 1 1 0];
matlabbatch{3}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'PD > HC (Catch > IntExt)';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.weights = [1 1 1 -3 -1 -1 -1 3];
matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.name = 'HC > PD (Catch > IntExt)';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.weights = [-1 -1 -1 3 1 1 1 -3];
matlabbatch{3}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.name = 'HC > PD (Int3 > Int2)';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.weights = [0 -1 1 0 0 1 -1 0];
matlabbatch{3}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.name = 'PD > HC (Int3 > Int2)';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.weights = [0 1 -1 0 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{24}.fcon.name = 'Group x Cond (ExtInt)';
matlabbatch{3}.spm.stats.con.consess{24}.fcon.weights = [1 -1 0 0 -1 1 0 0
                                                         0 1 -1 0 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{24}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{25}.fcon.name = 'Group (ExtInt)';
matlabbatch{3}.spm.stats.con.consess{25}.fcon.weights = [1 1 1 0 -1 -1 -1 0];
matlabbatch{3}.spm.stats.con.consess{25}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{26}.fcon.name = 'Condition (ExtInt)';
matlabbatch{3}.spm.stats.con.consess{26}.fcon.weights = [1 -1 0 0 1 -1 0 0
                                                         0 1 -1 0 0 1 -1 0];
matlabbatch{3}.spm.stats.con.consess{26}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
%matlabbatch{4}.spm.tools.tfce_estimate.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%matlabbatch{4}.spm.tools.tfce_estimate.mask = '';
%matlabbatch{4}.spm.tools.tfce_estimate.conspec.titlestr = '';
%matlabbatch{4}.spm.tools.tfce_estimate.conspec.contrasts = [19, 20, 21, 27]; %[19,20,21,26,27,30,31];
%matlabbatch{4}.spm.tools.tfce_estimate.conspec.n_perm = 5000;
%matlabbatch{4}.spm.tools.tfce_estimate.nuisance_method = 2;
%matlabbatch{4}.spm.tools.tfce_estimate.tbss = 0;
%matlabbatch{4}.spm.tools.tfce_estimate.E_weight = 0.5;
%matlabbatch{4}.spm.tools.tfce_estimate.singlethreaded = 0;
