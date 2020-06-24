%% ToDo
%Improve descriptions
%Improve error handling

%% OS CHECK
if ispc
    pfProject="P:\";
elseif isunix
    pfProject="/project/";
else
    warning('Platform not supported - Linux settings are used')
    pfProject="/project/";
end


%% USER SETTINGS (CHANGE!!)
%The script requieres a table as input with both a subjectnumber and file
%name for that sub. You can make the table yourself or use the sections below
%to find the correct files. I advise to comment out the parts you don't need

%Make input table
%for resting state scans (Note that I find both rest1 and %rest2 files)
cDirInfo = dir(fullfile(pfProject, "3022026.01", "analyses", "motor", "emg", "test", "data", "*task*.vmrk")); %Look in DataEMG for all .vmrk files with rest in them
allFiles = string(join([{cDirInfo.folder}', {cDirInfo.name}'], filesep));
allSubs = extractBetween(allFiles, strcat("data", filesep), "_task");
inputTable = splitvars(table([allSubs, allFiles]), 'Var1');

%For reward scans (COMMENT OUT IF YOU DON'T WORK ON REWARD)
% subTable = getSubjects("PD_on_study");
% inputTable = rowfun(@(cSub) getRewardInputTable(cSub, pfProject), subTable(:, "SubjectNumber"), 'NumOutputs', 2);

%Settings
settings.TR         = 1;                                                                %double with TR time in seconds
settings.RawFolder  = fullfile(pfProject, "3022026.01", "raw");                             %We count the number of images in the raw folder
settings.ScanFolder = fullfile("ses-mri01", "*MB6_fMRI_2.0iso_TR1000TE34", "*.IMA");        %To search the raw images, we need a path within a subject folder to the raw images of the currect scan. Note the * at the scanname (instead of numbers) and the file extension (all IMA files).
settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "motor", "emg", "test", "corrected");                 %Output folder for the new files
settings.EEGfolder  = fullfile(pfProject, "3022026.01", "analyses", "motor", "emg", "test", "data");                         %Raw folder containing the .eeg and .vhdr files
settings.NumberOfEchos = 1;                                                      % Number of Echos if you do not have a multi echo sequence, use 1. 

%% Execute & save log
logFile.LogTable = rowfun(@(cSub, oldFile) ChangeMarkersEMG(cSub, oldFile, settings), inputTable, ...
    'NumOutputs', 3, ...
    'OutputVariableNames', ["Subject", "File", "Error"]);
logFile.settings = settings;
Logname = fullfile(settings.NewFolder, strcat("LogFile", datestr(now,'_mm-dd-yyyy_HH-MM-SS'), ".mat"));
save(Logname, 'logFile');
disp(strcat("Saved log to: '", Logname, "'"));

%% Functions
function [cSub, oldFile, cError] = ChangeMarkersEMG(cSub, oldFile, settings)
%CHANGEMARKERSEMG Summary of this function goes here
%    Detailed explanation goes here

%Start Disp & check if not already ran for this sub
disp(strcat("Analysing Sub: ", cSub));
[~, cFileID, ~] = fileparts(oldFile);
newFile = fullfile(settings.NewFolder, strcat(cFileID, ".vmrk"));
if exist(newFile, 'file')
    warning(strcat("There is already a new markerfile in the new folder for: ", oldFile))
    cError = "There is already a new markerfile in the new folder";
    return
end

%Load file
%-----------------------------------
%Data
cError = string;
cData = readtable(oldFile, ...
    'FileType', 'text', ...
    'ReadVariableNames', false, ...
    'Delimiter', {'=', ','}, ...
    'HeaderLines', 11);
cData.Properties.VariableNames = {'MarkerNumber','MarkerType','Description','PositionInDatapoints','SizeInDataPoints', 'ChannelNumber', 'Unkown'};

%Header
cFile = fopen(oldFile);
header=strings(12,1);
for cLine = 1:12
    header(cLine)=string(fgetl(cFile));
end
fclose(cFile);


%Checks for whether the marker file is acceptable.
%-----------------------------------
%Check 1) acceptable R1 notations, remove all others.
%All possible markers
acceptableDescriptions = [strcat("R  ", string(3:2:9)), strcat("R ", string(11:2:31))];
if any(ismember(string(cData.Description), acceptableDescriptions))
    warning(strcat("Adjusted R pulses to R1 for: ", oldFile));
    cError = strcat(cError, " & Adjusted R pulses to R1");
    cData = cData(ismember(string(cData.Description), ["R  1", acceptableDescriptions]), :);
else
    cData = cData(ismember(string(cData.Description), "R  1"), :);
end

