library(HDInterval)
library(tidyverse)
library(reshape2)
library(mgcv)
library(rstan)
source("helper_functions.r")

theme_set(theme_void(base_size = 10, base_family="Times New Roman"))
theme_update(axis.text.x=element_blank(),
             axis.ticks.x=element_blank(),
             axis.text.y=element_blank(),
             axis.ticks.y=element_blank(),
             legend.position="left",
             legend.title = element_text(face="italic"))

circledat <- circleFun(c(0, 0), 4, npoints = 100)

fit <- readRDS("../../fitted_models/m2t_50_fit.rds")

diffs_c <- combn(c('ML','AN','AV','MP','RR','RV'),2)
diffs_c_idx <- combn(c(1:6),2)

diff_order     <- matrix(0, nrow=2, ncol=15)
diff_order_idx <- matrix(0, nrow=2, ncol=15)

diff_order[,1:4]     <- diffs_c[,2:5]
diff_order[1,5]      <- diffs_c[2,1]
diff_order[2,5]      <- diffs_c[1,1]
diff_order[,6:15]    <- diffs_c[,6:15]
diff_order[c(1,2),1] <- diff_order[c(2,1),1]

diff_order_idx[,1:4]     <- diffs_c_idx[,2:5]
diff_order_idx[1,5]      <- diffs_c_idx[2,1]
diff_order_idx[2,5]      <- diffs_c_idx[1,1]
diff_order_idx[,6:15]    <- diffs_c_idx[,6:15]
diff_order_idx[c(1,2),1] <- diff_order_idx[c(2,1),1]

################################################################################
#----------------------------- Extract the fit --------------------------------#
################################################################################

a_c <- extract(fit, "a_c")$a_c
a_e <- extract(fit, "a_e")$a_e

for(i in 1:32){
    a_e[,i,] <- a_e[,i,] + a_c
}

alpha_CE <- 1 - inv_logit(a_e) # Mean resulant length

# Gives a (S * 32 * 6 array)

################################################################################
#-------------------------- Sort out electrode mapping ------------------------#
################################################################################
# Read the layout
layout <- read_delim("../../data/EEG1005.lay",
                     col_names = c("num","x", "y", "a", "b", "electrode"),
                     col_select = c(2,3,6))

# get channels we have
channels <- read_delim("../../data/channel_list.txt", col_names = c("num", "electrode"))

# Get the channels that we have
electrode_info <- merge(layout, channels)
electrode_info <- electrode_info[order(electrode_info$num),]

################################################################################
#------------------ Calculate difference pairs from samples -------------------#
################################################################################

# Create a df with electrode rows and columns for condition differences
col_names  <- vector(length=15)
diff_idxs  <- diff_order_idx
diff_names <- diff_order
diffs <- matrix(0, nrow=32, ncol=15) # Hold the result
hdi_sig  <- matrix(0, nrow=32, ncol=15)

for(i in 1:15){
    pair         <- diff_idxs[,i]
    diffs[,i]    <- apply(X=(alpha_CE[,,pair[1]] - alpha_CE[,,pair[2]]), FUN=mean,MARGIN=2)
    col_names[i] <- paste(diff_names[,i][1], "-", diff_names[,i][2], sep=" ")
    hdi_interval <- apply(X=(alpha_CE[,,pair[1]] - alpha_CE[,,pair[2]]), FUN=hdi,MARGIN=2)
    hdi_sig[,i]  <- apply(hdi_interval, FUN=function(x) (0 < x[1]) || (0 > x[2]), MARGIN=2)
}

hdi_layout <- data.frame("x"    = rep(electrode_info$x, 15) ,
                         "y"    = rep(electrode_info$y, 15),
                         "diff" = rep(col_names, each=32),
                         "sig"  = c(hdi_sig))

################################################################################
# ---------------------- Interpolate each difference --------------------------#
################################################################################
N_points <- 200
datmat   <- matrix(0, ncol=15, nrow=N_points**2)
colnames(datmat) <- col_names

grid_points <- expand.grid(x = seq(-2, 2, length=N_points), y = seq(-2, 2, length=N_points))

for(i in 1:15){
  # Or Splines on spheres
  #spl1 <- gam(signal ~ s(x,y, bs = "sos", k=27),data=data.frame(signal=diffs[,i], x=layout$x, y=layout$y))
  spl1 <- gam(signal ~ s(x,y, bs = "ts"),data=data.frame(signal=diffs[,i], x=electrode_info$x, y=electrode_info$y))
  datmat[,i] <- predict(spl1, grid_points, type = "response")
}

datmat   <- as.data.frame(datmat)
datmat$x <- grid_points$x
datmat$y <- grid_points$y

datmat <- pivot_longer(datmat, cols =c(1:15), names_to = c("diff"))

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
ggsave(eeg_cap, filename = "../Figure_6/cap_by_condition_p16.tiff",dpi = 600, units = "in", height = 2.6, width=5.2/1.15, compression = "lzw")

theme_set(theme_void(base_size = 10, base_family="Times New Roman"))
theme_update(legend.title = element_text(face="italic"))

eeg_cap <- ggplot(filter(datmat, diff == "AN - AV"), aes(x, y, z = value)) +
  geom_tile(aes(fill = value)) +
  geom_contour(colour = 'white', alpha = 0.8) +
  scale_fill_distiller(palette = "RdYlBu", na.value = NA) +
  geom_path(data = circledat, aes(x, y, z = NULL), color="#0072B2") +

  # draw the nose (haven't drawn ears yet)
  geom_line(data = data.frame(x = c(-0.25, 0, 0.25), y = c(2, 2.3, 2)),
            aes(x, y, z = NULL), color="#0072B2") +
  geom_text(data = electrode_info, aes(x, y, z = NULL, fill = NULL, label=electrode), size=2.85) + labs(fill="\u0394R")

# Save the plot
ggsave(eeg_cap, filename = "../Figure_7/AN-AV_big.tiff",dpi = 600, units = "in", height = 2.6, width=3, compression = "lzw")
