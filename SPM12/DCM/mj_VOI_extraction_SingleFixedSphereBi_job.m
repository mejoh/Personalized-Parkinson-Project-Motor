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
% Reference: TBA
%-----------------------------------------------------------------------
% M1
    % R
matlabbatch{1}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{1}.spm.util.voi.adjust = 1;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'R_M1';
matlabbatch{1}.spm.util.voi.roi{1}.sphere.centre = [28 -24 63];
matlabbatch{1}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{1}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{1}.spm.util.voi.expression = 'i1';
% M1
    % L
matlabbatch{2}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{2}.spm.util.voi.adjust = 1;
matlabbatch{2}.spm.util.voi.session = 1;
matlabbatch{2}.spm.util.voi.name = 'L_M1';
matlabbatch{2}.spm.util.voi.roi{1}.sphere.centre = [-28 -24 63];
matlabbatch{2}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{2}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{2}.spm.util.voi.expression = 'i1';    
    
% Putamen
    % R
matlabbatch{3}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{3}.spm.util.voi.adjust = 1;
matlabbatch{3}.spm.util.voi.session = 1;
matlabbatch{3}.spm.util.voi.name = 'R_PUT';
matlabbatch{3}.spm.util.voi.roi{1}.sphere.centre = [26 -2 3];
matlabbatch{3}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{3}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{3}.spm.util.voi.expression = 'i1';
% Putamen
    % L
matlabbatch{4}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{4}.spm.util.voi.adjust = 1;
matlabbatch{4}.spm.util.voi.session = 1;
matlabbatch{4}.spm.util.voi.name = 'L_PUT';
matlabbatch{4}.spm.util.voi.roi{1}.sphere.centre = [-26 -2 3];
matlabbatch{4}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{4}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{4}.spm.util.voi.expression = 'i1';

% Cerebellum IV-V
    % R
matlabbatch{5}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{5}.spm.util.voi.adjust = 1;
matlabbatch{5}.spm.util.voi.session = 1;
matlabbatch{5}.spm.util.voi.name = 'R_CB';
matlabbatch{5}.spm.util.voi.roi{1}.sphere.centre = [16 -50 -20];
matlabbatch{5}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{5}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{5}.spm.util.voi.expression = 'i1';
% Cerebellum IV-V
    % L
matlabbatch{6}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{6}.spm.util.voi.adjust = 1;
matlabbatch{6}.spm.util.voi.session = 1;
matlabbatch{6}.spm.util.voi.name = 'L_CB';
matlabbatch{6}.spm.util.voi.roi{1}.sphere.centre = [-16 -50 -20];
matlabbatch{6}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{6}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{6}.spm.util.voi.expression = 'i1';

% FEF
    % R
matlabbatch{7}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{7}.spm.util.voi.adjust = 1;
matlabbatch{7}.spm.util.voi.session = 1;
matlabbatch{7}.spm.util.voi.name = 'R_FEF';
matlabbatch{7}.spm.util.voi.roi{1}.sphere.centre = [45 -3 44];
matlabbatch{7}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{7}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{7}.spm.util.voi.expression = 'i1';
% FEF
    % L
matlabbatch{8}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{8}.spm.util.voi.adjust = 1;
matlabbatch{8}.spm.util.voi.session = 1;
matlabbatch{8}.spm.util.voi.name = 'L_FEF';
matlabbatch{8}.spm.util.voi.roi{1}.sphere.centre = [-45 -3 44];
matlabbatch{8}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{8}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{8}.spm.util.voi.expression = 'i1';

% SPL
    % R
matlabbatch{9}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{9}.spm.util.voi.adjust = 1;
matlabbatch{9}.spm.util.voi.session = 1;
matlabbatch{9}.spm.util.voi.name = 'R_SPL';
matlabbatch{9}.spm.util.voi.roi{1}.sphere.centre = [9 -61 54];
matlabbatch{9}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{9}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{9}.spm.util.voi.expression = 'i1';
% SPL
    % L
matlabbatch{10}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
matlabbatch{10}.spm.util.voi.adjust = 1;
matlabbatch{10}.spm.util.voi.session = 1;
matlabbatch{10}.spm.util.voi.name = 'L_SPL';
matlabbatch{10}.spm.util.voi.roi{1}.sphere.centre = [-9 -61 54];
matlabbatch{10}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{10}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{10}.spm.util.voi.expression = 'i1';
