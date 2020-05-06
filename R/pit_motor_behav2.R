### TO DO ################################
# 1. Exclude poorly performing subjects
# 2. Exclude outliers
# 3. Deal with outliers in each subjects RT distribution. For example, exclude RTs above or below 2.5 SD
# 4. Exclude NAs and NaNs
#############


### Libraries #################

library('tidyverse')
library('reshape2')
library('ggpubr')
library('ggsci')

#################


### Specify directories ####################################################################
PITDir <- c('P:/3024006.01')
PITTaskDir <- paste(PITDir,'/task_data/motor',sep="")
PITRawmapper <- paste(PITDir,'/users/marjoh/backups/rawmapper_PatientComments.tsv',sep="")
POMDir <- c('P:/3022026.01')
POMTaskDir <- paste(POMDir,'/DataTask',sep="")
###########################


### Assemble logfiles ###########################################################
PITLogFiles <- dir(PITTaskDir, full.names = TRUE, pattern = 'task1_logfile.txt')
POMLogFiles <- dir(POMTaskDir, full.names = TRUE, pattern = 'task1-MotorTaskEv')    # Select only Motor logfiles
for (i in 1:length(POMLogFiles)){
  POMLogFiles[i] = gsub('-MotorTaskEv_right.log', '_logfile.txt', POMLogFiles[i])
  POMLogFiles[i] = gsub('-MotorTaskEv_left.log', '_logfile.txt', POMLogFiles[i])
}
LogFiles <- c(PITLogFiles, POMLogFiles)
#########################


### Generate group-vector ###############################################################################################
Rawmapper <- read.delim(PITRawmapper,
                        header = TRUE, colClasses = c(rep('character',1),rep('NULL',1),rep('character',1),rep('NULL',1)))
Rawmapper <- Rawmapper[-c(seq(2,nrow(Rawmapper),2)), ]
Rawmapper$subid <- as.numeric(gsub('sub-','',Rawmapper$subid))
Rawmapper$Group <- as.logical(Rawmapper$subid >= 61)
Rawmapper <- Rawmapper[order(Rawmapper$newsubid),]
row.names(Rawmapper) <- seq(1,nrow(Rawmapper),1)
for (i in 1:length(PITLogFiles)){
  if(Rawmapper$Group[i] == 'FALSE'){
    Rawmapper$Group[i] <- c('Control')
  } else{
    Rawmapper$Group[i] <- c('Off')
  }
}
PITGroup <- Rawmapper$Group
POMGroup <- rep('On',length(POMLogFiles))
Group <- c(PITGroup,POMGroup)
Group <- as.factor(Group)
#############################


### Import data (RTs may be log10 transformed) ##############################################################################################################
ext_RT <- c()
int2_RT <- c() 
int3_RT <- c()
ext_err <- c()
int2_err <- c()
int3_err <- c()
for (i in 1:length(LogFiles)){
  if (file.exists(LogFiles[i])) {
    Data <- read.table(LogFiles[i], skip=1, header = TRUE, sep = '\t',
                         colClasses = c(rep('integer', 1), rep('character', 1), rep('NULL', 3), rep('numeric', 1), rep('NULL', 2), rep('character', 1)))
    #Data$Reaction_Time <- log10(Data$Reaction_Time)
    ext_RT[i] <- mean(subset(Data$Reaction_Time, Data$Task == 'Ext' & Data$Correct_Response == 'Hit')) #& Data$Reaction_Time >= 200))        
    int2_RT[i] <- mean(subset(Data$Reaction_Time, Data$Task == 'Int2' & Data$Correct_Response == 'Hit')) #& Data$Reaction_Time >= 200))
    int3_RT[i] <- mean(subset(Data$Reaction_Time, Data$Task == 'Int3' & Data$Correct_Response == 'Hit')) #& Data$Reaction_Time >= 200))
    ext_err[i] <- length(which(subset(Data$Correct_Response, Data$Task == 'Ext') == 'Hit')) / 60              
    int2_err[i] <- length(which(subset(Data$Correct_Response, Data$Task == 'Int2') == 'Hit')) / 30
    int3_err[i] <- length(which(subset(Data$Correct_Response, Data$Task == 'Int3') == 'Hit')) / 30
  } else {
    ext_RT[i] <- NaN        
    int2_RT[i] <- NaN
    int3_RT[i] <- NaN
    ext_err[i] <- NaN             
    int2_err[i] <- NaN
    int3_err[i] <- NaN
    }
}
##################################################


