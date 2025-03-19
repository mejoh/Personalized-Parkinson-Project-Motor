close all;

output.dir = '/project/3011164.01/2_Uitvoer/Data/Processing/MRI/2_Analysis/zscorePmod_6mmSmooth_noGS_inclmotion_3Fcontrasts/3_DCM_models/Bayesian Model Selection/onestate_Fall';
BMS_file = fullfile(output.dir,'BMS.mat');
load(BMS_file)
node_names = {'BA4','Thal','CBL','GPi'};
connect_names = {
'BA4-BA4','Thal-BA4','CBL-BA4','GPi-BA4'
'BA4-Thal','Thal-->Thal','CBL-->Thal','GPi-Thal'
'BA4-CBL','Thal-CBL','CBL-CBL','GPi-CBL'
'BA4-GPi','Thal-GPi','CBL-GPi','GPi-GPi'
};

addpath('/home/action/frenie/Persoonlijk Post-Doc/Github-scripts/Additionals/MatlabGraphs-master');
%% figure all models
figure('units','normalized','outerposition',[0 0 1 1]);
ax(1) = subplot(2,1,1);
plot(BMS.DCM.rfx.model.exp_r)
ylabel('expected posterior probability');
ax(2) = subplot(2,1,2);
plot(BMS.DCM.rfx.model.xp)
ylabel('exceedance probability');
linkaxes(ax(:),'xy')

figure('units','normalized','outerposition',[0 0 1 1]);
[sorted,index] = sort(BMS.DCM.rfx.model.exp_r);
bar(1:31,sorted(end-30:end))
title('Models sorted on exceedance probability (top 31)')
xlabel('model number');
ylabel('exceedance probability');
set(gca,'XTick',[1:31],'XTickLabel',cellfun(@num2str,num2cell(index(end-30:end)),'un',0));
% txt = {'BA4 1:2048';'Thal 2049:4096';'CBL 4097:6144';'GPi 6145:8192'};
% text(2,0.03,txt);

%% figure model families
figure('units','normalized','outerposition',[0 0 0.5 1]);
ax(1) = subplot(2,1,1);
bar(BMS.DCM.rfx.family.exp_r)
ylabel('expected posterior probability');
xticklabels(strrep(BMS.DCM.rfx.family.names,'_','-'));
ax(2) = subplot(2,1,2);
bar(BMS.DCM.rfx.family.xp)
ylabel('exceedance probability');
xticklabels(strrep(BMS.DCM.rfx.family.names,'_','-'));
linkaxes(ax(:),'xy');

%% Average parameters
%DCM.a, check direction
DCMa = BMS.DCM.rfx.bma.mEp.A;
names = node_names';
DCMatable_mean = table(names,DCMa(:,1),DCMa(:,2),DCMa(:,3),DCMa(:,4));
DCMatable_mean.Properties.VariableNames = horzcat({'names'},node_names);
DCMatable_mean
DCMatable_std = table(names,BMS.DCM.rfx.bma.sEp.A(:,1),BMS.DCM.rfx.bma.sEp.A(:,2),BMS.DCM.rfx.bma.sEp.A(:,3),BMS.DCM.rfx.bma.sEp.A(:,4));
DCMatable_std.Properties.VariableNames = horzcat({'names'},node_names);
DCMatable_std

%DCM.b and DCM.a, check significance
for sb=1:numel(BMS.DCM.rfx.bma.mEps)
    DCMb_subjects(:,:,sb) = BMS.DCM.rfx.bma.mEps{sb}.B(:,:,1);
    DCMa_subjects(:,:,sb) = BMS.DCM.rfx.bma.mEps{sb}.A;
end
% DCMb_subjects(DCMb_subjects == 0) = NaN; %ignores models not in occams window 
for r = 1:4
    for c = 1:4
        [DCMb_sign(r,c),DCMb_pval(r,c),~,DCMb_tstat{r,c}] = ttest(DCMb_subjects(r,c,:),0);
        [DCMa_sign(r,c),DCMa_pval(r,c)] = ttest(DCMa_subjects(r,c,:),0);
    end
