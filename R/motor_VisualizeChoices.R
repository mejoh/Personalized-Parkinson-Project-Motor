fDat <- 'P:/3022026.01/pep/bids/sub-POMU30A8145094B8568C/ses-Visit1/beh/sub-POMU30A8145094B8568C_ses-Visit1_task-motor_acq-MB6_run-1_events.tsv'
fDat <- 'P:/3022026.01/pep/bids/sub-POMU40A846C18C7D2997/ses-Visit1/beh/sub-POMU40A846C18C7D2997_ses-Visit1_task-motor_acq-MB6_run-1_events.tsv'
fDat <- 'P:/3022026.01/pep/bids/sub-POMU40A846C18C7D2997/ses-Visit3/beh/sub-POMU40A846C18C7D2997_ses-Visit3_task-motor_acq-MB6_run-1_events.tsv'
fDat <- 'P:/3022026.01/pep/bids/sub-POMU10D1CBD2A4EB7831/ses-Visit1/beh/sub-POMU10D1CBD2A4EB7831_ses-Visit1_task-motor_acq-MB6_run-1_events.tsv'
dDat <- read_tsv(fDat)

df_cue <- dDat %>%
        filter(event_type == 'cue') %>%
        select(trial_number, trial_type, correct_response) %>%
        mutate(trial_number = as.numeric(trial_number))

df_resp <- dDat %>%
        filter(event_type == 'response') %>%
        select(trial_number, button_pressed, button_expected) %>%
        mutate(trial_number = as.numeric(trial_number),
               button_pressed = as.numeric(button_pressed),
               button_expected = as.numeric(button_expected))

df <- left_join(df_cue, df_resp, by = 'trial_number')

df <- df %>%
        separate(button_expected, c('Expected_1','Expected_2','Expected_3'), sep = c(1, 2), convert = TRUE) %>%
        pivot_longer(c('Expected_1','Expected_2','Expected_3'),
                     names_to = 'filled_circles',
                     values_to = 'button_expected') %>%
        select(-c('filled_circles'))

# Plot trial number on the x-axis
# Put expected buttons along the x-axis
# Put pressed button along the y-axis as a line going through the expected buttons

ggplot(df, aes(x = trial_number)) + 
        geom_hline(aes(yintercept = button_expected)) + 
        geom_vline(aes(xintercept = trial_number, col = correct_response), size = 1.2) +
        geom_line(aes(y = button_pressed), col = 'black', size=1.2) + 
        geom_point(aes(y = button_expected), size = 2) + 
        geom_hline(aes(yintercept = mean(button_pressed, na.rm = TRUE)), linetype = 2)


