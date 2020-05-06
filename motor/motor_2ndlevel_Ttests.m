% Move contrast images from PIT and POM to a single location within the POM
% project folder and label them according to group.

function motor_2ndlevel_Ttests(Swap,Offstate)
%% Swap

if nargin<1 || isempty(Swap)
	Swap = false;               % A left-right swap of the con-images
end

%% Group to comapre against controls

if isempty(Offstate)
    Offstate = false;
end

%% Paths

CWD = pwd;
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');
addpath('/home/common/matlab/fieldtrip/qsub');

%% Directories

PITRoot        = '/project/3024006.01';            % PIT: directories
PITBIDSDir     = fullfile(PITRoot, 'bids');
PITStatsDir    = fullfile(PITBIDSDir, '/derivatives/motor/spm');
PITTaskDir     = fullfile(PITBIDSDir, 'task_data/motor');
PITSub         = spm_BIDS(PITBIDSDir, 'subjects', 'ses','mri01', 'task','motor');
fprintf('PIT: Found %i subjects with ses=mri01 and task=motor\n', numel(PITSub))
POMRoot        = '/project/3022026.01';            % POM: directories
POMBIDSDir     = fullfile(POMRoot, 'bids2');
POMStatsDir    = fullfile(POMBIDSDir, 'derivatives/spm');
POMTaskDir     = fullfile(POMRoot, 'DataTask');
%POMSub         = spm_BIDS(POMBIDSDir, 'subjects', 'ses','mri01', 'task','motor');
fprintf('POM: Found %i subjects with ses=mri01 and task=motor\n', numel(POMSub))
CommonStatsDir = fullfile(POMBIDSDir, 'derivatives/spm/common');
FDThres        = 0.5;

%% Selection

PITSel = false(size(PITSub));       % PIT: include existing 1st-level
for n = 1:numel(PITSub)
	if spm_select('List', fullfile(PITStatsDir, ['sub-' PITSub{n}], 'motor/stats'), '^con.*\.nii$')
		fprintf('Including sub-%s with previous SPM output\n', PITSub{n})
		PITSel(n) = true;
	end
end
PITSub = PITSub(PITSel);

POMSel = false(size(POMSub));       % POM: include existing 1st-level
for n = 1:numel(POMSub)
	if spm_select('List', fullfile(POMStatsDir, ['sub-' POMSub{n}], 'motor/stats'), '^con.*\.nii$')
		fprintf('Including sub-%s with previous SPM output\n', POMSub{n})
		POMSel(n) = true;
	end
end
POMSub = POMSub(POMSel);

%% Copy and flip

% ConList = {'con_0001'         'con_0002'          'con_0003'          'con_0004'          'con_0005'          'con_0006'          'con_0007'          'con_0008'          'con_0009'          'con_0010'          'con_0011'          'con_0012'          'con_0013'                  'con_0014'};
% Names   = {'Ext>0'            'Ext<0'             'Int>0'             'Int<0'             'Int2>0'            'Int2<0'            'Int3>0'            'Int3<0'            'Ext>Int'           'Ext<Int'           'Int2>Int3'         'Int2<Int3'         'Catch>Ext|Int'             'Catch<Ext|Int'};
ConList = {'con_0009'          'con_0010'         'con_0012'};
Names   = {'Ext>Int'           'Ext<Int'          'Int2<Int3'};

NrCon = numel(ConList);

NrSub    = numel(PITSub);
PITGroup = NaN(size(PITSub));
PITFD	 = NaN(size(PITSub));
PITSel   = true(size(PITSub));
for i = 1:NrCon         % For every contrast...
    CommonConDir = fullfile(CommonStatsDir, ConList{i});
    if ~exist(CommonConDir, 'dir')          % Start with fresh directory
        mkdir(CommonConDir);
    else
        delete(fullfile(CommonConDir, '*.*')); 
    end
    for n = 1:NrSub         % Copy 1st-level results of each participant to common directory
        SubStatsDir     = fullfile(PITStatsDir, ['sub-' PITSub{n}], 'motor', 'stats');
        SubSPMDir       = fullfile(PITStatsDir, ['sub-' PITSub{n}], 'motor');
        DWIDir = fullfile(PITBIDSDir, ['sub-' PITSub{n}], 'ses-mri01', 'dwi');
        PresLog  = spm_select('FPList', PITTaskDir, [PITSub{n} '_(t|T)ask1-MotorTaskEv_.*\.log$']);
        InputConFile    = fullfile(SubStatsDir, [ConList{i} '.nii']);
        if exist(DWIDir, 'dir')     % If DWI directory exists, then healthy control
            PITGroup(n) = 1;
            OutputConFile   = fullfile(CommonConDir, ['Hc_sub-' PITSub{n} '_' ConList{i} '.nii']);
        else
            PITGroup(n) = 2;
            OutputConFile   = fullfile(CommonConDir, ['Off_sub-' PITSub{n} '_' ConList{i} '.nii']);
        end
        copyfile(InputConFile, OutputConFile);
        fprintf('Copied sub-%s to common stats directory\n', PITSub{n});
        if contains(PresLog,'left') && Swap         % Flip left-responders horizontally
			fprintf('LR-swapping: %s\n', OutputConFile)
			Hdr		  = spm_vol(OutputConFile);
			Vol		  = spm_read_vols(Hdr);
			Hdr.fname = spm_file(OutputConFile, 'suffix', 'LRswap');
			spm_write_vol(Hdr, flipdim(Vol,1));		% LR is the first dimension in MNI space
            delete(OutputConFile);
        end
		PITConf  = spm_load(fullfile(SubSPMDir, ['sub-' PITSub{n} '_ses-mri01_task-motor_run-1_echo-1_desc-confounds_regressors.mat']));
		PITFD(n) = mean(PITConf.R(2:end, strcmp(PITConf.names, 'framewise_displacement')));
        
        if i==1                                     % TODO: Exclusion based on mean(FD). Not yet implemented, for either PIT or POM
			Reason = sprintf('\t\t\t');
            if PITFD(n) > FDThres
				PITSel(n) = false;
				Reason = sprintf('\tmean(FD) = %f', PITFD(n));
            end
            if PITSel(n)
				fprintf('Included: %s\n', PITSub{n})
			else
				fprintf('Excluded: %s\t%s\n', PITSub{n}, Reason)
            end
        end
        
    end
