
# Vector length
cabs <- function(x) sqrt(Re(x)**2 + Im(x)**2)

# Points of a circle
circleFun <- function(center = c(0,0),diameter = 2, npoints = 100){
  r = diameter / 2
  tt <- seq(0,2*pi,length.out = npoints)
  xx <- center[1] + r * cos(tt)
  yy <- center[2] + r * sin(tt)
  return(data.frame(x = xx, y = yy))
}

# angle
catan2 <- function(x) atan2(Im(x), Re(x))

# Bundt - Gamma density
dens_func <- function(x,y){
    return(dgamma(sqrt(x^2+y^2),shape = 10,rate = 10) * (1/sqrt(x^2 +y^2)))
}

# Wrapped cauchy pdf
WC_d <- function(theta, mu, gamma){
    (1/(2*pi)) * sinh(gamma) / (cosh(gamma) - cos(theta-mu))
}

inv_logit <- function(x){
  return(1/(1+exp(-x)))
}

load_data <- function(fp="sim_data.rds"){
  data <- readRDS(fp)
  data$condition <- fct_relabel(as.factor(data$condition), function(x) c('group1', 'group2'))
  return(data)
}
