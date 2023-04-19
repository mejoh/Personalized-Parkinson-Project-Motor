disaggregate <- function(df, yvar='Up3OfBradySum', id_vars = c('pseudonym', 'TimeNr')){
 
 # Disaggregate within- and between-subject effects
 dat <- test.long %>%
  select(pseudonym, any_of(yvar), any_of(id_vars)) %>%
  mutate(yvar.pm = mean(.data[[yvar]]), .by = 'pseudonym') %>%
  mutate(yvar.gmc = .data[[yvar]] - mean(.data[[yvar]]),
         yvar.xw = .data[[yvar]] - yvar.pm,
         yvar.xb = yvar.gmc - yvar.xw)
 
 # Fix column names
 cn <- colnames(dat)
 colnames(dat) <- str_replace(cn, 'yvar', yvar)
 
 dat
 
}