function mj_DCM_param_extract(name, conf)

%--------------------------------------------------------------------------
% mj_DCM_param_extract
% 20241126 - Martin E. Johansson
%
% Extract DCM matrices for each row in an estimated GCM and write to csv
% file. Column names will be generic, identifying type of matrix (A,B,C)
% and the row/column indices from which parameters were extracted. Consult
% the original DCM for more detailed names.
%--------------------------------------------------------------------------

% Load GCM
dcmtype = [conf.par_ex.dcmname,'_PEB-', num2str(conf.par_ex.peb)];
gcms_mat       = spm_select('FPList',conf.par_ex.gcmdir,['^GCM_',name,'_',dcmtype,'.mat']);
gcms_txt       = spm_select('FPList',conf.par_ex.gcmdir,['^GCM_',name,'_',dcmtype,'.txt']);
load(gcms_mat,'GCM');
% Load GCM labels (pseudonym and session id)
GCM_labels = readtable(gcms_txt);

% Extract estimated parameters from DCM matrices
par_tab = [];
for i = 1:size(GCM,1)
    
    clear lab A B C DCM_par
    
    lab = GCM_labels(i,:);
    
    % Parameter estimates
    try
        A = tabularize(GCM{i,1}.Ep.A,'A');
    catch
        warning('Problem tabularizing A, assigning value of 0')
        A = [];
    end
    try
        B = tabularize(GCM{i,1}.Ep.B(:,:,2),'B');
    catch
        warning('Problem tabularizing B, assigning empty.')
        B = table();
    end
    try
        C = tabularize(GCM{i,1}.Ep.C,'C');
    catch
        warning('Problem tabularizing C, assigning empty.')
        C = table();
    end
    DCM_par = horzcat(lab,A,B,C);
    
    % Probabilities
    % TO DO
    
    par_tab = [par_tab; DCM_par];
    
end

% Write to file
ses = extractBetween(gcms_mat, 'GCM_ses-', '.mat');
filename = char(strcat('DCMpar_ses-', ses, '.csv'));
writetable(par_tab, fullfile(conf.par_ex.outputdir, filename))


% Turn a DCM matrix (EPp.A, EP.B, EP.C) into a named table
function [M_tab] = tabularize(M,type)
    % Names of parameters
    [rows, cols] = ndgrid(1:size(M,1), 1:size(M,2));
    indexStrings = arrayfun(@(r, c) sprintf('To%d_From%d', r, c), rows, cols, 'UniformOutput', false);
    indexStringsVector = reshape(indexStrings, [], 1);
    M_names = strcat(type, '_', indexStringsVector);
    % Values of parameters
    M_vals = reshape(M,1,[]);
%     M_vals = round(M_vals,10);
    % Table
    M_tab = array2table(M_vals, 'VariableNames', M_names);
    

