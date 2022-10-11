suppressMessages(library(tidyverse))
suppressMessages(library(rstan))
suppressMessages(library(bayesplot))
suppressMessages(library(stringr))
color_scheme_set("purple")

rstan_options(auto_write = TRUE);
options(mc.cores = parallel::detectCores());

# Command line args
args = commandArgs(trailingOnly=TRUE)
model_file_path     <- args[1]                  # Stan Model File Path
iter_n              <- as.integer(args[2])      # Number of sampling iterations
freq_band           <- as.integer(args[3])      # What frequency
id                  <- args[4]                  # Character indetifier for saved model reference
print(model_file_path)

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
                 "condition_idx"   = as.numeric(factor(df$condition)),
                 "participant_idx" = as.numeric(factor(df$participant)),
                 "y" = df$angle)

# Not all intermediate parameters are of interest, so specify ones to ignore. Also keeps output size down.
drop_params <- c("mu_vec", "gamma_vec")

#################################### MCMC ######################################

# Run the stan model, uncomment for MCMC
#fit <- stan(file=model_file_path, data=stan_data, iter=iter_n, chains=4, include = FALSE, pars=drop_params)

################################################################################

################### Optimising, MVN posterior approximation ####################
sm <- stan_model(file=model_file_path)
fit <- optimizing(object=sm,
                  data=stan_data,
                  verbose=TRUE,
                  as_vector=FALSE,
                  importance_resampling=TRUE,
                  draws=iter_n)

################################################################################

# Save fit
print("Saving Fit")
saveRDS(fit, paste("fitted_models/fit_", id, "_", freq_band, ".rds", sep=""))

############################ Basic Plotting ####################################

# Plot the marginals.
idxs <- which(str_detect(colnames(fit$theta_tilde), "alpha_C\\["))
alpha_C <- fit$theta_tilde[,idxs]
colnames(alpha_C) <- c('ML','AN','AV','MP','RR','RV') # Give the columns more usful names

# order the cols by mean
idx_order <- order(colMeans(fit$theta_tilde[,idxs]))
alpha_C <- alpha_C[, idx_order]

ggsave("plots/ac_marginals.png", mcmc_areas(alpha_C))

### And for differences
diffs     <- matrix(0, nrow=iter_n, ncol=15)
col_names <- vector(length=15)
diff_pairs <- combn(c(1:6),2)
diff_names <- combn(colnames(alpha_C),2)

for(i in 1:15){
    pair         <- diff_pairs[,i]
    diffs[,i]    <- alpha_C[,pair[2]] - alpha_C[,pair[1]]
    col_names[i] <- paste(diff_names[,i][2], " - ", diff_names[,i][1])

}

colnames(diffs) <-col_names
idx_order <- order(colMeans(diffs))
diffs     <- diffs[, idx_order]

ggsave("plots/ac_diffs.png", mcmc_intervals(diffs, prob_outer = .97))
