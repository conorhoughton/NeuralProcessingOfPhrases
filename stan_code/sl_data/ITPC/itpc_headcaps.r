library(tidyverse)
library(reshape2)
library(mgcv)
source("../helper_functions.r")

# Takes a list of dataframes and computes the difference between experimental conditions
condition_diff <- function(df_lst){
    bind_rows(df_lst) %>%
        pivot_wider(names_from = condition, values_from = mr) %>%
        mutate(diff = EXP - BL) %>%
        select(-c(BL, EXP))
}

# Code adapted from :
# https://stackoverflow.com/questions/35019382/topoplot-in-ggplot2-2d-visualisation-of-e-g-eeg-data

theme_set(theme_void(base_size = 10, base_family="Times New Roman"))
theme_update(axis.text.x=element_blank(),
             axis.ticks.x=element_blank(),
             axis.text.y=element_blank(),
             axis.ticks.y=element_blank(),
             legend.position="left",
             legend.title = element_text(face="italic"),
             legend.key.height = unit(0.45, "cm"))

circledat <- circleFun(c(0, 0), 4, npoints = 100)

########################################
#----Calculate pairwise differences----#
########################################

# Load and filter data
data <- load_data()

# Calculate ITPC for each electrode by averaging over participant values calculated from trials
mean_res <- data %>%
                group_by(electrode, condition, freq, participant) %>%
                summarise(mr=cabs(mean(phase))) %>% # Across trials
                summarise(mr=mean(mr)) %>% # Across particpants
                ungroup() %>%
                group_by(electrode) %>%
                group_split()

mean_res <- lapply(mean_res, FUN=function(x) split(x, x$condition)) # list of lists
mean_res <- bind_rows(lapply(mean_res, FUN=condition_diff))

mean_res <- mean_res %>%
                    pivot_wider(names_from = freq, values_from = diff) %>%
                    select(-c(electrode)) # cols 1-4 are frequncies 1.33, 2.66, 4, 5.33

mean_res <- as.matrix(mean_res)

####################################
#----Sort out electrode mapping----#
####################################

# Read the layout
layout <- read_delim("../../data/EEG1005.lay",
                     col_names = c("num","x", "y", "a", "b", "electrode"),
                     col_select = c(2,3,6))

# get channels we have
channels <- read_csv("../../data/sl_data/channel_lst.csv", col_names = c("num","electrode"))

# Get the channels that we have
electrode_info <- merge(layout, channels)
electrode_info <- electrode_info[order(electrode_info$num),]

# Load the cluster-based permuatation significance results
cluster_res   <- readRDS("cluster_perm_results.rds")
cluster_res$x <- rep(electrode_info$x, 4)
cluster_res$y <- rep(electrode_info$y, 4)

######################################
#---- Interpolate each difference----#
######################################

N_points <- 250
grid_points <- expand.grid(x = seq(-2, 2, length=N_points), y = seq(-2, 2, length=N_points))
datmat   <- matrix(0, ncol=4, nrow=N_points**2)

for(i in 1:4){ # over each frequency
    spl1 <- gam(signal ~ s(x,y, bs = "ts"),data=data.frame(signal=mean_res[,i], x=electrode_info$x, y=electrode_info$y)) # "sos" k=27
    datmat[,i] <- predict(spl1, grid_points, type = "response")
}

colnames(datmat) <- c("1.33 Hz", "2.66 Hz", "4 Hz", "5.33 Hz")
datmat   <- as.data.frame(datmat)
datmat$x <- grid_points$x
datmat$y <- grid_points$y
datmat   <- pivot_longer(datmat, cols =c(1:4), names_to = c("diff"))

# ignore anything outside the circle
datmat$incircle <- (datmat$x - 0)^2 + (datmat$y - 0)^2 < 2^2
datmat <- datmat[datmat$incircle,]

eeg_cap <- ggplot(datmat, aes(x, y, z = value)) +
               geom_tile(aes(fill = value)) +
               geom_contour(colour = 'white', alpha = 0.8, size=0.3) +
               scale_fill_distiller(palette = "RdYlBu", na.value = NA) +
               geom_path(data = circledat, aes(x, y, z = NULL)) +

               # draw the nose
               geom_line(data = data.frame(x = c(-0.25, 0, 0.25), y = c(2, 2.3, 2)), aes(x, y, z = NULL)) +

               # add points for the electrodes that appear in significant clusters
               geom_point(data = cluster_res %>% filter(significant==T), aes(x, y, z = NULL),
                          shape = 20, size=0.75) +
               # mark every other electrode
               geom_point(data = cluster_res %>% filter(significant==F), aes(x, y, z = NULL, fill = NULL),
                          shape = 4, colour = 'black', size=0.25, alpha=0.33) +
               labs(fill="\u0394\u0052") +
               facet_wrap(vars(diff), ncol = 4)

# Save the plot
ggsave(plot     = eeg_cap,
       filename = "figures/9B_itpc_cap.tiff",
       dpi = 600, units = "in", height = 1.5*(25.36/30.26), width=5.2,
       compression = "lzw")
