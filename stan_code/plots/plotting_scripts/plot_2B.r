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

sig_plot <- ggplot(mean_res, aes(x=condition, y=ITPC)) +
							geom_jitter(height = 0, width=0.25, alpha=0.5, size=0.9, aes(color=condition)) +
     					scale_color_brewer(palette = "Dark2") +
    					geom_boxplot(alpha=0.0) +
					    geom_signif(test        = "wilcox.test",
					                test.args   = list("paired" =TRUE),
					                comparisons = list(c("AN", "AV"),
					                                   c("AN", "MP"),
					                                   c("AN", "RR"),
					                                   c("AN", "RV")),
					                map_signif_level=TRUE,
					                y_position=c(0.4, 0.5, 0.55, 0.60, 0.65)) +
							ylim(0.07, 0.65) +
							ylab("R")

ggsave(plot = sig_plot,
	 		 filename = "../Figure_2/2B_boxplot.tiff",
			 width = 2.6, height = 2.6, units = "in", dpi=600,
			 compression = "lzw")