% Images to summarize
% ImageList = {'con_0001' 'con_0002' 'con_0003' 'ResMS'};
ImageList = {'con_0001' 'con_0002'};

% Generate a histogram of image intensities for each subject
% Generate a boxplot + histogram of image intensities for the whole group
% Generate a textfile containing image intensities and outlier classification
for i = 1:numel(ImageList)
    
    img = ImageList{i};
    ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
    OutputDir = fullfile('/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC', img, '/');
    % Start with clean directory
    if ~exist(OutputDir, 'dir')
        mkdir(OutputDir);
    else
        delete(fullfile(OutputDir, '*.*'));
    end
    
    % Subject list
    Sub = cellstr(spm_select('List', fullfile(ANALYSESDir), 'dir', '^sub-POM.*'));
    fprintf('Number of subjects processed: %i\n', numel(Sub))
    SubInfo.Sub = {};
    SubInfo.Visit = {};
    SubInfo.GrandMean = [];
    Counter = 1;
    % Generate histogram of image intensities
    for n = 1:numel(Sub)
        Visit = cellstr(spm_select('List', fullfile(ANALYSESDir, Sub{n}), 'dir', 'ses-Visit1*'));
        for v = 1:numel(Visit)
            ContrastImage = spm_select('FPList', fullfile(ANALYSESDir, Sub{n}, Visit{v}, '1st_level'), [img '.nii']);
            if exist(ContrastImage, 'file')
                [G, S, V] = DistributionMean_1stlevelCon(ContrastImage, OutputDir);     % Store subject information
                SubInfo.Sub{Counter} = S;
                SubInfo.Visit{Counter} = V;
                SubInfo.GrandMean(Counter) = G;
                Counter = Counter + 1;
            end
        end
    end

    % Define outliers as +-IQR*2
    m = mean(SubInfo.GrandMean);
    lower = m - iqr(SubInfo.GrandMean)*2;
    upper = m + iqr(SubInfo.GrandMean)*2;
    SubInfo.Outlier = false(size(SubInfo.GrandMean));
    for n = 1:length(SubInfo.Outlier)
        if SubInfo.GrandMean(n) < lower || SubInfo.GrandMean(n) > upper
            SubInfo.Outlier(n) = true;
        end
    end

    % Boxplot of grand means
    figure
    subplot(1,2,1)
    boxplot(SubInfo.GrandMean)
    subplot(1,2,2)
    histogram(SubInfo.GrandMean, 100)
    sgtitle('Grand mean intensity per subject')
    saveas(gcf, fullfile(OutputDir, 'Group.png'))
    close(gcf)
    
    % Textfile of subject information
    SubInfo.Sub = SubInfo.Sub';
    SubInfo.Visit = SubInfo.Visit';
    SubInfo.GrandMean = SubInfo.GrandMean';
    SubInfo.Outlier = SubInfo.Outlier';
    SubInfoTable = struct2table(SubInfo);
    writetable(SubInfoTable, sprintf('%s/Group.txt', OutputDir))
    
end

