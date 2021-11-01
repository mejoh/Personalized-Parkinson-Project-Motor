% Swap=false;
% if Swap
%     motor_copycontrasts('ses-POMVisit1',true)
%     motor_copycontrasts('ses-PITVisit1',true)
% else
%     motor_copycontrasts('ses-POMVisit1',false)
%     motor_copycontrasts('ses-PITVisit1',false)
% end

exclude_outliers=[true; false];
for i = 1:length(exclude_outliers)
    
  e=exclude_outliers(i);

%   %motor_2ndlevel_2x4RMANOVA
%   motor_2ndlevel_2x4RMANOVA(false,e)
%   motor_2ndlevel_2x4RMANOVA(true,e)
% 
%   %motor_2ndlevel_2x4RMANOVA_Tremor
%   motor_2ndlevel_2x4RMANOVA_Tremor('TremorHc','TremorRegressors',e)
%   motor_2ndlevel_2x4RMANOVA_Tremor('NonTremorHc','TremorRegressors',e)
%   motor_2ndlevel_2x4RMANOVA_Tremor('TremorNonTremor','TremorRegressors',e)
% 
%   %motor_2ndlevel_4x4RMANOVA
%   motor_2ndlevel_4x4RMANOVA(e)
% 
%   %motor_2ndlevel_OffOn
%   motor_2ndlevel_OffOn(e)

%   Subtypes = {[] 'Mild-Motor' 'Intermediate' 'Diffuse-Malignant'};
%   Subtypes = {'Mild-Motor' 'Intermediate' 'Diffuse-Malignant'};
%   for s = 1:numel(Subtypes)
%     %motor_2ndlevel_OneSampleTtests(BaselineOnly, Subscore)
%     motor_2ndlevel_OneSampleTtests(true, 'Total', e, Subtypes{s})
%     motor_2ndlevel_OneSampleTtests(false, 'Total', e, Subtypes{s})
%     motor_2ndlevel_OneSampleTtests(true, 'AppendicularSum', e, Subtypes{s})
%     motor_2ndlevel_OneSampleTtests(false, 'AppendicularSum',e, Subtypes{s})
%     motor_2ndlevel_OneSampleTtests(true, 'CompositeTremorSum', e, Subtypes{s})
%     motor_2ndlevel_OneSampleTtests(false, 'CompositeTremorSum', e, Subtypes{s})
%   end
  
end

dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcOff_x_ExtInt2Int3Catch_NoOutliers';
dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers';
dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/OneSampleTtest_ClinCorr-Off-BAAppendicularSum_NoOutliers/Int>Ext';
dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/OneSampleTtest_ClinCorr-Off-BAAppendicularSum_NoOutliers/Mean_ExtInt';
dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/OneSampleTtest_ClinCorr-Off-Prog-AppendicularSum_NoOutliers/Int>Ext';
motor_extractvoi(dAnalysis)
