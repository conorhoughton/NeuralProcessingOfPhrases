library(tidyverse)
library(rstan)
library(posterior)

diagnostic_df <- function(draws, par){
  data.frame("ess_basic" = ess_basic(draws),
             "ess_tail"  = ess_tail(draws),
             "ess_bulk"  = ess_bulk(draws),
             "rhat"      = rhat(draws),
             "mcse_mean" = mcse_mean(draws),
             "mcse_quantiles" = mcse_quantile(draws, probs = c(0.05, 0.95)),
             "mcse_sd"   = mcse_sd(draws),
             "par"       = par)
}

fit <- readRDS("../../fitted_models//sl_39_24_fit.rds")

par_names <- names(fit)
par_names <- par_names[str_detect(par_names, pattern = "a_cv\\[[1-2]\\]|a_e\\[[0-9]*,[1-2]\\]|a_p\\[[0-9]*,[1-2]]")]

df_lst <- lapply(par_names, FUN= function(x) diagnostic_df(extract_variable(fit, variable = x), x))
df_res <- bind_rows(df_lst)
saveRDS(df_res, "diagnostic_df.rds")
