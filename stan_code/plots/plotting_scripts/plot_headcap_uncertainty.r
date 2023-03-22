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
# ---------------------------- Plot Uncertainty -------------------------------#
################################################################################
pair         <- diff_idxs[,6]
an_av_diffs  <- (alpha_CE[,,pair[1]] - alpha_CE[,,pair[2]])

N_points <- 100
datmat   <- matrix(0, ncol=25, nrow=N_points**2)
colnames(datmat) <- c("1":"25")

grid_points <- expand.grid(x = seq(-2, 2, length=N_points), y = seq(-2, 2, length=N_points))

set.seed(430)
post_idxs <- sample(x = c(1:8000), replace = F, size = 25)

for(i in 1:25){
  spl1 <- gam(signal ~ s(x,y, bs = "ts"),data=data.frame(signal=an_av_diffs[post_idxs[i],], x=electrode_info$x, y=electrode_info$y))
  datmat[,i] <- predict(spl1, grid_points, type = "response")
}

datmat   <- as.data.frame(datmat)
datmat$x <- grid_points$x
datmat$y <- grid_points$y

datmat <- pivot_longer(datmat, cols =c(1:25), names_to = c("diff"))

datmat <- datmat %>% group_by(diff) %>% mutate(value = (value-mean(value))/sd(value))
datmat$diff <- reorder(datmat$diff, order(datmat$diff))

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
  geom_point(data = hdi_layout %>% filter(diff == "AN - AV") %>% select(c(x,y)), aes(x, y, z = NULL, fill = NULL),
  		shape = 4, colour = 'black', size=0.25, alpha=0.33) +
  facet_wrap(vars(diff), nrow = 5, ncol=5) +
  labs(fill="z(\u0394R)")

# Save the plot
ggsave(eeg_cap, filename = "AN_AV_posterior.tiff",dpi = 600, units = "in", height = 5.2, width=5.2, compression="lzw")
