% [s] = remove_subs(Sub, RemovalPattern)
% Removes subjects that match a given pattern
% Sub - Cell vector containing subject names
% RemovalPattern - Self-explanatory, e.g. RemovalPattern = 'PD_POM_sub-POMU[7-9A-Z].*';
% Tip: set RemovalPattern = '' to retain all participants

function [s] = remove_subs(Sub, RemovalPattern)

s = Sub;
idx = regexp(Sub,RemovalPattern, 'match');
idx = [idx{:}]';
Sel = false(size(s));
for n = 1:numel(s)
    if sum(strcmp(idx, s{n})) < 1
        Sel(n) = true;
    end
end
s = s(Sel);