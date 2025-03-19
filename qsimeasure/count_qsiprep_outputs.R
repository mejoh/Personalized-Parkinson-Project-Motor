library(tidyverse)

count_files <- function(qsiprepdir, pseudonym, session) {
    
    # Checks the number of files in dwi and metric directories
    
    # qsiprepdir = 'P:/3022026.01/pep/bids/derivatives/qsiprep'
    # pseudonym = 'sub-POMU38588D7F10CCC56F'
    # session = 'ses-POMVisit3'
    
    datadir <- paste(qsiprepdir, pseudonym, session, sep='/')
    
    dat <- tibble(
        pseudonym = pseudonym,
        session = session,
        dwi = list.files(paste(datadir, 'dwi', sep = '/')) %>% length(),
        amico_noddi = list.files(paste(datadir, 'metrics', 'amico_noddi', sep = '/')) %>% length(),
        dipy_b0 = list.files(paste(datadir, 'metrics', 'dipy_b0', sep = '/')) %>% length(),
        dipy_fw = list.files(paste(datadir, 'metrics', 'dipy_fw', sep = '/')) %>% length(),
        pasternak_fw = list.files(paste(datadir, 'metrics', 'pasternak_fw', sep = '/')) %>% length(),
    )
    
    dat
}
clean_dirs <- function(qsiprep, pseudonym, session, metric) {
    
    # qsiprepdir = 'P:/3022026.01/pep/bids/derivatives/qsiprep'
    # pseudonym = 'sub-POMUBA95A9F6A41E872C'
    # session = 'ses-POMVisit1'
    # metric = 'dipy_fw'
    
    d <- paste(qsiprepdir, pseudonym, session, 'metric', metric, sep = '/')
    unlink(d, recursive = T)
    
}

# List of subjects
qsiprepdir = 'P:/3022026.01/pep/bids/derivatives/qsiprep'
subs <- list.dirs(qsiprepdir, full.names = F, recursive = F)
subs <- subs[grepl('sub-POMU.*', subs)]

# Initial data frame
df <- 
    tibble(
        pseudonym = character(),
        session = character(),
        dwi = numeric(),
        amico_noddi = numeric(),
        dipy_b0 = numeric(),
        dipy_fw = numeric(),
        pasternak_fw = numeric()
    )

# Add rows by subject and session
for(s in 1:length(subs)){
    sdir <- paste(qsiprepdir, subs[s], sep = '/')
    sessions <- list.dirs(sdir, full.names = F, recursive = F)
    sessions <- sessions[grepl('ses-.*Visit.*',sessions)]
    for(v in 1:length(sessions)){
        df <- df %>%
            bind_rows(count_files(qsiprepdir, subs[s], sessions[v]))
    }
}

# Define incomplete subjects
df <- df %>%
    mutate(
        incomplete = case_when(
            dwi < 12 ~ 1,
            amico_noddi < 9 ~ 1,
            dipy_b0 < 2 ~ 1,
            dipy_fw < 31 ~ 1,
            pasternak_fw < 26 ~ 1,
            .default = 0
        )
    )

# Report complete subjects
df %>%
    count(incomplete, session)
