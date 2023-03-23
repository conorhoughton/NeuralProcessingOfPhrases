library(ggsignif)
library(tidyverse)
source("../helper_functions.r")

# Set plot theme
theme_set(theme_classic(base_size = 10, base_family="Times New Roman"))
theme_update(legend.position = "none",
             axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"),
            strip.text=element_text(face="italic"))

# load the data, construct the complex numbers and create factors for frequency/condition
data <- load_data()

# Calculate the ITPC for each partiicpant and electrode pairing
mean_res <- data %>%
        group_by(participant, condition,freq, electrode) %>%
                summarise(mpa=cabs(mean(phase))) %>% # Over trials
                summarise(ITPC=mean(mpa)) # Over electrodes

# Plot
# 1) This only calcultes the t.test result, but labels include results from a precomputed wilcox test.
# 2) Because the 4Hz frequency is the opposite tail to the pseudoword frequency we use a two-sided test
# and double the threshold for significance.
sig_plot <- ggplot(mean_res, aes(x=condition, y=ITPC)) +
                geom_jitter(height = 0, width=0.25, alpha=0.5, size=0.9, aes(color=condition)) +
                scale_color_brewer(palette = "Dark2") +
                geom_boxplot(alpha=0.0) +
                geom_signif(test        = "t.test",
                    test.args           = list("paired" =TRUE, "alternative"="two.sided"), # some tests are greater some are less, so do two-sided and multiply thresholds by
                    comparisons         = list(c("EXP", "BL")),
                    map_signif_level    = c("***/***"=0.001*2, "**"=0.01*2, "NS./*"=0.05*2, "NS./NS."=1),
                    y_position          = c(0.3)) +
                ylab("R") +
                facet_grid(cols=vars(freq))

# save the plot
ggsave(plot = sig_plot,
       filename = "figures/9A_boxplot.tiff",
       width = 5.2, height = 2.6, units = "in", dpi=600,
       compression = "lzw")
