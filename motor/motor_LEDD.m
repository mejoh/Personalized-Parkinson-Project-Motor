% Requires matlab/R2020b

clear

addpath('/home/sysneu/marjoh/scripts/FromJorryt')
fConversionTable = '/project/3022026.01/scripts/jortic/LEDD_conversion_factors.xlsx';
cConversionTable = readtable(fConversionTable);
OutputFolder = '/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/LEDD';
dClinVars = '/project/3022026.01/pep/ClinVars_10-08-2023/';
cSubs = cellstr(spm_select('List', dClinVars, 'dir', 'sub-.*'));

if exist(OutputFolder, 'dir')
    delete(fullfile(OutputFolder, '*.*'))
else
    mkdir(OutputFolder)
end

FileRowId = 1;
for n = 1:numel(cSubs)
    cSessions = cellstr(spm_select('List', fullfile(dClinVars, cSubs{n}), 'dir', 'ses-POMVisit[0-9]'));
    for s = 1:numel(cSessions)
        fMeds = spm_select('FPList', fullfile(dClinVars, cSubs{n}, cSessions{s}), 'Castor.*Demografische_vragenlijsten.Parkinson_medicatie.json');
        if isempty(fMeds)
            continue
        end
        clear medout error MatOutputName AllMedNames UsedMedNames
        [medout, error] = ScoreMedication(string(fMeds), cConversionTable);
        if medout.medUser == 0
            fprintf('Skipping %s/%s, not a med user \n', cSubs{n}, cSessions{s})
            continue
        end
        MatOutputName = fullfile(OutputFolder, [cSubs{n} '_' cSessions{s} '_medication.mat']);
        save(MatOutputName, 'medout')
        
        FileContents.pseudonym(FileRowId,1) = cSubs(n);
        FileContents.Timepoint(FileRowId,1) = cSessions(s);
        AllMedNames = fieldnames(medout.medClass);
        UsedMedNames = AllMedNames(struct2array(medout.medClass));
        if numel(UsedMedNames) == 1
            FileContents.MedicationType(FileRowId,1) = UsedMedNames;
        else
            FileContents.MedicationType(FileRowId,1) = {'MultipleMedsUsed'};
        end
        FileContents.LEDD(FileRowId,1) = {medout.LEDD};
        
        FileRowId = FileRowId + 1;
    end
end

MedTable = struct2table(FileContents);
TableOutputName = fullfile(OutputFolder, 'MedicationTable.csv');
if exist(TableOutputName, 'file')
    delete(TableOutputName)
end
writetable(MedTable, TableOutputName)

