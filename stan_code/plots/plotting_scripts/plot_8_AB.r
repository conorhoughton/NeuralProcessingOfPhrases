library(tidyverse)
library(rstan)
library(HDInterval)
library(reshape2)

cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)

theme_set(theme_classic(base_size = 10, base_family="Times New Roman"))
theme_update(legend.position = "none",axis.title.y = element_text(angle = 0, vjust = 0.5, face="italic"))

#################
#------HDI------#
#################

n_min <- 5
n_res <- 16 - n_min + 1

result_mtx <- matrix(0, nrow=8000, ncol=n_res) # 8000 samples

for(i in n_min:16){
    this_fit <- readRDS(paste("../../fitted_models/m2t_", i, "_fit.rds", sep=""))
    a_mrl    <- 1 - extract(this_fit, "a_cv")$a_cv # Get mean resultant length
    diff     <- a_mrl[,2] - a_mrl[,5] # AN-RR
    result_mtx[,(i-4)] <- diff # index 1 to 13
}

result_mtx <- as.data.frame(result_mtx)
colnames(result_mtx) <- c(as.character(n_min):"16")
result_mtx           <- pivot_longer(result_mtx, cols = c(as.character(n_min):"16"))


p <- ggplot(data=result_mtx, aes(x=as.numeric(name), y=value, group=name)) +
            geom_hline(aes(yintercept=0), alpha=0.5) +
            geom_crossbar(stat = "summary",
            fun.min = function(x) hdi(x, credMass = 1-0.05/6)[1],
            fun.max = function(x) hdi(x, credMass = 1-0.05/6)[2],
            fun     = median,
            alpha   = 1, color="black", fill="#efedf5", width=0.75, size=0.25)+
            geom_crossbar(stat = "summary",
            fun.min = function(x) hdi(x, credMass = 0.95)[1],
            fun.max = function(x) hdi(x, credMass = 0.95)[2],
            fun     = median,
            alpha   = 1, color="black", fill="#bcbddc", width=0.75, size=0.25) +
            geom_crossbar(stat = "summary",
            fun.min = function(x) hdi(x, credMass = 0.9)[1],
            fun.max = function(x) hdi(x, credMass = 0.9)[2],
            fun     = median,
            alpha   = 1, color="black", fill="#756bb1", width=0.75, size=0.25)+
            ylab("\u0394R") +
            xlab("number of participants") +
            scale_x_continuous(breaks=c(n_min:16))

ggsave(plot = p, filename = "../Figure_8/hdi_bars.tiff", width = 2.6, height = 2, units = "in", dpi=600, compression = "lzw")


################
#---P values---#
################

# load the data
data <- read_csv("../../data/full_data.csv", col_types =c("icciiiid??d"))
data <- data %>% filter(freqC==21)

# Covert the ft coeffs to complex numbers - slow but works
data$phase <- sapply(X=data$phase, FUN = function(x) as.complex(gsub(" ", "", substr(x,1,nchar(x)-1))))

pvals <- vector(length=n_res)

for(i in n_min:16){
    # What participants to run from
    part_lst <- read_csv("../../data/participants.csv", col_types="int",n_max=i)
    this_data <- data %>% filter(participant %in% part_lst$participant)

    # Calc ITPC
    mean_res <- this_data %>%
            group_by(participant, condition, electrode) %>%
                summarise(mpa=cabs(mean(phase))) %>% # Over trials
                summarise(ITPC=mean(mpa)) # Over electrodes

    AN <- filter(mean_res, condition=="anan")$ITPC
    RR <- filter(mean_res, condition=="rrrr")$ITPC
    pvals[16 - i + 1] <- wilcox.test(AN, RR, paired=TRUE)$p.value #  Get the P value
}

# write the p values out for reference
#df_pval <- data.frame("p_val"=pvals, n=16 - c(as.character(n_min):16) + 1)
#write.csv(df_pval, "../Figure_reduced/p_vals.csv", row.names=F)


p <- ggplot() +
   geom_hline(yintercept = 0.1, alpha=0.5) +
   geom_hline(yintercept = 0.05, alpha=0.5) +
   geom_hline(yintercept = 0.05/6, alpha=0.5) +
   geom_line(aes(x=c(16:5), y=pvals), size=0.3) +
   geom_point(aes(x=as.integer(c(16:5)), y=pvals), shape=21, fill="#66a61e", size=2) +
   xlab("number of participants") + ylab("p-value") + scale_x_continuous(breaks=c(16:n_min))

ggsave(plot = p, filename = "../Figure_8/p_vals.tiff", width = 2.6, height = 2, units = "in", dpi=600, compression = "lzw")
