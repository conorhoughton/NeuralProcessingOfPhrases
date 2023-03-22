library(tidyverse)
library(rstan)
library(cmdstanr)
library(HDInterval)

set.seed(635415) # Seed for MRL generation

# converts our angles into phase
get_phase <- function(angle){
    return(complex(real = cos(angle) , imaginary = sin(angle)))
}

cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)

samples <- 500
r1 <- runif(samples, 0,1)
r2 <- r1 #  No difference in data generating process.

result_df_bayes <- data.frame("diff" = vector(length = samples),
                        "r1"         = vector(length = samples),
                        "r2"         = vector(length = samples),
                        "r1_hat"     = vector(length = samples),
                        "r2_hat"     = vector(length = samples),
                        "r1_hat_sd"  = vector(length = samples),
                        "r2_hat_sd"  = vector(length = samples))

result_df_freq <- data.frame("p.val"   = vector(length = samples),
                        "r1"      = vector(length = samples),
                        "r2"      = vector(length = samples),
                        "r1_hat"  = vector(length = samples),
                        "r2_hat"  = vector(length = samples))

# Set the data generating parameters
P <- 10
C <- 2  # Number of conditions
E <- 8  # Number of electrodes
T <- 20
N <- E * P * C

# Hold the indices
participant_idx <- array(0, dim = N)
electrode_idx   <- array(0, dim = N)
condition_idx   <- array(0, dim = N)

# set the indices
for(i in 1:P){
  for(j in 1:C){
    for(k in 1:E){
      participant_idx[(i-1)*C*E + (j-1)*E + k] <- i
      condition_idx[(i-1)*C*E + (j-1)*E + k]   <- j
      electrode_idx[(i-1)*C*E + (j-1)*E + k]   <- k
    }
  }
}

# stan data
stan_data <-list("N"               = N,
                 "P"               = P,
                 "C"               = C,
                 "E"               = E,
                 "T"               = T,
                 "participant_idx" = participant_idx,
                 "electrode_idx"   = electrode_idx,
                 "condition_idx"   = condition_idx,
                 "nu_sim"          = 20,
                 "sig"             = 0.25,
                 "tau"             = 0.25)

mod_gen <- cmdstan_model("../models/generate_data.stan")
mod_fit <- cmdstan_model("../../models/model_2t.stan")
seed_lst <- readRDS("seed.rds")$seed

for(i in 1:samples){
    stan_data$a_cv = c(1-r1[i],1-r2[i])

    # samples the data
    fit <- mod_gen$sample(data    = stan_data,
                  chains          = 1,
                  iter_sampling   = 1,
                  fixed_param     = TRUE,
                  seed            = seed_lst[i])

    fit <- read_stan_csv(fit$output_files())
    stan_data$y <- extract(fit, "y_sim")$y_sim[1,,]

    fit <- mod_fit$sample(data            = stan_data,
                      chains          = 4,
                      parallel_chains = 4,
                      step_size       = 0.5,
                      init            = 0.5,
                      iter_warmup     = 500,
                      iter_sampling   = 500)

    # Save fit and generating params
    fit <- read_stan_csv(fit$output_files()) # Save output from cmdstanr in a way that preserves param layout.

    a_cv <- extract(fit, "a_cv")$a_cv
    mean_diff <- mean((1-a_cv[,1]) - (1-a_cv[,2]))

    # hdi
    hdi_vals  <- hdi((1-a_cv[,1]) - (1-a_cv[,2]))
    diff      <- (0 < hdi_vals[1]) || (0 > hdi_vals[2])

    # write the result
    result_df_bayes$diff[i]       = diff
    result_df_bayes$r1[i]         = r1[i]
    result_df_bayes$r2[i]         = r2[i]
    result_df_bayes$r1_hat[i]     = mean(1 - a_cv[,1])
    result_df_bayes$r2_hat[i]     = mean(1 - a_cv[,2])
    result_df_bayes$r1_hat_sd[i]  = sd(1 - a_cv[,1])
    result_df_bayes$r2_hat_sd[i]  = sd(1 - a_cv[,2])

    # freq results

    # now put into a format to how the experimental data is used (calculate ITPC and such)
    sim_df <- data.frame("angle"       = c(stan_data$y) ,
                         "phase"       = sapply(c(stan_data$y), FUN=function(x) get_phase(x)),
                         "participant" = rep(stan_data$participant_idx, T),
                         "condition"   = rep(stan_data$condition_idx, T),
                         "electrode"   = rep(stan_data$electrode_idx, T),
                         "trial"       = rep(c(1:T),each=N))

    sim_df$condition <- fct_relabel(as.factor(sim_df$condition), function(x) c('group1', 'group2'))

    # calculate ITPC
    mean_res <- sim_df %>%
                group_by(participant, condition, electrode) %>%
                summarise(mpa=cabs(mean(phase))) %>% # Over trials
                summarise(ITPC=mean(mpa)) %>%
                pivot_wider(names_from = condition, values_from = ITPC)# Over electrodes

    # write the result
    result_df_freq$p.val[i]   = wilcox.test(x=mean_res$group1, y=mean_res$group2, paired = T, alternative = "two.sided")$p.val
    result_df_freq$r1[i]      = r1[i]
    result_df_freq$r2[i]      = r2[i]
    result_df_freq$r1_hat[i]  = mean(mean_res$group1)
    result_df_freq$r2_hat[i]  = mean(mean_res$group2)

}

saveRDS(result_df_bayes, paste("FD_bayes_result_", T, "_", P, "_", E, ".rds", sep=""))
saveRDS(result_df_freq, paste("FD_freq_result_", T, "_", P, "_", E,".rds", sep=""))
