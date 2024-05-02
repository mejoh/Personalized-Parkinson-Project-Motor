compute_cognitive_composite <- function(df){
 
 selection_characteristrics <- c('pseudonym','ParticipantType','TimepointNr')
 vars <- c('NpsMisWaisLcln','NpsMisBrixton','NpsMisBenton','NpsMisSemFlu','NpsMisModa90',
           'NpsMis15wRigTot', 'NpsMis15WrdDelRec', 'NpsMis15WrdRecognition')
 
 z_score <- function(x){
  var <- (x - mean(x, na.rm=T)) / sd(x, na.rm=T)
  var
 }
 

 df1 <- df %>% 
  select(all_of(selection_characteristrics), all_of(vars)) %>%
  mutate(across(all_of(vars), .fns = z_score, .names = 'z_{.col}'),
         AVLT = (NpsMis15wRigTot + NpsMis15WrdDelRec + NpsMis15WrdRecognition)/3,
         z_AVLT = z_score(AVLT),
         CognitiveComposite_raw = (z_NpsMisWaisLcln+z_NpsMisBrixton+z_NpsMisBenton+z_NpsMisSemFlu+z_NpsMisModa90+z_AVLT)/6,
         across(where(is.numeric), \(x) round(x, digits=5)))
 
 df1 <- df1 %>%
  select(all_of(selection_characteristrics), CognitiveComposite_raw)
 
 df1
 
}