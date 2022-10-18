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
part_lst <- read_csv("data/participants.csv", col_types="int",n_max=n_part)

# load the full data
df <- read_csv("data/full_data.csv", col_types =c("icciiiid??d"));
df <- df %>% mutate(phase=as.complex(phase))

# Filter based on the condition and participants
df <- df %>%
          filter(freqC==freq_band, participant %in% part_lst$participant) %>%
          mutate(participant = participant-4) #

# Input data
by_trials <- df %>% group_by(participant, electrode, condition) %>%
                   summarise(angle=list(angle))
y         <- sapply(by_trials$angle, FUN=unlist)

# Create data structure holding input for stan
stan_data <-list("N"               = length(by_trials$participant),
                 "P"               = length(part_lst$participant),
                 "C"               = 6,
                 "E"               = 32,
                 "T"               = 24,
                 "participant_idx" = by_trials$participant,
                 "electrode_idx"   = by_trials$electrode,
                 "condition_idx"   = as.numeric(factor(by_trials$condition)),
                 "y"               = t(y))

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
saveRDS(fit, paste("fitted_models/", model_id,"_",n_part,"_fit.rds", sep=""))
