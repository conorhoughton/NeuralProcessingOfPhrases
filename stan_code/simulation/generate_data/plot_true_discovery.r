library(tidyverse)
library(rstan)
library(cmdstanr)
library(boot)



boot_fun <- function(data, ind, weight=FALSE, val=NULL){
    if(weight){
        sum(data[ind] * val[ind])/sum(val[ind]) * 100
    }
    else{
        sum(data[ind])/length(ind) * 100
    }
}

calc_FD_rate <- function(file){
    df <- readRDS(file)
    file_info <- unlist(str_extract_all(file, "[a-z]+|[0-9]+")) # (model, _, T, P, _, _)

    if(file_info[1] == "freq"){
        df$diff <- df$p.val < 0.05
    }

    n   <- sum(df$diff)/length(df$diff) * 100
    W_n <- sum(df$diff * (1 - df$r1 ))/sum((1 - df$r1 )) * 100

    res_df <- data.frame("n"     = n,
                         "W_n"   = W_n,
                         "model" = file_info[1],
                         "t"     = file_info[3],
                         "p"     = file_info[4])

    if(n>0){
        ci <- boot.ci(boot(data=df$diff, R=10000, statistic = boot_fun), type = "bca")
        res_df$ci_u  = ci$bca[5]
        res_df$ci_l  = ci$bca[4]
    }
    else{
        res_df$ci_u  = 0
        res_df$ci_l  = 0
    }
    return(res_df)
}

files     <- list.files()
idxs      <- str_detect(string = files, pattern = "^D_([a-z]+_)+[0-9]+_[0-9]+.rds")
fd_files  <- files[idxs]
result_df <- bind_rows(lapply(fd_files, FUN=calc_FD_rate))

# combine trial and participant to a single factor/ factor modifications
result_df <- result_df %>% mutate(pt=interaction(p,t, sep = " "))
result_df$model <- fct_relabel(as.factor(result_df$model), .fun = function(x) c("Bayes", "ITPC"))

levels(result_df$pt) <- c("p=10, t=10",
                          "p=15, t=10",
                          "p=5, t=10",
                          "p=10, t=20",
                          "p=15, t=20",
                          "p=5, t=20")

result_df$order <- rep(c(3,5,1,4,6,2), 2)

result_df$pt <- fct_reorder(result_df$pt, result_df$order)

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="top", axis.text.x=element_text(angle=45, vjust=0.5), axis.title.x=element_blank())

p <- ggplot(data = result_df, aes(x=pt, y=n, group=model, fill=model)) +
    geom_col(position = position_dodge(width = 1)) +
    scale_fill_brewer(palette = "Paired") +
    geom_point(position = position_dodge(width = 1), show.legend = F, size=0.5)+
    geom_linerange(aes(ymin=ci_l, ymax=ci_u),position = position_dodge(width = 1)) +
    ylab("true discovery rate (%)")

ggsave(plot = p, filename ="true_discovery_rate.tiff", dpi=600, units = "in", height = 2.6, width = 5.2)
