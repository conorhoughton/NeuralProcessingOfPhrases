library(tidyverse)
source("helper_functions.r")

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(axis.title.y = element_text(angle = 0, vjust = 0.5))

xx    <- seq(-pi, pi, by=0.01)
gamma <- c(0.5,1,2,5)
wc_dens <- sapply(gamma, FUN=function(x) WC_d(xx,0,x))

df <- data.frame(angle   = rep(xx, length(gamma)),
                 density = c(wc_dens),
                 gamma   = rep(as.character(gamma), each=length(xx)))

wc_plot <- ggplot(data=df, aes(x=angle, y=density, fill=gamma, color=gamma)) +
              geom_line()+
              xlab(label="\u03b8") +
              ylab(label="p(\u03b8)") +
              scale_x_continuous(breaks=c(-pi, -pi/2, 0, pi/2, pi),
                                 labels=c("-\u03c0", "-\u03c0/2","0","\u03c0/2","\u03c0")) +
              scale_color_brewer(palette = "Set1",name  = "\u03b3")

ggsave(filename = "../Figure_5/WC_examples.tiff",
       plot  = wc_plot,
       width = 5.2-1.732, height=1.5, units = "in", dpi=600,
       compression = "lzw", bg="transparent")
