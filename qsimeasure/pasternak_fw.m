function [] = pasternak_fw()

% Coded by Ofer Pasternak: ofer@bwh.harvard.edu
% Use on your own risk.
% This code was not meant to be used as a clinical tool.

addpath('/home/sysneu/marjoh/scripts/ParkInShape-misc/FromOthers/free_water_imaging');
addpath('/home/sysneu/marjoh/scripts/ParkInShape-misc/FromOthers/free_water_imaging/FWFunctions');

% Applys a free water correction on DWI data.
% The input file is assumed to be a nii.gz file, with .bval and .bvec files
% For best use, also requires a binary mask file
InputDir = '/project/3022026.01/pep/bids/derivatives/qsiprep'; 
cases=cellstr(spm_select('List',InputDir,'dir','sub.*'));

%%  SET THE BELOW PARAMETERS TO MATCH YOUR FILES
%   Need to set fname_in, fname_out, mask, bvak and bvec for each dataset. 
for i=1:numel(cases)
%     dashes = strfind(cases{i},'/');
%     curcase = cases{i}(1:dashes(1)-1);
%     h_l = lower(cases{i}(dashes(1)+1:dashes(2)-1));
%     mask = [DIR '/' curcase '/' h_l '/brainmask' curcase '_' h_l '.nii.gz'];  % If your data is not already masked, supply a mask here.
%     fname_in = [DIR '/' cases{i}]; % The data file
%     bval = [DIR '/' curcase '/' h_l '/bval' curcase '_' h_l '.bval'];
%     bvec = [DIR '/' curcase '/' h_l '/bvec' curcase '_' h_l '.bvec'];
%     fname_out = [outDIR '/' curcase '_' h_l]; % The prefix of files to be saved.

    sessions = cellstr(spm_select('List', fullfile(InputDir, cases{i}), 'dir', 'ses-*'));
    for s=1:numel(sessions)
        
        mask = spm_select('FPList', fullfile(InputDir, cases{i}, sessions{s}, 'dwi'), '.*desc-brain_mask.nii.gz');  % If your data is not already masked, supply a mask here.
        fname_in = spm_select('FPList', fullfile(InputDir, cases{i}, sessions{s}, 'dwi'), '.*desc-preproc_dwi.nii.gz');
        bval = spm_select('FPList', fullfile(InputDir, cases{i}, sessions{s}, 'dwi'), '.*desc-preproc_dwi.bval');
        bvec = spm_select('FPList', fullfile(InputDir, cases{i}, sessions{s}, 'dwi'), '.*desc-preproc_dwi.bvec');
        OutputDir = fullfile(InputDir, cases{i}, sessions{s}, 'metrics', 'pasternak_fw');
        previous_output = spm_select('FPList', OutputDir, '^sub.*FW.nii.gz');
        if exist(previous_output, 'file')
            fprintf('>>> Already processed: %s %s\n', cases{i}, sessions{s})
            continue
        else
            [~, ~, ~] = mkdir(OutputDir);
        end
        fname_out = fullfile(OutputDir, [cases{i}, '_', sessions{s}]); % The prefix of files to be saved.
        Inputs = {fname_in;fname_out;mask;bval;bvec};
        
        %freeWaterNii(fname_in,fname_out,mask,bval,bvec);
        qsubfeval(@freeWaterNii, Inputs{:}, 'memreq',6*1024^3,'timreq',0.5*60*60);
        
    end

end
%% EXPLANATION OF OUPUT

% In outDIR the following files will be saved:


% XXX_FW.nii.gz -                  A file with the free-water map

% XXX_FW_TensorFWCorrected.nii.gz - A file with the tensor map after
%                               correcting for free-water

% XXX_FW_TensorDTINoNeg.nii.gz       A file with a tensor map that is NOT
% corrected for free-water, but has the same negative eigenvalue
% correction that was used as pre-processing for the free-water.

% XXX_FW.mat  -                 The final output in Matlab format

% To create scalar maps from the tensor files, use:
% fslmaths XXX_TensorFWCorrected.nii.gz -tensor_decomp output_FWCorrected
% or
% fslmaths XXX_TensorDTINoNeg.nii.gz -tensor_decomp output_DTI


