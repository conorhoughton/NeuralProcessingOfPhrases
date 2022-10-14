library(HDInterval)
library(tidyverse)
library(reshape2)
library(rstan)

string_swap <- function(x){
	grps <- unlist(strsplit(x, " "))[c(1,3)]
	paste(grps[2], "-", grps[1], sep=" ")
}

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position="none",
	     axis.title.y=element_text(face="italic", angle = 0, vjust = 0.5),
	     axis.title.x=element_blank())

fit <- readRDS("../../fitted_models/m2t_50_fit.rds")

##############################
#---- Draw the Marginals ----#
##############################

R           <- 1-extract(fit, "a_cv")$a_cv
colnames(R) <- c('ML','AN','AV','MP','RR','RV')
R           <- melt(R,value.name = "x", varnames =  c("iter","cond") )

R <- R %>% mutate(cond = factor(cond, c("AN", "AV", "ML", "MP", "RR", "RV")))

p <- ggplot(R, aes(x = x, y = cond, fill = cond, group=cond, color=cond)) +
			geom_violin(alpha=0.25) +
			geom_linerange(stat = "summary",
									  	fun.min = function(x) hdi(x, credMass = 0.9)[1],
									  	fun.max = function(x) hdi(x, credMass = 0.9)[2]) +
			geom_point(stat="summary", fun=median, shape = 21,colour = "black", size=0.75, alpha=1) +
   		scale_fill_brewer(palette = "Dark2") +
			scale_color_brewer(palette = "Dark2") +
			coord_flip() +
			xlab("") + xlab("")

ggsave(plot=p, filename = "../Figure_5/R_marginals.tiff", dpi=600, width = 2.6, height = 2.6/2, units = "in", compression="lzw")

###################################################
#---- Calculate difference pairs from samples ----#
###################################################

# This is horribly complicated, having alphabetical order into stan will fix this,
# although will now require code changing. This is a manual reordering to give the
# same layout as in fig 2C

diffs_c <- combn(c('ML','AN','AV','MP','RR','RV'),2)
diffs_c_idx <- combn(c(1:6),2)

diff_order     <- matrix(0, nrow=2, ncol=15)
diff_order_idx <- matrix(0, nrow=2, ncol=15)

diff_order[,1:4]   <- diffs_c[,2:5]
diff_order[1,5]    <- diffs_c[2,1]
diff_order[2,5]    <- diffs_c[1,1]
diff_order[,6:15]  <- diffs_c[,6:15]
diff_order[c(1,2),1] <- diff_order[c(2,1),1]

diff_order_idx[,1:4]   <- diffs_c_idx[,2:5]
diff_order_idx[1,5]    <- diffs_c_idx[2,1]
diff_order_idx[2,5]    <- diffs_c_idx[1,1]
diff_order_idx[,6:15]  <- diffs_c_idx[,6:15]
diff_order_idx[c(1,2),1] <- diff_order_idx[c(2,1),1] # AV needs more comparisons than ML to line up with adopted ordering

S           <- extract(fit, "a_cv")$a_cv
colnames(S) <- c('ML','AN','AV','MP','RR','RV')

# Create a df with electrode rows and columns for condition differences
col_names  <- vector(length=15)
diff_idxs  <- diff_order_idx
diff_names <- diff_order
diffs      <- matrix(0, nrow=8000, ncol=15) # Hold the result

for(i in 1:15){
    pair <- diff_idxs[,i]
    diffs[,i] <- (S[,pair[1]] - S[,pair[2]]) * -1 # Multiply by -1 for mean resultant length difference.
    col_names[i] <- paste(diff_names[,i][1], "-", diff_names[,i][2], sep=" ")
}

colnames(diffs) <- col_names

diffs <- melt(diffs,  varnames = c("iter", "group"), value.name="diffs")

diff_fct_order <- c("AN - AV", "AN - ML", "AN - MP", "AN - RR", "AN-RV",
  "AV - ML", "AV - MP", "AV - RR", "AV - RV",
  "ML - MP", "ML - RR", "ML - RV",
  "MP - RR", "MP - RV",
  "RR - RV")

diffs2 <- diffs
# reverse group labellings
diffs2$group      <- sapply(as.character(diffs2$group), FUN=string_swap)
diffs2$ref_group  <- sapply(as.character(diffs2$group), FUN=function(x) unlist(strsplit(x, " "))[1])
diffs2$diff_group <- sapply(as.character(diffs2$group), FUN=function(x) unlist(strsplit(x, " "))[3])

diffs$ref_group  <- sapply(as.character(diffs$group), FUN=function(x) unlist(strsplit(x, " "))[1])
diffs$diff_group <- sapply(as.character(diffs$group), FUN=function(x) unlist(strsplit(x, " "))[3])

diffs <- bind_rows(diffs, diffs2)

diffs <- diffs %>% mutate(ref_group = factor(ref_group, c("AN", "AV", "ML", "MP", "RR", "RV")))
diffs <- diffs %>% mutate(diff_group = factor(diff_group, c("AN", "AV", "ML", "MP", "RR", "RV")))

p <- ggplot(data=diffs, aes(x=ref_group, y=diffs, group=group, color=diff_group, fill=diff_group)) +
	geom_crossbar(stat = "summary",
                fun.min = function(x) hdi(x, credMass = 0.9)[1],
                fun.max = function(x) hdi(x, credMass = 0.9)[2],
								fun = median,
								position=position_dodge2(preserve = "single",padding=0.5),alpha=0.25) +
				geom_hline(aes(yintercept=0), alpha=0.50) +
				scale_color_brewer(palette="Dark2") +
				scale_fill_brewer(palette="Dark2") + ylab("\u0394R") + theme(axis.text.x = element_blank())

ggsave(plot=p, filename = "../Figure_5/R_diffs.tiff", dpi=600, width = 2.6, height = 2.6/2, units = "in", compression="lzw")
