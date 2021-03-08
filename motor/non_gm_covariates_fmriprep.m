function [covarfile, nrcov] = non_gm_covariates_fmriprep(ConfoundsFile, NVolFile, NrPulses)

% [covarfile nrcov] = non_gm_covariates_fmriprep(ConfoundsFile, NVolFile)
%
% Reads the confounds-file from fmriprep and creates a SPM nuisance regressor
% matfile from it. Dummy regressors are added to account in case there are more
% volumes than recorded scanner pulses (as stored in NVolFile)
%
% Marcel

if nargin<3 || isempty(NrPulses)
	NrPulses = load(char(NVolFile));				% The number of measured scanner pulses by Presentation / during the experiment
end
Confounds = spm_load(char(ConfoundsFile));
ndum	  = max([0 (length(Confounds.csf) - NrPulses(1))]);
dum		  = [zeros(NrPulses(1),ndum); eye(ndum)];	% Add dummies for acquired volumes after the experiment has ended
dumid	  = cell(1,ndum);
for n = 1:ndum
	dumid{n} = sprintf('dum%02d', n);
end

allconfnames = fieldnames(Confounds);
% substrings = {'TremorLog', 'framewise_displacement', 'std_dvars', 'trans_', 'rot_', 'a_comp_cor_01', 'a_comp_cor_02', 'a_comp_cor_03', 'a_comp_cor_04', 'a_comp_cor_05', 'a_comp_cor_06', 'a_comp_cor_07', 'a_comp_cor_08', 'aroma2_', 'cosine'};
substrings = {'framewise_displacement', 'std_dvars', 'trans_', 'rot_', 'a_comp_cor_01', 'a_comp_cor_02', 'a_comp_cor_03', 'a_comp_cor_04', 'a_comp_cor_05', 'a_comp_cor_06', 'a_comp_cor_07', 'a_comp_cor_08', 'aroma2_', 'cosine'};
names={};
for i = 1:length(substrings)                % Finds all instances of substrings in confounds file (multiple instances of trans/rot/t_comp_cor/aroma)
    filterednames = rmfield(Confounds, allconfnames(find(cellfun(@isempty, strfind(allconfnames, substrings{i})))));
    names = [names, fieldnames(filterednames)'];
end
R         = [cell2mat(cellfun(@getfield, repmat({Confounds}, size(names)), names, 'UniformOutput',false))];
if ndum > 0
    R       = [R dum];
    names	= [names dumid];
    sprintf('%i volumes MORE than total number of pulses', (length(Confounds.csf) - NrPulses(1)))
else
    sprintf('%i volumes LESS than total number of pulses', (length(Confounds.csf) - NrPulses(1)))
end
nrcov     = length(names);
covarfile = spm_file(char(NVolFile), 'filename',spm_file(ConfoundsFile,'filename'), 'ext','.mat');
R(isnan(R) | isinf(R)) = 0;							% SPM cannot handle NaN or Inf
disp(['Saving confounds in: ' covarfile])
save(covarfile, 'R', 'names')