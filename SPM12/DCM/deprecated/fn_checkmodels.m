
dcm.dir = '/project/3011164.01/2_Uitvoer/Data/Processing/MRI/2_Analysis/zscorePmod_6mmSmooth_noGS_inclmotion_3Fcontrasts/3_DCM_models/DCMc_BA4__DCMb_10_11_12_14_16/onestate_Fall';
dcm.file = 'DCM_onestate_Fall.mat';

subjects = {
'D02'    
};


for sb=1:numel(subjects)
load(fullfile(dcm.dir,subjects{sb},dcm.file))
spm_dcm_fmri_check

end