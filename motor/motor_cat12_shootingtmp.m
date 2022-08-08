function motor_cat12_shootingtmp()

spm('defaults', 'FMRI');
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
dClust = '/project/3024006.02/Analyses/CAT12/cluster_output/';
dInput = '/project/3024006.02/Analyses/CAT12/shooting_template/';
fAnat = cellstr(spm_select('FPList', dInput, '_acq-MPRAGE_rec-norm_run-.*_T1w.nii'));

CAT12jobs = cell(numel(fAnat),1);
current = pwd;
cd(dClust)
for f = 1:numel(fAnat)
    
    input = cellstr(fAnat{f});
    CAT12jobs{f} = qsubfeval('spm_jobman', 'run', JobFile, input, 'memreq',4*1024^3,'timreq',1*60*60);
%     spm_jobman('run', JobFile, input);
    
end
cd(current)

end
