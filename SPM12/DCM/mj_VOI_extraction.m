function mj_VOI_extraction(subject, conf)
%--------------------------------------------------------------------------
% mj_VOI_extraction
% 20241029 - Martin E. Johansson
% Defines volumes-of-interest (VOIs) and extracts time series. There are 
% several *_job.m scripts available with different settings that determine 
% how the VOIs are defined.
%--------------------------------------------------------------------------

% Check that number of coordinates and labels match
if size(conf.VOI.roi_coordinates,1) ~= size(conf.VOI.roi_labs,1)
    error('>>> ERROR: Number of coordinate sets does not match number of ROI labels\n')
end

visits = cellstr(spm_select('List', fullfile(conf.firstleveldir, subject), 'dir', 'ses-.*'));

for j = 1:size(visits,1)
    for i = 1:size(conf.VOI.roi_coordinates,1)
        
        matfile = spm_select('FPListRec', fullfile(conf.firstleveldir, subject, visits{j}), 'SPM.mat');
        % Start clean
        delete([fileparts(matfile),'/VOI_',conf.VOI.roi_labs{i,1},'*'])
        
        if conf.VOI.fixed_sphere
            % Simple fixed sphere (doesn't distinguish between signal and
            % noise)
            matlabbatch = [];
            matlabbatch{1}.spm.util.voi.spmmat = {matfile};
            matlabbatch{1}.spm.util.voi.adjust = 1;
            matlabbatch{1}.spm.util.voi.session = 1;
            matlabbatch{1}.spm.util.voi.name = conf.VOI.roi_labs{i,1};
            matlabbatch{1}.spm.util.voi.roi{1}.sphere.centre = conf.VOI.roi_coordinates{i,1};
            matlabbatch{1}.spm.util.voi.roi{1}.sphere.radius = conf.VOI.roi_inner_radius(i,1);
            matlabbatch{1}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
            matlabbatch{1}.spm.util.voi.roi{2}.mask.image = conf.VOI.restriction_mask;
            matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
            matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
            spm_jobman('run', matlabbatch); % Run extraction
        else
            % Threshold contrast map > Outer sphere at coordinates > Inner
            % sphere centered on global max of the outer sphere
            matlabbatch = [];
            matlabbatch{1}.spm.util.voi.spmmat = {matfile};
            matlabbatch{1}.spm.util.voi.adjust = 1;
            matlabbatch{1}.spm.util.voi.session = 1;
            matlabbatch{1}.spm.util.voi.name = conf.VOI.roi_labs{i,1};
            matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = conf.VOI.roi_contrasts(i,1);
            matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
            %         matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = conf.VOI.pthresh(1);   Set in iterations to ensure success of voi extraction (see below)
            matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
            % matlabbatch{1}.spm.util.voi.roi{2}.mask.image = conf.VOI.restriction_mask;
            % matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = conf.VOI.roi_coordinates{i,1};
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = conf.VOI.roi_inner_radius(i,1);
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
            matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
            matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';
            
            % Perform VOI extraction, re-iterate at lower threshold if failure
            success = 0;
            idx = 1;
            while success < 1 && idx < size(conf.VOI.pthresh,1)+1
                fprintf('>>> Attempting p<%i\n', conf.VOI.pthresh(idx))
                matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = conf.VOI.pthresh(idx); % Set p-value threshold
                spm_jobman('run', matlabbatch); % Run extraction
                % Check whether a VOI matfile was generated
                checkfile = fullfile(fileparts(matfile),['VOI_',conf.VOI.roi_labs{i,1},'_1.mat']); % If extraction fails, re-iterate with more lenient threshold
                if exist(checkfile,'file')
                    % Check whether the VOI was placed in a location adjacent
                    % to the specified coordinates
                    VOI = load(checkfile);
                    coord_dev = max(conf.VOI.roi_coordinates{i,1} - VOI.xY.xyz');
                    if coord_dev < 10
                        fprintf('>>> Succesful VOI extraction, stopping here...\n')
                        success = 1;
                    else
                        fprintf('>>> Unsuccesful: VOI not adjacent to intended coordinates...\n')
                        idx = idx + 1;
                    end
                else
                    fprintf('>>> Unsuccesful: no VOI found...\n')
                    idx = idx + 1;
                end
                
                % Remove outputs if now VOI could be generated
                if idx == size(conf.VOI.pthresh,1)+1
                    warning('VOI could not be generated. Deleting spurious outputs and moving on...')
                    delete([fileparts(matfile),'/VOI_',conf.VOI.roi_labs{i,1},'*'])
                end
            end
            
        end
                
    end
    
end

% DEPRECATED: use of job scripts
% List of open inputs
% dcm_dir = '/project/3024006.02/Analyses/motor_task_dcm_02';
% subs = cellstr(spm_select('List', dcm_dir, 'dir', 'g*sub-POMU.*'));
% conf.VOI.jobfile = {'/home/sysneu/marjoh/scripts/proj_DCM/mj_VOI_extraction_MovingInnerSphereUni_job.m'};
% jobs = repmat(conf.VOI.jobfile, 1, 1);
% inputs = cell(10, 1);
% if ~conf.VOI.concat
%     visits = cellstr(spm_select('List', fullfile(conf.firstleveldir, subject), 'dir', 'ses-.*'));
% else
%     visits = cellstr(spm_select('List', fullfile(conf.dcmdir,'concatenated_sessions', subject), 'dir', 'ses-.*'));
% end
% for v = 1:numel(visits)
%     matfile = spm_select('FPList', fullfile(conf.firstleveldir, subject, visits{v}, '1st_level'), 'SPM.mat');
% %     matfile = spm_select('FPList', fullfile(conf.firstleveldir, subs{n}), 'SPM.mat');
%     inputs{1,1} = {matfile};
%     inputs{2,1} = {matfile};
%     inputs{3,1} = {matfile};
%     inputs{4,1} = {matfile};
%     inputs{5,1} = {matfile};
%     inputs{6,1} = {matfile};
%     inputs{7,1} = {matfile};
%     inputs{8,1} = {matfile};
%     inputs{9,1} = {matfile};
%     inputs{10,1} = {matfile};
%     spm('defaults', 'FMRI');
%     spm_jobman('run', jobs, inputs{:});
% end

% DEPRECATED: automatic side selection
% Easier to define both sides and just select the right VOIs at a later
% stage in the analysis
% % Moving inner sphere, unilateral, automatic side selection
% matlabbatch = [];
% matlabbatch{1}.spm.util.voi.spmmat = '<UNIDENTIFIED>';
% matlabbatch{1}.spm.util.voi.adjust = 1;
% matlabbatch{1}.spm.util.voi.session = 1;
% matlabbatch{1}.spm.util.voi.name = 'uniM1';
% matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
% matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 2;
% matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
% matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
% matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = conf.VOI.pthresh{1};
% matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
% matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
% matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {'/project/3024006.02/Analyses/motor_task_dcm_02/masks/s_bi_M1.nii,1'};
% matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
% % matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [28 -24 63];
% % matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
% % matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
% matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
% matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 6;
% matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm = 1;
% matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';
% matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';

