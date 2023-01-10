% Summarise 1st-level beta values in significant clusters
% Depends on the ExtractClusters.sh script
% 1st-level images are those that were used as inputs for 3dLME
% Images are concatenated
% Cluster index masks are loaded using spm_atlas
% spm_summarise extracts the average beta within each cluster
% Averages are appended to the datatable that was used as input in 3dLME

function ExtractBetas(dir)

if nargin<1
    dir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dLME_severity';
end

dStats =  fullfile(dir, 'stats');
fname_dataTable = spm_select('FPList', dir, '.*dataTable.txt');
if(size(fname_dataTable,1)>1)
    msg = strcat('Error: More than one dataTable found in ', dir);
    error(msg)
end
dataTable = readtable(fname_dataTable);     % 3dLME input table
spm_file_merge(dataTable.InputFile, fullfile(dStats, '4d_Cons'))    % Concatenate 1st-level contrasts
ConcatImg = spm_select('FPList', dStats, '4d_Cons.nii');
Masks = cellstr(spm_select('FPList',dStats, '.*idxmask.nii'));  % Find cluster index masks

for m = 1:numel(Masks)
    % For each value in each cluster index mask, extract the average beta
    % estimate and append it to the 3dLME input table
    IdxMask = spm_atlas('load', Masks{m}); %https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;d4de8f88.1704
    for i = 2:numel(IdxMask.labels) % Note that labels include 0, which is the background. Therefore, skip first label
        clear d
        d = spm_summarise(ConcatImg, spm_atlas('mask',IdxMask,IdxMask.labels(i).index), @mean);
        d = table(d,'VariableNames',{[erase(IdxMask.info.name,'_idxmask') '_cid' num2str(IdxMask.labels(i).index)]});
        dataTable = [dataTable,d];
    end
end
outputname = fullfile(dStats, ['dataTable_' date '.txt']);
writetable(dataTable, outputname)

% Binary mask of all contrast images
% Used to reslice the mask_ICV.nii mask
% ci = ConcatImg;
% co = fullfile('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks', '3dLME_4dConsMask.nii');
% spm_imcalc(ci, co, '(i1.^2) > 0');
delete(ConcatImg)

end