%Check 2) acceptable timings, will also show additional pulses
acceptableTimings=[settings.TR*5000, (settings.TR*5000)-1, (settings.TR*5000)+1];
if ~all(ismember(diff(cData.PositionInDatapoints), round(acceptableTimings)))
    warning(strcat("Not all R1 scans have the same interval for: ", oldFile, "trying to fix..."))
    cError = strcat(cError, " & Not all R1 pulses have the same interval FIXED!!!!!");
    cData = fixTimings(cData, acceptableTimings);
    
    %Check if fixed
    if ~all(ismember(diff(cData.PositionInDatapoints), round(acceptableTimings)))
        warning(strcat("Not all R1 scans have the same interval for: ", oldFile))
        cError = strcat(cError, " & Not all R1 pulses have the same interval");
        return
    end
end

%Check 3) Check if there are sufficient pulses
%Find number of pulses
cImaFiles = size(dir(strcat(settings.RawFolder, filesep, "sub-", cSub, filesep, settings.ScanFolder)),1);
cImaFiles = cImaFiles / settings.NumberOfEchos ;
if (size(cData, 1) == cImaFiles+1)
    warning(strcat("One pulse too many for: ", oldFile));
    cError = strcat(cError, " & One pulse too many - REMOVED LAST PULSE");
    cData(end,:)=[];
elseif (size(cData, 1) > cImaFiles)
    warning(strcat("More then one pulse too many for: ", oldFile));
    cError = strcat(cError, " & More then one pulse too many");
    return
elseif (size(cData, 1) < cImaFiles)
    warning(strcat("Not enough pulses for: ", oldFile));
    cError = strcat(cError, " & Not enough pulses");
    return
end

%Check 4) acceptable header name
cHeaderRow = contains(header, "DataFile");
cHeaderID = extractBetween(header(cHeaderRow),"DataFile=",".eeg");
if cHeaderID ~= cFileID
    warning(strcat("Headerfile does not match with filename for: ", oldFile))
    cError = strcat(cError, " & Headerfile does not match with filename");
end

%If no error
if strcmp(cError, ""); cError = "No error detected"; end

% Fix potential problems
%-----------------------------------
%Update fileChange Header "\1" to make it interpretable
header = replace(header, '"\1".', '\"\\1\".');

%Fix Header ID
if contains(cError, "Headerfile")
    header(cHeaderRow)=replace(header(cHeaderRow), cHeaderID, cFileID);
end

%Rework marker numbers & remove unnecessary columns
cData.MarkerNumber = strcat("Mk", string(2:length(cData.MarkerNumber)+1))';
cData.MarkerNumber = strcat(cData.MarkerNumber, "=", cData.MarkerType);
cData=removevars(cData, {'MarkerType', 'Unkown'});

%Set Description markers to "R  1"
cData.Description = repmat("R  1", size(cData,1), 1);

%Save new file
%-----------------------------------
%Make a file with the updated header
cFile = fopen(newFile, 'w+');
for cLine = 1:12
    fprintf(cFile, strcat(header(cLine), '\r\n'));
end
fclose(cFile);

%Make a temp file with the data
tempDataFile = fullfile(settings.NewFolder, strcat(cFileID, "_tempData.vmrk"));
writetable(cData, tempDataFile, 'WriteVariableNames', false, 'FileType', 'text');

%Merge
cHeaderFile = fopen(newFile, 'a'); %open
cDataFile = fopen(tempDataFile, 'r');
cDataFileContents = fread(cDataFile); %read data as binary
fwrite(cHeaderFile,cDataFileContents); %append to headerfile
fclose(cHeaderFile); %close
fclose(cDataFile);

%Remove tempData file
delete(tempDataFile)

%Copy .eeg and .vhdr files
cBase = fullfile(settings.EEGfolder, cFileID);
cTarget = fullfile(settings.NewFolder, cFileID);
copyfile(strcat(cBase, ".eeg"), strcat(cTarget, ".eeg")); %.eeg
copyfile(strcat(cBase, ".vhdr"), strcat(cTarget, ".vhdr")); %.vhdr

%End disp
disp("Done! Next file...");
end

%This function will fix wrong timings
function newData = fixTimings (cData, allTimings)
cDiff = diff(cData.PositionInDatapoints);
cWrong = ~ismember(cDiff, round(allTimings));

%If the pulses are in the beginning, they can just be removed
while cWrong(1)
    cData(1, :) = [];
    cDiff = diff(cData.PositionInDatapoints);
    cWrong = ~ismember(cDiff, allTimings);
end

%Otherwise, find the first one and remove the one afterwards.
while sum(cWrong)>0
    RemovePulse = find(cWrong,1)+1;
    cData(RemovePulse, :) = [];
    cDiff = diff(cData.PositionInDatapoints);
    cWrong = ~ismember(cDiff, round(allTimings));
end

%Parse cData
newData = cData;
end

function [cSub, cFile] = getRewardInputTable(cSub, pfProject)
cDir = dir(fullfile(pfProject, "3022026.01", "DataEMG", strcat(cSub, "*task*.vmrk")));
cFile = string(join([cDir(end).folder, filesep, cDir(end).name])); %Note that I only take the last file (if there are multiple i.g. task1, task2)
end