end
DCMa_pval
DCMb.mean = BMS.DCM.rfx.bma.mEp.B(:,:,1);DCMb.std = BMS.DCM.rfx.bma.sEp.B(:,:,1);
% DCMb.mean(find(DCMb_sign~=1))= NaN; DCMb.std(find(DCMb_sign~=1))= NaN;
% DCMb.mean(find(DCMb_sign==1)) = DCMb_mean(DCMb_sign==1);DCMb.std(DCMb_sign==1) = DCMb_std(DCMb_sign==1);
DCMbtable_mean = table(names,DCMb.mean(:,1),DCMb.mean(:,2),DCMb.mean(:,3),DCMb.mean(:,4));
DCMbtable_mean.Properties.VariableNames = horzcat({'names'},node_names);DCMbtable_mean
DCMbtable_std = table(names,DCMb.std(:,1),DCMb.std(:,2),DCMb.std(:,3),DCMb.std(:,4));
DCMbtable_std.Properties.VariableNames = horzcat({'names'},node_names);DCMbtable_std
DCMb_pval

% Extract for correlation
ind.template = reshape(1:16,4,4);
ind.sign = find(DCMb_sign==1);
for s=1:numel(ind.sign)
    [r,c] = find(ind.template == ind.sign(s));
    DCMbsign(:,s) = squeeze(DCMb_subjects(r,c,:));
end
% DCMbsign(DCMbsign==0) = NaN;
if numel(ind.sign)~=0 
    fprintf(' Index %2.0f has a significant DCMb\n', ind.sign);
    DCMsign_subjectvalues = table(DCMbsign)
else
    fprintf('No significant DCMb\n')
    
end

pvals = DCMb_pval(~isnan(DCMb_pval));
csvwrite(fullfile(output.dir,'DCMb_pvalues.txt'),pvals) 

%% extract model diagnoses
try load(fullfile(output.dir,'diagnostics_DCMcBA4models.mat'))
    
    for m=1:size(diagnostics_output.diagsummary,2)
        variance_exp(m,1) = diagnostics_output.diagsummary(m).mean(1);
    end
    sorted = sort(variance_exp, 'descend');
    fprintf('\nVariance explained by 5 models that explain most: \n %2.2f %% \n %2.2f %% \n %2.2f %% \n %2.2f %% \n %2.2f %% \n',sorted(1:5)' );  
catch
    fprintf('\nModel diagnosing not yet done or wrong filename given \n');
end

%% Plot paper figures
%Family selection DCMc
figure();
bar(BMS.DCM.rfx.family.xp,'k')
ylabel('Exceedance probability');
ylab = strrep(BMS.DCM.rfx.family.names,'DCMc_','');
ylab = strrep(ylab,'amus','');
xticklabels(ylab);
linkaxes(ax(:),'xy');
ylim([0 1]);
ytickformat('%.1f');
box off;

% DCMb parameters
lbl.jerkycolor = [1 0 0];
lbl.jerky = [
0
0
0
0
0
0
0
0
0
0
0
0
0
1
1
0
0
1
0
1
0
0
0
0
0
0
0 
];
lbl.jerky = logical(lbl.jerky);

lbl.image_size = [8 8];
lbl.setText.titleText = '';
lbl.setText.xLabels = connect_names([6 10])' ; % (name xType for each colum)
lbl.setText.hYLabel = 'DCM.B (Tremor amplitude)';
lbl.MarkerSize = 4;
lbl.lines =false;
% lbl.yAxis = [0 0.25];
lbl.colorSpec = {[0 0 0;0 0 0]};
inData = {DCMbsign(:,3:4)};
avn_plotBarScatter_fnadjusted(inData,lbl);
set(gcf,'color','w');
ytickformat('%.0f');

figure()
[R,p] = corrcoef(inData{1}(:,1),inData{1}(:,2));
plot(inData{1}(:,1),inData{1}(:,2),'k.','MarkerSize',15);
hl = lsline;
xlabel('DCM.B Thal-->Thal');
ylabel('DCM.B CBL-->Thal');
fprintf('\n R=%4.3f p=%4.3f \n',R(2,1),p(2,1));
