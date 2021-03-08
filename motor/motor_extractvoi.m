% Description:
% Loads VOI files, removes Catch scans, and saves to new VOI file + csv file for use in R

function motor_extractvoi()

dOutput = '/project/3024006.02/Analyses/VOIs/NoTrem';
% Load SPM.mat file
dAnalysis = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_NoTrem/Group/HcOn x ExtInt2Int3Catch';
fSPM = load(fullfile(dAnalysis, 'SPM.mat'));

% List all available VOIs (except ones that have been edited)
VOI_list = cellstr(spm_select('FPList', dAnalysis, '^VOI.*.mat'));
VOI_list = VOI_list(~contains(VOI_list, 'NoCatch'));
for v = 1:numel(VOI_list)

    % Load info from SPM.mat and voi file
    fVOI = load(VOI_list{v});
    Vals = fVOI.Y;                                  % Extract eigenvariate
    Scans = {fSPM.SPM.xY.VY.fname}';                % List scans that the eigenvariate is based on
    pseudonym = extractBetween(Scans, '_sub-', '_ses');   % Define pseudonyms
    pseudonym = insertBefore(pseudonym,'POM','sub-');
    nHC = sum(contains(Scans,'HC_PIT'))/4;
    nPD = sum(contains(Scans,'PD_POM'))/4;
    Cond_HC = [cellstr(repmat('Ext', nHC, 1)); cellstr(repmat('Int2', nHC, 1)); cellstr(repmat('Int3', nHC, 1)); cellstr(repmat('Catch', nHC, 1))];
    Cond_PD = [cellstr(repmat('Ext', nPD, 1)); cellstr(repmat('Int2', nPD, 1)); cellstr(repmat('Int3', nPD, 1)); cellstr(repmat('Catch', nPD, 1))];
    Cond = [Cond_HC;Cond_PD];                       % Label scans by condition (note that order matters here)
    
    % Define structure of csv file
    Dat.Scans = Scans;
    Dat.pseudonym = pseudonym;
    Dat.Vals = Vals;
    Dat.Cond = Cond;
    Dat.Group = cell(numel(Dat.pseudonym),1);
    for n = 1:numel(Dat.pseudonym)
        if contains(Dat.Scans{n}, 'HC_PIT')
            Dat.Group{n} = 'Healthy';
        else
            Dat.Group{n} = 'Patient';
        end
    end
    Dat = removefields(Dat, 'Scans');

    % Remove data related to the Catch condition
    Sel = true(numel(Dat.Cond),1);
    for n = 1:numel(Cond)
        if strcmp(Cond{n}, 'Catch')
            Sel(n) = false;
        end
    end
    Dat.pseudonym = Dat.pseudonym(Sel);
    Dat.Vals = Dat.Vals(Sel);
    Dat.Cond = Dat.Cond(Sel);
%     Dat.Cond2 = extractBefore(Dat.Cond,4);
    Dat.Group = Dat.Group(Sel);
    
    % Write VOI without Catch condition
    fVOI_edit = fVOI;
    fVOI_edit.Y = fVOI_edit.Y(Sel);
    fVOI_edit.xY.y = fVOI_edit.xY.y(Sel);
    fVOI_edit.xY.u = fVOI_edit.xY.u(Sel);
    OutputName = insertBefore(VOI_list{v}, '.mat', '_NoCatch');
    spm_save(OutputName, fVOI_edit)

    % Write table to csv file for use in R
    Dat_tab = struct2table(Dat);
    OutputName = fullfile(dOutput, ['VOI_' fVOI.xY.name '.csv']);
    writetable(Dat_tab, OutputName)
    
end

end