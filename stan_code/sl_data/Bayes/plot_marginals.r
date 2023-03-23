library(HDInterval)
library(tidyverse)
library(reshape2)
library(rstan)
source("../helper_functions.r")

# Load the posterior fits for each frequency
p_6  <- readRDS("../../fitted_models/sl_39_6_fit.rds")
p_12 <- readRDS("../../fitted_models/sl_39_12_fit.rds")
p_18 <- readRDS("../../fitted_models/sl_39_18_fit.rds")
p_24 <- readRDS("../../fitted_models/sl_39_24_fit.rds")

p_6  <- 1 - extract(p_6, "a_cv")$a_cv
p_12 <- 1 - extract(p_12, "a_cv")$a_cv
p_18 <- 1 - extract(p_18, "a_cv")$a_cv
p_24 <- 1 - extract(p_24, "a_cv")$a_cv

# Arrange the data frame
df <- bind_rows(data.frame("bl" = p_6[,1]  , "exp" = p_6[,2]),
                data.frame("bl" = p_12[,1] , "exp" = p_12[,2]),
                data.frame("bl" = p_18[,1] , "exp" = p_18[,2]),
                data.frame("bl" = p_24[,1] , "exp" = p_24[,2]), .id="freq")

df$iteration <- rep(c(1:length(p_6[,1])))

df <- df %>% pivot_longer(values_to = "x", cols = c(bl, exp), names_to = "cond")

df$freq <- fct_recode(as.factor(df$freq), "1.33 Hz" = "1",
                                          "2.66 Hz" = "2",
                                          "4 Hz"    = "3",
                                          "5.33 Hz" = "4")
df$cond <- fct_relabel(df$cond, fct_r)

# Plot the violins
theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="none",
       strip.text=element_text(face="italic"),
       axis.title.y = element_blank())

p <- ggplot(df, aes(x = x, y = cond, fill = cond, group=cond, color=cond)) +
			geom_violin(alpha=0.25) +
			geom_linerange(stat = "summary",
									  	fun.min = function(x) hdi(x, credMass = 0.9)[1],
									  	fun.max = function(x) hdi(x, credMass = 0.9)[2]) +
			geom_point(stat="summary", fun=median, shape = 21,colour = "black", size=0.75, alpha=1) +
   		scale_fill_brewer(palette = "Dark2") +
			scale_color_brewer(palette = "Dark2") +
      ylab("condition") +
			coord_flip()+
      facet_grid(cols = vars(freq))

ggsave(plot=p, filename = "figures/10B_marginals.tiff", dpi=600, width = 5.2, height = 3.5/2, units = "in", compression="lzw")
