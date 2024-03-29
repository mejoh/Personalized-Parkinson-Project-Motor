% Flip

dOutput = '/project/3024006.02/Analyses/CAT12/stats/masks/';

% mask = {'/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_HCgtPD_Mean_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_PDgtHC_3gt1_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers/x_IMgtDM_3gt1_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtDM_3gt1_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtDM_Mean_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtDM_3gt1_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtDM_Mean_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtIM_Mean_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtMMP_Mean_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtHC_3gt1_Mask.nii';...
%     '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtHC_3gt2_Mask.nii'};
mask = {'/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_HCgtPD_Mean_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_PDgtHC_2gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_PDgtHC_3gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers/x_IMgtDM_3gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtDM_3gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtDM_Mean_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtDM_3gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_IMgtHC_2gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_MMPgtHC_3gt1_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtMMP_Mean_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtIM_Mean_Mask.nii';...
    '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtDM_Mean_Mask.nii'};
    
for m = 1:numel(mask)
    
    % Copy original mask
    name = spm_file(mask{m}, 'prefix', 'nf_');
    copyfile(mask{m},fullfile(dOutput,basename(name)))
    
    % Create flipped mask
    Hdr		  = spm_vol(mask{m});
    Vol		  = spm_read_vols(Hdr);
    name = fullfile(dOutput, basename(Hdr.fname));
    Hdr.fname = spm_file(name, 'prefix', 'f_');
    spm_write_vol(Hdr, flipdim(Vol,1));		% LR is the first dimension in MNI space
    
end
