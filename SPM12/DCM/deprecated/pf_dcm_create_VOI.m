function pf_dcm_create_VOI(conf)
%
% pf_dcm_create_VOI(conf) makes the matlabbatches of your VOIs (according
% to your configuration in the conf structure) and runs them subsequently.
% VOIs are stored in your original first level directory (where your
% SPM.mat files are stored as well) and thereafter copied to your specified
% folder, encoding subject and VOI in the file name.

% � Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Initializing parameters
%--------------------------------------------------------------------------

fprintf('\n%s\n','% ----- Creating VOI.mat files (Volume of Interest) -----%')

% -- Deal with '.' in threshold for filename -- %

if length(conf.voi.Pthresh)==1
    if strfind(num2str(conf.voi.Pthresh),'.') == 2
        Thrsh  = num2str(conf.voi.Pthresh);
        Thrsh  = Thrsh([1 3:end]);
    else
        Thrsh  = num2str(conf.voi.Pthresh);
    end
else
    Thrsh = 'subspecif';
end

% -- Making save directories -- %

if exist(conf.dir.saveVOI,'dir') ~=7; mkdir(conf.dir.saveVOI); end      % Make root VOI savedir if necessary
SaveDir  =   fullfile(conf.dir.saveVOI,[conf.voi.method '_P=' Thrsh '-' conf.voi.P '_new' ]);
if exist(SaveDir,'dir') ~= 7; mkdir(SaveDir); end                       % Make specific VOI savedir if necessary

%--------------------------------------------------------------------------

%% Make the matlabbatch
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nVOI    =   length(conf.voi.roi.name);
if ischar(conf.voi.sphere.cent{1})
    if strcmp(conf.voi.sphere.cent{1},'subjectspecific')
        xyz = conf.voi.sphere.centsubspec;
    end
end
    
for i = 1:nSub
    
    clear SPM
    
    CurSub  =   conf.sub.name{i};
    CurHand =   conf.sub.hand(i);
    
    CurDir  =   pf_findfile(conf.dir.firstlevel,['/' CurSub '/*/'],'fullfile');
    fprintf('\n%s\n',['Making matlabbatch of ' CurSub])
    
    load(fullfile(CurDir,'SPM.mat'))
    
    nCon    =   length(SPM.xCon);
    
    clear CurF
    for j = 1:nVOI
        
        CurROI  =   conf.voi.roi.name{j};
        CurSide =   conf.voi.side(j);
        CurConT =   conf.voi.conT{j};
        CurConF =   conf.voi.conF;
        
        % --- Deal with handedness --- %
        
        if iscell(CurHand)
            if strcmp(CurHand,'R') && CurSide == 1
                LR  =   'L';                        % Postfix for VOI name
            elseif strcmp(CurHand,'R') && CurSide == 0
                LR  =   'R';
            elseif strcmp(CurHand,'L') && CurSide == 1
                LR  =   'R';
            elseif strcmp(CurHand,'L') && CurSide == 0
                LR  =   'L';
            end
        else
            if CurHand == 1 && CurSide == 1
                LR  =   'L';                        % Postfix for VOI name
            elseif CurHand == 1 && CurSide == 0
                LR  =   'R';
            elseif CurHand == 0 && CurSide == 1
                LR  =   'R';
            elseif CurHand == 0 && CurSide == 0
                LR  =   'L';
            end
        end
        conf.sub.curside    =   LR;
        
        % --- Deal with dependency of conf.sub.sess1 --- %
        
        if iscell(CurConT) % deal with dependency of conf.sub.sess1
            CurSess1    =   conf.sub.sess1{i};
            if strcmp(CurSess1,CurConT{2})
                CurConT =   CurConT{3};
            else
                CurConT =   CurConT{4};
            end
        end
        if iscell(CurConF)
            if strcmp(CurSess1,conf.voi.conF{2})
                CurConF =   conf.voi.conF{3};
            else
                CurConF =   conf.voi.conF{4};
            end
        end
        
        % --- Find the T and F-contrast index specified in your SPM file --- %
        
        clear CurT              
        for k = 1:nCon
            
            if strcmp(CurConT,SPM.xCon(k).name) == 1
                CurT  = k;
            elseif strcmp(CurConF,SPM.xCon(k).name) == 1
                CurF  = k;
            end
        end
        
        if ~exist('CurT','var') 
            warning('VOI:Contrast',['The specified T-contrast ("' CurConT '") could not be found in ' fullfile(CurDir,'SPM.mat')])
            disp(['Please enter the index of the contrast which is supposed to be "' CurConT '"'])
            disp({SPM.xCon.name})
            CurT = input('Enter correct index now (ascending from left to right)');
        elseif ~exist('CurF','var') 
            warning('VOI:Contrast',['The specified F-contrast ("' conf.voi.conF{1} '") could not be found in ' fullfile(CurDir,'SPM.mat')])
            disp(['Please enter the index of the contrast which is supposed to be "' conf.voi.conF '"'])
            disp({SPM.xCon.name})
            CurF = input('Enter correct index now (ascending from left to right)');
        end
        
        % --- Deal with session --- %
        
        if iscell(conf.voi.sess)
            CurSess1    =   conf.sub.sess1{i};
            if strcmp(conf.voi.sess{2},CurSess1)
                matlabbatch{1}.spm.util.voi.session                 = conf.voi.sess{3};        
            else
                matlabbatch{1}.spm.util.voi.session                 = conf.voi.sess{4};        
            end
        else
            matlabbatch{1}.spm.util.voi.session                 = conf.voi.sess;               
        end
        
        % --- Make the Matlabbatch --- %
        
        matlabbatch{1}.spm.util.voi.spmmat                  = {fullfile(CurDir,'SPM.mat')};
        matlabbatch{1}.spm.util.voi.adjust                  = CurF;             % Adjust for effects of interest (F-contrast)
        
        matlabbatch{1}.spm.util.voi.name                    = [LR '-' CurROI];
        matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat       = {fullfile(CurDir,'SPM.mat')};             % I use the SPM file above
        matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast     = CurT;             % T-contrast used for VOI extraction
        matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction  = 1;                % Conjunction number, unused if simple contrast is used
        matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc   = conf.voi.P;       % (Un)corrected P-value
        
        if length(conf.voi.Pthresh)>1
            matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh       = conf.voi.Pthresh(i); % Threshold value, if conf.voi.Pthresh is a vector for each subject
        else
            matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh       = conf.voi.Pthresh; % Threshold value
        end
        
        
        matlabbatch{1}.spm.util.voi.roi{1}.spm.extent       = 0;                % I never extend values
        matlabbatch{1}.spm.util.voi.roi{1}.spm.mask         = struct('contrast', {}, 'thresh', {}, 'mtype', {});    % I don't use masks
        
        % --- Determine if mask or sphere --- %
        
        if strcmp(conf.voi.method,'Mask') == 1
            Mask    =   pf_findfile(conf.dir.ROImasks,conf.voi.roi.sc,'conf',conf,'CurROI',j,'CurSide');
            if isempty(Mask)
                error('VOI:mask',['Could not find matching files for ' LR '_' CurROI '^.nii in directory ' conf.dir.ROImasks])
            elseif iscell(Mask)
                warning('VOI:mask',['More than one matching file was found in directory ' conf.dir.ROImasks])
                disp(['Please enter the index of the right file for mask ' CurROI])
                disp(Mask)
                in = input('Enter correct index now (Top = 1, Bottom = end)');
                Mask    =   Mask{in};
            end
            matlabbatch{1}.spm.util.voi.roi{2}.mask.image     = {fullfile(conf.dir.ROImasks,Mask)};
            disp(['Used mask (' Mask ') for VOI extraction'])
            matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;   % Don't quite understand this p-value?
        elseif strcmp(conf.voi.method,'Sphere') == 1
            if exist('xyz','var')
                matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre            = xyz{i};            % Centre coordinates from file
            else
                matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre            = conf.voi.sphere.cent{j};  % Centre coordinates 
            end
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius            = conf.voi.sphere.rad;        % Sphere radius
            matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed        = 1;                          % If you don't want the centre, you'll have to change this
        else
            in = input('Could not recognize VOI method, do you only want to use the SPM file? 1 = yes NB: you probably have to change the expression');
            if in ~= 1
                error('VOI:method','Could not make VOIs, no methods were specified')
            end
        end
                            
        matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';     % This probably won't work if you're only using roi{1}.SPM
        
        % --- Save the Bitch --- %
        
        save(fullfile(SaveDir,['Batch_' CurSub '_' LR '-' CurROI '_' conf.voi.method '_P' Thrsh]),'matlabbatch')
        
    end 
    disp(['Saved all batches for ' CurSub])
