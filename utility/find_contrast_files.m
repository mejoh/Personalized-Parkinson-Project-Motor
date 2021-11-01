% files = find_contrast_files(Sub, Conpath)
% Find contrast files for a set of subjects
% Sub - Cell vector containing subjects
% Conpath - Path to contrast of interest

function files = find_contrast_files(Sub, Conpath)

s = Sub;     %Sub=MildMotor;
c = Conpath; %Conpath=fullfile(ANALYSESDir, 'Group', ConList{1}, ses);

files = cell(size(s));
for n=1:numel(files)
    files{n} = spm_select('FPList', c, s{n});
end

end