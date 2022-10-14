library(tidyverse)

# load the data
data <- read_csv("data/full_data.csv", col_types =c("icciiiid??d"))

# Covert the ft coeffs to complex numbers - slow but works
data$phase <- sapply(X=data$phase, FUN = function(x) as.complex(gsub(" ", "", substr(x,1,nchar(x)-1))))

# Save the data
write.csv(data, "data/full_data.csv",row.names=FALSE)
