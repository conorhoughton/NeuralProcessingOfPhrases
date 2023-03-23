library(tidyverse)
library(bayesplot)
color_scheme_set("purple")

get_highest_rhat <- function(param_regex){
  increasing_rhat <- params$unique_name[order(params$rhat)]
  param_idxs      <- str_detect(increasing_rhat, param_regex)
  params$unique_name[tail(order(params$rhat)[param_idxs],1)]
}

fit   <- readRDS("../../fitted_models/m2t_50_fit.rds")
rhats <- rhat(fit)
neff  <- neff_ratio(fit)

get_param_ss <- function(param_regex){
  idxs <- which(str_detect(string = names(rhats), pattern = param_regex))
  data.frame("param_name"  = rep(param_regex, length(idxs)),
             "unique_name" = names(rhats)[idxs],
             "rhat"        = rhats[idxs],
             "neff"        = neff[idxs],
             "size"        = 1/length(idxs))
}

param_names <- c("a_c\\[", "a_p\\[", "a_e\\[", "s_p\\[","s_e\\[")
params <- bind_rows(lapply(param_names, FUN=get_param_ss)) #  then flatted over the list

b_a_c <- get_highest_rhat("a_c\\[")
b_a_p <- get_highest_rhat("a_p\\[")
b_a_e <- get_highest_rhat("a_e\\[")
b_s_e <- get_highest_rhat("s_e\\[")
b_s_p <- get_highest_rhat("s_p\\[")
bad_pars <- c(b_a_c, b_a_p, b_a_e, b_s_e, b_s_p)

################################################################################
############################ Rhat vs Neff ######################################
################################################################################

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"),
             axis.title.x = element_text(face="italic"),
             legend.position="none",
             legend.title=element_blank())

p <- ggplot() +
        geom_point(data=params,aes(x=rhat,y=neff,fill=param_name, size=size, color=param_name), alpha=0.50) +
        geom_point(data=params %>%filter(unique_name %in% bad_pars),aes(x=rhat,y=neff,fill=param_name, size=size), shape=21) +
        geom_hline(yintercept=c(0.1,0.5), linetype=c("solid", "dashed")) +
        scale_size(guide = 'none') +
        scale_color_brewer(palette = "Accent") +
        scale_fill_brewer(palette = "Accent") +
        xlab( expression(italic(widehat(R)))) + ylab(expression(italic(frac(N[eff], N))))

ggsave(filename = "../Figure_8/neff_rhat.tiff", plot = p, dpi = 600, width = 0.6*5.2, height=2.6, units="in", compression="lzw")

################################################################################
################################### Energy #####################################
################################################################################

np <- nuts_params(fit)

bayesplot_theme_set(theme_classic())
bayesplot_theme_update(text= element_text(size = 10,family="Times New Roman"))
p <- mcmc_nuts_energy(np, merge_chains=TRUE) + theme(legend.position=c(0.85, 0.75))
ggsave(filename = "../Figure_8/energy.tiff", plot = p, dpi = 600, width = 0.4*5.2, height=2.6, units="in", compression="lzw")

################################################################################
################################# Trace ########################################
################################################################################
# trace should show the "worst" sampled for each param

bayesplot_theme_set(theme_classic())
bayesplot_theme_update(text= element_text(size = 10,family="Times New Roman"))

color_scheme_set(colorRampPalette(c("#7fc97f", "black"))(8)[1:6])
p <- mcmc_trace(fit, bad_pars[1]) + legend_none() + yaxis_ticks(FALSE) + yaxis_text(FALSE) + ylab("")
ggsave(filename = "../Figure_8/bp1.tiff", plot = p, dpi = 600, width = 5.2-0.162, height=2.6/4, units="in", compression="lzw")


color_scheme_set(colorRampPalette(c("#beaed4", "black"))(8)[1:6])
p <- mcmc_trace(fit, bad_pars[2], transform=function(x) 1/(1+x^2))  + legend_none() + yaxis_ticks(FALSE) + yaxis_text(FALSE) + ylab("")
ggsave(filename = "../Figure_8/bp2.tiff", plot = p, dpi = 600, width = 5.2-0.162, height=2.6/4, units="in", compression="lzw")

color_scheme_set(colorRampPalette(c("#fdc086", "black"))(8)[1:6])
p <- mcmc_trace(fit, bad_pars[3])  + legend_none() + yaxis_ticks(FALSE) + yaxis_text(FALSE) + ylab("")
ggsave(filename = "../Figure_8/bp3.tiff", plot = p, dpi = 600, width = 5.2-0.162, height=2.6/4, units="in", compression="lzw")

color_scheme_set(colorRampPalette(c("#ffff99", "black"))(8)[1:6])
p <- mcmc_trace(fit, bad_pars[4])  + legend_none() + yaxis_ticks(FALSE) + yaxis_text(FALSE) + ylab("")
ggsave(filename = "../Figure_8/bp4.tiff", plot = p, dpi = 600, width = 5.2-0.162, height=2.6/4, units="in", compression="lzw")

color_scheme_set(colorRampPalette(c("#386cb0", "black"))(8)[1:6])
p <- mcmc_trace(fit, bad_pars[5])  + legend_none() + yaxis_ticks(FALSE) + yaxis_text(FALSE) + ylab("")
ggsave(filename = "../Figure_8/bp5.tiff", plot = p, dpi = 600, width = 5.2-0.162, height=2.6/4, units="in", compression="lzw")