### Assemble data frames #######################################################################################################
ID <- 1:length(LogFiles)
RTData <- data.frame(ID = ID, Group = Group, Ext = ext_RT, Int2 = int2_RT, Int3 = int3_RT)
ErrData <- data.frame(ID = ID, Group = Group, Ext = ext_err, Int2 = int2_err, Int3 = int3_err)

RTData <- na.omit(RTData)       # Exclude NaNs
ErrData <- na.omit(ErrData)

SelErr <- which(ErrData$Ext < 0.8 | ErrData$Int2 < 0.8 | ErrData$Int3 < 0.8)     # Exclude error rates above 20%
#RTData <- RTData[-c(SelErr),]
#SelRt <- c(which(RTData$Ext > (mean(RTData$Ext) + sd(RTData$Ext) * 3)))    # Exclude any participant with RTs 3 SDs over the mean for either condition
#SelRt <- c(SelRt, which(RTData$Int2 > (mean(RTData$Int2) + sd(RTData$Int2) * 3)))
#SelRt <- c(SelRt, which(RTData$Int3 > (mean(RTData$Int3) + sd(RTData$Int3) * 3)))
#RTData <- RTData[-c(SelRt),]

RTData_melt <- melt(RTData, id.vars = c('ID','Group'))
RTData_melt <- RTData_melt[order(RTData_melt$ID),]
colnames(RTData_melt) <- c('ID','Group','Condition','MeanRT')
ErrData_melt <- melt(ErrData, id.vars = c('ID','Group'))
ErrData_melt <- ErrData_melt[order(ErrData_melt$ID),]
colnames(ErrData_melt) <- c('ID','Group','Condition','Percentage')
############################


### Generate descriptive stats #######################################################################################################################################################################################
RTData.Ext <- RTData %>%
  group_by(Group) %>%
  dplyr::summarise(
    Ext=mean(Ext, na.rm = TRUE),
    SE=c(0)
  )
RTData.Ext$SE <- c(sd(subset(RTData$Ext, RTData$Group == 'Control'), na.rm = TRUE), sd(subset(RTData$Ext, RTData$Group == 'Off'), na.rm = TRUE), sd(subset(RTData$Ext, RTData$Group == 'On'), na.rm = TRUE))
RTData.Ext$SE <- RTData.Ext$SE / c(sqrt(length(subset(RTData$Group, RTData$Group == 'Control'))), sqrt(length(subset(RTData$Group, RTData$Group == 'Off'))), sqrt(length(subset(RTData$Group, RTData$Group == 'On'))))

RTData.Int2 <- RTData %>%
  group_by(Group) %>%
  dplyr::summarise(
    Int2=mean(Int2, na.rm = TRUE),
    SE=c(0)
  )
RTData.Int2$SE <- c(sd(subset(RTData$Int2, RTData$Group == 'Control'), na.rm = TRUE), sd(subset(RTData$Int2, RTData$Group == 'Off'), na.rm = TRUE), sd(subset(RTData$Int2, RTData$Group == 'On'), na.rm = TRUE))
RTData.Int2$SE <- RTData.Int2$SE / c(sqrt(length(subset(RTData$Group, RTData$Group == 'Control'))), sqrt(length(subset(RTData$Group, RTData$Group == 'Off'))), sqrt(length(subset(RTData$Group, RTData$Group == 'On'))))

RTData.Int3 <- RTData %>%
  group_by(Group) %>%
  dplyr::summarise(
    Int3=mean(Int3, na.rm = TRUE),
    SE=c(0)
  )
RTData.Int3$SE <- c(sd(subset(RTData$Int3, RTData$Group == 'Control'), na.rm = TRUE), sd(subset(RTData$Int3, RTData$Group == 'Off'), na.rm = TRUE), sd(subset(RTData$Int3, RTData$Group == 'On'), na.rm = TRUE))
RTData.Int3$SE <- RTData.Int3$SE / c(sqrt(length(subset(RTData$Group, RTData$Group == 'Control'))), sqrt(length(subset(RTData$Group, RTData$Group == 'Off'))), sqrt(length(subset(RTData$Group, RTData$Group == 'On'))))

