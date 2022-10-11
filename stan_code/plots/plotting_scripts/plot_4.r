library(tidyverse)
library(viridis)

circleFun <- function(center = c(0,0),diameter = 2, npoints = 100){
  r = diameter / 2
  tt <- seq(0,2*pi,length.out = npoints)
  xx <- center[1] + r * cos(tt)
  yy <- center[2] + r * sin(tt)
  return(data.frame(x = xx, y = yy))
}

dens_func <- function(x,y){
    return(dgamma(sqrt(x^2+y^2),shape = 10,rate = 10) * (1/sqrt(x^2 +y^2)))
}

WC_d <- function(theta, mu, gamma){
    (1/(2*pi)) * sinh(gamma) / (cosh(gamma) - cos(theta-mu))
}

theme_set(theme_classic(base_size = 10,base_family="Times New Roman"))
theme_update(legend.position = "none",
	      axis.title.y = element_text(angle = 0, vjust = 0.5))

circle_dat <- circleFun(diameter = 4)
angle_list <- c(0.5*pi,-0.75*pi)

# Generate a square grid on the Bundt distribution support
N       <- 250
xmin    <- -2
xmax    <- 2
xx      <- seq(xmin, xmax, length.out = N)
xy_grid <- expand.grid(x=xx, y=xx)

xy_grid <- xy_grid[which(xy_grid$x^2 <= 4-xy_grid$y^2),]
xy_grid <- xy_grid[which(xy_grid$y^2 <= 4-xy_grid$x^2),]

# Run prior over the grid of points
xy_grid$dens    <- dens_func(xy_grid$x, xy_grid$y) # set length correspondance with grid

# Plot 4C
b_p <- ggplot() +
            geom_tile(data=xy_grid, aes(x=x,y=y,fill=dens)) +
            scale_fill_viridis() +
						geom_path(aes(x=circle_dat$x, y=circle_dat$y), color="indianred")+
						annotate("text", label="0", y=0, x=1.5+0.2, parse=TRUE,color="white") +
				    annotate("text", label="pi/2", y=1.5+0.2, x=0, parse=TRUE,color="white") +
				    annotate("text", label="pi", y=0, x=-1.5-0.2, parse=TRUE,color="white") +
				    annotate("text", y=-1.5-0.2, x=0,label="-pi/2", parse=TRUE,color="white") +
            geom_point(aes(x=cos(angle_list[1]), y=sin(angle_list[1])), color="white") +
            geom_point(aes(x=cos(angle_list[2]), y=sin(angle_list[2])), color="white") +
            geom_text(aes(x=cos(angle_list[1]), y=sin(angle_list[1]), label="1"),nudge_x = 0.15, nudge_y = 0.15,color="white") +
            geom_text(aes(x=cos(angle_list[2]), y=sin(angle_list[2]), label="2"),nudge_x = 0.15, nudge_y = 0.15, color="white") +
            theme(legend.position="none")

ggsave(plot = b_p, filename = "../Figure_4/prior_ring.tiff",dpi = 600, units = "in", height = 2.6, width=5.2 * 0.5, compression = "lzw")

# Plot 4D
xx <- seq(0,1,length.out = 100)

beta_dens <- ggplot() + geom_area(aes(x = xx, y=dbeta(xx,3,2)), fill="#a6cee3",color="black") + xlab("1-R") +
             		geom_segment(aes(x=0.4, y=0, yend=dbeta(0.4,3,2), xend=0.4)) +
           			geom_point(aes(x=0.4, y=dbeta(0.4,3,2)))+
           			geom_text(aes(x=0.4, y=dbeta(0.4,3,2), label="1"), nudge_y = -0.1, nudge_x=0.05) +
           			geom_segment(aes(x=0.7, y=0, yend=dbeta(0.7,3,2), xend=0.7)) +
           			geom_point(aes(x=0.7, y=dbeta(0.7,3,2))) +
           			geom_text(aes(x=0.7, y=dbeta(0.7,3,2), label="2"), nudge_y = -0.3, nudge_x=0.05) +
								theme(axis.title.y = element_blank(),
											axis.text.y=element_blank(),
											axis.ticks.y=element_blank()) +
								xlab("1-R") + ylab("")

ggsave(plot = beta_dens, filename = "../Figure_4/prior_beta.tiff",dpi = 600, units = "in", height = 2.6*0.5, width=5.2*0.5, compression = "lzw")

# plot 4E
wc_supp <- seq(from = -pi, to = pi, length.out = 1000)

df <- data.frame(y= c(WC_d(wc_supp, mu = angle_list[1], gamma = -log(1-0.4)),
                      WC_d(wc_supp, mu = angle_list[2], gamma = -log(1-0.7))),
                 x= c(wc_supp, wc_supp),
                 group= rep(c("1", "2"), each=1000))

c_p <- ggplot(data = df) +
       geom_area(aes(x = x, y=y,group=group), fill="#b2abd2",color="black") +
       facet_wrap(vars(group), ncol = 2) +
       theme(axis.title.y = element_blank(),
             axis.text.y=element_blank(),
             axis.ticks.y=element_blank()) +
       scale_x_continuous(breaks=c(-pi, 0, pi),
                          labels=c("-\u03c0","0","\u03c0"))+
       xlab("\u03bc")

ggsave(plot = c_p, filename = "../Figure_4/prior_wc.tiff",dpi = 600, units = "in", height = 2.6*0.5, width=5.2*0.5, compression = "lzw")
