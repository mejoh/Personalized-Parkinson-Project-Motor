ex = table2cell(readtable('/project/3024006.02/Analyses/CAT12/Exclusions.txt', 'ReadVariableNames', false));

hc = cellstr(spm_select('FPList', pwd, 'HC_sub.*'));
Sel = true(size(hc));
for i = 1:numel(hc)
    if contains(hc{i}, ex)
        Sel(i) = false;
    end
end
hc = hc(Sel);

pd = cellstr(spm_select('FPList', pwd, 'PD_sub.*'));
Sel = true(size(pd));
for i = 1:numel(pd)
    if contains(pd{i}, ex)
        Sel(i) = false;
    end
end
pd = pd(Sel);

p = randperm(numel(pd), numel(hc));
images = [hc; pd(p)];

for i = 1:numel(images)
    copyfile(images{i}, '/project/3024006.02/Analyses/CAT12/processing/fslvbm_template/')
end

writecell(images, '/project/3024006.02/Analyses/CAT12/processing/template_list');