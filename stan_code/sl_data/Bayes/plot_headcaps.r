library(HDInterval)
library(tidyverse)
library(reshape2)
library(mgcv)
library(abind)
library(rstan)
source("../helper_functions.r")


theme_set(theme_void(base_size = 10, base_family="Times New Roman"))
theme_update(axis.text.x=element_blank(),
             axis.ticks.x=element_blank(),
             axis.text.y=element_blank(),
             axis.ticks.y=element_blank(),
             legend.position="left",
             legend.title = element_text(face="italic"),
             legend.key.height = unit(0.45, "cm"))

circledat <- circleFun(c(0, 0), 4, npoints = 100)

################################################################################
#----------------------------- Extract the fit --------------------------------#
################################################################################
p_6  <- readRDS("../../fitted_models/sl_39_6_fit.rds")
p_12 <- readRDS("../../fitted_models/sl_39_12_fit.rds")
p_18 <- readRDS("../../fitted_models/sl_39_18_fit.rds")
p_24 <- readRDS("../../fitted_models/sl_39_24_fit.rds")

a_c6  <- extract(p_6, "a_c")$a_c
a_c12 <- extract(p_12, "a_c")$a_c
a_c18 <- extract(p_18, "a_c")$a_c
a_c24 <- extract(p_24, "a_c")$a_c

a_e6  <- extract(p_6, "a_e")$a_e
a_e12 <- extract(p_6, "a_e")$a_e
a_e18 <- extract(p_18, "a_e")$a_e
a_e24 <- extract(p_24, "a_e")$a_e

for(i in 1:64){
    a_e6[,i,]  <- a_e6[,i,]  + a_c6 # 4000 * 64 *2
    a_e12[,i,] <- a_e12[,i,] + a_c12
    a_e18[,i,] <- a_e18[,i,] + a_c18
    a_e24[,i,] <- a_e24[,i,] + a_c24
}

a_ce_6  <- 1 - inv_logit(a_e6)
a_ce_12 <- 1 - inv_logit(a_e12)
a_ce_18 <- 1 - inv_logit(a_e18)
a_ce_24 <- 1 - inv_logit(a_e24)

alpha_CE <- abind(a_ce_6, a_ce_12, a_ce_18, a_ce_24, along = 0)
################################################################################
#-------------------------- Sort out electrode mapping ------------------------#
################################################################################
# Read the layout
layout <- read_delim("../../data/EEG1005.lay",
                     col_names = c("num","x", "y", "a", "b", "electrode"),
                     col_select = c(2,3,6))

# get channels we have
channels <- read_csv("../../data/sl_data/channel_lst.csv", col_names = c("num","electrode"))

# Get the channels that we have
electrode_info <- merge(layout, channels)
electrode_info <- electrode_info[order(electrode_info$num),]
################################################################################
#------------------ Calculate difference pairs from samples -------------------#
################################################################################

# Create a df with electrode rows and columns for condition differences
diffs      <- matrix(0, nrow=64, ncol=4) # Hold the result
hdi_sig   <- matrix(0, nrow=64, ncol=4)
col_names  <- c("1.33 Hz", "2.66 Hz", "4 Hz", "5.33 Hz")

for(i in 1:4){
    diffs[,i]    <- apply(X=(alpha_CE[i,,,2] - alpha_CE[i,,,1]), FUN=mean,MARGIN=2)
    hdi_interval <- apply(X=(alpha_CE[i,,,2] - alpha_CE[i,,,1]), FUN=function(x) hdi(x),MARGIN=2)
    hdi_sig[,i]  <- apply(hdi_interval, FUN=function(x) (0 < x[1]) || (0 > x[2]), MARGIN=2)
}

hdi_layout <- data.frame("x"    = rep(electrode_info$x, 4) ,
                         "y"    = rep(electrode_info$y, 4),
                         "diff" = rep(col_names, each=64),
                         "sig"  = c(hdi_sig))

################################################################################
# ---------------------- Interpolate each difference --------------------------#
################################################################################
N_points <- 250
datmat   <- matrix(0, ncol=4, nrow=N_points**2)
colnames(datmat) <- col_names

grid_points <- expand.grid(x = seq(-2, 2, length=N_points), y = seq(-2, 2, length=N_points))

for(i in 1:4){
  # Or Splines on spheres
  #spl1 <- gam(signal ~ s(x,y, bs = "sos", k=27),data=data.frame(signal=diffs[,i], x=layout$x, y=layout$y))
  spl1 <- gam(signal ~ s(x,y, bs = "ts"),data=data.frame(signal=diffs[,i], x=electrode_info$x, y=electrode_info$y))
  datmat[,i] <- predict(spl1, grid_points, type = "response")
}

datmat   <- as.data.frame(datmat)
datmat$x <- grid_points$x
datmat$y <- grid_points$y

datmat <- pivot_longer(datmat, cols =c(1:4), names_to = c("diff"))

# ignore anything outside the circle
datmat$incircle <- (datmat$x - 0)^2 + (datmat$y - 0)^2 < 2^2 # mark
datmat <- datmat[datmat$incircle,]

eeg_cap <- ggplot(datmat, aes(x, y, z = value)) +
  geom_tile(aes(fill = value)) +
  geom_contour(colour = 'white', alpha = 0.8, size=0.3) +
  scale_fill_distiller(palette = "RdYlBu", na.value = NA) +
  geom_path(data = circledat, aes(x, y, z = NULL)) +

  # draw the nose (haven't drawn ears yet)
  geom_line(data = data.frame(x = c(-0.25, 0, 0.25), y = c(2, 2.3, 2)),
            aes(x, y, z = NULL)) +

  # add points for the electrodes
  geom_point(data = hdi_layout %>% filter(sig==T), aes(x, y, z = NULL),
  		shape = 20, size=0.75) +

  geom_point(data = hdi_layout %>% filter(sig==F), aes(x, y, z = NULL, fill = NULL),
  		shape = 4, colour = 'black', size=0.25, alpha=0.33) +
  facet_wrap(vars(diff), nrow = 3, ncol=5) +
  labs(fill="\u0394R")

# Save the plot
ggsave(plot     = eeg_cap,
       filename = "figures/10C_headcap.tiff",
       dpi = 600, units = "in", height = 1.5*(25.36/30.26), width=5.2,
       compression = "lzw")
