library(tidyverse)
library(rstan)
library(ggridges)
library(reshape2)
library(HDInterval)

fit <- readRDS("../../fitted_models/m2t_50_fit.rds")

# Want electrodes : F8, T7, P4
electrodes <- c("F8", "T7", "P4") # 7,12,26, makes sure these are in increasing order

layout <- read_delim("../../data/channel_list.txt", col_names = c("num", "electrode"))

electrodes_idx <- (layout %>% filter(electrode %in% electrodes))$num

main_effect <- extract(fit, "a_c")$a_c
lambda_post <- extract(fit, "a_e")$a_e
lambda_post_diff <- 1/(1+exp(-lambda_post[,electrodes_idx,3]-main_effect[,3]))  -  1/(1+exp(-lambda_post[,electrodes_idx,2]-main_effect[,2])) # AN - AV

colnames(lambda_post_diff) <- electrodes
lambda_post_diff <- melt(lambda_post_diff, varnames = c("iter", "electrode"), value.name = "sample")

lambda_post_diff$electrode <- fct_relevel(as.factor(lambda_post_diff$electrode), c("T7", "P4", "F8"))

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="none",
             axis.title.x=element_text(face="italic"))

p <- ggplot(data=lambda_post_diff, aes(x=sample, y=electrode, color=electrode, fill=electrode)) + geom_vline(aes(xintercept=0), alpha=0.5) +
        geom_linerange(stat = "summary",
                  fun.min = function(x) hdi(x, credMass = 0.9)[1],
                  fun.max = function(x) hdi(x, credMass = 0.9)[2]) +
        geom_linerange(stat = "summary",
                  fun.min = function(x) hdi(x, credMass = 0.5)[1],
                  fun.max = function(x) hdi(x, credMass = 0.5)[2], size=1.1) +
        geom_point(stat = "summary",
          	   fun = median, size=2, shape = 21, color="black") +
        scale_color_brewer(palette = "Dark2") + xlab("\u0394R (AN - AV)") + ylab("") +
        scale_fill_brewer(palette = "Dark2")

ggsave(p, filename = "../Figure_7/plot_7d.tiff",dpi = 600, units = "in", height = 2.6*0.5, width=2.2, compression = "lzw")
