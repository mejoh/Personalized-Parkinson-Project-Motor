% Summarise 1st-level beta values in significant clusters
% Depends on the ExtractClusters.sh script
% 1st-level images are those that were used as inputs for 3dLME/3dttest++
% These images are concatenated and used to extract stats with idx masks
% Cluster index masks are loaded using spm_atlas
% spm_summarise extracts the average beta within each cluster
% Averages are appended to the datatable that was used as input in group
% comparisons

function ExtractBetas(dir,con)

if nargin<1
    dir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dLME_disease';
%     dir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dttest++_severity';
    con = 'con_0010';
end

dStats =  fullfile(dir, 'stats');

% Find cluster index masks
% Exit if none are found
if exist(spm_select('FPList',dStats, [con '.*idxmask.nii']),'file')
    msg = ['Masks found for search pattern ' [con '.*idxmask.nii'] '\n'];
    fprintf(msg)
    Masks = cellstr(spm_select('FPList',dStats, [con '.*idxmask.nii']));  % Find cluster index masks
else
    msg = ['No masks found for search pattern ' [con '.*idxmask.nii'] ', moving on...\n'];
    fprintf(msg)
    return
end
%Masks = {'/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/x_BG-dysfunc_and_parietal-comp_subset.nii'};

% Load data table and concatenate betas
if(contains(dir,'3dttest++'))
    fname_dataTable = spm_select('FPList', dir, [con '.*covars.txt']);
    if(size(fname_dataTable,1)>1)
        msg = strcat('Error: More than one dataTable found in ', dir);
        error(msg)
    end
    opts = delimitedTextImportOptions("NumVariables", 4);
    opts.VariableNamesLine = 1;
    opts.VariableTypes = ["char", "double", "double", "char"];
    opts.DataLines = [2 Inf];
    opts.Delimiter = {'\t'};
    dataTable = readtable(fname_dataTable,opts);     % input table
    dataTable.InputFile = strrep(dataTable.voxelwiseBA,'Visit1','Diff');
    dataTable.InputFile = strrep(dataTable.InputFile,'POMDiff','POMVisitDiff');
    dataTable.InputFile = strrep(dataTable.InputFile,'PITDiff','PITVisitDiff');
    spm_file_merge(dataTable.InputFile, fullfile(dStats, '4d_Cons_Delta'))    % Concatenate 1st-level contrasts
    spm_file_merge(dataTable.voxelwiseBA, fullfile(dStats, '4d_Cons_BA'))    % Concatenate 1st-level contrasts
    ConcatImg = spm_select('FPList', dStats, '4d_Cons_Delta.nii');
    BaselineImg = spm_select('FPList', dStats, '4d_Cons_BA.nii');
elseif(contains(dir,'3dLME_subtype'))
    comp = char(extractBetween(con,'con_combined_','_x_'));
    tname = ['con_combined_disease_' comp '_dataTable.txt'];
    fname_dataTable = spm_select('FPList', dir, tname);
    if(size(fname_dataTable,1)>1)
        msg = strcat('Error: More than one dataTable found in ', dir);
        error(msg)
    end
    dataTable = readtable(fname_dataTable);     % input table
    spm_file_merge(dataTable.InputFile, fullfile(dStats, '4d_Cons'))    % Concatenate 1st-level contrasts
    ConcatImg = spm_select('FPList', dStats, '4d_Cons.nii');
elseif(contains(dir,'3dLME_disease'))
    tname = 'con_combined_disease_dataTable.txt';
    fname_dataTable = spm_select('FPList', dir, tname);
    if(size(fname_dataTable,1)>1)
        msg = strcat('Error: More than one dataTable found in ', dir);
        error(msg)
    end
    dataTable = readtable(fname_dataTable);     % input table
    spm_file_merge(dataTable.InputFile, fullfile(dStats, '4d_Cons'))    % Concatenate 1st-level contrasts
    ConcatImg = spm_select('FPList', dStats, '4d_Cons.nii');
end

for m = 1:numel(Masks)
    % For each value in each cluster index mask, extract the average beta
    % estimate and append it to the 3dLME input table
    IdxMask = spm_atlas('load', Masks{m}); %https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;d4de8f88.1704
    for i = 2:numel(IdxMask.labels) % Note that labels include 0, which is the background. Therefore, skip first label
        clear d
        if(contains(dir,'3dttest++'))
            d = spm_summarise(ConcatImg, spm_atlas('mask',IdxMask,IdxMask.labels(i).index), @mean);
            b = spm_summarise(BaselineImg, spm_atlas('mask',IdxMask,IdxMask.labels(i).index), @mean);
            d = round(d,5);
            b = round(b,5);
            colname = erase(IdxMask.info.name, {'_idxmask'});
            colname1 = {[colname '_cid' num2str(IdxMask.labels(i).index)]};
            colname2 = {[colname '_ba_cid' num2str(IdxMask.labels(i).index)]};
            d = [table(d,'VariableNames',colname1),table(b,'VariableNames',colname2)];
        else
            d = spm_summarise(ConcatImg, spm_atlas('mask',IdxMask,IdxMask.labels(i).index), @mean);
            d = round(d,5);
            colname = erase(IdxMask.info.name, {'_idxmask' '_x_' 'Group2' 'TimepointNr2-poly1' 'Type3'});
            colname = {[colname '_cid' num2str(IdxMask.labels(i).index)]};
            d = table(d,'VariableNames',colname);
        end
        dataTable = [dataTable,d];
    end
end
outputname = fullfile(dStats, [con '_dataTable_' date '.txt']);
writetable(dataTable, outputname)

% Binary mask of all contrast images
% Used to reslice the mask_ICV.nii mask
% ci = ConcatImg;
% co = fullfile('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks', '3dLME_4dConsMask.nii');
% spm_imcalc(ci, co, '(i1.^2) > 0');

if exist(ConcatImg,'file')
    delete(ConcatImg)
end

if(contains(dir,'3dttest++'))
    if exist(BaselineImg,'file')
        delete(BaselineImg)
    end
end

end