library(tidyverse)
library(igraph)
source("helper_functions.r")

# ----------------------------- Functions -------------------------------------#

get_graph <- function(active_nodes, delta){
    this_layout   <- filter(electrode_info, electrode %in% active_nodes)
    this_layout$z <- 1
    graph         <- position_to_graph(data=this_layout, name="electrode", delta = delta)
    return(graph)
}

sum_cluster_nodes <- function(nodes, active_nodes){
    sum(active_nodes[which(nodes %in% names(active_nodes))])
}

cluster_perm <- function(df_lst, rank_thresh){
    # split by electrode
    test_stat <- abs(sapply(df_lst,FUN=function(x) mean(x$itpc_diff * sample(c(-1,1), replace=T, size=16))))

    # Get clusters
    active_nodes <- test_stat[which(test_stat > rank_thresh)]
    names(active_nodes) <- str_extract(names(active_nodes), "[A-Za-z0-9]+") # remnaming necessary

    if(length(active_nodes) >0){
        g          <- get_graph(names(active_nodes), 0.75)
        clst       <- clusters(g) # clusters
        n_clusters <- clst$csize  # number of clusters
        memb       <- clst$membership # what node belongs to what cluster
        max(sapply(c(1:length(n_clusters)), function(x) sum_cluster_nodes(names(which(memb==x)),active_nodes)))
    }
    else{
        return(0)
    }
}

# taken from : https://github.com/jaromilfrossard/permuco4brain/blob/master/R/position_to_graph.
# but edited to remove error message
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
                            "significant" = vector(length=32)) # false

    if(length(active_nodes) == 0){
      print("No threshold electrodes")
      return(result_df)
    }

    g <- get_graph(names(active_nodes), 0.75)
    clst <- clusters(g) # clusters
    n_clusters <- clst$csize  # number of clusters
    memb       <- clst$membership # what node belongs to what cluster
    clst_vals  <- sapply(c(1:length(n_clusters)), function(x) sum_cluster_nodes(names(which(memb==x)),active_nodes))
    sig_check  <- clst_vals > cluster_thresh
    true_idxs  <- which(sig_check == TRUE)

    print(clst_vals)
    if(length(true_idxs) ==0){
        print("No significant electrodes")
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

#--------------------- Build the electrode layout -----------------------------#
layout <- read_delim("../data/EEG1005.lay",
                     col_names = c("num","x", "y", "a", "b", "electrode"),
                     col_select = c(2,3,6))

# get channels we have
channels <- read_delim("../data/channel_list.txt", col_names = c("num", "electrode"))

# Get the channels that we have
electrode_info <- merge(layout, channels)
electrode_info <- electrode_info[order(electrode_info$num),]

#----------------------------- Load the data ----------------------------------#
data <- load_data()
data <- data %>% filter(freqC==21)

# mean resultant length
mean_res <- data %>%
                group_by(participant, electrode, condition) %>%
                summarise(mr=cabs(mean(phase))) # Across trials
mean_res$condition <- fct_relabel(mean_res$condition, fct_r) # Give conditions better names
mean_res$electrode <- electrode_info$electrode[mean_res$electrode]

#-------------------------------- Compute -------------------------------------#

grp1_lst <- c("AN", "AN", "AN", "AN", "AN", "AV", "AV", "AV", "AV", "ML", "ML", "ML", "MP", "MP", "RR")
grp2_lst <- c("AV", "ML", "MP", "RR", "RV", "ML", "MP", "RR", "RV", "MP", "RR", "RV", "RR", "RV", "RV")

result_dfs <- list()

for(i in 1:length(grp1_lst)){
  print(i)
  grp1        <- grp1_lst[i]
  grp2        <- grp2_lst[i]
  r_val       <- 0.065

  # reshape data to be useful
  df <- mean_res %>%
      filter(condition %in% c(grp1, grp2)) %>%
      pivot_wider(names_from = condition, values_from = mr)

  df$itpc_diff <- df[[grp1]] - df[[grp2]]

  # main computation
  df_lst         <- split(df, df$electrode)
  cluster_sizes  <- replicate(5000, cluster_perm(df_lst, r_val))
  cluster_thresh <- quantile(cluster_sizes, 0.95)

  # Write the significant electrodes out
  df_lst       <- split(df, df$electrode)
  test_stat <- abs(sapply(df_lst,FUN=function(x) mean(x$itpc_diff)))

  # Get clusters
  active_nodes <- test_stat[which(test_stat > r_val)]
  names(active_nodes) <- str_extract(names(active_nodes), "[A-Za-z0-9]+")

  result_df <- write_significant_electrodes(active_nodes, cluster_thresh)
  result_df$diff <- paste(grp1, " - ", grp2, sep="")
  result_dfs[[i]] <- result_df
}

saveRDS(bind_rows(result_dfs), "cluster_perm_results.rds")
