library(tidyverse)
library(cmdstanr)
library(rstan)
library(zipfR)

# samples from a truncated gamma
sample_trun_gamma <- function(u, a, b){
    f2 <- Rgamma(a, 2*b, lower = T)
    c <- u*(1-f2) + f2
    Rgamma.inv(a, c, lower = T)/b
}

mod <- cmdstan_model("../models/simple_sim.stan")

# Set the data generating parameters
P <- 5  # Number of participants
C <- 2  # Number of conditions
E <- 8  # Number of electrodes
Trials <- 10 # Number of trials per participant
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

# hold the ranks
M <- 2000
trunc_nu_samples         <- sapply(runif(M, 0,1), FUN=function(x) sample_trun_gamma(x,2,0.1))
main_effect_ranks        <- vector("list", length=M)
electrode_effect_ranks   <- vector("list", length=M)
participant_effect_ranks <- vector("list", length=M)
participant_sd_ranks     <- vector("list", length=M)
electrode_sd_ranks       <- vector("list", length=M)
nu_ranks                 <- vector("list", length=M)
mrl_ranks                <- vector("list", length=M)

# Create data structure holding input for stan
stan_data <-list("N"               = N,
                 "P"               = P,
                 "C"               = C,
                 "E"               = E,
                 "T"               = Trials,
                 "participant_idx" = participant_idx,
                 "electrode_idx"   = electrode_idx,
                 "condition_idx"   = condition_idx)

# loop SBC
for(i in 1:M){
  stan_data$nu_sim <- trunc_nu_samples[i]

  fit <- mod$sample(data            = stan_data,
                    chains          = 1,
                    parallel_chains = 1,
                    iter_warmup     = 1000,
                    iter_sampling   = 1023,
                    init            = 0.5,
                    step_size       = 0.5)

  # Save fit
  fit <- read_stan_csv(fit$output_files()) # Save output from cmdstanr in a way that preserves param layout.

  main_effect_ranks[[i]]        <- colSums(extract(fit, "main_effect_ranks")$main_effect_ranks)
  electrode_effect_ranks[[i]]   <- colSums(extract(fit, "electrode_effect_ranks")$electrode_effect_ranks)
  participant_effect_ranks[[i]] <- colSums(extract(fit, "participant_effect_ranks")$participant_effect_ranks)
  participant_sd_ranks[[i]]     <- colSums(extract(fit, "participant_sd_ranks")$participant_sd_ranks)
  electrode_sd_ranks[[i]]       <- colSums(extract(fit, "electrode_sd_ranks")$electrode_sd_ranks)
  nu_ranks[[i]]                 <- sum(extract(fit, "nu_ranks")$nu_ranks)
  mrl_ranks[[i]]                <- sum(extract(fit, "mrl_diff_ranks")$mrl_diff_ranks)
}

# save the results
saveRDS(main_effect_ranks        , "main_effect_ranks.rds")
saveRDS(electrode_effect_ranks   , "electrode_effect_ranks.rds")
saveRDS(participant_effect_ranks , "participant_effect_ranks.rds")
saveRDS(participant_sd_ranks     , "participant_sd_ranks.rds")
saveRDS(electrode_sd_ranks       , "electrode_sd_ranks.rds")
saveRDS(nu_ranks                 , "nu_ranks.rds")
saveRDS(mrl_ranks                , "mrl_ranks.rds")
