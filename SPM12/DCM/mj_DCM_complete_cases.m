function mj_DCM_complete_cases(sessions,conf)

%--------------------------------------------------------------------------
% mj_DCM_estimate
% 20241129 - Martin E. Johansson
% Identifies subjects with complete-case data and writes new GCMs for this
% subset.
%--------------------------------------------------------------------------

% Identify subjects with complete-case data
fname_txt_t0 = fullfile(conf.DCM_complete_cases.gcmdir,['GCM_',sessions{1},'_',conf.DCM_complete_cases.dcmname,'_PEB-',num2str(conf.DCM_complete_cases.peb),'.txt']);
fname_txt_t1 = strrep(fname_txt_t0,sessions{1},sessions{2});
tab_t0 = readtable(fname_txt_t0);
tab_t1 = readtable(fname_txt_t1);
[~, idx0, idx1] = intersect(tab_t0(:,1),tab_t1(:,1));
tab_t0 = tab_t0(idx0,:);
tab_t1 = tab_t1(idx1,:);
writetable(tab_t0,fullfile(conf.DCM_complete_cases.outputdir, basename(fname_txt_t0)));
writetable(tab_t1,fullfile(conf.DCM_complete_cases.outputdir, basename(fname_txt_t1)));

% Write new GCMs. Note that the variable wherein the GCMs are stored must
% be 'GCM' for this to work!
fname_mat_t0 = strrep(fname_txt_t0, '.txt', '.mat');
fname_mat_t1 = strrep(fname_mat_t0,sessions{1},sessions{2});
GCM = [];
GCM = load(fname_mat_t0);
GCM = GCM.GCM(idx0,1);
save(fullfile(conf.DCM_complete_cases.outputdir, basename(fname_mat_t0)),'GCM','-v7.3');
GCM = [];
GCM = load(fname_mat_t1);
GCM = GCM.GCM(idx1,1);
save(fullfile(conf.DCM_complete_cases.outputdir, basename(fname_mat_t1)),'GCM','-v7.3');
