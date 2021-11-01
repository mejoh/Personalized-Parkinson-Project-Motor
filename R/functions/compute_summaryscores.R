compute_summaryscores <- function(df){
  
  ##### Lists of scores to summarize #####
        #Motor
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
  list.AXIALOff <- c('Up3OfSpeech', 'Up3OfArise', 'Up3OfPostur', 'Up3OfGait', 'Up3OfStaPos')    # Lau et al., 2019, Neurology
  list.AXIALOn <- str_replace(list.AXIALOff, 'Of', 'On')
  list.RestTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfConstan')
  list.RestTremorOn <- str_replace(list.RestTremorOff, 'Of', 'On')
  list.ActionTremorOff <- c('Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev')
  list.ActionTremorOn <- str_replace(list.RigidityOff, 'Of', 'On')
  list.CompositeTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw',
                               'Up3OfConstan','Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Updrs2It23') # Stebbins et al. 2013
  list.CompositeTremorOn <- str_replace(list.CompositeTremorOff, 'Of', 'On')
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
  list.RestTremorOff_pit <- c('Up3OfRAmpArmR', 'Up3OfRAmpArmL', 'Up3OfRAmpLegR', 'Up3OfRAmpLegL', 'Up3OfConstan')
  list.ActionTremorOff_pit <- c('Up3OfPosTR', 'Up3OfPosTL', 'Up3OfKinTreR', 'Up3OfKinTreL')
  list.CompositeTremorOff_pit <- c('Up3OfRAmpArmR', 'Up3OfRAmpArmL', 'Up3OfRAmpLegR', 'Up3OfRAmpLegL', 'Up3OfConstan',
                               'Up3OfPosTR', 'Up3OfPosTL', 'Up3OfKinTreR', 'Up3OfKinTreL')
        #Non-motor
  list.STAITrait <- c('StaiTrait01', 'StaiTrait02', 'StaiTrait03', 'StaiTrait04', 'StaiTrait05', 'StaiTrait06', 'StaiTrait07',
                      'StaiTrait08', 'StaiTrait09', 'StaiTrait10', 'StaiTrait11', 'StaiTrait12', 'StaiTrait13', 'StaiTrait14',
                      'StaiTrait15', 'StaiTrait16', 'StaiTrait17', 'StaiTrait18', 'StaiTrait19', 'StaiTrait20')
  list.STAIState <- c('StaiState01', 'StaiState02', 'StaiState03', 'StaiState04', 'StaiState05', 'StaiState06', 'StaiState07',
                      'StaiState08', 'StaiState09', 'StaiState10', 'StaiState11', 'StaiState12', 'StaiState13', 'StaiState14',
                      'StaiState15', 'StaiState16', 'StaiState17', 'StaiState18', 'StaiState19', 'StaiState20')
  list.QUIP_gambling <- c('QuipIt01', 'QuipIt08', 'QuipIt15', 'QuipIt22')
  list.QUIP_sex <- c('QuipIt02', 'QuipIt09', 'QuipIt16', 'QuipIt23')
  list.QUIP_buying <- c('test', 'QuipIt10', 'QuipIt17', 'QuipIt24')
  list.QUIP_eating <- c('QuipIt03', 'QuipIt05', 'QuipIt18', 'QuipIt25')
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
  list.TalkProb <- c('TalkProb01', 'TalkProb02', 'TalkProb03', 'TalkProb04', 'TalkProb05', 'TalkProb06', 'TalkProb07')
  list.VisualProb23 <- c('VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04', 'VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr08', 'VisualPr09',
                         'VisualPr10', 'VisualPr11', 'VisualPr12', 'VisualPr13', 'VisualPr14', 'VisualPr15', 'VisualPr16', 'VisualPr17', 'VisualPr18',
                         'VisualPr19', 'VisualPr20', 'VisualPr21', 'VisualPr22', 'VisualPr23')
  list.VisualProb17_ocularsurface <- c('VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04')
  list.VisualProb17_intraocular <- c('VisualPr08','VisualPr09','VisualPr15','VisualPr19')
  list.VisualProb17_oculomotor <- c('VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr23')
  list.VisualProb17_opticnerve <- c('VisualPr11', 'VisualPr13', 'VisualPr14', 'VisualPr21', 'VisualPr22')
  list.VisualProb17 <- c(list.VisualProb17_ocularsurface, list.VisualProb17_intraocular, list.VisualProb17_oculomotor, list.VisualProb17_opticnerve)
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
  #####
  
  df1 <- df %>%
    mutate(Up3OfTotal = rowSums(.[list.TotalOff]),
           Up3OnTotal = rowSums(.[list.TotalOn])) %>%
    mutate(Up3OfBradySum = rowSums(.[list.BradykinesiaOff]),
           Up3OnBradySum = rowSums(.[list.BradykinesiaOn])) %>%
    mutate(Up3OfRigiditySum = rowSums(.[list.RigidityOff]),
           Up3OnRigiditySum = rowSums(.[list.RigidityOn])) %>%
    mutate(Up3OfAppendicularSum = rowSums(.[list.AppendicularOff]),
           Up3OnAppendicularSum = rowSums(.[list.AppendicularOn])) %>%
    mutate(Up3OfPIGDSum = rowSums(.[list.PIGDOff]),
           Up3OnPIGDSum = rowSums(.[list.PIGDOn])) %>%
    mutate(Up3OfAxialSum = rowSums(.[list.AXIALOff]),
           Up3OnAxialSum = rowSums(.[list.AXIALOn])) %>%
    mutate(Up3OfRestTremAmpSum = rowSums(.[list.RestTremorOff]),
           Up3OnRestTremAmpSum = rowSums(.[list.RestTremorOn])) %>%
    mutate(Up3OfActionTremorSum = rowSums(.[list.ActionTremorOff]),
           Up3OnActionTremorSum = rowSums(.[list.ActionTremorOn])) %>%
    mutate(Up3OfCompositeTremorSum = rowSums(.[list.CompositeTremorOff]),
           Up3OnCompositeTremorSum = rowSums(.[list.CompositeTremorOn])) %>%
    mutate(Up3OfTotal_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.TotalOff_pit]), NA),
           Up3OfBradySum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.BradykinesiaOff_pit]), NA),
           Up3OfRigiditySum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.RigidityOff_pit]), NA),
           Up3OfAppendicularSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.AppendicularOff_pit]), NA),
           Up3OfPIGDSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.PIGDOff_pit]), NA),
           Up3OfAxialSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.AXIALOff_pit]), NA),
           Up3OfRestTremAmpSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.RestTremorOff_pit]), NA),
           Up3OfActionTremorSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.ActionTremorOff_pit]), NA),
           Up3OfCompositeTremorSum_pit = ifelse(Timepoint == 'ses-PITVisit1', rowSums(.[list.CompositeTremorOff_pit]), NA)) %>%
    mutate(Up3TotalOnOffDelta = Up3OnTotal - Up3OfTotal,
           Up3BradySumOnOffDelta = Up3OnBradySum - Up3OfBradySum,
           Up3RigidityOnOffDelta =  Up3OnRigiditySum- Up3OfActionTremorSum,
           Up3AppendicularOnOffDelta = Up3OnAppendicularSum - Up3OfAppendicularSum,
           Up3PIGDOnOffDelta = Up3OnPIGDSum - Up3OfPIGDSum,
           Up3RestTremAmpSumOnOffDelta = Up3OnRestTremAmpSum - Up3OfRestTremAmpSum,) %>%
    mutate(STAITraitSum = rowSums(.[list.STAITrait]),
           STAIStateSum = rowSums(.[list.STAIState]),
           QUIPicdSum = rowSums(.[list.QUIP_icd]),
           QUIPrsSum = rowSums(.[list.QUIP_rs]),
           AES12Sum = rowSums(.[list.AES12]),
           ApatSum = rowSums(.[list.Apat]),
           BDI2Sum = rowSums(.[list.BDI2]),
           TalkProbSum = rowSums(.[list.TalkProb]),
           VisualProb23Sum = rowSums(.[list.VisualProb23]),
           VisualProb17Sum = rowSums(.[list.VisualProb17]),
           PDQ39_mobilitySum = rowSums(.[list.PDQ39_mobility]) / (4*10) * 100,
           PDQ39_activitiesSum = rowSums(.[list.PDQ39_activities]) / (4*6) * 100,
           PDQ39_emotionalSum = rowSums(.[list.PDQ39_emotional]) / (4*6) * 100,
           PDQ39_stigmaSum = rowSums(.[list.PDQ39_stigma]) / (4*4) * 100,
           PDQ39_socialsupportSum = rowSums(.[list.PDQ39_socialsupport], na.rm = TRUE),
           PDQ39_cognitionsSum = rowSums(.[list.PDQ39_cognitions]) / (4*4) * 100,
           PDQ39_communicationSum = rowSums(.[list.PDQ39_communication]) / (4*3) * 100,
           PDQ39_bodilydiscomfortSum = rowSums(.[list.PDQ39_bodilydiscomfort]) / (4*3) * 100)
  
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
  
  df1
  
}

