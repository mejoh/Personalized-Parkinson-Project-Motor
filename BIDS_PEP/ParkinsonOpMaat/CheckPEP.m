function [Visit1, Visit2, Visit3] = CheckPEP(cPEPFolder)
%OS check
if ispc; cProject = 'P:\';
else ;   cProject = '/project';
end

%Retrieve list of subjects
PEPfolder = fullfile(cProject, "3022026.01", "pep", cPEPFolder);
allSubs = dir(PEPfolder);
allSubs([1, 2, 3, end], :) =[]; %First 2 are upper folders, 3rd is .pepData folder and last is 'pepData.specification.json'
allSubs = string({allSubs.name});

%Retrieve whether files are present
for cSub = allSubs
    filesPresent = CheckPEP_OneSub(cSub, PEPfolder);
    if strcmp(cSub, allSubs(1)) %First subjects should initiate tables
        Visit1 = struct2table(filesPresent.Visit1);
        Visit2 = struct2table(filesPresent.Visit2);
        Visit3 = struct2table(filesPresent.Visit3);
    else %Otherwise append to table
        Visit1 = [Visit1; struct2table(filesPresent.Visit1)];
        Visit2 = [Visit2; struct2table(filesPresent.Visit2)];
        Visit3 = [Visit3; struct2table(filesPresent.Visit3)];
    end
end

%Save files
saveFolder = fullfile(cProject, '3022026.01', 'documents', cPEPFolder);
if ~exist(saveFolder, 'dir'); mkdir(saveFolder); end
writetable(Visit1, fullfile(saveFolder, 'Visit1_filesPresent.xlsx'));
writetable(Visit2, fullfile(saveFolder, 'Visit2_filesPresent.xlsx'));
writetable(Visit3, fullfile(saveFolder, 'Visit3_filesPresent.xlsx'));
end

function filesPresent = CheckPEP_OneSub(cSub, PEPfolder)
%Folder management
shortSubID = char(cSub);
shortSubID = shortSubID(1:16);
SubFolder = fullfile(PEPfolder, cSub);

for cVisit = ["Visit1", "Visit2", "Visit3"]
    SubAnatFolder = fullfile(SubFolder, strcat(cVisit, ".MRI.Anat"), strcat("sub-POMU", shortSubID), strcat("ses-", cVisit));
    SubFuncFolder = fullfile(SubFolder, strcat(cVisit, ".MRI.Func"), strcat("sub-POMU", shortSubID), strcat("ses-", cVisit));
    
    filesPresent.(cVisit).LongID = cSub;
    filesPresent.(cVisit).ShortID = shortSubID;
    filesPresent.(cVisit).Visit = cVisit;
    
    %% Castor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Check Castor Home questionaires (there should be 20)
    if size(dir(fullfile(SubFolder, "Castor.HomeQuestionnaires*")), 1) > 15
        filesPresent.(cVisit).Castor_Home = true;
    else
        filesPresent.(cVisit).Castor_Home = false;
    end
    
    %Check How many questionaires there should be
    switch cVisit
        case "Visit1"
            nQuestionaires = 20;
        case "Visit2"
            nQuestionaires = 20;
        case "Visit3"
            nQuestionaires = 1;
    end
    %Check Castor Home questionaires (there should be 20)
    if size(dir(fullfile(SubFolder, strcat("Castor.", cVisit, "*"))), 1) > nQuestionaires
        filesPresent.(cVisit).Castor_Visit = true;
    else
        filesPresent.(cVisit).Castor_Visit = false;
    end
    
    %% Rest
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Func
    if size(dir(fullfile(SubFuncFolder, "func", "*task-rest*")), 1) == 4
        filesPresent.(cVisit).Func_Rest = true;
    else
        filesPresent.(cVisit).Func_Rest = false;
    end
    
    %EEG
    if size(dir(fullfile(SubFuncFolder, "eeg", "*task-rest*")), 1) == 6
        filesPresent.(cVisit).EEG_Rest = true;
    else
        filesPresent.(cVisit).EEG_Rest = false;
    end
    
    %Beh
    if size(dir(fullfile(SubFuncFolder, "beh", "*task-rest*")), 1) == 3
        filesPresent.(cVisit).Beh_Rest = true;
    else
        filesPresent.(cVisit).Beh_Rest = false;
    end
    
    %% Motor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Func
    if size(dir(fullfile(SubFuncFolder, "func", "*task-motor*")), 1) == 2 || size(dir(fullfile(SubFuncFolder, "func", "*task-reward*")), 1) == 10
        filesPresent.(cVisit).Task_Scan = true;
