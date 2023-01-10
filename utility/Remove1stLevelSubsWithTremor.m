dProject = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/';
Subs = cellstr(spm_select('FPList', dProject, 'dir', '^sub-POMU.*'));
for n = 1:numel(Subs)
    Visits = cellstr(spm_select('FPList', Subs{n}, 'dir', '^ses-.*'));
    for v = 1:numel(Visits)
        Confs = cellstr(spm_select('FPList', Visits{v}, '.*_desc-confounds_timeseries.*.mat'));
        if ~isempty(Confs) && numel(Confs)==1
            c = load(char(Confs));
            tremor = find(strcmp(c.names,'TremorLog_lin'));
            if ~isempty(tremor)
                fprintf('Tremor regressor found: %s\n', char(extractAfter(Visits{v}, 'DurAvg_ReAROMA_PMOD_TimeDer_Trem/')))
                rmdir(Visits{v},'s')
            end
        end
    end
end





