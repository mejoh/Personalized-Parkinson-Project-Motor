% mj_InsertColumnInTxtFile.m
% M.E. Johansson, Feb 2024
%
% Description:
% Inserts a column of values into a text file. Pre-existing columns with
% names corresponding to the function input will be removed. This makes it
% possible to add new columns or to rewrite old ones.
%
% Example: 
% 
% txtfile= '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/con_0007/covs__delta_clincorr_all.txt';
% cols = round(vals,3);
% colnames = {'Putamen_Delta'};
% mj_InsertColumnInTxtFile(txtfile, cols, colnames)

function tab = mj_InsertColumnInTxtFile(txtfile, cols, colnames) %, suffix, delimiter)

    old_tab = readtable(txtfile);
    filter_cols = ~matches(old_tab.Properties.VariableNames, colnames);
    old_tab = old_tab(:,filter_cols);
    
    new_cols = array2table(cols);
    new_cols.Properties.VariableNames = colnames;
    tab = [old_tab, new_cols];
    
%     [fp.p, fp.name, fp.ext] = fileparts(txtfile);
%     fp.name = [fp.name, '_Edit'];
%     outputname = fullfile(fp.p, [fp.name, suffix, fp.ext]);
%     writetable(tab, outputname, 'Delimiter', delimiter)

end
