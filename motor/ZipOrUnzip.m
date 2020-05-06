function ZipOrUnzip(ParkinsonOpMaat)

PIT = '3024006.01';
POM = '3022026.01';
if nargin <1 || isempty(ParkinsonOpMaat)
    Project = PIT;
else
    Project = POM;
end

Root     = strcat('/project/', Project);
BIDSDir  = fullfile(Root, 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
BIDS     = spm_BIDS(BIDSDir);
Sub      = spm_BIDS(BIDS, 'subjects', 'task','motor');

% Skip ambiguous multiple runs/series cases (for now)
for AmbigSub = spm_BIDS(BIDS, 'subjects', 'run','2', 'task','motor')
	fprintf('Skipping sub-%s with ambiguous run-2 data\n', char(AmbigSub))
	Sub(strcmp(char(AmbigSub), Sub)) = [];
end

Sel = true(size(Sub));

% Skip unfinished frmiprep jobs or subjects with already unzipped images
for n = 1:numel(Sub)
	Report = spm_select('FPList', FMRIPrep, ['sub-' Sub{n} '.*\.html$']);
	if size(Report,1)~=1
		fprintf('Skipping sub-%s with no fmriprep output\n', Sub{n})
		disp(Report)
		Sel(n) = false;
    end
	
	SrcNii = spm_select('FPList', fullfile(FMRIPrep, ['sub-' Sub{n}], 'func'), ['sub-' Sub{n} '.*task-motor.*_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz$']);
	if size(SrcNii,1)~=1
		fprintf('Skipping sub-%s with no zipped fmriprep images\n', Sub{n})
		Sel(n) = false;
    end
end

Sub     = Sub(Sel);
NrSub   = numel(Sub);

for n = 1:NrSub
    SrcNii = spm_select('FPList', fullfile(FMRIPrep, ['sub-' Sub{n}], 'func'), ['sub-' Sub{n} '.*task-motor.*_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz$']);
    disp(['Unzipping: ' SrcNii])
    gunzip(SrcNii, fileparts(SrcNii))
    delete(SrcNii)
end

end