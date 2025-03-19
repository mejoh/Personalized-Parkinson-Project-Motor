fName = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_NoTrem/Group/SubInfo.csv';
dat = readtable(fName);
dat.tremorfile = cell(height(dat),1);
dat.destination = cell(height(dat),1);

automaticdir = '/project/3024006.02/Analyses/EMG/motor/automaticdir';
files = cellstr(spm_select('FPList', automaticdir, 'sub-.*'));
personaldir = '/project/3024006.02/Analyses/EMG/motor/automaticdir/Martin';

for n = 1:numel(dat.tremorfile)
    s = dat.Sub{n};
    sel = dat.Selection(n);
    if isnan(sel)
        continue
    end
    fid = find(contains(files, [s '-ses-Visit1']));
    if isempty(fid)
        continue
    end
    dat.tremorfile{n} = files{fid};
    [~, fparts, ~] = fileparts(dat.tremorfile{n});
    newfile = fullfile(personaldir, num2str(sel), fparts);
    dat.destination{n} = newfile;
    
    copyfile(char(dat.tremorfile{n}), dat.destination{n})
end