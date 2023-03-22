suppressMessages(library(tidyverse))
suppressMessages(library(stringr))
library(cmdstanr)
library(rstan)

# Command line args
args = commandArgs(trailingOnly=TRUE)
model_file_path     <- args[1]                  # Stan Model File Path
iter_n              <- as.integer(args[2])      # Number of sampling iterations
freq_band           <- as.integer(args[3])      # What frequency
model_id            <- args[4]                  # identifier to discriminate model fits
n_part              <- as.integer(args[5])      # Participant Number
print(model_file_path)

# What participants to run from
part_lst <- read_csv("data/sl_data/participants.csv", col_types="int", n_max=n_part)

# load the full data
df <- read_csv("data/sl_data/data.csv");
df <- df %>% mutate(phase = complex(real =p_real , imaginary =p_im ))

# Filter based on the condition and participants
df <- df %>% filter(freq==freq_band, participant %in% part_lst$participant)

# Participant 1 has an extra set of 4 electrodes for one condition, remove these
df <- df %>% filter(electrode<=64)

# Input data
by_trials <- df %>% group_by(participant, electrode, condition) %>%
                   summarise(angle=list(angle))

y <- matrix(0,nrow = nrow(by_trials), ncol = length(by_trials[1,]$angle[[1]]))
n_trials <- vector(length=nrow(by_trials))

for(i in 1:(nrow(by_trials))){
    angles               <- unlist(by_trials[i,]$angle)
    n_trials[i]          <- length(angles)
    y[i,(1:n_trials[i])] <- angles
}

# Create data structure holding input for stan
stan_data <-list("N"               = length(by_trials$participant),
                 "P"               = length(part_lst$participant),
                 "C"               = length(unique(df$condition)),
                 "E"               = length(unique(df$electrode)),
                 "T_max"           = 132,
                 "trials"          = n_trials,
                 "participant_idx" = by_trials$participant,
                 "electrode_idx"   = by_trials$electrode,
                 "condition_idx"   = as.numeric(factor(by_trials$condition)),
                 "y"               = y)

# Run the stan model
mod <- cmdstan_model(model_file_path)

fit <- mod$sample(data            = stan_data,
                  chains          = 4,
                  parallel_chains = 4,
                  iter_warmup     = iter_n/2,
                  iter_sampling   = iter_n/2,
                  refresh         = 50,
                  save_warmup     = F,
                  init            = 0.5)

# Save fit
fit <- read_stan_csv(fit$output_files()) # Save output from cmdstanr in a way that preserves param layout.
saveRDS(fit, paste("fitted_models/", model_id,"_",n_part, "_", freq_band, "_fit.rds", sep=""))
