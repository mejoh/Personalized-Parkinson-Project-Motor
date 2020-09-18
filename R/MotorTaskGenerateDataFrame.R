MotorTaskGenerateDataFrame <- function(rerun = FALSE){
        
        if(rerun == TRUE){
                source('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskDatabase.R')
                dfMotor <- MotorTaskDatabase('3022026.01')
                save.image('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskData_environment1.RData')
        }else{
                load('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskData_environment1.RData')
        }
        
        print(dfMotor)
        
}