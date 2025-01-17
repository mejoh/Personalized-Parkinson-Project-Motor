dir = {'/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/ROI/Masked_full/3dttest++';
    '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/ROI/Masked_full/3dttest++_severity'};
con = {'con_0010' 'con_0007'};
for d = 1:numel(dir)
    for c = 1:numel(con)
        ExtractBetas(dir{d},con{c})
    end
end

dir = '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/ROI/Masked_full/3dLME_disease';
con = {'con_combined_Group2_x_TimepointNr2_x_Type3_z_Group_by_Time';
    'con_combined_Group2_x_TimepointNr2_x_Type3_z_Group_by_Type_Time'};
for c = 1:numel(con)
    ExtractBetas(dir,con{c})
end
dir = '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/WholeBrain/3dLME_disease';
con = {'con_combined_Group2_x_TimepointNr2_x_Type3_Z_Group';
    'con_combined_Group2_x_TimepointNr2_x_Type3_z_Group_by_Type';
    'con_combined_Group2_x_TimepointNr2_x_Type3_z_Group_by_Time';
    'con_combined_Group2_x_TimepointNr2_x_Type3_z_Group_by_Type_Time'};
for c = 1:numel(con)
    ExtractBetas(dir,con{c})
end


dir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dLME_subtype';
con = {'con_combined_MMPvsIM_x_TimepointNr2_x_Type3_Z_TimeGroup';
    'con_combined_MMPvsIM_x_TimepointNr2_x_Type3_Z_TimeGroupType2gt1';
    'con_combined_MMPvsIM_x_TimepointNr2_x_Type3_Z_TimeGroupType3gt1';
    'con_combined_MMPvsDM_x_TimepointNr2_x_Type3_Z_TimeGroup';
    'con_combined_MMPvsDM_x_TimepointNr2_x_Type3_Z_TimeGroupType2gt1';
    'con_combined_MMPvsDM_x_TimepointNr2_x_Type3_Z_TimeGroupType3gt1';
    'con_combined_IMvsDM_x_TimepointNr2_x_Type3_Z_TimeGroup';
    'con_combined_IMvsDM_x_TimepointNr2_x_Type3_Z_TimeGroupType2gt1';
    'con_combined_IMvsDM_x_TimepointNr2_x_Type3_Z_TimeGroupType3gt1'};
for c = 1:numel(con)
    ExtractBetas(dir,con{c})
end

dir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dLME_subtype';
con = {'con_combined_HCvsMMP_x_TimepointNr2_x_Type3_Z_TimeGroup';
    'con_combined_HCvsMMP_x_TimepointNr2_x_Type3_Z_TimeGroupType2gt1';
    'con_combined_HCvsMMP_x_TimepointNr2_x_Type3_Z_TimeGroupType3gt1';
    'con_combined_HCvsIM_x_TimepointNr2_x_Type3_Z_TimeGroup';
    'con_combined_HCvsIM_x_TimepointNr2_x_Type3_Z_TimeGroupType2gt1';
    'con_combined_HCvsIM_x_TimepointNr2_x_Type3_Z_TimeGroupType3gt1';
    'con_combined_HCvsDM_x_TimepointNr2_x_Type3_Z_TimeGroup';
    'con_combined_HCvsDM_x_TimepointNr2_x_Type3_Z_TimeGroupType2gt1';
    'con_combined_HCvsDM_x_TimepointNr2_x_Type3_Z_TimeGroupType3gt1'};
for c = 1:numel(con)
    ExtractBetas(dir,con{c})
end

COI='con_combined';
AOI={'disease' 'severity'};
for a = 1:numel(AOI)
    motor_ROI_BetaExtraction(COI, a, false)
end

