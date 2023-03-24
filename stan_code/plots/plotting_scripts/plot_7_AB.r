library(tidyverse)
library(rstan)
library(ggridges)
library(reshape2)
library(HDInterval)

fit <- readRDS("../../fitted_models/m2t_50_fit.rds")

a_p <- extract(fit, "a_p")$a_p
a_p <- a_p[,,2]
a_p <- melt(a_p,varnames = c("iter", "participant"))

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="none")
theme_update(axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"))

p <- ggplot(data=a_p, aes(y=value,x=reorder(participant,value, FUN=median), group=participant)) +
        geom_hline(aes(yintercept=0), alpha=0.5) +
        geom_linerange(stat = "summary",
                  fun.min = function(x) hdi(x, credMass = 0.9)[1],
                  fun.max = function(x) hdi(x, credMass = 0.9)[2], color="#3182bd") +
        geom_linerange(stat = "summary",
                  fun.min = function(x) hdi(x, credMass = 0.5)[1],
                  fun.max = function(x) hdi(x, credMass = 0.5)[2], size=1.1*1.36, color="#08519c") +
        geom_point(stat = "summary",
                  fun = median, size=1.36, color="black", shape=21, fill="#9ecae1") +
        ylab("\u03b2") + xlab("participant")

ggsave(p, filename = "../Figure_7/part_mariginals.tiff",dpi = 600, units = "in", height = 2.6*(3/4), width=5.2, compression = "lzw")

sigma_t <- extract(fit, "s_p")$s_p
nu      <- extract(fit, "nu")$nu

slope_var <- matrix(0, nrow=8000, ncol=6)

for(i in 1:6){
    slope_var[,i] <- sqrt(sigma_t[,i]^2 * (nu/(nu-2)))
}

colnames(slope_var) <- c('ML','AN','AV','MP','RR','RV')
slope_var          <- melt(slope_var,value.name = "sd",varnames =  c("iter","cond"))
slope_var$cond <- factor(slope_var$cond, levels=c("AN", "AV", "ML", "MP", "RR", "RV"))

p <- ggplot(data=slope_var, aes(x=sd,y=cond, fill=cond)) +
    geom_density_ridges(quantile_lines = TRUE, quantiles = c(0.1, 0.5,0.9),) +
    scale_fill_brewer(palette = "Dark2") +
    coord_cartesian(xlim=c(0, 2)) + ylab("") + xlab("std deviation")

 ggsave(p, filename = "../Figure_7/s_e.tiff",dpi = 600, units = "in", height = 2.6* 0.5, width=2.2, compression = "lzw")
