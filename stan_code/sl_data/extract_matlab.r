library(R.matlab)
library(stringr)
library(dplyr)
library(readr)

write_df <- function(block_dat, block_id, file){
    file_info <- unlist(str_extract_all(file, pattern = "[0-9]+|(bl|exp)")) # 1: participant, 2: condition
    phases    <- block_dat[[4]]
    dat_dims  <- dim(phases) #  dimensions

    N <- prod(dat_dims) #(trials, electrodes, frequency)

    # Hold the indices
    trials      <- array(0, dim = N)
    electrodes  <- array(0, dim = N)
    frequency   <- array(0, dim = N)
    phase       <- array(0, dim = N)

    T <- dat_dims[1]
    E <- dat_dims[2]
    F <- dat_dims[3]

    # set the indices
    for(i in 1:T){
      for(j in 1:E){
        for(k in 1:F){
          trials[    (i-1)*E*F + (j-1)*F + k] <- i
          electrodes[(i-1)*E*F + (j-1)*F + k] <- j
          frequency[ (i-1)*E*F + (j-1)*F + k] <- k
          phase[     (i-1)*E*F + (j-1)*F + k] <- phases[i,j,k]
        }
      }
    }

     df <- data.frame("participant" = as.integer(file_info[1]),
                      "electrode"   = electrodes,
                      "block"       = block_id,
                      "condition"   = file_info[2],
                      "trial"       = trials,
                      "phase"       = phase,
                      "freq"        = frequency)

    df <- df %>% filter(freq %in% c(6,12,18,24))
}


extract_phases <- function(file, loc){
    full_path <- paste(loc, file, sep="")
    print(full_path)
    mat_dat   <- readMat(full_path) # should be a list with blocks 1, 2, and 3 at indexes 3,4, and 5

    blk1      <- write_df(mat_dat[[3]], 1, file)
    blk2      <- write_df(mat_dat[[4]], 2, file)
    blk3      <- write_df(mat_dat[[5]], 3, file)

    # bind the rows
    bind_rows(blk1, blk2, blk3, .id = "block")
}

file_dir  <- "../../../../../../media/sydney/CORSAIR/post_eeg/" # The directory of files and folders
file_lst  <- dir(file_dir, recursive = T) # List all files in all sub directories
phase_dfs <- lapply(file_lst, FUN = function(x) extract_phases(x, file_dir))
full_df   <- bind_rows(phase_dfs)

# save the real and imaginary parts in separate columns as saving this format has issues
full_df$p_real    <- Re(full_df$phase)
full_df$p_im      <- Im(full_df$phase)

# remove phase
full_df <- full_df %>% select(-c(phase))

# calculate angle
full_df$angle <- atan2(y = full_df$p_im, x=full_df$p_real)

write_csv(full_df, file = "data.csv")