end

NrSub = numel(POMSub);
POMFD = NaN(size(POMSub));
POMSel   = true(size(POMSub));
for i = 1:NrCon
    CommonConDir = fullfile(CommonStatsDir, ConList{i});
    for n = 1:NrSub
        SubStatsDir     = fullfile(POMStatsDir, ['sub-' POMSub{n}], 'motor', 'stats');
        SubSPMDir       = fullfile(POMStatsDir, ['sub-' POMSub{n}], 'motor');
        PresLog         = spm_select('FPList', POMTaskDir, [POMSub{n} '_(t|T)ask1-MotorTaskEv_.*\.log$']);
        InputConFile    = fullfile(SubStatsDir, [ConList{i} '.nii']);
        OutputConFile   = fullfile(CommonConDir, ['On_sub-' POMSub{n} '_' ConList{i} '.nii']);
        copyfile(InputConFile, OutputConFile);
        fprintf('Copied sub-%s to common stats directory\n', POMSub{n});
        if contains(PresLog,'left') && Swap         
			fprintf('LR-swapping: %s\n', OutputConFile)
			Hdr		  = spm_vol(OutputConFile);
			Vol		  = spm_read_vols(Hdr);
			Hdr.fname = spm_file(OutputConFile, 'suffix', 'LRswap');
			spm_write_vol(Hdr, flipdim(Vol,1));	
            delete(OutputConFile);
        end
		POMConf  = spm_load(fullfile(SubSPMDir, ['sub-' POMSub{n} '_ses-mri01_task-motor_run-1_echo-1_desc-confounds_regressors.mat']));
		POMFD(n) = mean(POMConf.R(2:end, strcmp(POMConf.names, 'framewise_displacement')));
        
        if i==1
			Reason = sprintf('\t\t\t');
            if POMFD(n) > FDThres
				POMSel(n) = false;
				Reason = sprintf('\tmean(FD) = %f', POMFD(n));
            end
            if POMSel(n)
				fprintf('Included: %s\n', POMSub{n})
			else
				fprintf('Excluded: %s\t%s\n', POMSub{n}, Reason)
            end
        end
        
    end
end

%% Assemble inputs

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

inputs = cell(4, 1);

for n = 1:NrCon
    ConDir = fullfile(CommonStatsDir, ConList{n});
    if Offstate
        inputs{1,1} = {fullfile(CommonStatsDir, 'Ttests_HcVsOff', Names{n})};
        HcIms = dir(fullfile(ConDir, 'Hc*'));
        inputs{2,1} = fullfile(ConDir, {HcIms.name}');
        PdIms = dir(fullfile(ConDir, 'Off*'));
        inputs{3,1} = fullfile(ConDir, {PdIms.name}');
        FD = [PITFD(PITGroup == 1) PITFD(PITGroup == 2)];
    else
        inputs{1,1} = {fullfile(CommonStatsDir, 'Ttests_HcVsOn', Names{n})};
        HcIms = dir(fullfile(ConDir, 'Hc*'));
        inputs{2,1} = fullfile(ConDir, {HcIms.name}');
        PdIms = dir(fullfile(ConDir, 'On*'));
        inputs{3,1} = fullfile(ConDir, {PdIms.name}');
        FD = [PITFD(PITGroup == 1) POMFD];
    end
    inputs{4,1} = FD';
    
    delete(fullfile(char(inputs{1}), '*.*'))
%     spm_jobman('run', JobFile, inputs{:});
    qsubcellfun('spm_jobman', repmat({'run'},[1 NrCon]), repmat(JobFile,[1 NrCon]), inputs{:}, 'memreq',5*1024^3, 'timreq',8*60*60, 'StopOnError',false, 'options','-l gres=bandwidth:1000')
end

cd(CWD);

end

