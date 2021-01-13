MotorTaskGenerateDataFrame <- function(rerun = FALSE){
        
        if(rerun == TRUE){
                source('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskDatabase.R')
                dfMotor <- MotorTaskDatabase('3022026.01')
                save(dfMotor, file = 'M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorVars.RData')
        }else{
                load('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorVars.RData')
        }
        
        print(dfMotor)
        
}