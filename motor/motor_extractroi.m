% Description:
% Searches an SPM group analysis directory for ROI files
% Writes CSV file containing ROI information intended for plotting in R
% Columns: pseudonym, group, condition, eigenvariate values

% Preparation:
% 1. Create marsbar directory in analysis folder
% 2. spm > Toolbox > marsbar
% 3. ROI definition > Get SPM clusters > Threshold at FWEc extent and write
% all clusters
% 4. Design > Set design from file > Select SPM.mat
% 5. Data > Extract ROI data (default) > Select all available rois > Save data to file > Store data in
% marsbar directory

% AnalysisDirectory = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcOn_x_ExtInt2Int3Catch_NoOutliers';


function motor_extractroi(AnalysisDirectory)

fROIdat = load(fullfile(AnalysisDirectory, 'marsbar', 'roi_data.mat'));

for v = 1:numel(fROIdat.regions)
    
    % Load info from SPM.mat and ROI data file
    Region = fROIdat.regions{1,v}.name;
    Vals = fROIdat.Y(:,v);
    Scans = {fROIdat.info.VY.fname}';
    [~, Scans] = fileparts(Scans);
    
    fprintf('Generating table: %s \n', Region)
    
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
            Dat.Cond{i} = 'IntgtExt';
        elseif contains(Dat.scans{i}, 'con_0010')
            Dat.Cond{i} = 'Mean_ExtInt';
        elseif contains(Dat.scans{i}, 'con_0012')
            Dat.Cond{i} = 'Int2gtExt';
        elseif contains(Dat.scans{i}, 'con_0013')
            Dat.Cond{i} = 'Int3gtExt';
        elseif contains(Dat.scans{i}, 'con_0008')
            Dat.Cond{i} = 'Int3gtInt2';
        else
            error('Error: Contrast files do not match any available conditions')
        end
    end

    % Write table to csv file for use in R
    Dat_tab = struct2table(Dat);
    OutputName = fullfile(AnalysisDirectory, 'marsbar', [Region, '.csv']);
    writetable(Dat_tab, OutputName, 'WriteMode', 'overwrite')
    
end

end