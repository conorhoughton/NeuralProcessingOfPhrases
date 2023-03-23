library(tidyverse)
library(igraph)
source("../helper_functions.r")

# ----------------------------- Functions -------------------------------------#

get_graph <- function(active_nodes, delta=0.5){
    this_layout   <- filter(electrode_info, electrode %in% active_nodes)
    this_layout$z <- 1
    graph         <- position_to_graph(data=this_layout, name="electrode", delta = delta)
    return(graph)
}

# sum the statisitc within cluster
sum_cluster_nodes <- function(nodes, active_nodes){
    sum(active_nodes[which(nodes %in% names(active_nodes))])
}


shuffle_phases <- function(df, grp1, grp2){
  df$phase <- sample(df$phase, replace=F)

  df <- df %>%
        group_by(participant, electrode, condition) %>%
        summarise(mean_phase=cabs(mean(phase))) %>% # Across trials
        ungroup() %>%
        pivot_wider(names_from = condition, values_from = mean_phase)

  return(abs(mean(df[[grp1]] - df[[grp2]])))
}


cluster_perm <- function(df_lst, rank_thresh, grp1, grp2){

    # shuffle the data columns
    test_stat <- sapply(df_lst,FUN=function(x) shuffle_phases(x, grp1, grp2))

    # Get clusters
    active_nodes <- test_stat[which(test_stat > rank_thresh)]
    names(active_nodes) <- str_extract(names(active_nodes), "[A-Za-z0-9]+") # remnaming necessary

    if(length(active_nodes) >0){
        g          <- get_graph(names(active_nodes))
        clst       <- clusters(g) # clusters
        n_clusters <- clst$csize  # number of clusters
        memb       <- clst$membership # what node belongs to what cluster
        max(sapply(c(1:length(n_clusters)), function(x) sum_cluster_nodes(names(which(memb==x)),active_nodes))) # size of largest cluster
    }
    else{
        return(0)
    }
}

# taken from : https://github.com/jaromilfrossard/permuco4brain/blob/master/R/position_to_graph.
# and edited to remove error output message
position_to_graph <- function(data, delta, name = "name", x = "x", y = "y", z = "z"){
  mc <- match.call()
  f <- formals()
  f <- f[!(names(f)%in%names(mc))]
  ## mc with default
  mc <- as.call(c(as.list(mc),f))

  layout <- list()
  data <- as.data.frame(data)

  for(i in c("name","x","y","z")){
    layout[[i]] <- data[[mc[[i]]]]
  }
  layout <- as.data.frame(layout)

  distance_matrix <- dist(layout[, -1])

  adjacency_matrix <- as.matrix(distance_matrix) < delta
  diag(adjacency_matrix) <- FALSE

  dimnames(adjacency_matrix) <- list(layout$name, layout$name)

  graph <- graph_from_adjacency_matrix(adjacency_matrix, mode = "undirected")

  cl <- clusters(graph,mode = "weak")

  graph <- delete_vertices(graph, V(graph)[!vertex_attr(graph, "name")%in%(layout[[1]])])

  graph <-set_vertex_attr(graph,"x", value = layout[match(vertex_attr(graph,"name"),layout[[1]]),][[2]])
  graph <-set_vertex_attr(graph,"y", value = layout[match(vertex_attr(graph,"name"),layout[[1]]),][[3]])
  graph <-set_vertex_attr(graph,"z", value = layout[match(vertex_attr(graph,"name"),layout[[1]]),][[4]])
  return(graph)
}

write_significant_electrodes <- function(active_nodes, cluster_thresh){
    result_df <- data.frame("electrode"   = electrode_info$electrode,
                            "significant" = vector(length=64)) # false

    if(length(active_nodes) == 0){
      print("No threshold electrodes")
      return(result_df)
    }

    g <- get_graph(names(active_nodes))
    clst <- clusters(g) # clusters
    n_clusters <- clst$csize  # number of clusters
    memb       <- clst$membership # what node belongs to what cluster
    clst_vals  <- sapply(c(1:length(n_clusters)), function(x) sum_cluster_nodes(names(which(memb==x)),active_nodes))
    sig_check  <- clst_vals > cluster_thresh
    true_idxs  <- which(sig_check == TRUE)

    if(length(true_idxs) ==0){
        print("No significant clusters")
        return(result_df)
    }
    else{
        for(idx in true_idxs){
            sig_names <- names(memb)[which(memb == idx)]
            result_df$significant[which(result_df$electrode %in% sig_names)] <- TRUE
        }
        return(result_df)
    }
}

################################################################################
#--------------------- Build the electrode layout -----------------------------#
################################################################################

layout <- read_delim("../../data/EEG1005.lay",
                     col_names = c("num","x", "y", "a", "b", "electrode"),
                     col_select = c(2,3,6))

# get channels we have
channels <- read_csv("../../data//sl_data/channel_lst.csv", col_names = c("num", "electrode"))

# Get the channels that we have
electrode_info <- merge(layout, channels)
electrode_info <- electrode_info[order(electrode_info$num),]

################################################################################
#----------------------------- Load the data ----------------------------------#
################################################################################

# Load and filter data
data <- load_data()

data$electrode <- electrode_info$electrode[data$electrode]
data <- data %>% mutate(condition = paste(condition, freq, sep=" ")) %>% select(-c(freq))

################################################################################
#-------------------------------- Compute -------------------------------------#
################################################################################

grp1_lst <- c("EXP 1.33 Hz", "EXP 2.66 Hz", "EXP 4 Hz", "EXP 5.33 Hz")
grp2_lst <- c("BL 1.33 Hz" , "BL 2.66 Hz" , "BL 4 Hz" , "BL 5.33 Hz")

result_dfs <- list()

for(i in 1:length(grp1_lst)){
  print(i)
  grp1  <- grp1_lst[i]
  grp2  <- grp2_lst[i]
  r_val <- 0.018

  # reshape data to be useful
  df <- data %>% filter(condition %in% c(grp1, grp2))
  df_lst  <- split(df, df$electrode)

  # main computation
  cluster_sizes  <- replicate(1000, cluster_perm(df_lst, r_val, grp1, grp2)) # generate the null
  cluster_thresh <- quantile(cluster_sizes, 0.95)

  # Write the significant electrodes out
  df <- data %>%
                  group_by(participant, electrode, condition) %>%
                  summarise(mean_phase=cabs(mean(phase))) %>% # Across trials
                  ungroup() %>%
                  filter(condition %in% c(grp1, grp2)) %>%
                  pivot_wider(names_from = condition, values_from = mean_phase)

  df$diff      <- df[[grp1]] - df[[grp2]]
  df_lst       <- split(df, df$electrode)
  test_stat    <- abs(sapply(df_lst,FUN=function(x) mean(x$diff) ))

  # Get clusters
  active_nodes <- test_stat[which(test_stat > r_val)] # Filter which electrodes are significant for non-shuffled data
  names(active_nodes) <- str_extract(names(active_nodes), "[A-Za-z0-9]+") # Name them

  result_df <- write_significant_electrodes(active_nodes, cluster_thresh)
  result_df$diff  <- paste(grp1, " - ", grp2, sep="")
  result_dfs[[i]] <- result_df
}

result_df <- bind_rows(result_dfs)
result_df$diff <- fct_relabel(bind_rows(result_dfs)$diff,.fun = function(x) c("1.33 Hz", "2.66 Hz", "4 Hz", "5.33 Hz"))

saveRDS(result_df, "cluster_perm_results.rds")
