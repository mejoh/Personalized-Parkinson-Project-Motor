function mj_DCM_collate_stochastic(name,conf)
    
    search_for = ['^GCM_sub-.*',name,'.*',conf.DCM_collate_stoch.dcmname,'_PEB-',num2str(conf.DCM_collate_stoch.peb),'.mat'];
    GMC_mat = cellstr(spm_select('FPList',conf.DCM_collate_stoch.gcmdir,search_for));
    
    % Tabularize subject names and sessions and write to file
    oname = fullfile(conf.DCM_collate_stoch.gcmdir, ['GCM_',name,'_',conf.DCM_collate_stoch.dcmname,'_PEB-',num2str(conf.DCM_collate_stoch.peb),'.txt']);
    t = [];
    t.pseudonym = strcat('sub-',extractBetween(GMC_mat,'sub-','_ses'));
    t.Timepoint = strcat('ses-',extractBetween(GMC_mat,'ses-','_c'));
    t = struct2table(t);
    writetable(t, oname)
    
    % Collate GCMs by session and write to file
    oname = strrep(oname,'.txt','.mat');
    GCMs=[];
    for i = 1:numel(GMC_mat)
        load(GMC_mat{i,1})
        GCMs=[GCMs;GCM];
    end
    GCM=GCMs;
    save(oname,'GCM','-v7.3')
    
end