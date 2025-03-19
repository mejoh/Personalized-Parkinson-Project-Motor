%-----------------------------------------------------------------------
% Job saved on 29-Nov-2023 15:48:29 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% Pre-defined volumes-of-interest (VOI):
% - 1. Primary motor cortex (M1)
% - 2. Putamen
% - 3. Cerebellum (IV-V)
% - 4. Premotor cortex (FEF)
% - 5. Superior parietal lobule (7A)
% VOIs #1-3 represent the motor network, which is dysfunctional in PD
% VOI #4 represents compensation, as identified by a correlation
% between longitudinal clinical progression and selection-related activity
% VOI #5 also represents compensation, but identified by a correlation
% between clinical severity and selection-related activity
%
% Masks for these VOIs are located in:
% - /project/3024006.02/Analyses/motor_task_dcm_02/masks/
% Masks are generated with
% - /project/3024006.02/Analyses/motor_task_dcm_02/masks/masks.sh
%
% Reference: TBA
%-----------------------------------------------------------------------
% M1
matlabbatch{1}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{1}.spm.util.voi.adjust = 1;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'uniM1';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_bi_M1.nii,1'};
matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
% matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [28 -24 63];
% matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
% matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';
    
% Putamen
matlabbatch{2}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{2}.spm.util.voi.adjust = 1;
matlabbatch{2}.spm.util.voi.session = 1;
matlabbatch{2}.spm.util.voi.name = 'uniPUT';
matlabbatch{2}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{2}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{2}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{2}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{2}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{2}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{2}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{2}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_bi_PUT.nii,1'};
matlabbatch{2}.spm.util.voi.roi{2}.mask.threshold = 0.5;
% matlabbatch{2}.spm.util.voi.roi{2}.sphere.centre = [26 -2 3];
% matlabbatch{2}.spm.util.voi.roi{2}.sphere.radius = 8;
% matlabbatch{2}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{2}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{2}.spm.util.voi.expression = 'i1 & i3';

% Cerebellum IV-V
matlabbatch{3}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{3}.spm.util.voi.adjust = 1;
matlabbatch{3}.spm.util.voi.session = 1;
matlabbatch{3}.spm.util.voi.name = 'uniCB';
matlabbatch{3}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{3}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{3}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{3}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{3}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{3}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{3}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{3}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_bi_CB.nii,1'};
matlabbatch{3}.spm.util.voi.roi{2}.mask.threshold = 0.5;
% matlabbatch{3}.spm.util.voi.roi{2}.sphere.centre = [16 -50 -20];
% matlabbatch{3}.spm.util.voi.roi{2}.sphere.radius = 8;
% matlabbatch{3}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{3}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{3}.spm.util.voi.expression = 'i1 & i3';

% FEF
matlabbatch{4}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{4}.spm.util.voi.adjust = 1;
matlabbatch{4}.spm.util.voi.session = 1;
matlabbatch{4}.spm.util.voi.name = 'uniFEF';
matlabbatch{4}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{4}.spm.util.voi.roi{1}.spm.contrast = 3;
matlabbatch{4}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{4}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{4}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{4}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{4}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{4}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_bi_FEF.nii,1'};
matlabbatch{4}.spm.util.voi.roi{2}.mask.threshold = 0.5;
% matlabbatch{4}.spm.util.voi.roi{2}.sphere.centre = [45 -3 44];
% matlabbatch{4}.spm.util.voi.roi{2}.sphere.radius = 8;
% matlabbatch{4}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{4}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{4}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{4}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{4}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{4}.spm.util.voi.expression = 'i1 & i3';

% SPL
matlabbatch{5}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{5}.spm.util.voi.adjust = 1;
matlabbatch{5}.spm.util.voi.session = 1;
matlabbatch{5}.spm.util.voi.name = 'uniSPL';
matlabbatch{5}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{5}.spm.util.voi.roi{1}.spm.contrast = 3;
matlabbatch{5}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{5}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{5}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{5}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{5}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{5}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_bi_SPL.nii,1'};
matlabbatch{5}.spm.util.voi.roi{2}.mask.threshold = 0.5;
% matlabbatch{5}.spm.util.voi.roi{2}.sphere.centre = [9 -61 54];
% matlabbatch{5}.spm.util.voi.roi{2}.sphere.radius = 8;
% matlabbatch{5}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{5}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{5}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{5}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{5}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{5}.spm.util.voi.expression = 'i1 & i3';
