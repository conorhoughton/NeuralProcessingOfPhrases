library(HDInterval)
library(tidyverse)
library(rstan)
source("../helper_functions.r")

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="none",
       strip.text=element_text(face="italic"),
       axis.title.y=element_text(),
       axis.title.x=element_text(face="italic"))

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

# The differences plot
df <- df %>% pivot_wider(names_from = cond, values_from = x)
df <- df %>% mutate(diff = EXP-BL)

# 90% HDI's
df_hdi <- df %>% group_by(freq) %>%
            summarise(hdl=hdi(diff, 0.9)[1], hdu=hdi(diff, 0.9)[2], med=median(diff), stdd=sd(diff), pmean=mean(diff)) %>%
            ungroup()

print(df_hdi)

p <- ggplot() +
        geom_errorbarh(data=df_hdi, aes(y=-3.5,xmax=hdu, xmin=hdl), color="#D41159", height=3) +
        geom_point(data=df_hdi, aes(x=med, y=-3.5), size =1,
                       color="black", fill="#D41159", shape=21, stroke=0.2)+
        geom_histogram(data=df,
                       aes(x=diff,y=ifelse(after_stat(density) >0,after_stat(density), NA)),
                       alpha=0.1,
                       color="#1A85FF",
                       binwidth=0.005) +
        facet_grid(cols = vars(freq)) + coord_cartesian(ylim = c(-5,50))+
        scale_x_continuous(breaks = scales::pretty_breaks(n = 4)) +
        xlab("\u0394R") + ylab("density")

ggsave(plot=p, filename = "figures/10A_hdis.png", dpi=600, width = 5.2*0.9892, height = 3.5/2, units = "in")