end

fprintf('\n%s\n',['Saved all batches to ' SaveDir])

%--------------------------------------------------------------------------

%% Run batches
%--------------------------------------------------------------------------

fprintf('\n%s\n','%- Now running all the batches -%')

for m = 1:nSub
    
    CurSub  =   conf.sub.name{m};
    CurHand =   conf.sub.hand(m);
    
    CurDir  =   pf_findfile(conf.dir.firstlevel,['/' CurSub '/*/'],'fullfile');
    
    
    fprintf('\n%s\n',['Running batch of ' CurSub])
    
    for n = 1:nVOI
        
        clear matlabbatch
        CurROI  =   conf.voi.roi.name{n};
        CurSide =   conf.voi.side(n);
        
        if iscell(CurHand)
            if strcmp(CurHand,'R') && CurSide == 1
                LR  =   'L';                        % Postfix for VOI name
            elseif strcmp(CurHand,'R') && CurSide == 0
                LR  =   'R';
            elseif strcmp(CurHand,'L') && CurSide == 1
                LR  =   'R';
            elseif strcmp(CurHand,'L') && CurSide == 0
                LR  =   'L';
            end
        else
            if CurHand == 1 && CurSide == 1
                LR  =   'L';                        % Postfix for VOI name
            elseif CurHand == 1 && CurSide == 0
                LR  =   'R';
            elseif CurHand == 0 && CurSide == 1
                LR  =   'R';
            elseif CurHand == 0 && CurSide == 0
                LR  =   'L';
            end
        end
        
        disp(['Current VOI is ' LR '-' CurROI ])
        load(fullfile(SaveDir,['Batch_' CurSub '_' LR '-' CurROI '_' conf.voi.method '_P' Thrsh]))
        
        spm_jobman('initcfg')
        spm_jobman('run',matlabbatch)
        
        % --- direct to spm directory --- %
        
        cd(fileparts(matlabbatch{1}.spm.util.voi.spmmat{1}));
        renamefile(['VOI_' LR '-' CurROI '*'],['VOI_' LR '-' CurROI],['VOI_' CurSub '_' LR '-' CurROI '_' conf.voi.method '_P' Thrsh])
        
        movefile(fullfile(CurDir,['VOI_' CurSub '_' LR '-' CurROI '_' conf.voi.method '_P' Thrsh '*']),SaveDir)
        cd(SaveDir)
        
    end
end

%--------------------------------------------------------------------------