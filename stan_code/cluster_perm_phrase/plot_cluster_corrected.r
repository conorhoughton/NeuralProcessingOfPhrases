library(tidyverse)
library(reshape2)
library(mgcv)
source("helper_functions.r")

# Code adapted from :
# https://stackoverflow.com/questions/35019382/topoplot-in-ggplot2-2d-visualisation-of-e-g-eeg-data

theme_set(theme_void(base_size = 10, base_family="Times New Roman"))
theme_update(axis.text.x=element_blank(),
             axis.ticks.x=element_blank(),
             axis.text.y=element_blank(),
             axis.ticks.y=element_blank(),
             legend.position="left",
             legend.title = element_text(face="italic"))

########################################
#----Calculate pairwise differences----#
########################################


# Load and filter data
data <- load_data()
data <- data %>% filter(freqC==21)

# mean resultant length
mean_res <- data %>%
                group_by(participant, electrode, condition) %>%
                summarise(mr=cabs(mean(phase))) # Across trials
mean_res$condition <- fct_relabel(mean_res$condition, fct_r) # Give conditions better names

mean_res <- mean_res %>% pivot_wider(names_from = "condition", values_from = "mr")

# Manually get the differences
mean_res <- mean_res %>% mutate(AN-AV)
mean_res <- mean_res %>% mutate(AN-ML)
mean_res <- mean_res %>% mutate(AN-MP)
mean_res <- mean_res %>% mutate(AN-RR)
mean_res <- mean_res %>% mutate(AN-RV)
mean_res <- mean_res %>% mutate(AV-ML)
mean_res <- mean_res %>% mutate(AV-MP)
mean_res <- mean_res %>% mutate(AV-RR)
mean_res <- mean_res %>% mutate(AV-RV)
mean_res <- mean_res %>% mutate(ML-MP)
mean_res <- mean_res %>% mutate(ML-RR)
mean_res <- mean_res %>% mutate(ML-RV)
mean_res <- mean_res %>% mutate(MP-RR)
mean_res <- mean_res %>% mutate(MP-RV)
mean_res <- mean_res %>% mutate(RR-RV)

mean_res <- mean_res %>% select(c(-3,-4,-5,-6,-7,-8))
mean_res <- mean_res %>% pivot_longer(cols = names(mean_res)[3:17], values_to="mr", names_to="condition")
mean_res <- mean_res %>% group_by(electrode, condition) %>% summarise(value=mean(mr)) # Average over participanrs
mean_res <- as.matrix(mean_res %>% ungroup() %>% pivot_wider(names_from = condition) %>% select(-electrode))

circledat <- circleFun(c(0, 0), 4, npoints = 100)

####################################
#----Sort out electrode mapping----#
####################################

# Read the layout
layout <- read_delim("../data/EEG1005.lay",
                     col_names = c("num","x", "y", "a", "b", "electrode"),
                     col_select = c(2,3,6))

# get channels we have
channels <- read_delim("../data/channel_list.txt", col_names = c("num", "electrode"))

# Get the channels that we have
electrode_info <- merge(layout, channels)
electrode_info <- electrode_info[order(electrode_info$num),]


# Load the cluster perm significance results
cluster_res <- readRDS("cluster_perm_results.rds")
cluster_res$x <- rep(electrode_info$x, 15)
cluster_res$y <- rep(electrode_info$y, 15)

######################################
#---- Interpolate each difference----#
######################################

N_points <- 200
datmat   <- matrix(0, ncol=15, nrow=N_points**2)
colnames(datmat) <- colnames(mean_res)

grid_points <- expand.grid(x = seq(-2, 2, length=N_points), y = seq(-2, 2, length=N_points))

for(i in 1:15){
  spl1 <- gam(signal ~ s(x,y, bs = "ts"),data=data.frame(signal=mean_res[,i], x=electrode_info$x, y=electrode_info$y), sl=0.01) # "sos" k=27
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
               geom_contour(colour = 'white', alpha = 0.8, size=0.2) +
               scale_fill_distiller(palette = "RdYlBu", na.value = NA) +
               #scale_fill_viridis_c(option = "H")+
               geom_path(data = circledat, aes(x, y, z = NULL)) +

               # draw the nose
               geom_line(data = data.frame(x = c(-0.25, 0, 0.25), y = c(2, 2.3, 2)), aes(x, y, z = NULL)) +

               # add points for the electrodes
               geom_point(data = cluster_res %>% filter(significant==T), aes(x, y, z = NULL),
                          shape = 20, size=0.75) +

                geom_point(data = cluster_res %>% filter(significant==F), aes(x, y, z = NULL, fill = NULL),
                          shape = 4, colour = 'black', size=0.25, alpha=0.33) +

               facet_wrap(vars(diff), nrow = 3, ncol=5) +
               labs(fill="\u0394\u0052")

# Save the plot
ggsave(plot     = eeg_cap,
       filename = "figures/2C_cluster_corrected.tiff",
       dpi = 600, units = "in", height = 2.6, width=5.2/1.15,
       compression = "lzw")
