library(HDInterval)
library(tidyverse)
library(rstan)
source("../helper_functions.r")


create_all_part_df <- function(){
    p_6  <- readRDS("../../fitted_models/sl_39_6_fit.rds")
    p_12 <- readRDS("../../fitted_models/sl_39_12_fit.rds")
    p_18 <- readRDS("../../fitted_models/sl_39_18_fit.rds")
    p_24 <- readRDS("../../fitted_models/sl_39_24_fit.rds")

    data_lst <- c(p_6, p_12, p_18, p_24)

    df <- bind_rows(lapply(data_lst, FUN = create_part_df), .id = "freq")

    df$freq <- fct_recode(as.factor(df$freq), "1.33 Hz" = "1",
                                              "2.66 Hz" = "2",
                                              "4 Hz"    = "3",
                                              "5.33 Hz" = "4")
    return(df)

}

create_part_df <- function(df){
    a_c <- rstan::extract(df, "a_c")$a_c
    a_p <- rstan::extract(df, "a_p")$a_p

    part_res <- 1-inv_logit(a_p[,,2] + a_c[,2]) - (1 - inv_logit(a_p[,,1] + a_c[,1]))

    rownames(part_res) <- c(1:4000) # 4000 is number of posterior iterations
    colnames(part_res) <- c(1:39)

    part_res <- data.frame("x"    = c(part_res),
           "part" = factor(rep(c(1:39), each=4000)),
           "iter" = rep(c(1:4000), 39))

    #part_res$part <- fct_reorder(part_res$part,part_res$x)
    return(part_res)
}

all_part_df <- create_all_part_df()

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="top",
       strip.text=element_blank(),
       axis.title.y=element_text(angle=0, vjust=0.5, face="italic"),
       axis.text.x=element_text(angle=90, vjust=0.5))

p <- ggplot(data=all_part_df, aes(x=part, y=x, color=freq)) +
        geom_hline(aes(yintercept=0)) +
        geom_crossbar(stat="summary",
                     fun = median,
                     fun.min = function(x) hdi(x, 0.99)[1],
                     fun.max = function(x) hdi(x, 0.99)[2]) +
                     xlab("participant") +
                     ylab("\u0394R") +
                     facet_grid(rows = vars(freq), switch="x") +
                     scale_color_brewer(palette = "Dark2", "")

ggsave(plot = p, filename = "figures/participant_posteriors.tiff", width = 5.2, height = 5.2, dpi=600, compression="lzw")
