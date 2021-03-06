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
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'ON>OFF, Ext';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'ON>OFF, Int';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 -1 1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'ON>OFF, Ext>Int';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-2 2 1 -1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'ON>OFF, Int>Ext';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [2 -2 -1 1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'ON>OFF, Int3>Int2';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 1 -1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'ON>OFF, Int2>Int3';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 -1 1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{24}.tcon.name = 'ON>OFF, group';
matlabbatch{3}.spm.stats.con.consess{24}.tcon.weights = [-1 1 -1 1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'OFF>ON, Ext';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [1 -1 0 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'OFF>ON, Int';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 1 -1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'OFF>ON, Ext>Int';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [2 -2 -1 1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'OFF>ON, Int>Ext';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [-2 2 1 -1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'OFF>ON, Int3>Int2';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 0 -1 1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'Off>ON, Int2>Int3';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [0 0 1 -1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{25}.tcon.name = 'OFF>ON, group';
matlabbatch{3}.spm.stats.con.consess{25}.tcon.weights = [1 -1 1 -1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'Mean, Ext';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [1 1 0 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Mean, Int';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [0 0 1 1 1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'Mean, Ext>Int';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [2 2 -1 -1 -1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'Mean, Int>Ext';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.weights = [-2 -2 1 1 1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'Mean, Int3>Int2';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.weights = [0 0 -1 -1 1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'Mean, Int2>Int3';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.weights = [0 0 1 1 -1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'Mean, ExtInt';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.weights = [1 1 1 1 1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{21}.fcon.name = 'Medication';
matlabbatch{3}.spm.stats.con.consess{21}.fcon.weights = [1 -1 1 -1 1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{21}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{22}.fcon.name = 'Condition';
matlabbatch{3}.spm.stats.con.consess{22}.fcon.weights = [1 1 -1 -1 0 0 0 0
                                                         0 0 1 1 -1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{22}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{23}.fcon.name = 'Condition x Medication';
matlabbatch{3}.spm.stats.con.consess{23}.fcon.weights = [1 -1 -1 1 0 0 0 0
                                                         0 0 1 -1 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{23}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;