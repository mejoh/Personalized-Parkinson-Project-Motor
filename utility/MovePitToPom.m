Dir1 = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
Dir2 = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer_PIT_Tremor';
Sub2 = cellstr(spm_select('List', fullfile(Dir2), 'dir', '^sub-POM.*'));

for n = 1:numel(Sub2)
    Source = fullfile(Dir2, Sub2{n}, 'ses-Visit1');
    Destination = fullfile(Dir1, Sub2{n}, 'ses-Visit1_PIT');
    status = copyfile(Source, Destination);
    if status == 1
        fprintf('%s has been succesfully copied \n', Sub2{n})
    else
    fprintf('Failed to copy %s', Sub2{n})
    end
end