%         filesPresent.(cVisit).Func_Motor = true;
        
    else
        filesPresent.(cVisit).Task_Scan = false;
%         filesPresent.(cVisit).Func_Motor = false;
        
    end
    
    %EEG
    if size(dir(fullfile(SubFuncFolder, "eeg", "*task-motor*")), 1) == 6 || size(dir(fullfile(SubFuncFolder, "eeg", "*task-reward*")), 1) == 6
        filesPresent.(cVisit).Task_EEG = true;
%         filesPresent.(cVisit).EEG_Motor = true;
        
    else
        filesPresent.(cVisit).Task_EEG = false;
%         filesPresent.(cVisit).EEG_Motor = false;
        
    end
    
    %Beh
    if size(dir(fullfile(SubFuncFolder, "beh", "*task-motor*")), 1) == 6 || size(dir(fullfile(SubFuncFolder, "beh", "*task-reward*")), 1) == 6
        filesPresent.(cVisit).Task_Beh = true;
%         filesPresent.(cVisit).Beh_Motor = true;
    else
        filesPresent.(cVisit).Task_Beh = false;
%         filesPresent.(cVisit).Beh_Motor = false;
    end
    
    %% Reward
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Func
%     if size(dir(fullfile(SubFuncFolder, "func", "*task-reward*")), 1) == 10
%         filesPresent.(cVisit).Func_Reward = true;
%     else
%         filesPresent.(cVisit).Func_Reward = false;
%     end
%     
%     %EEG
%     if size(dir(fullfile(SubFuncFolder, "eeg", "*task-reward*")), 1) == 6
%         filesPresent.(cVisit).EEG_Reward = true;
%     else
%         filesPresent.(cVisit).EEG_Reward = false;
%     end
%     
%     %Beh
%     if size(dir(fullfile(SubFuncFolder, "beh", "*task-reward*")), 1) == 6
%         filesPresent.(cVisit).Beh_Reward = true;
%     else
%         filesPresent.(cVisit).Beh_Reward = false;
%     end
    
    %% ANATOMICAL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %T1
    if size(dir(fullfile(SubAnatFolder, "anat", "*T1w*")), 1) == 2
        filesPresent.(cVisit).Anat_T1 = true;
    else
        filesPresent.(cVisit).Anat_T1  = false;
    end
    
    %T2
    if size(dir(fullfile(SubAnatFolder, "anat", "*T2w*")), 1) == 2
        filesPresent.(cVisit).Anat_T2  = true;
    else
        filesPresent.(cVisit).Anat_T2 = false;
    end
    
    %FLAIR
    if size(dir(fullfile(SubAnatFolder, "anat", "*FLAIR*")), 1) == 2
        filesPresent.(cVisit).Anat_FLAIR  = true;
    else
        filesPresent.(cVisit).Anat_FLAIR  = false;
    end
    
    %T2star
    if size(dir(fullfile(SubAnatFolder, "anat", "*T2star*")), 1) == 36
        filesPresent.(cVisit).Anat_T2star  = true;
    else
        filesPresent.(cVisit).Anat_T2star  = false;
    end
    
    %% DWI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DWI
    if size(dir(fullfile(SubAnatFolder, "dwi", "*dwi*")), 1) == 4
        filesPresent.(cVisit).DWI_dwi = true;
    else
        filesPresent.(cVisit).DWI_dwi  = false;
    end
    
    %DWI sbref
    if size(dir(fullfile(SubAnatFolder, "dwi", "*sbref*")), 1) == 4
        filesPresent.(cVisit).DWI_sbref  = true;
    else
        filesPresent.(cVisit).DWI_sbref = false;
    end
    
    %% fieldmap
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if size(dir(fullfile(SubAnatFolder, "fmap", "*epi*")), 1) == 4
        filesPresent.(cVisit).DWI_dwi = true;
    else
        filesPresent.(cVisit).DWI_dwi  = false;
    end
end
end