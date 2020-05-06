function DistributionsMeanStd(ParkinsonOpMaat)

PIT = '3024006.01';
POM = '3022026.01';
if nargin <1 || isempty(ParkinsonOpMaat)
    Project = PIT;
else
    Project = POM;
end

fprintf('Processing data in project: %s\n', Project)
Root     = strcat('/project/', Project);
BIDSDir  = fullfile(Root, 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
QCDir    = fullfile(Root, 'users/marjoh/QC');
BIDS     = spm_BIDS(BIDSDir);
Sub      = spm_BIDS(BIDS, 'subjects', 'task','motor');
Sel = true(size(Sub));

% Skip unfinished frmiprep jobs
for n = 1:numel(Sub)
	Report = spm_select('FPList', FMRIPrep, ['sub-' Sub{n} '.*\.html$']);
	if size(Report,1)~=1
		fprintf('Skipping sub-%s with no fmriprep output\n', Sub{n})
		disp(Report)
		Sel(n) = false;
    end
	
	SrcNii = spm_select('FPList', fullfile(FMRIPrep, ['sub-' Sub{n}], 'func'), ['sub-' Sub{n} '.*task-motor.*_space-MNI152NLin6Asym_desc-preproc_bold.nii$']);
	if size(SrcNii,1)~=1
		fprintf('Skipping sub-%s with no fmriprep images\n', Sub{n})
		Sel(n) = false;
    end
end

Sub     = Sub(Sel);
NrSub	= numel(Sub);

GrandMean = zeros(1, NrSub);
GrandStd = zeros(1, NrSub);
for n = 1:NrSub
    InputImg	   = spm_select('FPList', fullfile(FMRIPrep, ['sub-' Sub{n}], 'func'), ['sub-' Sub{n} '.*task-motor.*_space-MNI152NLin6Asym_desc-preproc_bold.nii$']);
    Hdr = spm_vol(InputImg);
    Vol = spm_read_vols(Hdr);
    VolDim = size(Vol);
    NrVoxels = VolDim(1) * VolDim(2) * VolDim(3);
    
    SubjectMean = zeros(1, NrVoxels);
    SubjectStd = zeros(1, NrVoxels);
    Count = 1;
    for x = 1:VolDim(1)
        for y = 1:VolDim(2)
            for z = 1:VolDim(3)
                SubjectMean(Count) = mean(Vol(x,y,z,1:VolDim(4)));
                SubjectStd(Count) = std(Vol(x,y,z,1:VolDim(4)));
                Count = Count + 1;
            end
        end
    end
    GrandMean(n) = mean(SubjectMean);
    GrandStd(n) = mean(SubjectStd);

    figure
    subplot(1,2,1)
    histogram(SubjectMean,100)
    title('Mean')
    txtMean = sprintf('Grand mean = %s \n', GrandMean(n));
    text(1, 1, txtMean, 'FontWeight', 'bold')
    subplot(1,2,2)
    histogram(SubjectStd,100)
    title('Std')
    txtStd = sprintf('Grand std = %s \n', GrandStd(n));
    text(1, 1, txtStd, 'FontWeight', 'bold')
    sgtitle(Sub{n})
    saveas(gcf, fullfile(QCDir, sprintf('%s.png', Sub{n})))
    close(gcf)
    
end
    
% Boxplot of grand mean and std for all participants
figure
subplot(1,2,1)
boxplot(GrandMean)
title('Mean')
subplot(1,2,2)
boxplot(GrandStd)
title('Std')
sgtitle('All subjects')
saveas(gcf, fullfile(QCDir, '/Group.png'))
close(gcf)

% Textfile of grand mean and std for all participants
fileID = fopen(sprintf('%s/Group.txt', QCDir), 'w');
fprintf(fileID, 'Subject \t\t Mean \t\t Std \n');
for n = 1:NrSub
    fprintf(fileID, '%s \t %s \t %s \n', Sub{n}, GrandMean(n), GrandStd(n));
end
fclose(fileID);

end