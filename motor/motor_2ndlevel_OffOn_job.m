matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Condition';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 4;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Medication';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
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
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [4
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [3
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = '<UNDEFINED>';
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [4
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = '<UNDEFINED>';
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
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'On > Off (all)';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [-1 -1 -1 -1 1 1 1 1];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'Off > On (all)';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [1 1 1 1 -1 -1 -1 -1];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'On > Off (IntExt)';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [-1 -1 -1 0 1 1 1 0];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Off > On (IntExt)';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [1 1 1 0 -1 -1 -1 0];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'On > Off (Catch)';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 -1 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'Off > On (Catch)';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 1 0 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'On > Off (Ext > Int)';      % Identical to HC > PD (Int > Ext)
matlabbatch{3}.spm.stats.con.consess{18}.tcon.weights = [-2 1 1 0 2 -1 -1 0];
matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'Off > On (Ext > Int)';      % Identical to PD > HC (Int > Ext)
matlabbatch{3}.spm.stats.con.consess{19}.tcon.weights = [2 -1 -1 0 -2 1 1 0];
matlabbatch{3}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'On > Off (Catch > IntExt)';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.weights = [1 1 1 -3 -1 -1 -1 3];
matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.name = 'Off > On (Catch > IntExt)';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.weights = [-1 -1 -1 3 1 1 1 -3];
matlabbatch{3}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.name = 'Off > On (Int3 > Int2)';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.weights = [0 -1 1 0 0 1 -1 0];
matlabbatch{3}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.name = 'On > Off (Int3 > Int2)';
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