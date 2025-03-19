function mj_DCM_concatenatesess(subject,conf)

%--------------------------------------------------------------------------
% mj_DCM_concatenatesess
% 20241121 - Martin E. Johansson
% Defining VOIs for separate sessions in a single subject has the downside
% that you allow the VOIs to move around, which they might do based simply
% on noise in the data. This function concatenates 1st-level analyses from
% baseline and follow-up sessions to generate more robust 1st-level results
% that can be used to define VOIs in a manner that is not biased by
% timepoint. Alternatively, these concatenated 1st-level analyses can be
% used to carry out more robust between-subjects comparisons of
% task-related activity. 
%--------------------------------------------------------------------------

% Add SPM to path
if ~exist('spm')
    addpath(conf.spmdir);
    spm fmri
    addpath(conf.additionalsdir);
end

% Define names of new files
newsubname = subject;
newdir = fullfile(conf.firstlevel_rootdir,'concatenated_sessions',newsubname);
if ~exist(newdir,'dir')
    mkdir(newdir)
end

fprintf(['\n >>>  Working on subject ' newsubname '\n']);

%% Locate sessions
cs = [];
cs.sess1.dirname = spm_select('FPList', fullfile(conf.firstleveldir,subject),'dir','ses-.*Visit1');
cs.sess2.dirname = spm_select('FPList', fullfile(conf.firstleveldir,subject),'dir','ses-.*Visit[2-3]');

%% Load SPMsc
cs.sess1.SPM = load(fullfile(cs.sess1.dirname,'1st_level','SPM.mat'));
cs.sess2.SPM = load(fullfile(cs.sess2.dirname,'1st_level','SPM.mat'));

% Check if subject has two sessions, exit if not
if isempty(cs.sess1.SPM) || isempty(cs.sess2.SPM)
    fprintf(['\n >>>  ERROR: ', char(subject), 'does not have multiple sessions. Exiting...\n']);
    return
end

%% Load events
cs.sess1.events = load(spm_select('FPList',cs.sess1.dirname,'.*events.mat'));
cs.sess2.events = load(spm_select('FPList',cs.sess2.dirname,'.*events.mat'));

% Adjust T2 onset times so that they continue where T1 onset times end
cs.sess2.events.onsets = cellfun(@(x) x+(cs.sess1.SPM.SPM.nscan*conf.TR),cs.sess2.events.onsets,'UniformOutput',false);

%% Load confounds
cs.sess1.confts = load(spm_select('FPList',cs.sess1.dirname,'.*confounds_timeseries.*.mat'));
cs.sess2.confts = load(spm_select('FPList',cs.sess2.dirname,'.*confounds_timeseries.*.mat'));

%% Create new concatenated batch
matlabbatch = [];
matlabbatch{1}.spm.stats.fmri_spec.dir = {newdir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 72;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 36;

% Concatenate scans
% matlabbatch{1}.spm.stats.fmri_spec.sess.scans = vertcat(sess1{1}.spm.stats.fmri_spec.sess.scans,sess2{1}.spm.stats.fmri_spec.sess.scans);
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(vertcat(cs.sess1.SPM.SPM.xY.P,cs.sess2.SPM.SPM.xY.P));

% Concatenate events
names =  {'Cue' 'Selection' 'Catch'};% 'Catch' 'Incorrect' 'FalseAlarm' 'Miss'};
onsets{1} = horzcat(cs.sess1.events.onsets{1},cs.sess2.events.onsets{1});
onsets{2} = horzcat(cs.sess1.events.onsets{2},cs.sess2.events.onsets{2});
onsets{3} = horzcat(cs.sess1.events.onsets{3},cs.sess2.events.onsets{3});
average_duration = (cs.sess1.events.durations{1} + cs.sess2.events.durations{1}) / 2;
durations = {average_duration,average_duration,average_duration};
pmod(1).name = {'Cue'};
pmod(2).name = {'Selection'};
pmod(1).param = {horzcat(cs.sess1.events.pmod(1).param{1},cs.sess2.events.pmod(1).param{1})};
pmod(2).param = {horzcat(cs.sess1.events.pmod(2).param{1},cs.sess2.events.pmod(2).param{1})};
pmod(1).poly = {1};
pmod(2).poly = {1};
filename = fullfile(newdir,[subject '_events_concat.mat']);
save(filename,'names','onsets','durations','pmod');
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {filename};

% Concatenate confounds
substrings = {'framewise_displacement', 'std_dvars', 'trans_', 'rot_',...
    'a_comp_cor_00''a_comp_cor_01','a_comp_cor_02','a_comp_cor_03','a_comp_cor_04','a_comp_cor_05','a_comp_cor_06','a_comp_cor_07',...
    't_comp_cor_00','t_comp_cor_01','t_comp_cor_02'};
allnames_t1 = cs.sess1.confts.names;
allnames_t2 = cs.sess2.confts.names;
names={};
for i = 1:length(substrings)                % Finds all instances of substrings in confounds file (multiple instances of trans/rot/t_comp_cor/aroma)
    name_idx = cellfun(@(x) ~isempty(x), strfind(allnames_t1, substrings{i}));
    names = [names, allnames_t1(name_idx)];
end
conf_id_t1 = ismember(allnames_t1,names);
conf_id_t2 = ismember(allnames_t2,names);

