addpath(genpath('/home/sysneu/marjoh/scripts/MatlabTFCE'))
cd /project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/con_0001/
imgs_on = dir('PD_POM*');
imgs_off = dir('PD_PIT*');
imgs_all = [imgs_on; imgs_off];
NrImgs = length(imgs_all);
imgs = string(NaN(NrImgs,1));
for n = 1:NrImgs
    imgs(n) = string([imgs_all(n).folder '/' imgs_all(n).name]);
end
NrSub = length(imgs)/2;
on = [ones(NrSub,1) eye(NrSub)];
off = [-1*ones(NrSub,1) eye(NrSub)];
design = [on;off];
FD = rand(NrSub*2,1);
design = [design FD];

imgs_4d = NaN(91,109,91,NrImgs);
for n = 1:NrImgs 
    img_loaded =  load_nii(char(imgs(n)));
    imgs_4d(:,:,:,n) = img_loaded.img;
end

[pcorr_pos,pcorr_neg] = matlab_tfce('regression',2,imgs_4d,[],design,50,[],[],[],[],[],[0 ones(NrSub,1)' 1]);

pcorr_pos_nii = make_nii(pcorr_pos{1});
save_nii(pcorr_pos_nii, '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/con_0001/pcorr_pos.nii')
pcorr_neg_nii = make_nii(pcorr_neg{1});
save_nii(pcorr_neg_nii, '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/con_0001/pcorr_neg.nii')
