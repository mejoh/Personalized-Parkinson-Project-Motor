% Read in quality control checks and locate outliers
f1 = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/con_0001/Group.txt';
f2 = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/con_0002/Group.txt';
f3 = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/con_0003/Group.txt';
f4 = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/ResMS/Group.txt';
t1 = readtable(f1);
t3 = readtable(f2);
t4 = readtable(f3);
t5 = readtable(f4);


% PD_POM has a weird thing going on in con_0003
% Take all subject names from this con and quality control
input = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/OffOn x ExtInt2Int3Catch/Inputs.mat';
dat = load(input);
dat = dat.Inputs;
d = dat{7,1};
s = extractBetween(d,97,120);

