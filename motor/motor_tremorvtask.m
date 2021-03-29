% Compute correlation between tremor regressor and task conditions
function [ext, int2, int3, bp] = motor_tremorvtask(spmmat, tremreg)

if ~exist(spmmat, 'file') || ~exist(tremreg, 'file')
    msg = 'Cannot find SPM matfile or tremor regressor file';
    error(msg)
end

load(spmmat);
regnames = {'Sn(1) Ext*bf(1)', 'Sn(1) Int2*bf(1)', 'Sn(1) Int3*bf(1)', 'Sn(1) ButtonPress*bf(1)'};
regids = contains(SPM.xX.name, regnames);
taskregressors = SPM.xX.X(:,regids);

load(tremreg);
leftpad = zeros(5,1);
tremorregressor = [leftpad; R(:,2)];

ext = corr(taskregressors(:,1), tremorregressor);
int2 = corr(taskregressors(:,2), tremorregressor);
int3 = corr(taskregressors(:,3), tremorregressor);
bp = corr(taskregressors(:,4), tremorregressor);

end