% Concatenate as separate confound matrices (probably not feasible)
% testmat1 = vertcat(sess1_regr.R,zeros(size(sess2_regr.R,1),size(sess1_regr.R,2)));
% testmat2 = vertcat(zeros(size(sess1_regr.R,1),size(sess2_regr.R,2)),sess2_regr.R);
% testmat = horzcat(testmat1,testmat2);
% testnames = [strcat('t1_',sess1_regr.names) strcat('t2_',sess2_regr.names)];
% R = horzcat(sessR, testmat);

% concatenate as a single confound matrix
R = horzcat(vertcat(cs.sess1.confts.R(:,conf_id_t1), cs.sess2.confts.R(:,conf_id_t2)));

% Add non-steady state regressors
nst_s1_R = cs.sess1.confts.R(:,contains(cs.sess1.confts.names,'non_steady_state'));
nst_s2_R = cs.sess2.confts.R(:,contains(cs.sess2.confts.names,'non_steady_state'));
nst_s1_names = cs.sess1.confts.names(:,contains(cs.sess1.confts.names,'non_steady_state'));
nst_s2_names = cs.sess2.confts.names(:,contains(cs.sess2.confts.names,'non_steady_state'));
R = horzcat(R, vertcat(nst_s1_R,zeros(size(nst_s2_R,1),size(nst_s1_R,2))));
R = horzcat(R, vertcat(zeros(size(nst_s1_R,1),size(nst_s2_R,2)),nst_s2_R));
names = [names, nst_s1_names, nst_s2_names];

% Add dummy regressors
dum_s1_R = cs.sess1.confts.R(:,contains(cs.sess1.confts.names,'dum'));
dum_s2_R = cs.sess2.confts.R(:,contains(cs.sess2.confts.names,'dum'));
dum_s1_names = cs.sess1.confts.names(:,contains(cs.sess1.confts.names,'dum'));
dum_s2_names = cs.sess2.confts.names(:,contains(cs.sess2.confts.names,'dum'));
R = horzcat(R, vertcat(dum_s1_R,zeros(size(dum_s2_R,1),size(dum_s1_R,2))));
R = horzcat(R, vertcat(zeros(size(dum_s1_R,1),size(dum_s2_R,2)),dum_s2_R));
names = [names, dum_s1_names, dum_s2_names];

% Add AROMA-ICA noise components
aroma_s1_R = cs.sess1.confts.R(:,contains(cs.sess1.confts.names,'aroma2'));
aroma_s2_R = cs.sess2.confts.R(:,contains(cs.sess2.confts.names,'aroma2'));
max_nr_comps = min([size(aroma_s1_R,2),size(aroma_s2_R,2)]);
aroma_R = vertcat(aroma_s1_R(:,1:max_nr_comps), aroma_s2_R(:,1:max_nr_comps));
aroma_names = strcat('a', arrayfun(@(x) cellstr(num2str(x)),1:max_nr_comps));
R = horzcat(R, aroma_R);
names = [names, aroma_names];

% names = horzcat({'Session'}, names);
filename = fullfile(newdir,[subject '_confs_concat.mat']);
save(filename,'R','names');
% writematrix(R,strrep(filename,'.mat','.txt'),'Delimiter','\t')
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {filename};

matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 180;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.3;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';

% spm_fmri_concatenate before estimation: https://www.fil.ion.ucl.ac.uk/spm/docs/wikibooks/Concatenation/
% First, estimate design
save(fullfile(newdir,['Batch_ConcatDesign_' newsubname]),'matlabbatch');
spm_jobman('run',matlabbatch);
% Second, adjust design. Adds block regressors for session + adjust HPF and
% temporal non-sphericity calculations to account for length of sessions
scans = [cs.sess1.SPM.SPM.nscan cs.sess2.SPM.SPM.nscan];
spm_fmri_concatenate(spm_select('FPList',newdir,'SPM.mat'),scans)

% Estimate the concatenated design
matlabbatch = [];
matlabbatch{1}.spm.stats.fmri_est.spmmat(1) = {spm_select('FPList',newdir, 'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{2}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.con.consess{1}.fcon.name = 'EOI';
matlabbatch{2}.spm.stats.con.consess{1}.fcon.weights = [1 0 0 0 0
                                                        0 0 0 0 1];
matlabbatch{2}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{2}.spm.stats.con.consess{2}.tcon.name = 'Cue';
matlabbatch{2}.spm.stats.con.consess{2}.tcon.weights = [1 0 0 0 0];
matlabbatch{2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{2}.spm.stats.con.consess{3}.tcon.name = 'Selection';
matlabbatch{2}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 1];
matlabbatch{2}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
nreg=10+size(R,2);
matlabbatch{2}.spm.stats.con.consess{4}.tcon.name = 'T1>T2';
matlabbatch{2}.spm.stats.con.consess{4}.tcon.weights = [zeros(1,nreg) 1 -1];
matlabbatch{2}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{2}.spm.stats.con.consess{5}.tcon.name = 'T2>T1';
matlabbatch{2}.spm.stats.con.consess{5}.tcon.weights = [zeros(1,nreg) -1 1];
matlabbatch{2}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{2}.spm.stats.con.delete = 0;

save(fullfile(newdir,['Batch_EstimateDesign_' newsubname]),'matlabbatch');
spm_jobman('run',matlabbatch);

fprintf(['\n ----------  Concatenated and ran first level for subject ' newsubname '\n']);

end