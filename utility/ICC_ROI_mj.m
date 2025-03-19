%Add relevant paths
addpath('/home/common/matlab/spm12');
addpath('/opt/freesurfer/7.3.2/matlab')

%Directories
projectdir = '/project/3024006.02/Analyses/motor_task/Group/';
roidir = fullfile(projectdir,'ROI');
savedir = fullfile('/project/3024006.02/Analyses/motor_task/Group/con_0010/ICC');
con = 'con_0010';
firstlvldir1 = fullfile(projectdir, con,'COMPLETE_ses-Visit1');
firstlvldir2 = fullfile(projectdir, con,'COMPLETE_ses-Visit2');
Sub = extractBefore(cellstr(spm_select('List', firstlvldir1, '.*sub-POM.*')), '_ses');

%ROI overview
ROI_1 = fullfile('/project/3024006.02/Analyses/motor_task/Group/con_0010/ICC/ROI/x_HCgtPD_Mean_Mask.nii');

%Choose ROI for analysis
ROI_choice = ROI_1; savename = ('HCgtPD_Mean');

%Load the ROI
ROI = MRIread(ROI_choice);
[aa,bb,cc] = size(ROI.vol);
ROI_v = reshape(ROI.vol,aa*bb*cc,1)';
ROI_inx = find(ROI_v > 0);

%Load contrast images
con_v_all = [];
for i = 1:numel(Sub)
    
    % Read MRI
    disp(Sub{i})
    con_a = MRIread(spm_select('FPList', firstlvldir1, [Sub{i} '.*']));
    con_b = MRIread(spm_select('FPList', firstlvldir2, [Sub{i} '.*']));
    
    %Vectorize the contrast image
    [aa,bb,cc,tt] = size(con_a.vol);
    con_a_v = reshape(con_a.vol, aa*bb*cc,tt)';
    con_a_v_mean = mean(con_a_v(:,ROI_inx),2);
    [aa,bb,cc,tt] = size(con_b.vol);
    con_b_v = reshape(con_b.vol, aa*bb*cc,tt)';
    con_b_v_mean = mean(con_b_v(:,ROI_inx),2);
    
    % Save
    con_v_all{i,1} = con_a_v;
    con_v_all{i,2} = con_b_v;
    con_v_all{i,3} = con_a_v_mean;
    con_v_all{i,4} = con_b_v_mean;
    
    clear con_a; clear con_a_v; clear con_b; clear con_b_v; clear con_a_v_mean; clear con_b_v_mean
    
end

%Loop over all voxels within the ROI and calculate ICC per voxel
newnii = ROI;
newniicorr = ROI;
newniip = ROI;
newniicorrp = ROI;
clear ROI 
Mtrx = [];
for k = 1:size(con_v_all{1,1},2)
    disp(k);
    if ROI_v(k) == 0
        nii_v(k) = 0;
        nii_v_p(k) = 0;
        niicorr_v(k) = 0;
        niicorr_v_p(k) = 0;
    else
        j = size(Mtrx,1)+1;
        for i = 1:numel(Sub)
            Mtrx{j,1}(i,1) = con_v_all{i,1}(k);
            Mtrx{j,1}(i,2) = con_v_all{i,2}(k);
        end
        [r, LB, UB, F, df1, df2, p] = ICC(Mtrx{j}, 'C-1', 0.05, 0);
        [rho,pval] = corr(Mtrx{j,1}(:,1),Mtrx{j,1}(:,2),'Type','Spearman');
%         if p<=0.05
%             niicorr_v(1,k) = r;
%         else
%             niicorr_v(1,k) = NaN;
%         end
        nii_v(1,k) = r;
        nii_v_p(1,k) = p;
        niicorr_v(1,k) = rho;
        niicorr_v_p(1,k) = pval;
        
    end
end
newnii.vol = reshape(nii_v',aa,bb,cc,1);
newniip.vol = reshape(nii_v_p',aa,bb,cc,1);
newniicorr.vol = reshape(niicorr_v',aa,bb,cc,1);
newniicorrp.vol = reshape(niicorr_v_p',aa,bb,cc,1);

%Save new volume
cd(savedir);
MRIwrite(newnii,fullfile(savedir,strcat('ICC_',savename,'.nii.gz')));
MRIwrite(newniip,fullfile(savedir,strcat('ICC_',savename,'_p.nii.gz')));
MRIwrite(newniicorr,fullfile(savedir,strcat('CORR_',savename,'.nii.gz')));
MRIwrite(newniicorrp,fullfile(savedir,strcat('CORR_',savename,'_p.nii.gz')));