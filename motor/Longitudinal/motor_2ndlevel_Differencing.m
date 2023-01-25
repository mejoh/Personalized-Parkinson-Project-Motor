% motor_2ndlevel_Differencing.m
% Martin E. Johansson
% Calculates between-session differences per participant
% Finds follow-up data, matches it with baseline data, checks that L2R
% swapping is consistent between images, then takes the T2 - T1 difference.

dGroup = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group';
con = {'con_0001','con_0002','con_0003','con_0004', 'con_0005',...
    'con_0010', 'con_0007', 'con_0012', 'con_0013'};
% con = {'con_0005'};

for c = 1:numel(con)
    
    fprintf('Processing %s... \n', con{c})

    % Ensure that con has both baseline and follow-up directories
    dCon = fullfile(dGroup,con{c});
    s1 = spm_select('FPList',dCon,'dir','^ses-Visit1');
    s2 = spm_select('FPList',dCon,'dir','^ses-Visit2');
    try
        s1_s2 = [exist(s1,'dir'); exist(s2,'dir')];
    catch
        error('Missing session!')
    end
    
    % Select available images
    s1_imgs = cellstr(spm_select('List',s1,'.*nii'));
    s2_imgs = cellstr(spm_select('List',s2,'.*nii'));
    
    s1_imgs = s1_imgs(~contains(s1_imgs,'PD_PIT'));
    s2_imgs = s2_imgs(~contains(s2_imgs,'PD_PIT'));
    
    fprintf('Found %i baseline images \n', numel(s1_imgs))
    fprintf('Found %i follow-up images \n', numel(s2_imgs))
    
    % Differencing procedure
    dOut = fullfile(dCon,'ses-Diff');
    if ~exist(dOut,'dir')
 		mkdir(dOut)
 	else
 		delete(fullfile(dOut,'*.*'))
    end
    dOutS1 = fullfile(dCon,'COMPLETE_ses-Visit1');
    if ~exist(dOutS1,'dir')
 		mkdir(dOutS1)
 	else
 		delete(fullfile(dOutS1,'*.*'))
    end
    dOutS2 = fullfile(dCon,'COMPLETE_ses-Visit2');
    if ~exist(dOutS2,'dir')
 		mkdir(dOutS2)
 	else
 		delete(fullfile(dOutS2,'*.*'))
    end
    for i = 1:numel(s2_imgs)
        
        % Select follow-up image
        b = s2_imgs{i};
        
        % Check whether there is a corresponding baseline image
        pseudo = extractBetween(b, 'sub-','_ses');
        idx = contains(s1_imgs,pseudo);
        if sum(idx) == 1
            a = s1_imgs{idx};
        elseif sum(idx) == 2
            % Multiple matching images indicates cohort overlap, which
            % needs to be resolved in order to select the correct image
            [img1, img2] = s1_imgs{idx};
            mi = {img1;img2};
            cohort = extractBefore(b,'_sub');
            idx = contains(mi, cohort);
            a = mi{idx};
        else
            fprintf('Skipping %s lacks visit 1 for %s\n',char(pseudo),con{c})
            continue
        end
        
        % Check consistency of L2R swapping
        bLRswap = contains(b, 'L2Rswap');
        aLRswap = contains(a, 'L2Rswap');
        if bLRswap ~= aLRswap
            fprintf('Skipping %s %s: swapping procedure is inconsistent!!\n',char(pseudo),con{c})
            continue
        end
        
        % Read volumes
        imvol = spm_vol([fullfile(s1,a);fullfile(s2,b)]);
        
        % Take difference between follow-up and baseline
        if(contains(b,'Visit2'))
            output_img = fullfile(dOut, strrep(b,'Visit2','VisitDiff'));
        elseif (contains(b,'Visit3'))
            output_img = fullfile(dOut, strrep(b,'Visit3','VisitDiff'));
        end
        Q = spm_imcalc(imvol, output_img, 'i2-i1');
        
        % Save complete case images
        copyfile(imvol(1).fname, dOutS2)
        copyfile(imvol(2).fname, dOutS1)
        
    end

end