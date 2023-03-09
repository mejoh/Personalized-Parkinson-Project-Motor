% motor_ROI_BetaExtraction(COI, AOI)
% Extract average betas and principal components from ROIs.
% The ROIs are defined by index masks.

function motor_ROI_BetaExtraction(COI, AOI, DoPCA)

if nargin < 1
    COI = 'con_combined'; % 'con_0010' or 'con_0012' or 'con_0013' or 'con_combined'
    AOI = 'severity'; % 'severity-poly1' or 'disease-poly1'
    DoPCA = false;
end

dInput = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI';
dOutput = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI_BetaExtraction';
dMask = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks';

ftab = spm_select('FPList', dInput, [COI '_' AOI '_dataTable.txt']);        % Import AFNI-style table and set options
opts = detectImportOptions(ftab);
opts.VariableNamesLine = 1;
opts.DataLines = [2 Inf];
opts.Delimiter = {'\t'};
tab = readtable(ftab, opts);
tab = rmmissing(tab,2);
% if(contains(AOI,'poly1'))
%     tab = removevars(tab,{'MeanFD'});
% else
%     tab = removevars(tab,{'voxelwiseBA' 'MeanFD'});
% end
spm_file_merge(tab.InputFile, fullfile(dOutput, [COI '_' AOI '_4d_Cons']))    % Concatenate 1st-level output found in table
img = spm_select('FPList', dOutput, [COI '_' AOI '_4d_Cons.nii']);
mask = cellstr(spm_select('FPList', dMask, '^x_.*.nii$'));

f = spm_vol(img);
for m = 1:numel(mask)
    IdxMask = spm_atlas('load', mask{m}); %https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;d4de8f88.1704
    for i = 2:numel(IdxMask.labels) % Note that labels include 0 (i.e. IdxMask.labels==1), which is the background. Therefore, skip first label
        
%         clear d tab2 PCA
%         tab2 = tab;
%         d = spm_summarise(f, spm_atlas('mask',IdxMask,IdxMask.labels(i).index), @mean);
%         d = table(d,'VariableNames',{[erase(IdxMask.info.name,'_idxmask') '_cid' num2str(IdxMask.labels(i).index) '-mean']});
%         tab2 = [tab2,d];
        
        clear Y idx x y z XYZ est_full PCA est_mean d tname parts
        Y = spm_read_vols(spm_vol(mask{m}),1);      % Load mask
        idx = find(Y==i-1);                         % Find voxels corresponding to ROI (-1 because ids start at 0, mask labels do not)
        [x,y,z] = ind2sub(size(Y),idx);             % Determine coordinates of voxels
        XYZ = [x y z]';
        est_full = spm_get_data(f,XYZ);             % Extract betas (Subject by voxel array)
        est_mean = mean(est_full,2,'omitnan');      % Take the mean for each subject. This will basically be the same as the first PCA component.
        if istrue(DoPCA)
            [PCA.coeff,PCA.score,PCA.latent,PCA.t2,PCA.explained] = pca(est_full, 'Algorithm', 'als');  % Dimension reduction through PCA. Scores represent components that explain variability in betas in an ROI. 'als' algorithm deals with missing values.
            PCA.explained = round(PCA.explained);
            d = array2table([PCA.score(:,1:3),est_mean]);           % Generate tab containing 3 comps that explain most variance in ROI and the average
            tname = {[erase(IdxMask.info.name,{'x_' '_Mask'}) '_cid' num2str(IdxMask.labels(i).index)]};
            parts = {['_PCA1_exp' num2str(PCA.explained(1))] ['_PCA2_exp' num2str(PCA.explained(2))] ['_PCA3_exp' num2str(PCA.explained(3))] '_Mean'};
        else
            d = array2table(est_mean);           % Generate tab containing 3 comps that explain most variance in ROI and the average
            tname = {[erase(IdxMask.info.name,{'x_' '_Mask'}) '_cid' num2str(IdxMask.labels(i).index)]};
            parts = {'_Mean'};
        end
        d.Properties.VariableNames = strcat(tname, parts);
        
        tab = [tab,d];
        
    end
end
outputname = fullfile(dOutput, [[COI '_' AOI '_'] date '_dataTable.txt']);
writetable(tab, outputname)
delete(img)

end