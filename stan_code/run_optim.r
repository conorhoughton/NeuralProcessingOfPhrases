suppressMessages(library(tidyverse))
suppressMessages(library(stringr))
library(rstan)
library(cmdstanr)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)

# Command line args
args = commandArgs(trailingOnly=TRUE)
model_file_path     <- args[1]                  # Stan Model File Path
iter_n              <- as.integer(args[2])      # Number of sampling iterations
model_id            <- args[3]                  # identifier to discriminate model fits
print(model_file_path)

# What participants to run from
part_lst <- read_csv("data/participants.csv", col_types="int", n_max=16)

# load the full data
df       <- read_csv("data/full_data.csv", col_types =c("icciiiid??d"));

for(i in 1:58){

  # Filter based on the condition and participants
  this_freq_df <- df %>%
            filter(freqC==i, participant %in% part_lst$participant) %>%
            mutate(participant = participant-4)

  # Input data
  by_trials <- this_freq_df %>% group_by(participant, electrode, condition) %>%
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

  sm <- stan_model(file      = model_file_path)
  fit <- optimizing(object   = sm,
                    data     = stan_data,
                    verbose  = TRUE,
                    hessian  = FALSE,
                    as_vector= FALSE,
                    draws    = iter_n)

  # Save fit
  saveRDS(fit, paste("fitted_models/optim/","opt_",i,".rds", sep=""))

}

#sm  <- cmdstan_model(model_file_path)
#fit <- sm$optimize(data = stan_data, iter=)

# Save fit
#fit <- read_stan_csv(fit$output_files()) # Save output from cmdstanr in a way that preserves param layout.
#
