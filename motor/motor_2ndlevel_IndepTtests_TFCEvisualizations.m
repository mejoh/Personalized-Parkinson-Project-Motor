TFCEdir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/TFCE';
analyses = dir(fullfile(TFCEdir, 'Independent*'));
for a = 1:length(analyses)
    currentcomp = fullfile(TFCEdir, analyses(a).name);
    cons = dir(currentcomp);
    cons = cons(3:length(cons));
    for c = 1:length(cons)
        statimg = spm_select('FPList', fullfile(cons(c).folder, cons(c).name), 'TFCE_log_pFDR_0002.nii');
        t = spm_vol(statimg);
        outputpth = fullfile(cons(c).folder);
        try
            overlay_log10_1minp_statimg(statimg,outputpth)
        catch
%             fprintf([cons(c).name, ': NS', '\n'])
        end
    end
end