% Description:
% Searches an SPM group analysis directory for VOI files
% Writes CSV file containing VOI information intended for plotting in R
% Columns: pseudonym, group, condition, eigenvariate values

function motor_extractvoi(AnalysisDirectory)

fSPM = load(fullfile(AnalysisDirectory, 'SPM.mat'));
VOI_list = cellstr(spm_select('FPList', AnalysisDirectory, '^VOI.*.mat'));

for v = 1:numel(VOI_list)

    % Load info from SPM.mat and voi file
    fVOI = load(VOI_list{v});
    fprintf('Generating table: %s, %s \n', fVOI.xY.name, fVOI.xY.str)
    Vals = fVOI.Y;                                  % Extract eigenvariate
    Scans = {fSPM.SPM.xY.VY.fname}';                % List scans that the eigenvariate is based on
    [~, Scans] = fileparts(Scans);
    pseudonym = extractBetween(Scans, '_sub-', '_ses');   % Define pseudonyms
    pseudonym = insertBefore(pseudonym, 1, 'sub-');
    group = extractBefore(Scans, '_sub-');
    
    % Define structure of csv file
    Dat = [];
    Dat.scans = Scans;
    Dat.pseudonym = pseudonym;
    Dat.Group = group;
    Dat.Vals = round(Vals, 8);
    Dat.Cond = cell(size(Dat.scans));
    for i = 1:numel(Dat.Cond)
        if contains(Dat.scans{i}, 'con_0001')
            Dat.Cond{i} = 'Ext';
        elseif contains(Dat.scans{i}, 'con_0002')
            Dat.Cond{i} = 'Int2';
        elseif contains(Dat.scans{i}, 'con_0003')
            Dat.Cond{i} = 'Int3';
        elseif contains(Dat.scans{i}, 'con_0004')
            Dat.Cond{i} = 'Catch';
        elseif contains(Dat.scans{i}, 'con_0007')
            Dat.Cond{i} = 'Mean_ExtInt';
        elseif contains(Dat.scans{i}, 'con_0010')
            Dat.Cond{i} = 'Int>Ext';
        end
    end

    % Write table to csv file for use in R
    Dat_tab = struct2table(Dat);
    OutputName = replace(VOI_list{v}, '.mat', '.csv');
    writetable(Dat_tab, OutputName, 'WriteMode', 'overwrite')
    
end

end