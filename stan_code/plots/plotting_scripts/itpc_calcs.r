library(ggsignif)
library(tidyverse)
source("helper_functions.r")

theme_set(theme_classic(base_size = 10, base_family="Times New Roman"))
theme_update(legend.position = "none",
	     axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"))

# load the data
data <- load_data()
data <- data %>% filter(freqC==21)  # pick a certain frequency

mean_res <- data %>%
		 group_by(participant, condition, electrode) %>%
                summarise(mpa=cabs(mean(phase))) %>% # Over trials
                summarise(ITPC=mean(mpa)) # Over electrodes

mean_res$condition <- fct_relabel(mean_res$condition, fct_r)
mean_res <- mean_res %>% mutate(condition = factor(condition, c("AN", "AV", "ML", "MP", "RR", "RV")))



print(mean_res)
