% it = 1;
% nr = 120;
% for i = 1:it
%     motor_1stlevel(true,nr,false)
% end

motor_2ndlevel_OneSampleTtests(false, 'Total')
motor_2ndlevel_OneSampleTtests(true, 'Total')

motor_2ndlevel_OneSampleTtests(false, 'BradySum')
motor_2ndlevel_OneSampleTtests(true, 'BradySum')
% 
% motor_2ndlevel_OneSampleTtests(false, 'RestTremAmpSum')
% motor_2ndlevel_OneSampleTtests(true, 'RestTremAmpSum')
% 
% motor_2ndlevel_OneSampleTtests(false, 'PIGDSum')
% motor_2ndlevel_OneSampleTtests(true, 'PIGDSum')
% 
% motor_2ndlevel_OneSampleTtests(false, 'Rigidity')
% motor_2ndlevel_OneSampleTtests(true, 'Rigidity')

% motor_2ndlevel_2x4RMANOVA_Tremor('TremorHc', 'ClinVars', false)
% motor_2ndlevel_2x4RMANOVA_Tremor('NonTremorHc', 'ClinVars', false)
% motor_2ndlevel_2x4RMANOVA_Tremor('TremorNonTremor', 'ClinVars', false)