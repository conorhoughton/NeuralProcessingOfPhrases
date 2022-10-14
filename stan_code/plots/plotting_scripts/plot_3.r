library(tidyverse)
source("helper_functions.r")

theme_set(theme_classic(base_size = 10, base_family="Times New Roman"))
theme_update(legend.position = "none",
	     axis.title.y = element_text(angle = 0, vjust = 0.5))

# Colored electrodes:   "T7", "P4", "F8"
# Corresponding indexes "12", "26", "7"

data <- load_data()
data <- data %>% filter(freqC==21, condition=="anan")

mean_res <- data %>%
							group_by(participant, electrode) %>%
              summarise(mpa=catan2(mean(phase)))

# start the participants from 1 (we drop the first four)
mean_res$participant <- mean_res$participant - 4

main_p <- ggplot() +
              geom_jitter(data = mean_res %>% filter(!(electrode %in% c(12,26,7))),
                  aes(x=participant, y=mpa),
                  height = 0, width = 0.15, shape=1, size=0.5) +
              geom_point(data = mean_res %>% filter(electrode %in% c(12,26,7)),
                  aes(x=participant, y=mpa, color=as.character(electrode)), shape=18, size=3) +
              scale_color_brewer(palette = "Set2") +
              scale_y_continuous(breaks=c(-pi, -pi/2, 0, pi/2, pi),
                  labels=c("-\u03C0", "-\u03C0/2", "0", "\u03C0/2","\u03C0")) +
              ylab("\u03BC")

ggsave(filename = "../Figure_3/elec_angle_participant.tiff", plot = main_p, width = 5.2*0.75, height = 1.5, units = "in", dpi=600, compression = "lzw")

sub_p <- ggplot() +
             geom_violin(data = mean_res %>% filter(electrode %in% c(12,26,7)),
                  aes(y=mpa, x=as.character(electrode), fill=as.character(electrode)))+
             geom_jitter(data = mean_res %>% filter(electrode %in% c(12,26,7)),
                  aes(y=mpa, x=as.character(electrode), fill=as.character(electrode)),
                  height = 0, width = 0.15, shape=1, size=0.5) +
                  ylab("") + xlab("electrode") +
             scale_fill_brewer(palette = "Set2")+
             theme(axis.text.y = element_blank(),
                   axis.ticks.y = element_blank(),
                   plot.margin=unit(c(5.5,5.5,5,0), "pt"),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank()) +
             scale_x_discrete(breaks=c("12","26","7"),
                   labels=c("T7","P4","F8"))

ggsave(filename = "../Figure_3/elec_angle_dist.tiff", plot = sub_p, width = 5.2*0.25, height = 1.5, units = "in", dpi=600, compression = "lzw")
