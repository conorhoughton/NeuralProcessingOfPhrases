library(ggplot2)

plot_id   <- "mrl_diff"
ranks     <- do.call(rbind, readRDS("ranks/mrl_ranks.rds")) # Set the rank to calculate here, one of the output files
reduction <- 32
ranks     <- ranks %/% reduction
bins      <- 1024/reduction
N         <- 2000 # how many interations was this run for?

lower_line <- qbinom(0.995, prob = 1/bins, size = N)
upper_line <- qbinom(0.005, prob = 1/bins, size = N)
med_line   <- qbinom(0.5, prob  = 1/bins, size = N)

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))

# get binomial quantiles
p <- ggplot() +
     geom_rect(aes(xmin=0, xmax=bins-1, ymin=lower_line, ymax=upper_line),alpha=0.15, fill="#1b9e77") +
     geom_hline(yintercept = med_line)+
     geom_hline(yintercept = upper_line)+
     geom_hline(yintercept = lower_line) +
     geom_histogram(aes(x = ranks), bins=bins, color="black", fill="#7570b3",alpha=0.8, closed = "left") +
     xlab("rank statistic") + ylab("frequency")

ggsave(plot     = p,
       filename = paste(plot_id, "_hist.png", sep=""),
       width = 2.6, height = 5.2/3, units = "in", dpi=600)

################################ ECDF ##########################################

# differences between finte sample ecdf and true uniform cdf
get_sample_ecdf <- function(dunif_cdf_vals){
   ecdf_df <- data.frame(table(sort(sample(c(0:(bins-1)), N, replace = T))))
   head((cumsum(ecdf_df$Freq/N) - dunif_cdf_vals), bins-1)
}

# discrete uniform cdf
dunif_cdf <- function(x,a,b){
    return( (x-a+1)/(b-a+1) )
}

dunif_cdf_vals      <- dunif_cdf(c(0:(bins-1)), 0, bins-1) # uniform cdf true
ecdf_diffs          <- sapply(c(1:20000), FUN=function(i) get_sample_ecdf(dunif_cdf_vals)) # estimate quantiles
ecdf_diff_quantiles <- apply(ecdf_diffs, FUN=function(x) quantile(x, c(0.005, 0.995)), MARGIN=1)
rank_ecdf_diff      <- cumsum(data.frame(table(sort(ranks)))$Freq/N) - dunif_cdf_vals

p <- ggplot() +
     geom_ribbon(aes(x = c(0:(bins-2)), ymin=ecdf_diff_quantiles[1,], ymax=ecdf_diff_quantiles[2,]), alpha=0.15, fill="#1b9e77") +
     geom_hline(yintercept=0, alpha=0.33) +
     geom_step(aes(x=c(0:(bins-1)), y=rank_ecdf_diff), color="#7570b3") +
     xlab("rank statistic") + ylab("ECDF difference")

ggsave(plot     = p,
      filename = paste(plot_id, "_ecdf.png", sep=""),
      width = 2.6, height = 5.2/3, units = "in", dpi=600)
