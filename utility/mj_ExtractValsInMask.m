% ExtractValsInMask.m
% M.E. Johansson, Feb 2024
% 
% Description:
% Mask an image and extract values
% img       Nifti or list of file paths
% mask      Nifti, index-mask, values starting from 1
% 
% Example: 
%   img = '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/con_0007/imgs__delta_clincorr.txt';
%   img_type = 'FPList'; % 'Concat'
%   mask = '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/Oxford-Imanova_putamen.nii';
%   vals = ExtractValsInMask(img, img_type, mask);
% 

function [vals, subjects] = mj_ExtractValsInMask(img, img_type, mask)

if strcmp(img_type, 'Concat')
    fprintf(">>> Processing concatenated 4d Nifti file\n");
    img_info = struct();
    [img_info.fp, img_info.name, img_info.ext] = fileparts(img);
    if contains(img_info.ext, '.gz')
        fprintf(">>> Unzipping input file\n");
        gunzip([fullfile(img_info.fp, img_info.name), img_info.ext])
        img_use = fullfile(img_info.fp, img_info.name);
    end
    subjects = [];
elseif strcmp(img_type, 'FPList')
    fprintf(">>> Processing list of file paths\n")
    opts = delimitedTextImportOptions("NumVariables", 1);
    opts.VariableNamesLine = 1;
    opts.VariableTypes = ["char"];
    opts.DataLines = [1 Inf];
    opts.Delimiter = {'\t'};
    img_use = table2cell(readtable(img,opts))';
    subjects = extractBetween(img_use, 'PD_POM_', '_ses-POM')';
else
    msg = ">>> ERROR: List option not found, exiting...";
    error(msg)
end

IdxMask = spm_atlas('load', mask);

row = [];
fprintf('>>> Processing %i mask label\n', numel(IdxMask.labels))
for i = 1:numel(IdxMask.labels)
    if i == 1
        fprintf('>>> Skipping mask label %s, assumed to be background\n', IdxMask.labels(i).name)
        continue
    end
    fprintf('>>> Processing mask label %s\n', IdxMask.labels(i).name)
    d = [];
    d = spm_summarise(img_use', spm_atlas('mask',IdxMask,IdxMask.labels(i).index), @mean);
    row = [row, d];
end

vals = row;

end