library(tidyverse)
library(rstan)
library(cmdstanr)
library(HDInterval)

set.seed(635415)

# converts our angles into phase
get_phase <- function(angle){
    return(complex(real = cos(angle) , imaginary = sin(angle)))
}

cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)


samples <- 500
r1 <- runif(samples, 0,1)
r2 <- runif(samples, 0,1)

result_df <- data.frame("delta_r" = vector(length = samples),
                        "y"       = vector(length = samples),
                        "size"    = vector(length = samples),
                        "diff"    = vector(length = samples),
                        "r1"      = vector(length = samples),
                        "r2"      = vector(length = samples),
                        "r1_hat"  = vector(length = samples),
                        "r2_hat"  = vector(length = samples),
                        "r1_hat_sd"  = vector(length = samples),
                        "r2_hat_sd"  = vector(length = samples))

# Set the data generating parameters
P <- 15
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
    result_df$delta_r[i]    = abs( r1[i] - r2[i] )
    result_df$y[i]          = (mean_diff) / ( r1[i] - r2[i] )
    result_df$size[i]       = min(r1[i], r2[i])/max(r1[i], r2[i])
    result_df$diff[i]       = diff
    result_df$r1[i]         = r1[i]
    result_df$r2[i]         = r2[i]
    result_df$r1_hat[i]     = mean(1 - a_cv[,1])
    result_df$r2_hat[i]     = mean(1 - a_cv[,2])
    result_df$r1_hat_sd[i]  = sd(1 - a_cv[,1])
    result_df$r2_hat_sd[i]  = sd(1 - a_cv[,2])
}

saveRDS(result_df, paste("bayes_result_", T, "_", P, ".rds", sep=""))

# plot
theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(axis.title.x = element_text(face="italic"))

p <- ggplot() +
      geom_hline(yintercept=1, alpha=0.33) +
      geom_point(data=result_df, aes(x=delta_r, y=y, color=diff), alpha=.33, size=1, show.legend = F) +
      coord_cartesian(ylim = c(-1,3), xlim = c(0,1)) +
      xlab("\u0394R") + ylab("ratio of difference")+
      scale_color_brewer(palette = "Dark2")

ggsave(p, filename = paste("D_bayes_result_", T, "_", P, ".png", sep=""), dpi=600, height = 5.2/3, width = 5.2, units = "in")
