suppressMessages(library(tidyverse))
suppressMessages(library(rstan))
rstan_options(auto_write = TRUE);
options(mc.cores = parallel::detectCores());

# Command line args
args = commandArgs(trailingOnly=TRUE)
model_file_path     <- args[1]                  # Stan Model File Path
iter_n              <- as.integer(args[2])      # Number of sampling iterations
freq_band           <- as.integer(args[3])      # What frequency
id                  <- args[4]                  # Character indetifier for saved model reference

# What participants to run from
part_lst <- read_csv("data/participants.csv", col_types="int")

# load the full data
df <- read_csv("data/full_data.csv", col_types =c("icciiiid??d"));

# Filter based on the condition wanted
df <- df %>% filter(freqC==freq_band) %>% filter(participant %in% part_lst$participant)

# Create data structure holding model input
stan_data <-list("N"= length(df$angle),
                 "E" = length(unique(df$electrode)),
                 "C" = length(unique(df$conditionC)),
                 "P" = length(part_lst$participant),
                 "electrode_idx"   = df$electrode,
                 "condition_idx"   = as.numeric(factor(df$conditionC)),
                 "participant_idx" = df$participant,
                 "y" = df$angle)

# Not all intermediate parameters are of interest, so specify ones to ignore. Also keeps output size down.
drop_params <- c("mu_vec", "gamma_vec")

# Run the stan model
fit <- stan(file=model_file_path, data=stan_data, iter=iter_n, chains=1, include = FALSE, pars=drop_params)

# Save fit
print("Saving Fit")
saveRDS(fit, paste("fitted_models/fit_", id, "_", freq_band, ".rds", sep=""))
