function mj_DCM_estimate(name,conf)

%--------------------------------------------------------------------------
% mj_DCM_estimate
% 20241121 - Martin E. Johansson
% Estimates DCMs either per session or per subject. Per session estimation
% yields a GCM containing all DCMs belonging to the specified session. Per
% subject estimation yields separate GCMs for each of the subject's
% sessions, which should be collated afterwards to facilitate group
% comparisons. Per session estimation is done either Full+BMR or 
% Full+BMR:PEB. Per subject estimation only allows Full+BMR.
%--------------------------------------------------------------------------

% Locate
if contains(name,'ses-')
    sessiondirs = cellstr(spm_select('FPListRec', conf.firstleveldir, 'dir', name));
elseif contains(name,'sub-')
    sessiondirs = cellstr(spm_select('FPListRec', fullfile(conf.firstleveldir,name), 'dir', 'ses-.*'));
else
    msg = ['Error: ', name, ' does not match the required format (sub- or ses-). Exiting!'];
    error(msg)
end

% Collate DCMs into a GCM file
GCMs = cell(size(sessiondirs,1),1);
for i = 1:size(sessiondirs,1)
    GCMs(i,1) = {spm_select('FPListRec',fullfile(sessiondirs{i}),['DCM_', conf.estimate.dcmname, '.*.mat'])};
end
[GCMs,missing] = rmmissing(GCMs);
fprintf('>>> GCMs prepared, no. of DCMs included: %i\n', sum(~missing))
fprintf('>>> No. of missing DCMs: %i\n', sum(missing))

% Set name of output files
oname = [char(conf.estimate.outputdir), '/GCM_',name,'_',conf.estimate.dcmname,'_PEB-',num2str(conf.estimate.peb)];
    
if conf.estimate.run_by_ses
    % Write text file of GCM contents
    t = [];
    t.pseudonym = strcat('sub-',extractBetween(GCMs,'sub-','/ses'));
    t.Timepoint = strcat('ses-',extractBetween(GCMs,'ses-','/1st_level'));
    t = struct2table(t);
    writetable(t, [oname,'.txt'])
end


% Estimate collated models
if conf.estimate.run_by_ses && conf.estimate.peb
    % Iterative estimation of each DCM in the GCM: estimates, sets priors
    % on each parameter to group mean, then re-estimates. This improves 
    % estimation by overcoming local optima, but takes longer. This option
    % typically considers a group DCM, where each row of the GCM is a
    % separate subject. Here, each row is a single session, meaning that
    % the purpose of the iterative estimation is somewhat different. Here,
    % priors are set to the subject's mean, and each session is
    % re-estimated around that mean. In principle, this approach should
    % give the estimation a bit more information to work with, without
    % making it computationally intractable in large samples.
    GCM = spm_dcm_peb_fit(GCMs);
    % Write GCM to file
    save([oname,'.mat'],'GCM');
elseif conf.estimate.run_by_ses && ~conf.estimate.peb
    % Separate estimation of each DCM in the GCM. Faster, but less accurate
    GCM = spm_dcm_fit(GCMs);
    % Write GCM to file
    save([oname,'.mat'],'GCM');
elseif ~conf.estimate.run_by_ses
    if conf.estimate.peb
        msg = 'Full + BMR PEB is not a viable option when GCMs are estimated by subject and session. Reverting to default Full + BMR estimation...';
        warning(msg)
    end
    for g = 1:numel(GCMs)
        oname_tmp = [char(conf.estimate.outputdir), '/GCM_',name,'_ses-',char(extractBetween(GCMs{g,1}, 'ses-', '/')),'_',conf.estimate.dcmname,'_PEB-',num2str(conf.estimate.peb)];
        fprintf('Running %s\n',oname_tmp)
        GCM = spm_dcm_fit(GCMs{g,1});
        % Write GCM to file
        save([oname_tmp,'.mat'],'GCM');
    end
end
