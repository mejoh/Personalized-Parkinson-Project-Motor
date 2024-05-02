% fsl_add_regressors_to_covs.m
% Description: This script will add covariates to text files that are used to create
% design matrices with the fsl_glm gui. Here, putamen activity and pSN free
% water regressors are added to create two new files. The aim to is to
% adjust for BG dysfunction to see if the relationship between bradykinesia
% and decline in parieto-premotor activity remains

img_type = 'FPList'; % 'Concat'
mask = '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/Oxford-Imanova_putamen.nii';
cons = {'con_0007', 'con_0010'};
sessions = {'delta', 'ba'};
txtfilenames = {'delta_clincorr_all', 'delta_clincorr_all_vxlEV',...
    'delta_clincorr_brady', 'delta_clincorr_brady_vxlEV',...
    'delta_clincorr_moca', 'delta_clincorr_moca_vxlEV',...
    'delta_clincorr_LEDD', 'delta_clincorr_LEDD_vxlEV'};

for c = 1:numel(cons)

    % BG activity
    vals = [];
    for i = 1:numel(sessions)
        img = ['/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/', cons{c}, '/imgs__', sessions{i}, '_clincorr.txt'];
        [beta_estimates, subjects] = mj_ExtractValsInMask(img, img_type, mask);
        vals = [vals, round(beta_estimates-mean(beta_estimates,'omitnan'),5)];
    end
    putamen_activity = [cell2table(subjects,'VariableNames',{'pseudonym'}), array2table(vals,'VariableNames',{'Putamen_Delta','Putamen_T0'})];
    
    % pSN free water
    pSN_FW = readtable(fullfile('/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data', cons{c}, '/covs__delta_pSN_FW.csv'), 'Delimiter', ',');
    pSN_FW{:,3} = round(pSN_FW{:,3} - mean(pSN_FW{:,3}, 'omitnan'),5);
    pSN_FW{:,4} = round(pSN_FW{:,4} - mean(pSN_FW{:,4}, 'omitnan'),5);
    
    % Merged table
    covs = join(putamen_activity, pSN_FW);
    covs = movevars(covs, 'paths', 'After', 'pseudonym');

    for t = 1:numel(txtfilenames)
        % Only Putamen covar
        txtfile = ['/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/', cons{c}, '/covs__', txtfilenames{t}, '.txt'];
        cols = table2array(covs(:,3:4));
        colnames = {covs.Properties.VariableNames{3}, covs.Properties.VariableNames{4}};
        covtab = mj_InsertColumnInTxtFile(txtfile, cols, colnames);
        [fp.p, fp.name, fp.ext] = fileparts(txtfile);
        outputname = fullfile(fp.p, [fp.name, '_AddCov1', fp.ext]);
        writetable(covtab, outputname, 'Delimiter', 'space', 'WriteVariableNames', false)
        
        % Putamen and pSN covars together (note that this table will have
        % fewer rows dues to missing pSN values
        cols = table2array(covs(:,3:6));
        colnames = {covs.Properties.VariableNames{3}, covs.Properties.VariableNames{4},...
            covs.Properties.VariableNames{5}, covs.Properties.VariableNames{6}};
        covtab = mj_InsertColumnInTxtFile(txtfile, cols, colnames);
        covtab = rmmissing(covtab);
        [fp.p, fp.name, fp.ext] = fileparts(txtfile);
        outputname = fullfile(fp.p, [fp.name, '_AddCov2', fp.ext]);
        writetable(covtab, outputname, 'Delimiter', 'space', 'WriteVariableNames', false)
            % Generate a new file with paths after removal of subjects
        complete_cases = rmmissing(covs);
        complete_cases = complete_cases{:,2};
        writecell(complete_cases, fullfile('/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data', cons{c}, 'imgs__delta_clincorr_AddCov2.txt'));
        complete_cases_ba = strrep(complete_cases, 'ses-Diff', 'COMPLETE_ses-Visit1');
        complete_cases_ba = strrep(complete_cases_ba, 'ses-POMVisitDiff', 'ses-POMVisit1');
        writecell(complete_cases_ba, fullfile('/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data', cons{c}, 'imgs__ba_clincorr_AddCov2.txt'));
        
    end

end