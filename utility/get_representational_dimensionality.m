function get_rd(inputdir, masks)

if(nargin<1)
    inputdir = '/home/sysneu/marjoh/GLMsingle/matlab/examples/exampleSPMoutput/MotorTask3';
    masks.name = {'HCgtPD_Mean'};
    masks.file = {'/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_HCgtPD_Mean_Mask.nii'};
end

% get_rd.m
% % USAGE %
% inputdir : directory containing GLMsingle output from a single subject
%
% masks : struct containing (1) cell vector of paths to mask ROIs and (2)
% cell vector of ROI names
%
% output : CSV file with names-by-RD
% % - %

current_dir = pwd;
cd(inputdir)

% Design and betas
design = load('DESIGNINFO.mat');
model_output = load('TYPEC_FITHRF_GLMDENOISE.mat');
imgdim = size(model_output.meanvol);
ntrials = size(model_output.modelmd,4);
betas = model_output.modelmd;

% Initialize output table
varnames = {'roi' 'stimulus' 'rd_eig', 'V', 'rd_var', 'rd_eff'};
tab = cell2table(cell(0,6), 'VariableNames', varnames);

% Loop over ROIs
for m = 1:length(masks.file)
    
    mask_info = spm_atlas('load', masks.file{m}); %https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;d4de8f88.1704
    
    for i = 2:length(mask_info.labels)  % Skip idx where mask == 0
        
        Y = spm_read_vols(spm_vol(masks.file{m}),1);      % Load mask
        Y = reshape(Y, imgdim(1)*imgdim(2)*imgdim(3), 1);
        mask_idx = find(Y==i-1);
        
        roi_label = [masks.name{m} '_' num2str(i-1)];
        
        % Assembles betas
        betas = reshape(betas, imgdim(1)*imgdim(2)*imgdim(3), ntrials);
        betas_masked = betas(mask_idx,:);
        
        % Stimulus label
        mn = struct();
        mn(1).stimulus = "AllTrials";
        mn(2).stimulus = "NChoice1";
        mn(3).stimulus = "NChoice2";
        mn(4).stimulus = "NChoice3";
        
        % Voxels x Trials matrix   
        mn(1).betas = betas_masked;
        mn(2).betas = betas_masked(:,design.stimorder==1);
        mn(3).betas = betas_masked(:,design.stimorder==2);
        mn(4).betas = betas_masked(:,design.stimorder==3);
        
        % Average beta
        mn(1).betas_avg = mean(mn(1).betas,2);
        mn(2).betas_avg = mean(mn(2).betas,2);
        mn(3).betas_avg = mean(mn(3).betas,2);
        mn(4).betas_avg = mean(mn(4).betas,2);
        
        % Demean rows
        mn(1).betas_dm = mn(1).betas - mean(mn(1).betas,2);
        mn(2).betas_dm = mn(2).betas - mean(mn(2).betas,2);
        mn(3).betas_dm = mn(3).betas - mean(mn(3).betas,2);
        mn(4).betas_dm = mn(4).betas - mean(mn(4).betas,2);
  
        % Correlation matrices
        mn(1).corrmat = corrcoef(mn(1).betas_dm);
        mn(2).corrmat = corrcoef(mn(2).betas_dm);
        mn(3).corrmat = corrcoef(mn(3).betas_dm);
        mn(4).corrmat = corrcoef(mn(4).betas_dm);
        
        % Do PCA
        [mn(1).coef, mn(1).lat, mn(1).exp] = pcacov(mn(1).corrmat);
        [mn(2).coef, mn(2).lat, mn(2).exp] = pcacov(mn(2).corrmat);
        [mn(3).coef, mn(3).lat, mn(3).exp] = pcacov(mn(3).corrmat);
        [mn(4).coef, mn(4).lat, mn(4).exp] = pcacov(mn(4).corrmat);

        % Get RD
        for stim = 1:length(mn)
            
            clear k1 k2
            k1 = find(mn(stim).lat>=1);
            k2 = find(cumsum(mn(stim).exp) < 90);
            mn(stim).V = sum(mn(stim).exp(k1));
            mn(stim).rd_eig = length(k1);       % Eigenvars above 1
            mn(stim).rd_var = length(k2);       % Egenvars explaining %90 variance
            mn(stim).rd_eff = mn(stim).rd_eig / mn(stim).V;
            
            mn(stim).roi = string(roi_label);
            
        end
        
        % Append
        tmp = struct2table(mn);
        tmp = tmp(:,["roi", "stimulus", "rd_eig","V","rd_var","rd_eff"]);
        tab = [tab;tmp];

    end
    
end

% Write to file
writetable(tab, 'RD.csv')

cd(current_dir)

end
