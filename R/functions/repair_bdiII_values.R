repair_bdiII_values <- function(df){
  # FIX: BDI2 variables 16, 18, and 21 need to be altered. 
  # 16/18 take on values 0-6 when they should take on values 0-3
  # 21 takes on values 1-4 when it should take on values 0-3
  df <- df %>%
    mutate(Bdi2It16 = as.numeric(Bdi2It16),
           Bdi2It18 = as.numeric(Bdi2It18),
           Bdi2It21 = as.numeric(Bdi2It21))
  for(v in 1:length(df$Bdi2It16)){
    if(is.na(df$Bdi2It16[v])){
      next
    }else if(df$Bdi2It16[v] == 1 | df$Bdi2It16[v] == 2){
      df$Bdi2It16[v] = 1
    }else if(df$Bdi2It16[v] == 3 | df$Bdi2It16[v] == 4){
      df$Bdi2It16[v] = 2
    }else if(df$Bdi2It16[v] == 5 | df$Bdi2It16[v] == 6){
      df$Bdi2It16[v] = 3
    }
  }
  for(v in 1:length(df$Bdi2It18)){
    if(is.na(df$Bdi2It16[v])){
    }else if(df$Bdi2It18[v] == 1 | df$Bdi2It18[v] == 2){
      df$Bdi2It18[v] = 1
    }else if(df$Bdi2It18[v] == 3 | df$Bdi2It18[v] == 4){
      df$Bdi2It18[v] = 2
    }else if(df$Bdi2It18[v] == 5 | df$Bdi2It18[v] == 6){
      df$Bdi2It18[v] = 3
    }
  }
  for(v in 1:length(df$Bdi2It21)){
    if(!is.na(df$Bdi2It21[v])){
      df$Bdi2It21[v] <- df$Bdi2It21[v]-1
    }
  }
  
  df
  
}