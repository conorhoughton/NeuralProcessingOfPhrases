library(ggplot2)
library(tidyverse)

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"),legend.position = "none")

cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)

fct_r <- function(x){
    c('ML','AN','AV','MP','RR','RV')
}

# load the data
data <- read_csv("../../data/full_data.csv", col_types =c("icciiiid??d"))
data <- data %>% filter(!(participant %in% c(1,2,3,4)))  # Ignore the first four participants

# Covert the ft coeffs to complex numbers - slow but works
data$phase <- sapply(X=data$phase, FUN = function(x) as.complex(gsub(" ", "", substr(x,1,nchar(x)-1))))

mean_res <- data %>%  group_by(freq, condition, participant, electrode) %>%
                summarise(mpa=cabs(mean(phase))) %>% # Over trials
                summarise(ITPC=mean(mpa)) # Over electrodes

# Better factor names + ordering
mean_res$condition <- fct_relabel(mean_res$condition, fct_r)
mean_res <- mean_res %>% mutate(condition = factor(condition, c("AN", "AV", "ML", "MP", "RR", "RV")))

x_freq <- seq(4/15.36, 15.36, by=1/15.36)

p <- ggplot() +
     geom_line(data=mean_res, aes(x=freq, y=ITPC, group=participant, color=condition), alpha=0.25, size=0.2) +
     geom_line(data=mean_res %>% summarise(ITPC = mean(ITPC)), aes(x=freq, y=ITPC),size=0.3) +
     geom_vline(xintercept = c(x_freq[9], x_freq[21], x_freq[45]), size=0.1) +
     facet_wrap(vars(condition)) +
     scale_color_brewer(palette = "Dark2") +
     xlab("frequency (Hz)") + ylab("R")

#layer_scales(p)$y$get_limits() Print out to help keep consistency of axis limits

ggsave(plot     = p,
       filename = "../Figure_2/2A_itpc_by_freq.tiff",
       width = 2.6, height = 2.6, units = "in", dpi=600,
       compression = "lzw")
