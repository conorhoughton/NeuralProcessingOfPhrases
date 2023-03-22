library(tidyverse)
library(rstan)
library(cmdstanr)

# converts our angles into phase
get_phase <- function(angle){
    return(complex(real = cos(angle) , imaginary = sin(angle)))
}

cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)

set.seed(635415)
samples <- 500
r1 <- runif(samples, 0,1)
r2 <- runif(samples, 0,1)

result_df <- data.frame("delta_r" = vector(length = samples),
                        "y"       = vector(length = samples),
                        "size"    = vector(length = samples),
                        "p.val"   = vector(length = samples),
                        "r1"      = vector(length = samples),
                        "r2"      = vector(length = samples),
                        "r1_hat"  = vector(length = samples),
                        "r2_hat"  = vector(length = samples))

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

mod <- cmdstan_model("../models/generate_data.stan")
seed_lst <- readRDS("seed.rds")$seed

for(i in 1:samples){
    stan_data$a_cv = c(1-r1[i],1-r2[i])
    # samples the data

    fit <- mod$sample(data        = stan_data,
                  chains          = 1,
                  iter_sampling   = 1,
                  fixed_param     = TRUE,
                  seed            = seed_lst[i])

    fit <- read_stan_csv(fit$output_files())

    stan_data$y <- extract(fit, "y_sim")$y_sim[1,,]

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
    result_df$delta_r[i] = abs( r1[i] - r2[i] )
    result_df$y[i]       = mean(mean_res$group1 - mean_res$group2)  / ( r1[i] - r2[i] )
    result_df$size[i]    = min(r1[i], r2[i])/max(r1[i], r2[i])
    result_df$p.val[i]   = wilcox.test(x=mean_res$group1, y=mean_res$group2, paired = T, alternative = "two.sided")$p.val
    result_df$r1[i]      = r1[i]
    result_df$r2[i]      = r2[i]
    result_df$r1_hat[i]  = mean(mean_res$group1)
    result_df$r2_hat[i]  = mean(mean_res$group2)
}

saveRDS(result_df, paste("D_freq_result_", T, "_", P, ".rds", sep=""))

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(axis.title.x = element_text(face="italic"))

result_df$sig <- result_df$p.val < 0.05

p <- ggplot() +
    geom_hline(yintercept=1, alpha=0.33) +
    geom_point(data=result_df, aes(x=delta_r, y=y, color=sig), alpha=.33, size=1, show.legend = F) +
    coord_cartesian(ylim = c(-1,3), xlim = c(0,1)) +
    xlab("\u0394R") + ylab("ratio of difference")+
    scale_color_brewer(palette = "Dark2")

ggsave(p, filename = paste("D_freq_result_", T, "_", P, ".png", sep=""), dpi=600, height = 5.2/3, width = 5.2, units = "in")
