function mj_DCM_VOI_qc(subject, conf)

%--------------------------------------------------------------------------
% mj_VOI_extraction
% 20241126 - Martin E. Johansson
% Quality control measures for volumes-of-interest (VOI). Includes
% preparation of a .png file with VOIs overlaid onto an MNI image where
% each row corresponds to a unique VOI. Also writes out a table that tells
% you (1) which VOIs were searched for, and (2) whether they exist for a
% particular subject and session. Uses the BrainSlicer toolbox to generate
% .png reports: https://www.fil.ion.ucl.ac.uk/spm/ext/#BrainSlicer
%--------------------------------------------------------------------------

addpath('/project/3024006.02/Users/marjoh/SPM/own_copy/spm12/toolbox/BrainSlicer');

% Identify sessions
visits = cellstr(spm_select('List', fullfile(conf.firstleveldir, subject), 'dir', 'ses-.*'));

for j = 1:size(visits,1)
    
    % Directory containing VOIs
    voidir = fullfile(conf.firstleveldir, subject, visits{j}, '1st_level');
    
    % Initialize table to store existance of VOIs
    voi_tab = table({subject}, visits(j), 'VariableNames', {'pseudonym', 'Timepoint'});
    
    % Loop over VOIs
    for i = 1:size(conf.VOI.roi_coordinates,1)
        % Locate VOI
        voi_mask = spm_select('FPList', voidir, ['VOI_',conf.VOI.roi_labs{i,1},'_mask.nii']);
        % Check if VOI exists
        voi_exists = [];
        if exist(voi_mask,'file')
            voi_exists = 1;
        else
            voi_exists = 0;
        end
        % Identify slice in the z-direction where VOI is most likely to appear
        z_cntr = conf.VOI.roi_z_slices(i,1);
        % BrainSlicer: VOI mask overlaid on an MNI image
        try slicer({conf.VOI.mni_template, voi_mask},...
                'limits',{[], [0 1]},...
                'minClusterSize',{0,0},...
                'labels',{[],[]},... % when a layer's label is empty no colorbar will be printed.
                'cbLocation','east',... % colorbar location can be south or east
                'title',[subject,'-',visits{j},'-',conf.VOI.roi_labs{i,1}],...
                'mount', [1 8],... % print one row with 8 slices equally spaced
                'slices', [z_cntr-4 z_cntr-2 z_cntr z_cntr+2 z_cntr+4 z_cntr+6],...
                'colormaps',{1,4},...
                'show', false,...
                'noMat', true,...
                'output', fullfile(voidir,['VOI_', conf.VOI.roi_labs{i,1}]));
        catch ME
            warning([conf.VOI.roi_labs{i,1}, ' not found. Probably non-existant']);
            fprintf(ME.message)
        end
        % Fill table
        t = table(voi_exists, 'VariableNames', {conf.VOI.roi_labs{i,1}});
        voi_tab = horzcat(voi_tab, t);
    end
    
    % Collate the individual .png files and delete intermediate output
    slicerCollage('folder', voidir,...
        'wildcard','slicer_VOI_*',...
        'output',fullfile(voidir,'VOI_QC_collage'),...
        'show', false);
%     delete(fullfile(voidir,'slicer*'))
    
    % Write table to vile
    writetable(voi_tab, fullfile(voidir,'VOI_QC_exist.csv'))
    
end