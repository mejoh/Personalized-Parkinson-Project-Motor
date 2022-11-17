compute_summaryscores <- function(df){
  
  ##### Lists of scores to summarize #####
        #Motor (MDS-UPDRS III)
        list.TotalOff <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle',
                     'Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                     'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                     'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur', 'Up3OfSpont', 'Up3OfPosTYesDev',
                     'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev',
                     'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw', 'Up3OfConstan')
        list.TotalOn <- str_replace(list.TotalOff, 'Of','On')
        list.BradykinesiaOff <- c('Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                                  'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                                  'Up3OfArise', 'Up3OfSpont')
        list.BradykinesiaOn <- str_replace(list.BradykinesiaOff, 'Of', 'On')
        list.RigidityOff <- c('Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle')
        list.RigidityOn <- str_replace(list.RigidityOff, 'Of','On')
        list.AppendicularOff <- c(list.BradykinesiaOff, list.RigidityOff)
        list.AppendicularOn <- str_replace(list.AppendicularOff, 'Of', 'On')
        list.PIGDOff <- c('Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Updrs2It25', 'Updrs2It26')     # Stebbins et al. 2013
        list.PIGDOn <- str_replace(list.PIGDOff, 'Of', 'On')
        list.PIGDOff_Up3Only <- c('Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos')
        list.PIGDOn_Up3Only <- str_replace(list.PIGDOff_Up3Only, 'Of', 'On')
        list.AXIALOff <- c('Up3OfSpeech', 'Up3OfArise', 'Up3OfPostur', 'Up3OfGait', 'Up3OfStaPos')    # Lau et al., 2019, Neurology
        list.AXIALOn <- str_replace(list.AXIALOff, 'Of', 'On')
        list.RestTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfConstan') # Zach et al., 2020
        list.RestTremorOn <- str_replace(list.RestTremorOff, 'Of', 'On')
        list.RestTremor2Off <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw', 'Up3OfConstan')
        list.RestTremor2On <- str_replace(list.RestTremorOff, 'Of', 'On')
        list.ActionTremorOff <- c('Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev')
        list.ActionTremorOn <- str_replace(list.RigidityOff, 'Of', 'On')
        list.CompositeTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw',
                                     'Up3OfConstan','Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Updrs2It23') # Stebbins et al. 2013
        list.CompositeTremorOn <- str_replace(list.CompositeTremorOff, 'Of', 'On')
        list.OtherOff <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfPostur', 'Up3OfRAmpJaw')
        list.OtherOn <- str_replace(list.OtherOff, 'Of', 'On')
        #Motor (MDS-UPDRS II)
        list.updrs2total <- c('Updrs2It14', 'Updrs2It15', 'Updrs2It16', 'Updrs2It17', 'Updrs2It18', 'Updrs2It19',
                              'Updrs2It20', 'Updrs2It21', 'Updrs2It22', 'Updrs2It23', 'Updrs2It24', 'Updrs2It25', 'Updrs2It26')
        #Motor, PIT
        list.TotalOff_pit <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle',
                               'Up3OfRigLle', 'Up3OfFiTaR', 'Up3OfFiTaL', 'Up3OfHaMoR', 'Up3OfHaMoL', 'Up3OfProS',
                               'Up3OfProSL', 'Up3OfToTaR', 'Up3OfToTaL', 'Up3OfLAgiR', 'Up3OfLAgiL',
                               'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur', 'Up3OfSpont',
                               'Up3OfPosTR', 'Up3OfPosTL', 'Up3OfKinTreR', 'Up3OfKinTreL', 'Up3OfRAmpArmR', 'Up3OfRAmpArmL',
                               'Up3OfRAmpLegR', 'Up3OfRAmpLegL', 'Up3OfRAmpJaw', 'Up3OfConstan')
        list.BradykinesiaOff_pit <- c('Up3OfFiTaR', 'Up3OfFiTaL', 'Up3OfHaMoR', 'Up3OfHaMoL', 'Up3OfProS',
                                      'Up3OfProSL', 'Up3OfToTaR', 'Up3OfToTaL', 'Up3OfLAgiR', 'Up3OfLAgiL',
                                      'Up3OfArise', 'Up3OfSpont')
        list.RigidityOff_pit <- c('Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle')
        list.AppendicularOff_pit <- c(list.BradykinesiaOff_pit, list.RigidityOff_pit)
        list.PIGDOff_pit <- c('Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos')
        list.AXIALOff_pit <- c('Up3OfSpeech', 'Up3OfArise', 'Up3OfPostur', 'Up3OfGait', 'Up3OfStaPos') 
        list.RestTremorOff_pit <- c('Up3OfRAmpArmR', 'Up3OfRAmpArmL', 'Up3OfRAmpLegR', 'Up3OfRAmpLegL', 'Up3OfRAmpJaw', 'Up3OfConstan')
        list.ActionTremorOff_pit <- c('Up3OfPosTR', 'Up3OfPosTL', 'Up3OfKinTreR', 'Up3OfKinTreL')
        list.CompositeTremorOff_pit <- c('Up3OfRAmpArmR', 'Up3OfRAmpArmL', 'Up3OfRAmpLegR', 'Up3OfRAmpLegL', 'Up3OfRAmpJaw', 'Up3OfConstan',
                                         'Up3OfPosTR', 'Up3OfPosTL', 'Up3OfKinTreR', 'Up3OfKinTreL')
        #Non-motor
        list.updrs1_1to6 <- c('Up1aAnxious', 'Up1aApathy', 'Up1aCognit', 'Up1aDepres', 'Up1aDopDysSyn', 'Up1aHalPsy')
        list.updrs1_7to13 <- c('Updrs2It07', 'Updrs2It08', 'Updrs2It09', 'Updrs2It10', 'Updrs2It11', 'Updrs2It12', 'Updrs2It13')
        list.updrs1_total <- c(list.updrs1_1to6, list.updrs1_7to13)
        list.STAITrait <- c('StaiTrait01', 'StaiTrait02', 'StaiTrait03', 'StaiTrait04', 'StaiTrait05', 'StaiTrait06', 'StaiTrait07',
                            'StaiTrait08', 'StaiTrait09', 'StaiTrait10', 'StaiTrait11', 'StaiTrait12', 'StaiTrait13', 'StaiTrait14',
                            'StaiTrait15', 'StaiTrait16', 'StaiTrait17', 'StaiTrait18', 'StaiTrait19', 'StaiTrait20')
        list.STAIState <- c('StaiState01', 'StaiState02', 'StaiState03', 'StaiState04', 'StaiState05', 'StaiState06', 'StaiState07',
                            'StaiState08', 'StaiState09', 'StaiState10', 'StaiState11', 'StaiState12', 'StaiState13', 'StaiState14',
                            'StaiState15', 'StaiState16', 'StaiState17', 'StaiState18', 'StaiState19', 'StaiState20')
        list.QUIP_gambling <- c('QuipIt01', 'QuipIt08', 'QuipIt15', 'QuipIt22')
        list.QUIP_sex <- c('QuipIt02', 'QuipIt09', 'QuipIt16', 'QuipIt23')
        list.QUIP_buying <- c('test', 'QuipIt10', 'QuipIt17', 'QuipIt24')
        list.QUIP_eating <- c('QuipIt03', 'QuipIt11', 'QuipIt18', 'QuipIt25')
        list.QUIP_hobbypund <- c('QuipIt04', 'QuipIt12', 'QuipIt19', 'QuipIt26', 'QuipIt05', 'QuipIt13', 'QuipIt20', 'QuipIt27')
        list.QUIP_medication <- c('QuipIt06', 'QuipIt14', 'QuipIt21', 'QuipIt28')
        list.QUIP_icd <- c(list.QUIP_gambling, list.QUIP_sex, list.QUIP_buying, list.QUIP_eating)
        list.QUIP_rs <- c(list.QUIP_icd, list.QUIP_hobbypund, list.QUIP_medication)
        list.AES12 <- c('Aes12Pd01', 'Aes12Pd02', 'Aes12Pd03', 'Aes12Pd04', 'Aes12Pd05', 'Aes12Pd06', 'Aes12Pd07', 'Aes12Pd08', 'Aes12Pd09',
                        'Aes12Pd10', 'Aes12Pd11', 'Aes12Pd12')
        list.Apat <- c('Apat01','Apat02','Apat03','Apat04','Apat05','Apat06','Apat07','Apat08','Apat09','Apat10','Apat11','Apat12',
                       'Apat13','Apat14')
        list.BDI2 <- c('Bdi2It01', 'Bdi2It02', 'Bdi2It03', 'Bdi2It04', 'Bdi2It05', 'Bdi2It06', 'Bdi2It07', 'Bdi2It08', 'Bdi2It09',  'Bdi2It10',
                       'Bdi2It11', 'Bdi2It12', 'Bdi2It13', 'Bdi2It14', 'Bdi2It15', 'Bdi2It16', 'Bdi2It17', 'Bdi2It18', 'Bdi2It19', 'Bdi2It20', 'Bdi2It21')
        list.ROMP <- c('TalkProb01', 'TalkProb02', 'TalkProb03', 'TalkProb04', 'TalkProb05', 'TalkProb06', 'TalkProb07')
        list.VIPDQ23 <- c('VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04', 'VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr08', 'VisualPr09',
                               'VisualPr10', 'VisualPr11', 'VisualPr12', 'VisualPr13', 'VisualPr14', 'VisualPr15', 'VisualPr16', 'VisualPr17', 'VisualPr18',
                               'VisualPr19', 'VisualPr20', 'VisualPr21', 'VisualPr22', 'VisualPr23')
        list.VIPDQ17_ocularsurface <- c('VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04')
        list.VIPDQ17_intraocular <- c('VisualPr08','VisualPr09','VisualPr15','VisualPr19')
        list.VIPDQ17_oculomotor <- c('VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr23')
        list.VIPDQ17_opticnerve <- c('VisualPr11', 'VisualPr13', 'VisualPr14', 'VisualPr21', 'VisualPr22')
        list.VIPDQ17 <- c(list.VIPDQ17_ocularsurface, list.VIPDQ17_intraocular, list.VIPDQ17_oculomotor, list.VIPDQ17_opticnerve)
        list.PDQ39_mobility <- c("Pdq39It01","Pdq39It02","Pdq39It03","Pdq39It04","Pdq39It05","Pdq39It06","Pdq39It07","Pdq39It08","Pdq39It09","Pdq39It10")
        list.PDQ39_activities <- c("Pdq39It11","Pdq39It12","Pdq39It13","Pdq39It14","Pdq39It15","Pdq39It16")
        list.PDQ39_emotional <- c("Pdq39It17","Pdq39It18","Pdq39It19","Pdq39It20","Pdq39It21","Pdq39It22")
        list.PDQ39_stigma <- c("Pdq39It23","Pdq39It24","Pdq39It25","Pdq39It26")
        list.PDQ39_socialsupport <- c("Pdq39It27","Pdq39It28b","Pdq39It29")
        list.PDQ39_cognitions <- c("Pdq39It30","Pdq39It31","Pdq39It32","Pdq39It33")
        list.PDQ39_communication <- c("Pdq39It34","Pdq39It35","Pdq39It36")
        list.PDQ39_bodilydiscomfort <- c("Pdq39It37","Pdq39It38","Pdq39It39")
        list.PDQ39_singleindex <-  c('PDQ39_mobilitySum', 'PDQ39_activitiesSum', 'PDQ39_emotionalSum', 'PDQ39_stigmaSum', 'PDQ39_socialsupportSum',
                                     'PDQ39_cognitionsSum', 'PDQ39_communicationSum', 'PDQ39_bodilydiscomfortSum')
        list.RBDSQ <- c('RemSbdq01', 'RemSbdq02', 'RemSbdq03', 'RemSbdq04', 'RemSbdq05',
                   'RemSbdq06', 'RemSbdq07', 'RemSbdq08', 'RemSbdq09', 'RemSbdq10', 
                   'RemSbdq11', 'RemSbdq12')
        list.SCOPA_AUT.man <- c('ScopaAut01', 'ScopaAut02', 'ScopaAut03', 'ScopaAut04', 'ScopaAut05',
                       'ScopaAut06', 'ScopaAut07', 'ScopaAut08', 'ScopaAut09', 'ScopaAut10',
                       'ScopaAut11', 'ScopaAut12', 'ScopaAut13', 'ScopaAut14', 'ScopaAut15',
                       'ScopaAut16', 'ScopaAut17', 'ScopaAut18', 'ScopaAut19', 'ScopaAut20',
                       'ScopaAut21', 'ScopaAut23', 'ScopaAut24')
        list.SCOPA_AUT.woman <- c('ScopaAut01', 'ScopaAut02', 'ScopaAut03', 'ScopaAut04', 'ScopaAut05',
                                'ScopaAut06', 'ScopaAut07', 'ScopaAut08', 'ScopaAut09', 'ScopaAut10',
                                'ScopaAut11', 'ScopaAut12', 'ScopaAut13', 'ScopaAut14', 'ScopaAut15',
                                'ScopaAut16', 'ScopaAut17', 'ScopaAut18', 'ScopaAut19', 'ScopaAut20',
                                'ScopaAut21', 'ScopaAut27', 'ScopaAut28')
        list.MOCA <- c('NpsMocVisExe', 'NpsMocNaming', 'NpsMocAtten1', 'NpsMocAtten2', 'NpsMocAtten3',
                       'NpsMocLangu1', 'NpsMocLangu2', 'NpsMocAbstra', 'NpsMocDelRec', 'NpsMocOrient')
                # Scores that have not yet been summarized
        # list.ESS <- c('Ess1','Ess2','Ess3','Ess4','Ess5','Ess6','Ess7','Ess8',)
        # list.SCOPASLP_night <- c('ScopaSlp03','ScopaSlp04','ScopaSlp05','ScopaSlp06','ScopaSlp07')
        # list.SCOPASLP_global <- c('ScopaSlp08')
        # list.SCOPASLP_day <- c('ScopaSlp09','ScopaSlp10','ScopaSlp11','ScopaSlp12','ScopaSlp13','ScopaSlp14')
        # list.NFOGQ <- c('FrOfGait02','FrOfGait03','FrOfGait04','FrOfGait05','FrOfGait06','FrOfGait07','FrOfGait08','FrOfGait09')
        # list.PASE <- c()
        # list.WOQ <- c()
        # list.SF12 <-c()
        #####
        df1 <- df %>%
                plyr::mutate(Up3OfTotal = rowSums(.[list.TotalOff]), Up3OfTotal.NrItems = length(list.TotalOff),
                       Up3OnTotal = rowSums(.[list.TotalOn]), Up3OnTotal.NrItems = length(list.TotalOn)) %>%
                plyr::mutate(Up3OfBradySum = rowSums(.[list.BradykinesiaOff]), Up3OfBradySum.NrItems = length(list.BradykinesiaOff),
                       Up3OnBradySum = rowSums(.[list.BradykinesiaOn]), Up3OnBradySum.NrItems = length(list.BradykinesiaOn)) %>%
                plyr::mutate(Up3OfRigiditySum = rowSums(.[list.RigidityOff]), Up3OfRigiditySum.NrItems = length(list.RigidityOff),
                       Up3OnRigiditySum = rowSums(.[list.RigidityOn]), Up3OnRigiditySum.NrItems = length(list.RigidityOn)) %>%
                plyr::mutate(Up3OfAppendicularSum = rowSums(.[list.AppendicularOff]), Up3OfAppendicularSum.NrItems = length(list.AppendicularOff),
                       Up3OnAppendicularSum = rowSums(.[list.AppendicularOn]), Up3OnAppendicularSum.NrItems = length(list.AppendicularOn)) %>%
                plyr::mutate(Up3OfPIGDSum = rowSums(.[list.PIGDOff]), Up3OfPIGDSum.NrItems = length(list.PIGDOff),
                       Up3OnPIGDSum = rowSums(.[list.PIGDOn]), Up3OnPIGDSum.NrItems = length(list.PIGDOn)) %>%
                plyr::mutate(Up3OfPIGDSum_Up3Only = rowSums(.[list.PIGDOff_Up3Only]), Up3OfPIGDSum_Up3Only.NrItems = length(list.PIGDOff_Up3Only),
                             Up3OnPIGDSum_Up3Only = rowSums(.[list.PIGDOn_Up3Only]), Up3OnPIGDSum_Up3Only.NrItems = length(list.PIGDOn_Up3Only)) %>%
                plyr::mutate(Up3OfAxialSum = rowSums(.[list.AXIALOff]), Up3OfAxialSum.NrItems = length(list.AXIALOff),
                       Up3OnAxialSum = rowSums(.[list.AXIALOn]), Up3OnAxialSum.NrItems = length(list.AXIALOn)) %>%
                plyr::mutate(Up3OfRestTremAmpSum = rowSums(.[list.RestTremorOff]), Up3OfRestTremAmpSum.NrItems = length(list.RestTremorOff),
                       Up3OnRestTremAmpSum = rowSums(.[list.RestTremorOn]), Up3OnRestTremAmpSum.NrItems = length(list.RestTremorOn)) %>%
                plyr::mutate(Up3OfRestTremAmpSum2 = rowSums(.[list.RestTremor2Off]), Up3OfRestTremAmpSum2.NrItems = length(list.RestTremor2Off),
                             Up3OnRestTremAmpSum2 = rowSums(.[list.RestTremor2On]), Up3OnRestTremAmpSum2.NrItems = length(list.RestTremor2On)) %>%
                plyr::mutate(Up3OfActionTremorSum = rowSums(.[list.ActionTremorOff]), Up3OfActionTremorSum.NrItems = length(list.ActionTremorOff),
                       Up3OnActionTremorSum = rowSums(.[list.ActionTremorOn]), Up3OnActionTremorSum.NrItems = length(list.ActionTremorOn)) %>%
                plyr::mutate(Up3OfCompositeTremorSum = rowSums(.[list.CompositeTremorOff]), Up3OfCompositeTremorSum.NrItems = length(list.CompositeTremorOff),
                       Up3OnCompositeTremorSum = rowSums(.[list.CompositeTremorOn]), Up3OnCompositeTremorSum.NrItems = length(list.CompositeTremorOn)) %>%
                plyr::mutate(Up3OfOtherSum = rowSums(.[list.OtherOff]), Up3OfOtherSum.NrItems = length(list.OtherOff),
                             Up3OnOtherSum = rowSums(.[list.OtherOn]), Up3OnOtherSum.NrItems = length(list.OtherOn)) %>%
                plyr::mutate(Up3OfTotal.Norm = Up3OfTotal/Up3OfTotal.NrItems,
                             Up3OnTotal.Norm = Up3OnTotal/Up3OnTotal.NrItems,
                             Up3OfBradySum.Norm = Up3OfBradySum/Up3OfBradySum.NrItems,
                             Up3OnBradySum.Norm = Up3OnBradySum/Up3OnBradySum.NrItems,
                             Up3OfRigiditySum.Norm = Up3OfRigiditySum/Up3OfRigiditySum.NrItems,
                             Up3OnRigiditySum.Norm = Up3OnRigiditySum/Up3OnRigiditySum.NrItems,
                             Up3OfAppendicularSum.Norm = Up3OfAppendicularSum/Up3OfAppendicularSum.NrItems,
                             Up3OnAppendicularSum.Norm = Up3OnAppendicularSum/Up3OnAppendicularSum.NrItems,
                             Up3OfPIGDSum.Norm = Up3OfPIGDSum/Up3OfPIGDSum.NrItems,
                             Up3OnPIGDSum.Norm = Up3OnPIGDSum/Up3OnPIGDSum.NrItems,
                             Up3OfPIGDSum_Up3Only.Norm = Up3OfPIGDSum_Up3Only/Up3OfPIGDSum_Up3Only.NrItems,
                             Up3OnPIGDSum_Up3Only.Norm = Up3OnPIGDSum_Up3Only/Up3OnPIGDSum_Up3Only.NrItems,
                             Up3OfAxialSum.Norm = Up3OfAxialSum/Up3OfAxialSum.NrItems,
                             Up3OnAxialSum.Norm = Up3OnAxialSum/Up3OnAxialSum.NrItems,
                             Up3OfRestTremAmpSum.Norm = Up3OfRestTremAmpSum/Up3OfRestTremAmpSum.NrItems,
                             Up3OnRestTremAmpSum.Norm = Up3OnRestTremAmpSum/Up3OnRestTremAmpSum.NrItems,
                             Up3OfRestTremAmpSum2.Norm = Up3OfRestTremAmpSum2/Up3OfRestTremAmpSum2.NrItems,
                             Up3OnRestTremAmpSum2.Norm = Up3OnRestTremAmpSum2/Up3OnRestTremAmpSum2.NrItems,
                             Up3OfActionTremorSum.Norm = Up3OfActionTremorSum/Up3OfActionTremorSum.NrItems,
                             Up3OnActionTremorSum.Norm = Up3OnActionTremorSum/Up3OnActionTremorSum.NrItems,
                             Up3OfCompositeTremorSum.Norm = Up3OfCompositeTremorSum/Up3OfCompositeTremorSum.NrItems,
                             Up3OnCompositeTremorSum.Norm = Up3OnCompositeTremorSum/Up3OnCompositeTremorSum.NrItems,
                             Up3OfOtherSum.Norm = Up3OfOtherSum/Up3OfOtherSum.NrItems,
                             Up3OnOtherSum.Norm = Up3OnOtherSum/Up3OnOtherSum.NrItems,
                             Up3OfSummedNorm = Up3OfBradySum.Norm+Up3OfRigiditySum.Norm+Up3OfPIGDSum_Up3Only.Norm+
                                     Up3OfRestTremAmpSum.Norm+Up3OfActionTremorSum.Norm+Up3OfOtherSum.Norm,
                             Up3OfSummedNorm2 = Up3OfBradySum.Norm+Up3OfRigiditySum.Norm+Up3OfPIGDSum_Up3Only.Norm+
                                     Up3OfRestTremAmpSum2.Norm+Up3OfActionTremorSum.Norm+Up3OfOtherSum.Norm,
                             Up3OfBradyProportion = Up3OfBradySum.Norm/Up3OfSummedNorm,
                             Up3OfRigidityProportion = Up3OfRigiditySum.Norm/Up3OfSummedNorm,
                             Up3OfPIGDProportion = Up3OfPIGDSum_Up3Only.Norm/Up3OfSummedNorm,
                             Up3OfRestTremProportion = Up3OfRestTremAmpSum.Norm/Up3OfSummedNorm,
                             Up3OfActTremProportion = Up3OfActionTremorSum.Norm/Up3OfSummedNorm,
                             Up3OfOtherProportion = Up3OfOtherSum.Norm/Up3OfSummedNorm,
                             Up3OfSummedProportion=Up3OfBradyProportion+Up3OfRigidityProportion+Up3OfPIGDProportion+
                                     Up3OfRestTremProportion+Up3OfActTremProportion+Up3OfOtherProportion,
                             Up3OfBradyProportion2 = Up3OfBradySum.Norm/Up3OfSummedNorm2,
                             Up3OfRigidityProportion2 = Up3OfRigiditySum.Norm/Up3OfSummedNorm2,
                             Up3OfPIGDProportion2 = Up3OfPIGDSum_Up3Only.Norm/Up3OfSummedNorm2,
                             Up3OfRestTremProportion2 = Up3OfRestTremAmpSum2.Norm/Up3OfSummedNorm2,
                             Up3OfActTremProportion2 = Up3OfActionTremorSum.Norm/Up3OfSummedNorm2,
                             Up3OfOtherProportion2 = Up3OfOtherSum.Norm/Up3OfSummedNorm2,
                             Up3OfSummedProportion2=Up3OfBradyProportion2+Up3OfRigidityProportion2+Up3OfPIGDProportion2+
                                     Up3OfRestTremProportion2+Up3OfActTremProportion2+Up3OfOtherProportion2) %>%
                plyr::mutate(Up3OfTotal_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.TotalOff_pit]), NA),
                       Up3OfBradySum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.BradykinesiaOff_pit]), NA),
                       Up3OfRigiditySum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.RigidityOff_pit]), NA),
                       Up3OfAppendicularSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.AppendicularOff_pit]), NA),
                       Up3OfPIGDSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.PIGDOff_pit]), NA),
                       Up3OfAxialSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.AXIALOff_pit]), NA),
                       Up3OfRestTremAmpSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.RestTremorOff_pit]), NA),
                       Up3OfActionTremorSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.ActionTremorOff_pit]), NA),
                       Up3OfCompositeTremorSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.CompositeTremorOff_pit]), NA)) %>%
                plyr::mutate(Up3TotalOnOffDelta = Up3OnTotal - Up3OfTotal,
                       Up3BradySumOnOffDelta = Up3OnBradySum - Up3OfBradySum,
                       Up3RigidityOnOffDelta =  Up3OnRigiditySum- Up3OfActionTremorSum,
                       Up3AppendicularOnOffDelta = Up3OnAppendicularSum - Up3OfAppendicularSum,
                       Up3PIGDOnOffDelta = Up3OnPIGDSum - Up3OfPIGDSum,
                       Up3RestTremAmpSumOnOffDelta = Up3OnRestTremAmpSum - Up3OfRestTremAmpSum,
                       Up3RestTremAmpSum2OnOffDelta = Up3OnRestTremAmpSum2 - Up3OfRestTremAmpSum) %>%
                plyr::mutate(Up1_1to6 = rowSums(.[list.updrs1_1to6]), Up1_1to6.NrItems = length(list.updrs1_1to6),
                       Up1_7to13 = rowSums(.[list.updrs1_7to13]), Up1_7to13.NrItems = length(list.updrs1_7to13),
                       Up1Total = rowSums(.[list.updrs1_total]), Up1Total.NrItems = length(list.updrs1_total),
                       Up2Total = rowSums(.[list.updrs2total]), Up2Total.NrItems = length(list.updrs2total),
                       STAITraitSum = rowSums(.[list.STAITrait]), STAITraitSum.NrItems = length(list.STAITrait),
                       STAIStateSum = rowSums(.[list.STAIState]), STAIStateSum.NrItems = length(list.STAIState),
                       QUIPicdSum = rowSums(.[list.QUIP_icd]), QUIPicdSum.NrItems = length(list.QUIP_icd),
                       QUIPrsSum = rowSums(.[list.QUIP_rs]), QUIPrsSum.NrItems = length(list.QUIP_rs),
                       AES12Sum = rowSums(.[list.AES12]), AES12Sum.NrItems = length(list.AES12),
                       ApatSum = rowSums(.[list.Apat]), ApatSum.NrItems = length(list.Apat),
                       BDI2Sum = rowSums(.[list.BDI2]), BDI2Sum.NrItems = length(list.BDI2),
                       ROMPSum = rowSums(.[list.ROMP]), ROMPSum.NrItems = length(list.ROMP),
                       VIPDQ23Sum = rowSums(.[list.VIPDQ23]), VIPDQ23Sum.NrItems = length(list.VIPDQ23),
                       VIPDQ17Sum = rowSums(.[list.VIPDQ17]), VIPDQ17Sum.NrItems = length(list.VIPDQ17),
                       PDQ39_mobilitySum = rowSums(.[list.PDQ39_mobility]) / (4*10) * 100, PDQ39_mobilitySum.NrItems = length(list.PDQ39_mobility),
                       PDQ39_activitiesSum = rowSums(.[list.PDQ39_activities]) / (4*6) * 100, PDQ39_activitiesSum.NrItems = length(list.PDQ39_activities),
                       PDQ39_emotionalSum = rowSums(.[list.PDQ39_emotional]) / (4*6) * 100, PDQ39_emotionalSum.NrItems = length(list.PDQ39_emotional),
                       PDQ39_stigmaSum = rowSums(.[list.PDQ39_stigma]) / (4*4) * 100, PDQ39_stigmaSum.NrItems = length(list.PDQ39_stigma),
                       PDQ39_socialsupportSum = rowSums(.[list.PDQ39_socialsupport], na.rm = TRUE), PDQ39_socialsupportSum.NrItems = length(list.PDQ39_socialsupport),
                       PDQ39_cognitionsSum = rowSums(.[list.PDQ39_cognitions]) / (4*4) * 100, PDQ39_cognitionsSum.NrItems = length(list.PDQ39_cognitions),
                       PDQ39_communicationSum = rowSums(.[list.PDQ39_communication]) / (4*3) * 100, PDQ39_communicationSum.NrItems = length(list.PDQ39_communication),
                       PDQ39_bodilydiscomfortSum = rowSums(.[list.PDQ39_bodilydiscomfort]) / (4*3) * 100, PDQ39_bodilydiscomfortSum.NrItems = length(list.PDQ39_bodilydiscomfort),
                       RBDSQSum = rowSums(.[list.RBDSQ]), RBDSQSum.NrItems = length(list.RBDSQ),
                       SCOPA_AUTSum = ifelse(Gender == 'Male', rowSums(.[list.SCOPA_AUT.man]), rowSums(.[list.SCOPA_AUT.woman])), SCOPA_AUTSum.NrItems = length(list.SCOPA_AUT.man),
                       MoCASum = ifelse(NpsEducYears <= 12, rowSums(.[list.MOCA])+1, rowSums(.[list.MOCA])), MoCASum.NrItems = length(list.MOCA),
                       NpsMis15WrdRecognition = NpsMis15WrdHits + (15-NpsMis15WrdFals),
                       MotorComposite = (Up2Total + Up3OfTotal + Up3OfPIGDSum)/3)
        
        for(v in 1:length(df1$PDQ39_socialsupportSum)){
                if(is.na(df1$Pdq39It27[v]) | (df1$Pdq39It28a[v] == 1 && is.na(df1$Pdq39It28b[v])) | is.na(df1$Pdq39It29[v])){
                        df1$PDQ39_socialsupportSum[v] <- NA
                }else{
                        nrvars <- length(na.omit(c(df1$Pdq39It27[v], df1$Pdq39It28a[v], df1$Pdq39It28b[v], df1$Pdq39It29[v])))
                        df1$PDQ39_socialsupportSum[v] <- df1$PDQ39_socialsupportSum[v] / (4*nrvars) * 100     
                }
        }
        
        df1 <- df1 %>%
                rowwise() %>%
                mutate(PDQ39_SingleIndex = sum(c_across(c('PDQ39_mobilitySum', 'PDQ39_activitiesSum', 'PDQ39_emotionalSum',
                                                          'PDQ39_stigmaSum', 'PDQ39_socialsupportSum', 'PDQ39_cognitionsSum',
                                                          'PDQ39_communicationSum', 'PDQ39_bodilydiscomfortSum')), na.rm = FALSE),
                       PDQ39_SingleIndex = PDQ39_SingleIndex / length(na.omit(c_across(c('PDQ39_mobilitySum', 'PDQ39_activitiesSum', 'PDQ39_emotionalSum',
                                                                                         'PDQ39_stigmaSum', 'PDQ39_socialsupportSum', 'PDQ39_cognitionsSum',
                                                                                         'PDQ39_communicationSum', 'PDQ39_bodilydiscomfortSum')))))
        
        # Compute asymmetry index scores for bradykinesia, rigidity, and tremor
        scoreList <- list(AllScores = c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle',
                                        'Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                                        'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                                        'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur', 'Up3OfSpont', 'Up3OfPosTYesDev',
                                        'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev',
                                        'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw', 'Up3OfConstan'),
                          Ridigity = c('Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle'),
                          Rigidity_R = c('Up3OfRigRue', 'Up3OfRigRle'),
                          Rigidity_L = c('Up3OfRigLue', 'Up3OfRigLle'),
                          Rigidity_Hand = c('Up3OfRigRue', 'Up3OfRigLue'),
                          Ridigity_Foot = c('Up3OfRigRle', 'Up3OfRigLue'),
                          Bradykinesia = c('Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                                           'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev'),
                          Bradykinesia_YesDev = c('Up3OfFiTaYesDev', 'Up3OfHaMoYesDev', 'Up3OfProSYesDev', 'Up3OfToTaYesDev', 'Up3OfLAgiYesDev'),
                          Bradykinesia_NonDev = c('Up3OfFiTaNonDev', 'Up3OfHaMoNonDev', 'Up3OfProSNonDev', 'Up3OfToTaNonDev', 'Up3OfLAgiNonDev'),
                          Bradykinesia_Hand = c('Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev', 'Up3OfProSNonDev'),
                          Bradykinesia_Foot = c('Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev'),
                          RestTremor = c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev'),
                          RestTremor_YesDev = c('Up3OfRAmpArmYesDev', 'Up3OfRAmpLegYesDev'),
                          RestTremor_NonDev = c('Up3OfRAmpArmNonDev', 'Up3OfRAmpLegNonDev'),
                          RestTremor_Hand = c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev'),
                          RestTremor_Foot = c('Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev'),
                          ActionTremor = c('Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev'),
                          ActionTremor_YesDev = c('Up3OfPosTYesDev', 'Up3OfKinTreYesDev'),
                          ActionTremor_NonDev = c('Up3OfPosTNonDev', 'Up3OfKinTreNonDev'),
                          CompositeTremor = c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev',
                                              'Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev'),
                          CompositeTremor_YesDev = c('Up3OfRAmpArmYesDev', 'Up3OfRAmpLegYesDev', 'Up3OfPosTYesDev', 'Up3OfKinTreYesDev'),
                          CompositeTremor_NonDev = c('Up3OfRAmpArmNonDev', 'Up3OfRAmpLegNonDev', 'Up3OfPosTNonDev', 'Up3OfKinTreNonDev'),
                          Sided = c('Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle',
                                    'Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev', 'Up3OfProSNonDev',
                                    'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                                    'Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev',
                                    'Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev'),
                          NonSided = c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos',
                                       'Up3OfPostur', 'Up3OfSpont', 'Up3OfRAmpJaw', 'Up3OfConstan'))
        
        df1 <- df1 %>%
                mutate(Up3OfBradySumYesDev = (Up3OfFiTaYesDev+Up3OfHaMoYesDev+Up3OfProSYesDev+Up3OfToTaYesDev+Up3OfLAgiYesDev)/5,
                       Up3OfBradySumNonDev = (Up3OfFiTaNonDev+Up3OfHaMoNonDev+Up3OfProSNonDev+Up3OfToTaNonDev+Up3OfLAgiNonDev)/5,
                       Up3OfBradySumRiLeDelta = abs(Up3OfBradySumYesDev-Up3OfBradySumNonDev),
                       Up3OfBradySumArm = (Up3OfFiTaYesDev+Up3OfHaMoYesDev+Up3OfProSYesDev+Up3OfFiTaNonDev+Up3OfHaMoNonDev+Up3OfProSNonDev)/6,
                       Up3OfBradySumLeg = (Up3OfToTaYesDev+Up3OfLAgiYesDev+Up3OfToTaNonDev+Up3OfLAgiNonDev)/4,
                       Up3OfBradySumArmLegDelta = abs(Up3OfBradySumArm-Up3OfBradySumLeg),
                       AsymmetryIndexRiLe.Brady = if_else(Up3OfBradySumRiLeDelta>0,
                                                          Up3OfBradySumRiLeDelta/(Up3OfBradySumYesDev+Up3OfBradySumNonDev), 0),
                       AsymmetryIndexArmLeg.Brady = if_else(Up3OfBradySumArmLegDelta>0, 
                                                            Up3OfBradySumArmLegDelta/(Up3OfBradySumArm+Up3OfBradySumLeg), 0),
                       
                       Up3OfRigiditySumR = (Up3OfRigRue+Up3OfRigRle)/2,
                       Up3OfRigiditySumL = (Up3OfRigLue+Up3OfRigLle)/2,
                       Up3OfRigiditySumRiLeDelta = abs(Up3OfRigiditySumR-Up3OfRigiditySumL),
                       Up3OfRigiditySumArm = (Up3OfRigRue + Up3OfRigLue)/2,
                       Up3OfRigiditySumLeg = (Up3OfRigRle + Up3OfRigLle)/2,
                       Up3OfRigiditySumArmLegDelta = abs(Up3OfRigiditySumArm-Up3OfRigiditySumLeg),
                       AsymmetryIndexRiLe.Rigidity = if_else(Up3OfRigiditySumRiLeDelta>0,
                                                             Up3OfRigiditySumRiLeDelta/(Up3OfRigiditySumR+Up3OfRigiditySumL), 0),
                       AsymmetryIndexArmLeg.Rigidity = if_else(Up3OfRigiditySumArmLegDelta>0,
                                                               Up3OfRigiditySumArmLegDelta/(Up3OfRigiditySumArm+Up3OfRigiditySumLeg), 0),
                       
                       Up3OfRestTremSumYesDev = (Up3OfRAmpArmYesDev+Up3OfRAmpLegYesDev)/2,
                       Up3OfRestTremSumNonDev = (Up3OfRAmpArmNonDev+Up3OfRAmpLegNonDev)/2,
                       Up3OfRestTremSumRiLeDelta = abs(Up3OfRestTremSumYesDev-Up3OfRestTremSumNonDev),
                       Up3OfRestTremSumArm = (Up3OfRAmpArmYesDev+Up3OfRAmpArmNonDev)/2,
                       Up3OfRestTremSumLeg = (Up3OfRAmpLegYesDev+Up3OfRAmpLegNonDev)/2,
                       Up3OfRestTremSumArmLegDelta = abs(Up3OfRestTremSumArm-Up3OfRestTremSumLeg),
                       AsymmetryIndexRiLe.RestTrem = if_else(Up3OfRestTremSumRiLeDelta>0, 
                                                             Up3OfRestTremSumRiLeDelta/(Up3OfRestTremSumYesDev+Up3OfRestTremSumNonDev), 0),
                       AsymmetryIndexArmLeg.RestTrem = if_else(Up3OfRestTremSumArmLegDelta>0, 
                                                               Up3OfRestTremSumArmLegDelta/(Up3OfRestTremSumArm+Up3OfRestTremSumLeg), 0),
                       
                       Up3OfActTremSumYesDev = (Up3OfPosTYesDev+Up3OfKinTreYesDev)/2,
                       Up3OfActTremSumNonDev = (Up3OfPosTNonDev+Up3OfKinTreNonDev)/2,
                       Up3OfActTremSumRiLeDelta = abs(Up3OfActTremSumYesDev-Up3OfActTremSumNonDev),
                       AsymmetryIndexRiLe.ActTrem = if_else(Up3OfActTremSumRiLeDelta>0, 
                                                            Up3OfActTremSumRiLeDelta/(Up3OfActTremSumYesDev+Up3OfActTremSumNonDev), 0),
                       
                       AsymmetryIndexRiLe.All = (AsymmetryIndexRiLe.Brady + AsymmetryIndexRiLe.Rigidity + 
                                                         AsymmetryIndexRiLe.RestTrem + AsymmetryIndexRiLe.ActTrem)/4,
                       AsymmetryIndexArmLeg.All = (AsymmetryIndexArmLeg.Brady + AsymmetryIndexArmLeg.Rigidity + 
                                                           AsymmetryIndexArmLeg.RestTrem)/3,
                       AsymmetryIndexRiLe.WeightedBradyRig = AsymmetryIndexRiLe.Brady*(10/14) + AsymmetryIndexRiLe.Rigidity*(4/14),
                       AsymmetryIndexArmLeg.WeightedBradyRig = AsymmetryIndexArmLeg.Brady*(10/14) + AsymmetryIndexArmLeg.Rigidity*(4/14),
                       AsymmetryIndexRiLeDelta.All = (Up3OfBradySumRiLeDelta + Up3OfRigiditySumRiLeDelta + 
                                                              Up3OfRestTremSumRiLeDelta + Up3OfActTremSumRiLeDelta)/4,
                       AsymmetryIndexArmLegDelta.All = (Up3OfBradySumArmLegDelta + Up3OfRigiditySumArmLegDelta + 
                                                                Up3OfRestTremSumArmLegDelta)/3)
        
        # Updrs 4 scores require a bit of manipulation and is therefore summarized spearately here
        df1 <- df1 %>%
                mutate(MotComDysKinTime = str_sub(MotComDysKinTime, start=1, end=1),
                       MotComDysKinTime = as.numeric(MotComDysKinTime),
                       MotComDysKinTime = if_else(MotComDysKinTime==5,as.numeric(NA),MotComDysKinTime),
                       MotComDysKinImpact = if_else(MotComDysKinImpact==5,as.numeric(NA),MotComDysKinImpact),
                       Up4Dyskinesia = MotComDysKinTime + MotComDysKinImpact,
                       MotComOffStateTime = str_sub(MotComOffStateTime, start=1, end=1),
                       MotComOffStateTime = as.numeric(MotComOffStateTime),
                       MotComOffStateTime = if_else(MotComOffStateTime==5,as.numeric(NA),MotComOffStateTime),
                       MotComFluctImpact = if_else(MotComFluctImpact==5,as.numeric(NA),MotComFluctImpact),
                       MotComFluctComplex = if_else(MotComFluctComplex==5,as.numeric(NA),MotComFluctComplex),
                       Up4Fluct = MotComOffStateTime + MotComFluctImpact + MotComFluctComplex,
                       MotComPainOffDyst = str_sub(MotComPainOffDyst, start=1, end=1),
                       MotComPainOffDyst = as.numeric(MotComPainOffDyst),
                       MotComPainOffDyst = if_else(MotComPainOffDyst==5,as.numeric(NA),MotComPainOffDyst),
                       Up4Dystonia = as.numeric(MotComPainOffDyst),
                       Up4Total = Up4Dyskinesia + Up4Fluct + Up4Dystonia)
        
        # Try to define whether most affected side is Right or Left
        df1 <- df1 %>% 
                mutate(MAS.reported=NA, MAS.rigidity=NA, MAS.watch=NA, MAS.watch2=NA)
        for(i in 1:nrow(df1)){
                # Check which side was reported as MAS
                MAS.reported <- df1$MostAffSide[i]
                if(!is.na(MAS.reported)){
                        if(MAS.reported == 'RightOnly' | MAS.reported == 'BiR>L'){
                                mostAffSide <- 'R'
                        }else if(MAS.reported == 'LeftOnly' | MAS.reported == 'BiL>R'){
                                MAS.reported <- 'L'
                        }else{
                                MAS.reported <- 'unknown'
                        }
                        df1$MAS.reported[i] <- MAS.reported  
                }
                # Determine MAS based on rigidity, since this is the only UPDRS3 variable for which we know side
                rigR <- df1[i,] %>% select(all_of(scoreList$Rigidity_R)) %>% rowSums()
                rigL <- df1[i,] %>% select(all_of(scoreList$Rigidity_L)) %>% rowSums()
                if(!is.na(rigR) & !is.na(rigL)){
                        if(rigR > rigL){
                                MAS.rigidity <- 'R'
                        }else if(rigL > rigR){
                                MAS.rigidity <- 'L'
                        }else{
                                MAS.rigidity <- 'unknown'
                        }
                        df1$MAS.rigidity[i] <- MAS.rigidity  
                }
                # Determine whether the MAS is on the watch side or not (probably not)
                ydi <- str_detect(scoreList$Sided,'YesDev')
                ndi <- str_detect(scoreList$Sided,'NonDev')
                ydSev <- df1[i,] %>% select(all_of(scoreList$Sided[ydi])) %>% rowSums()
                ndSev <- df1[i,] %>% select(all_of(scoreList$Sided[ndi])) %>% rowSums()
                if(!is.na(ydSev) & !is.na(ndSev)){
                        if(ydSev > ndSev){
                                MAS.watch <- 'YesDev'
                        }else if(ndSev > ydSev){
                                MAS.watch <- 'NonDev'
                        }else{
                                MAS.watch <- 'unknown'
                        }
                        df1$MAS.watch[i] <- MAS.watch        
                }
                # Determine MAS based on the assumption that the watch is on the least affected side, 
                watchSide <- df$WatchSide[i]
                if(!is.na(watchSide) & !is.na(MAS.watch)){
                        if(MAS.watch == 'NonDev' & watchSide == 'L'){
                                MAS.watch2 <- 'R'
                        }else if(MAS.watch == 'NonDev' & watchSide == 'R'){
                                MAS.watch2 <- 'L'
                        }else(
                                MAS.watch2 <- 'unknown'
                        )
                        df1$MAS.watch2[i] <- MAS.watch2
                }
        }
        
        df1
  
}

