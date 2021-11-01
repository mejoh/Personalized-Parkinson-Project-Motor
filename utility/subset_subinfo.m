% [s] = subset_subinfo(SubInfo, Sel)
% Subsets all fields of a structure based on a logical vector
% SubInfo - Structure used to store information necessary for SPM group analyses
% Sel - Logical vector denoting which rows of SubInfo (i.e. subjects) to retain

function [s] = subset_subinfo(SubInfo, Sel)

s = SubInfo;
fs = fieldnames(s);
for i=1:numel(fs)
    field = fs{i};
    s.(field) = s.(field)(Sel,:);
end