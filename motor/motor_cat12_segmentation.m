%motor_cat12_copyanat.m
% Copy anatomicals to CAT12 directory and unzip them for further processing
% Run CAT12 segmentation pipeline
% Smooth output images of interest
function motor_cat12_segmentation(Force)

if nargin < 1
    Force = false;
end

Session = 'ses-POMVisit1';
spm('defaults', 'FMRI');
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
dInput = '/project/3022026.01/pep/bids/';
% dOutput = '/project/3024006.02/Analyses/CAT12/processing';
% dOutput = '/project/3024006.02/Analyses/CAT12/processing_cDartel';
dOutput = '/project/3024006.02/Analyses/CAT12/processing_cShoot';
dClust = '/project/3024006.02/Analyses/CAT12/cluster_output';

% Take only subjects with 1st-level output
d1stlevel = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
Sub = cellstr(spm_select('List', fullfile(d1stlevel), 'dir', '^sub-POM.*'));
% Sub = Sub(36:45,1);

% Filter out subjects that do not have the specified session
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    
    check = spm_select('FPList', fullfile(dInput, Sub{n}), 'dir', Session);
    if isempty(check)
        Sel(n) = false;
    end
    
end
Sub = Sub(Sel);

% If PIT, take only healthy controls. Use anat images or beh JSON as the check
if contains(Session,'ses-PITVisit1')
    Sel = false(size(Sub,1),1);
    for n = 1:numel(Sub)
        % Check anatomicals
%         check_dwi = spm_select('FPList', fullfile(dInput, Sub{n}, 'ses-PITVisit1'),'dir', 'dwi');
%         check_flair = spm_select('FPList', fullfile(dInput, Sub{n}, 'ses-PITVisit1', 'anat'), '.*FLAIR.nii.gz');
%         check_qsm = spm_select('FPList', fullfile(dInput, Sub{n}, 'ses-PITVisit1', 'anat'), '.*GREhighresE01.*magnitude.*T2star.nii.gz');
%         check_t2w = spm_select('FPList', fullfile(dInput, Sub{n}, 'ses-PITVisit1', 'anat'), '.*T2w.nii.gz');
%         if exist(check_dwi,'dir') || exist(check_flair,'file') || exist(check_qsm,'file') || exist(check_t2w,'file')
%             Sel(n) = true;
%         end
        % Check JSON-file for participant type
        check_type = spm_select('FPList', fullfile(dInput, Sub{n}, Session, 'beh'), '.*acq-MB6.*events.json');
        json = fileread(check_type);
        json = jsondecode(json);
        type = json.Group.Value;
        if contains(type, 'HC_PIT')
            Sel(n) = true;
        end
    end
    Sub = Sub(Sel);
end

% Start with clean processing directory
if Force
        rmdir(dOutput,'s');
end
mkdir(dOutput);

% Skip processsed subjects
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    
    check_smwp1 = spm_select('FPList', fullfile(dOutput, 'mri'), ['smwp1.*' Sub{n} '.*nii']);
    check_swj = spm_select('FPList', fullfile(dOutput, 'mri'), ['swj.*' Sub{n} '.*nii']);
    
    if exist(check_smwp1, 'file') && exist(check_swj, 'file')
        Sel(n) = false;
    end
    
end
Sub = Sub(Sel);    

CAT12jobs = cell(numel(Sub),1);
current = pwd;
cd(dClust)
for n = 1:numel(Sub)
    
    % Find anatomical
    fAnat = cellstr(spm_select('FPList',fullfile(dInput, Sub{n}, Session, 'anat'), [Sub{n}, '_', Session, '_acq-MPRAGE_rec-norm_run-.*_T1w.nii.gz']));
    % Take last one if there are multiple
    if numel(fAnat) > 1
        fAnat = {fAnat{size(fAnat,1)}};
    end
    
    % Copy anatomical to output directory
    copyfile(fAnat{1},dOutput)
    
    % Unzip anatomical
    newImg = spm_select('FPList',dOutput, [Sub{n} '.*T1w.nii.gz']);
    gunzip(newImg);
    delete(newImg);
    newImg = strrep(newImg, '.nii.gz','.nii');
    
    % Flip the image based on whether the participant were flipped
    % for the functional analyses [probably not appropriate to do on raw
    % data]
%     check = spm_select('FPList', fullfile(d1stlevel, 'Group', 'con_0001', 'ses-Visit1'), ['.*' Sub{n} '_' Session '_con_0001.*.nii']);
%     if contains(check, 'L2Rswap')
%         Hdr		  = spm_vol(newImg);
%         Vol		  = spm_read_vols(Hdr);
%         Hdr.fname = spm_file(newImg, 'suffix', 'L2Rswap');
%         spm_write_vol(Hdr, flipdim(Vol,1));		% LR is the first dimension in MNI space
%         delete(newImg);
%         newImg = Hdr.fname;
%     end
    
    % Add group label to image name
    if contains(Session, 'ses-PITVisit')
        newImg2 = strrep(newImg, 'sub-', 'HC_sub-');
    else
        newImg2 = strrep(newImg, 'sub-', 'PD_sub-');
    end
    movefile(newImg, newImg2);
    
    % Specify input to CAT12
    input = {[newImg2,',1']};
    
    CAT12jobs{n} = qsubfeval('spm_jobman', 'run', JobFile, input, 'memreq',5*1024^3,'timreq',1.5*60*60);
%     spm_jobman('run', JobFile, input);
    
end
cd(current)

% if numel(Sub)==1
% 	spm_jobman('run', JobFile, inputs{1}{1});
% else
%   	qsubcellfun('spm_jobman', repmat({'run'},[1 numel(Sub)]), repmat(JobFile,[1 numel(Sub)]), inputs{:}, 'memreq',6*1024^3, 'timreq',1*60*60, 'StopOnError',false, 'options','-l gres=bandwidth:1000');
% end
% Save clusterjobs
if ~isempty(CAT12jobs)
    task.jobs = CAT12jobs;
    task.submittime = datestr(clock);
    task.mfile = mfilename;
    task.mfiletext = fileread([task.mfile '.m']);
    save([dClust '/jobs_' task.mfile  '_' datestr(clock) '.mat'],'task');
end

end