RTData_melt.summary <- dplyr::group_by(RTData_melt, Group, Condition) %>%
  dplyr::summarise(
    count = n(),
    mean = mean(MeanRT, na.rm = TRUE),
    sd = sd(MeanRT, na.rm = TRUE)
  )

cat('Number of subjects with error rates above 20%: ', length(SelErr), '\n')
#cat('Number of subjects with mean reaction times above 3 SDs: ', length(SelRt), '\n')
table(RTData_melt$Condition, RTData_melt$Group)
RTData_melt.summary

##################################


### Box-and-whiskers plot ###################################################################################################################################
# Hinges: 1st to 3rd quartile. This is the inter-quartile range (IQR)
# Whiskers: Extend above or below the hinge by 1.5 IQR. Data beyond these points are referred to as outliers
# Notches: Extend 1.58 * IQR / sqrt(n). Gives approx 95% confidence interval for comparing medians

boxrt <- RTData_melt %>% ggplot(aes(x=Condition, y=MeanRT, fill=Group)) +
  geom_boxplot(position = position_dodge(0.8), outlier.shape = NA, notch = TRUE) +
  coord_cartesian(ylim = c(500,1300)) +
  geom_dotplot(binaxis = 'y', stackdir = 'center', position = position_dodge(0.8), binwidth = 1, dotsize = 8)
boxrt+labs(title='Reaction time by group per condition', x='Condition', y='Reaction time (ms)')+scale_fill_manual(values = c('lightgrey','grey','darkgrey'))

#############################


### Bar plot ################################################################################################################################################

barrt <- ggbarplot(RTData_melt, x = "Condition", y = "MeanRT",
          add = c("mean_se","jitter"),
          color = "Group", palette = c("npg"),
          position = position_dodge(0.8), ylab = c('Reaction time (ms)'), main = 'Reaction times for each group and condition')
ggpar(barrt,
      font.x = c(20, "plain"),
      font.y = c(20, "plain"),
      font.main = c(20, "plain"),
      font.legend = c(16,"plain"),
      legend = "right")

barerr <- ggbarplot(ErrData_melt, x = "Condition", y = "Percentage",
          add = c("mean_se","jitter"),
          color = "Group", palette = c("npg"),
          position = position_dodge(0.8), ylim = c(0,1), ylab = c('Error rate (%)'), main = 'Error rates for each group and condition')
ggpar(barerr,
      font.x = c(20, "plain"),
      font.y = c(20, "plain"),
      font.main = c(20, "plain"),
      font.legend = c(16,"plain"),
      legend = "right")

################


### Line plot ##################################################################

linert <- ggline(RTData_melt, x = "Condition", y = "MeanRT", color = "Group",
       add = c("mean_se"),
       palette = c("npg"),
       ylab = c('Reaction time (ms)'),
       main = 'Reaction times for each group and condition',
       size = 0.85)
ggpar(linert,
      font.x = c(20, "plain"),
      font.y = c(20, "plain"),
      font.main = c(20, "plain"),
      font.legend = c(16,"plain"),
      legend = "right")

#################


### 2-way ANOVA with Group (HC, Off, On) and Condition (Ext, Int2, Int3) as between-group factors ###############

MyAnova <- aov(MeanRT ~ Group * Condition, data = RTData_melt)
summary(MyAnova)
TukeyHSD(MyAnova, which = 'Group')
TukeyHSD(MyAnova, which = 'Condition')

RTData_melt.PIT <- RTData_melt[RTData_melt$Group == 'Control' | RTData_melt$Group == 'Off',]
MyPITAnova <- aov(MeanRT ~ Group * Condition, data = RTData_melt.PIT)
summary(MyPITAnova)
TukeyHSD(MyPITAnova, which = 'Group')
TukeyHSD(MyPITAnova, which = 'Condition')

RTData_melt.POM <- RTData_melt[RTData_melt$Group == 'On',]
MyPOMAnova <- aov(MeanRT ~ Condition, data = RTData_melt.POM)
summary(MyPOMAnova)
TukeyHSD(MyPITAnova, which = 'Condition')

#####################################################################################################






