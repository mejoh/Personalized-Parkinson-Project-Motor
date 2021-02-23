dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer/';
Sub = cellstr(spm_select('List', fullfile(dAnalysis), 'dir', '^sub-POM.*'));
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(dAnalysis, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for v = 1:numel(Visit)
        MatFile = spm_select('FPList', fullfile(dAnalysis, Sub{n}, Visit{v}, '1st_level'), '^SPM.mat$');
        x = load(MatFile);
        if contains(x.SPM.swd, '3022026.01/a')
            x.SPM.swd = strrep(SPM.swd, '3022026.01/a', '3024006.02/A');
            save(MatFile, 'x')
        end
    end
end

MatFile = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer/Group/HcOn x ExtInt2Int3Catch/SPM.mat';
x = load(MatFile);
x.SPM.swd = strrep(x.SPM.swd, '3022026.01/a', '3024006.02/A');
save(MatFile, 'x')