function rewrite_fmriprep_confounds_aroma

addpath('/home/sysneu/marjoh/scripts/POM_PIT');
addpath('/home/common/matlab/spm12');

thr         = 0.05;         % Arbitrary threshold for excluding motion components
Root        = '/project/3024006.01/';
BIDSdir     = fullfile(Root, 'bids');
FMRIPREPdir = fullfile(BIDSdir, 'derivatives/motor/fmriprep');
SPMdir      = fullfile(BIDSdir, 'derivatives/motor/spm');
BIDS        = spm_BIDS(BIDSdir);
Sub         = spm_BIDS(BIDS, 'subjects', 'ses', 'mri01', 'task', 'motor');
%Sub = {Sub{4} Sub{5}};
Files       = spm_BIDS(BIDS, 'data', 'sub', Sub, 'ses', 'mri01', 'task', 'motor');
NrSub       = numel(Sub);

for n = 1:NrSub

    SPMfile = fullfile(SPMdir, ['sub-' Sub{n}], 'motor', 'stats', 'SPM.mat');
    SPMvar = load(SPMfile);
    TaskCols = contains(SPMvar.SPM.xX.name, '*bf(1)');
    TaskRegs = SPMvar.SPM.xX.X(:,TaskCols);
    
    covarfile   = strrep(strrep(Files{n}, BIDSdir, FMRIPREPdir), '_bold.nii.gz', '_desc-confounds_regressors.tsv');     % Org confound file
    if ~exist(covarfile, 'file')
        fprintf('Skipping subject sub-%s: Does not have confounds tsv file \n',AllSub{n})
        continue
    end
    covarfile2  = strrep(covarfile, '_desc-confounds_regressors.tsv', '_desc-confounds_regressors2.tsv');            % New confound file
    confounds   = spm_load(char(covarfile));    % Load confound file
    fid            = fopen(covarfile, 'r');
    Header         = strsplit(fgetl(fid), '\t');
    Content        = textscan(fid, '%s', 'Delimiter','\n');
    fclose(fid);
    
    fprintf('Sub-%s: Estimating correlation between task regressors and motion components\n', Sub{n})
    for m = 1:length(Header)
        if startsWith(Header{m}, 'aroma_')
            Fitted = fitlm(TaskRegs(:,1:4), confounds.(Header{m}));
            if Fitted.Rsquared.Ordinary < thr
                Header{m} = strrep(Header{m}, 'aroma_', 'aroma2_');
            else
                fprintf('R^2 = %f for %s\n', Fitted.Rsquared.Ordinary, Header{m})
            end
        end
    end
    
    fid = fopen(covarfile2, 'w');
    fprintf(fid, '%s%s\n', sprintf('%s\t', Header{1:end-1}), Header{end});
    for Line = Content{1}'
        fprintf(fid, '%s\n', Line{1});
    end
    fclose(fid);

end

end