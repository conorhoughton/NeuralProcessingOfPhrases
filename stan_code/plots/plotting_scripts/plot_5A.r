library(rstan)
library(stringr)
library(HDInterval)

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position = "none", axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"))

a_cv <- matrix(0, nrow=58, ncol=6)

for(i in 1:58){
    fit <- readRDS(paste("../../fitted_models/optim/opt_",i,".rds", sep = ""))$par
    a_cv[i,] <- 1 - 1/(1+exp(-fit$a_c))
}

x_freq <- seq(4/15.36, (58+3)/15.36, by=1/15.36)
df <- data.frame("Variance"     = c(a_cv),
                 "Frequency"    = rep(x_freq,6),
                 "Condition"    = rep(c('ML','AN','AV','MP','RR','RV'), each=58))

p <- ggplot(data = df, aes(x=Frequency, y=Variance, color=Condition)) +
     geom_line(size=0.5) +
     geom_vline(xintercept = c(x_freq[9], x_freq[21], x_freq[45]), size=0.1) +
     facet_wrap(vars(Condition)) +
     ylab("R") +
     xlab("frequency (Hz)") +
     scale_color_brewer(palette = "Dark2") +
     scale_y_continuous(breaks=c(0.2,0.4,0.6),limits=c(0.08328119,0.65192922))

ggsave(filename = "../Figure_5/fig_5A.tiff", plot = p, dpi = 600, width = 2.6, height=2.6, units="in", compression="lzw")
