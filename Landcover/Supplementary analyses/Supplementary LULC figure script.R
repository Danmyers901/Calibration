# Supplementary figure script
# Dan Myers, 10/25/22

library(dplyr)

# Set working directory
setwd("C:/GIS/Projects/AGU_study/Myers et al. Mendeley Data/Supplementary analyses")


### Step 1: Load data

# Load LULC data
lulc_grow <- read.csv("Dynamic_World_LULC_percent_area_growing_season.csv")
lulc_non <- read.csv("Dynamic_World_LULC_percent_area_Nongrowing_season.csv")
nlcd <- read.csv("watersheds_nlcd16_stats.csv")

# Make models (Open, Low, Medium, and High intensity; OLMH)
lm_grow <- lm(lulc_grow$built ~ nlcd$urb_tot_OLMH)
lm_non <- lm(lulc_non$built ~ nlcd$urb_tot_OLMH)

# Plot it
windows(5,5)
# par(mfrow=c(1,2))
plot(nlcd$urb_tot_OLMH, lulc_non$built, col="blue",xlab="NLCD 2016 developed (% area)*",
     ylab="Dynamic World built (% area)", xlim=c(0,100),ylim=c(0,100),
     sub="*Open, low, medium, and high intensity")
grid()
points(nlcd$urb_tot_OLMH, lulc_grow$built, col="red")


## Add 95% confidence intervals
# Growing season
x=nlcd$urb_tot_OLMH
model= lm_grow
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col=2,lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col=2,lty=3,lwd=0.5)

# Non-growing season
x=nlcd$urb_tot_OLMH
model= lm_non
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="blue",lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="blue",lty=3,lwd=0.5)

# Add lines
abline(lm_grow, col="red",lwd=2)
abline(lm_non, col="blue",lwd=2)

abline(0,1, lwd=2, col="darkgrey", lty=2)
legend("bottomright",legend=c("Growing season","Non-growing season","1:1 line"), 
       col=c("red","blue","darkgrey"), pch=c("o","o","-"),bg="white")

# Add relative mean absolute deviation (RMAD)
R1g <- mean(abs(nlcd$urb_tot_OLMH - lulc_grow$built),na.rm=T)
R1n <- mean(abs(nlcd$urb_tot_OLMH - lulc_non$built),na.rm=T)
text(20,95,paste("RMAD = ",round(R1g,1),"%",sep=""),col="red")
text(20,85,paste("RMAD = ",round(R1n,1),".0%",sep=""),col="blue")
