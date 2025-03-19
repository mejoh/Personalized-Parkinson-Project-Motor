##### MoveEyeData #####
# Moves eyetracker data to appropriate location in /project/3024006.01/raw folder

# Subject list
dRaw <- 'P:/3024006.01/raw'
dRaw.Contents <- dir(dRaw)
dRaw.Subs <- str_detect(dRaw.Contents, '^sub-PIT1MR.*')
dRaw.Subs <- dRaw.Contents[dRaw.Subs]
dRaw.Subs <- str_extract(dRaw.Subs, 'PIT1MR.*')

# Path to eyetracker data that gets copied
dEye.Raw <- 'P:/3024006.01/eye/Raw'
dEye.Converted <- 'P:/3024006.01/eye/Converted'
dEye.Raw.Contents <- dir(dEye.Raw, full.names = TRUE)
dEye.Converted.Contents <- dir(dEye.Converted, full.names = TRUE)

for(n in dRaw.Subs){
        
        SubjectFolder <- paste(dRaw, '/sub-', n, '/ses-Visit1', sep = '')
        SubjectFolder.Contents <- dir(SubjectFolder, full.names = TRUE)
        
        # Copy raw eyetracker files
        RawEyeId <- str_detect(dEye.Raw.Contents, n)
        RawEye <- dEye.Raw.Contents[RawEyeId]
        for(x in RawEye){
                if(str_detect(x, 'rest1')){
                        Destination <- str_detect(SubjectFolder.Contents, '.*rest_eye$')
                        Destination <- SubjectFolder.Contents[Destination]
                }else if(str_detect(x, 'task1')){
                        Destination <- str_detect(SubjectFolder.Contents, '.*motor_eye$')
                        Destination <- SubjectFolder.Contents[Destination]
                }else if(str_detect(x, 'task2')){
                        Destination <- str_detect(SubjectFolder.Contents, '.*reward_eye$')
                        Destination <- SubjectFolder.Contents[Destination]
                }else{
                        cat('WARNING:', x, 'unkown format, skipping')
                        next
                }
                file_copy(x, Destination, overwrite = TRUE)
        }
        
        # Copy converted eyetracker files
        ConvertedEyeId <- str_detect(dEye.Converted.Contents, n)
        ConvertedEye <- dEye.Converted.Contents[ConvertedEyeId]
        for(y in ConvertedEye){
                if(str_detect(y, 'rest1')){
                        Destination <- str_detect(SubjectFolder.Contents, '.*rest_eye$')
                        Destination <- SubjectFolder.Contents[Destination]
                }else if(str_detect(y, 'task1')){
                        Destination <- str_detect(SubjectFolder.Contents, '.*motor_eye$')
                        Destination <- SubjectFolder.Contents[Destination]
                }else if(str_detect(y, 'task2')){
                        Destination <- str_detect(SubjectFolder.Contents, '.*reward_eye$')
                        Destination <- SubjectFolder.Contents[Destination]
                }else{
                        cat('WARNING:', x, 'unkown format, skipping')
                        next
                }
                file_copy(y, Destination, overwrite = TRUE)
        }
        
        # Report if the number of eyetracker files is inconsistent (i.e. not 6)
        nFiles <- length(RawEye) + length(ConvertedEye)
        if(nFiles != 6){
                cat(n, 'has an inconsistent number of files', '\n')
                cat('Number of raw eyetracker files:', length(RawEye), '\n', RawEye, '\n')
                cat('Number of converted eyetracker files:', length(ConvertedEye), '\n', ConvertedEye, '\n', '\n')
        }
        
}










