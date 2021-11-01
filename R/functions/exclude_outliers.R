###-------------------------------------------------------------###
# exclude_outliers(dataframe, variable)
# Excludes outliers from a data frame based on some calculations on
# a selected variable. The default is to remove all values above and
# below 3 standard deviations
###-------------------------------------------------------------###

exclude_outliers <- function(dataframe, variable, nsds = 3){
  
  # dataframe <- data_SUBS_ProgTotalRTs_mean
  # variable <- 'INTgtEXT'
  ninitial <- nrow(dataframe)
  
  ### ------ Calculate stats to be used for exclusions ----- ###
  
  stats <- dataframe %>%
    ungroup() %>%
    select(matches(variable)) %>%
    dplyr::summarise(n=n(),
                     mean=mean(.data[[variable]], na.rm = TRUE),
                     sd=sd(.data[[variable]], na.rm = TRUE),
                     se=sd/sqrt(n))
  
  ### ------ Calculate criteria that will be used to subset the data ----- ###
  
  criterion_upper <- stats$mean + nsds * stats$sd
  criterion_lower <- stats$mean - nsds * stats$sd
  
  ### ------ Subset the data ------ ###
  
  dataframe_retained <- dataframe %>%
    ungroup() %>%
    filter(.data[[variable]] < criterion_upper) %>%
    filter(.data[[variable]] > criterion_lower) %>%
    filter(!is.na(.data[[variable]]))
  nretained <- nrow(dataframe_retained)
  
  ### ------ Count the number of exlcusions ------ ###
  
  dataframe_excluded <- dataframe %>%
    ungroup() %>%
    filter(.data[[variable]] > criterion_upper | .data[[variable]] < criterion_lower)
  nexcluded <- nrow(dataframe_excluded)
  
  dataframe_nas <- dataframe %>%
          ungroup() %>%
          filter(is.na(.data[[variable]]))
  nasexcluded <- nrow(dataframe_nas)
  
  ### ------ Print information regarding inclusions and exclusions ------ ###
  
  msg <- paste(ninitial, 'original rows,', nretained, 'participants retained,', nexcluded, 'participants excluded based on criteria,', nasexcluded, 'additional NAs excluded', sep = ' ')
  print(msg)
  
  ### ------ Return final data frame ------ ###
  
  dataframe_retained
  
}