function mj_DCM_split_subgroups(conf)

% Locate GCMs
GCMs_txt = cellstr(spm_select('FPList',conf.DCM_split_subgroups.gcmdir,['GCM_ses.*',conf.DCM_split_subgroups.dcmname,'_PEB-',num2str(conf.DCM_split_subgroups.peb),'.txt']));
GCMs_mat = cellstr(spm_select('FPList',conf.DCM_split_subgroups.gcmdir,['GCM_ses.*',conf.DCM_split_subgroups.dcmname,'_PEB-',num2str(conf.DCM_split_subgroups.peb),'.mat']));

% Find relevant sessions
GCM_txt_01 = readtable(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{1})});
GCM_mat_01 = load(GCMs_mat{contains(GCMs_mat,conf.DCM_split_subgroups.sessions{1})});
GCM_txt_02 = readtable(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{2})});
GCM_mat_02 = load(GCMs_mat{contains(GCMs_mat,conf.DCM_split_subgroups.sessions{2})});

% Healthy controls
HC = conf.DCM_split_subgroups.ptype.pseudonym(conf.DCM_split_subgroups.ptype.ParticipantType == -1, 1);
idx = contains(GCM_txt_01.pseudonym, HC);
LIST = GCM_txt_01(idx,:);
GCM = GCM_mat_01.GCM(idx);
writetable(LIST, strrep(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{1})},'.txt','_g-HC.txt'));
save(char(strrep(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{1})},'.txt','_g-HC.mat')),'GCM','-v7.3');

% Patients
% PD = conf.DCM_split_subgroups.ptype.pseudonym(conf.DCM_split_subgroups.ptype.ParticipantType == 1, 1);
PD_shared = intersect(GCM_txt_01.pseudonym, GCM_txt_02.pseudonym);
% OFF-state
idx_01 = contains(GCM_txt_01.pseudonym, PD_shared);
LIST = GCM_txt_01(idx_01,:);
GCM = GCM_mat_01.GCM(idx_01);
writetable(LIST, strrep(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{1})},'.txt','_g-PD.txt'));
save(char(strrep(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{1})},'.txt','_g-PD.mat')),'GCM','-v7.3');
% ON-state
idx_02 = contains(GCM_txt_02.pseudonym, PD_shared);
LIST = GCM_txt_02(idx_02,:);
GCM = GCM_mat_02.GCM(idx_02);
writetable(LIST, strrep(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{2})},'.txt','_g-PD.txt'));
save(char(strrep(GCMs_txt{contains(GCMs_txt,conf.DCM_split_subgroups.sessions{2})},'.txt','_g-PD.mat')),'GCM','-v7.3');


end