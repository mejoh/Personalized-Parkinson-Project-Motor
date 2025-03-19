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
    % R
matlabbatch{1}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{1}.spm.util.voi.adjust = 1;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'R_M1';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_R_M1.nii,1'};
% matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [28 -24 63];
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';
% M1
    % L
matlabbatch{2}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{2}.spm.util.voi.adjust = 1;
matlabbatch{2}.spm.util.voi.session = 1;
matlabbatch{2}.spm.util.voi.name = 'L_M1';
matlabbatch{2}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{2}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{2}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{2}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{2}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{2}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{2}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{2}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_L_M1.nii,1'};
% matlabbatch{2}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{2}.spm.util.voi.roi{2}.sphere.centre = [-28 -24 63];
matlabbatch{2}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{2}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{2}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{2}.spm.util.voi.expression = 'i1 & i3';    
    
% Putamen
    % R
matlabbatch{3}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{3}.spm.util.voi.adjust = 1;
matlabbatch{3}.spm.util.voi.session = 1;
matlabbatch{3}.spm.util.voi.name = 'R_PUT';
matlabbatch{3}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{3}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{3}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{3}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{3}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{3}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{3}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{3}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_R_PUT.nii,1'};
% matlabbatch{3}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{3}.spm.util.voi.roi{2}.sphere.centre = [26 -2 3];
matlabbatch{3}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{3}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{3}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{3}.spm.util.voi.expression = 'i1 & i3';
% Putamen
    % L
matlabbatch{4}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{4}.spm.util.voi.adjust = 1;
matlabbatch{4}.spm.util.voi.session = 1;
matlabbatch{4}.spm.util.voi.name = 'L_PUT';
matlabbatch{4}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{4}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{4}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{4}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{4}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{4}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{4}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{4}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_L_PUT.nii,1'};
% matlabbatch{4}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{4}.spm.util.voi.roi{2}.sphere.centre = [-26 -2 3];
matlabbatch{4}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{4}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{4}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{4}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{4}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{4}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{4}.spm.util.voi.expression = 'i1 & i3';

% Cerebellum IV-V
    % R
matlabbatch{5}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{5}.spm.util.voi.adjust = 1;
matlabbatch{5}.spm.util.voi.session = 1;
matlabbatch{5}.spm.util.voi.name = 'R_CB';
matlabbatch{5}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{5}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{5}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{5}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{5}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{5}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{5}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{5}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_R_CB.nii,1'};
% matlabbatch{5}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{5}.spm.util.voi.roi{2}.sphere.centre = [16 -50 -20];
matlabbatch{5}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{5}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{5}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{5}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{5}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{5}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{5}.spm.util.voi.expression = 'i1 & i3';
% Cerebellum IV-V
    % L
matlabbatch{6}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{6}.spm.util.voi.adjust = 1;
matlabbatch{6}.spm.util.voi.session = 1;
matlabbatch{6}.spm.util.voi.name = 'L_CB';
matlabbatch{6}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{6}.spm.util.voi.roi{1}.spm.contrast = 2;
matlabbatch{6}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{6}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{6}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{6}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{6}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{6}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_L_CB.nii,1'};
% matlabbatch{6}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{6}.spm.util.voi.roi{2}.sphere.centre = [-16 -50 -20];
matlabbatch{6}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{6}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{6}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{6}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{6}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{6}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{6}.spm.util.voi.expression = 'i1 & i3';

% FEF
    % R
matlabbatch{7}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{7}.spm.util.voi.adjust = 1;
matlabbatch{7}.spm.util.voi.session = 1;
matlabbatch{7}.spm.util.voi.name = 'R_FEF';
matlabbatch{7}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{7}.spm.util.voi.roi{1}.spm.contrast = 3;
matlabbatch{7}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{7}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{7}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{7}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{7}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{7}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_R_FEF.nii,1'};
% matlabbatch{7}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{7}.spm.util.voi.roi{2}.sphere.centre = [45 -3 44];
matlabbatch{7}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{7}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{7}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{7}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{7}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{7}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{7}.spm.util.voi.expression = 'i1 & i3';
% FEF
    % L
matlabbatch{8}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{8}.spm.util.voi.adjust = 1;
matlabbatch{8}.spm.util.voi.session = 1;
matlabbatch{8}.spm.util.voi.name = 'L_FEF';
matlabbatch{8}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{8}.spm.util.voi.roi{1}.spm.contrast = 3;
matlabbatch{8}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{8}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{8}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{8}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{8}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{8}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_L_FEF.nii,1'};
% matlabbatch{8}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{8}.spm.util.voi.roi{2}.sphere.centre = [-45 -3 44];
matlabbatch{8}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{8}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{8}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{8}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{8}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{8}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{8}.spm.util.voi.expression = 'i1 & i3';

% SPL
    % R
matlabbatch{9}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{9}.spm.util.voi.adjust = 1;
matlabbatch{9}.spm.util.voi.session = 1;
matlabbatch{9}.spm.util.voi.name = 'R_SPL';
matlabbatch{9}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{9}.spm.util.voi.roi{1}.spm.contrast = 3;
matlabbatch{9}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{9}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{9}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{9}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{9}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{9}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_R_SPL.nii,1'};
% matlabbatch{9}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{9}.spm.util.voi.roi{2}.sphere.centre = [9 -61 54];
matlabbatch{9}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{9}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{9}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{9}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{9}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{9}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{9}.spm.util.voi.expression = 'i1 & i3';
% SPL
    % L
matlabbatch{10}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{10}.spm.util.voi.adjust = 1;
matlabbatch{10}.spm.util.voi.session = 1;
matlabbatch{10}.spm.util.voi.name = 'L_SPL';
matlabbatch{10}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{10}.spm.util.voi.roi{1}.spm.contrast = 3;
matlabbatch{10}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{10}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{10}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{10}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{10}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{10}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_L_SPL.nii,1'};
% matlabbatch{10}.spm.util.voi.roi{2}.mask.threshold = 0.5;
matlabbatch{10}.spm.util.voi.roi{2}.sphere.centre = [-9 -61 54];
matlabbatch{10}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{10}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{10}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
matlabbatch{10}.spm.util.voi.roi{3}.sphere.radius = 6;
matlabbatch{10}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
matlabbatch{10}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
matlabbatch{10}.spm.util.voi.expression = 'i1 & i3';
