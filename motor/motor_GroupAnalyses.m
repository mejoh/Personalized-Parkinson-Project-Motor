% Swap=false;
% if Swap
%     motor_copycontrasts('ses-POMVisit1',true)
%     motor_copycontrasts('ses-PITVisit1',true)
% else
%     motor_copycontrasts('ses-POMVisit1',false)
%     motor_copycontrasts('ses-PITVisit1',false)
% end

% Independent samples t-tests
exclude_outliers=[true; false];
roi = {'WholeBrain','Herz','MotorNet'};
comps = {'HcVsOff', 'HcVsOn', 'HcVsMMP', 'HcVsIT', 'HcVsDM', 'MMPVsIT', 'MMPVsDM', 'ITVsDM'};
for i = 1:length(exclude_outliers)
    for r = numel(roi)
        for c = 1:numel(comps)
            if strcmp(comps{c}, 'HcVsOff')
                motor_2ndlevel_IndepTtests(true, comps{c}, exclude_outliers(i), char(roi(r)))
            else
                motor_2ndlevel_IndepTtests(false, comps{c}, exclude_outliers(i), char(roi(r)))
            end
        end
    end
end
% TFCE on t-tests above
searchstr = '^Independent.*Whole.*Removed';
Comparisons = cellstr(spm_select('FPList', '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/TFCE', 'dir', searchstr));
for c = 1:numel(Comparisons)
    Contrasts = cellstr(spm_select('FPList', Comparisons{c}, 'dir', 'I[Nn][Tt]'));
    for i = 1:numel(Contrasts)
       spmmat = spm_select('FPList', Contrasts{i}, 'SPM.mat');
       motor_tfce(spmmat, 2, 5000)
    end
end


for i = 1:length(exclude_outliers)
    
  e=exclude_outliers(i);

%   %motor_2ndlevel_2x4RMANOVA          % Compare patients with healthy controls
%   motor_2ndlevel_2x4RMANOVA(false,e)  % On vs Hc
%   motor_2ndlevel_2x4RMANOVA(true,e)   % Off vs Hc
% 
%   %motor_2ndlevel_2x4RMANOVA_Tremor   % Same as above, but stratifies patients by presence of tremor
%   motor_2ndlevel_2x4RMANOVA_Tremor('TremorHc','TremorRegressors',e)
%   motor_2ndlevel_2x4RMANOVA_Tremor('NonTremorHc','TremorRegressors',e)
%   motor_2ndlevel_2x4RMANOVA_Tremor('TremorNonTremor','TremorRegressors',e)
% 
%   %motor_2ndlevel_4x4RMANOVA      % Comparison between subtypes and healthy controls
%   motor_2ndlevel_4x4RMANOVA(e)
% 
%   %motor_2ndlevel_OffOn           % Comparison of on and off
%   motor_2ndlevel_OffOn(e)

%   % Brain-Clinical correlation analysis for baseline and progression data
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
