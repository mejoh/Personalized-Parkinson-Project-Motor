% DistributionMean_1stlevelCon
% Takes a contrast image as its input (i.e. 'ContrastImage').
% Generates a histogram of beta values and prints to 'OutputDir'
function [GrandMean, Sub, Visit] = DistributionMean_1stlevelCon(ContrastImage, OutputDir)

    Input = ContrastImage;
    Sub = cell2mat(extractBetween(Input, 'sub-', '/ses'));
    Visit = cell2mat(extractBetween(Input, '/ses-', '/1st_level'));
    Hdr = spm_vol(Input);
    Vol = spm_read_vols(Hdr);
    VolDim = Hdr.dim;
    NrVoxels = VolDim(1) * VolDim(2) * VolDim(3);
    beta = zeros(1, NrVoxels);
    Count = 1;
    for x = 1:VolDim(1)
        for y = 1:VolDim(2)
            for z = 1:VolDim(3)
                beta(Count) = Vol(x,y,z);
                Count = Count + 1;
            end
        end
    end
    beta = rmmissing(beta);
    GrandMean = mean(beta);
    
    figure('visible','off')
    subplot(1,1,1)
    histogram(beta,100)
    title('beta')
    txtMean = sprintf('Grand mean = %s \n', GrandMean);
    text(0, 1, txtMean, 'FontWeight', 'bold')
    sgtitle(Sub)
    saveas(gcf, fullfile(OutputDir, sprintf('%s_%s.png', Sub, Visit)))
    close(gcf)

end