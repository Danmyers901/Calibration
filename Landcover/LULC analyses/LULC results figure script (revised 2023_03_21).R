# LULC results figure script
# Dan Myers, 10/25/22

library(raster)
library(sf)
library(dplyr)

# Set working directory
setwd("C:/GIS/Projects/AGU_study/Revision/Myers et al. Mendeley Data (revised)/LULC analyses")
# setwd("R:/NPS_NCRN_VitalSigns/Data/GIS/Projects/AGU_study/Revision/Myers et al. Mendeley Data (revised)/LULC analyses")


# Start plot
windows(6.5,6.5)
nf2 <- layout(matrix(c(1,2, # top (boxplot)
                       1,2,
                       3,4, # middle (time series bars)
                       5,6), # bottom 
                     nrow=4, ncol=2,byrow=TRUE))

# nf2 <- layout(matrix(c(1,2, # top (boxplot)
#                        3,4, # middle (time series bars)
#                        5,6), # bottom 
#                      nrow=3, ncol=2,byrow=TRUE))

### Top Row (boxplot)
par(mar=c(5,4,1,2)+0.1) # (bottom, left, top, right)

# Read and extract data
lulc_data <- read.csv("Difference in land cover proportion for each watershed (revised 2023_02_09).csv")
lulc_dif <- lulc_data[,-c(1,2,5,10)] * -1

# Create palette
dw_pal2 <- c('#397D49', '#88B053', '#E49635', '#DFC35A',
             '#C4281B', '#A59B8F')

# Make boxplot
boxplot(lulc_dif, ylab = "Seasonal difference (% area)*", xaxt="n",
        sub="*Positive is larger during non-growing season", col=dw_pal2)
grid()
abline(h=0)
title("a)",adj=0.03, line=-1.2, cex.main=1.5)
axis(1, at=c(1:6),
     labels=c("Trees","Grass","Crops","Shrub/\nScrub","Built","Bare"),las=2)

## Built plot
# Load data
par(mar=c(5,4,1,2)+0.1)
lulc_grow <- read.csv("Dynamic_World_areas_in_watersheds_growingSeason_cleaned (revised 2023_02_09).csv", header=T)
lulc_dif <- read.csv("Difference in land cover proportion for each watershed (revised 2023_02_09).csv", header=T)
y <- lulc_dif$built*-1
x <- lulc_grow$built * 100

# Start plot
plot(x, y, xlab="Growing season built LULC (% area)",
     ylab="Built seasonal dif. (% area)*")
grid()
abline(h=0)

# Add model
model <- lm(y ~ x+I(x^2))
myPredict <- predict( model ) 
ix <- sort(x,index.return=T)$ix
lines(x[ix], myPredict[ix], col=2, lwd=2 )  
summary(model)
title("b)",adj=0.03, line=-1.2, cex.main=1.5)


## Plot 95% confidence intervals
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col=2,lty=2)
lines(xpr$x, xpr$pr.upr,col=2,lty=2)


### Middle/bottom Rows: LULC time series 
par(mar=c(3,4,1,2)+0.1)

# Read data
data1 <- read.csv("time_series_2023_03_21.csv")
buck <- data1[data1$site=="11NPSWRD_WQX-NCRN_MONO_BUCK",]
diru <- data1[data1$site=="11NPSWRD_WQX-NCRN_GWMP_DIRU",]
rocr <- data1[data1$site=="Rock_Creek_USGS",]

# Adjust barplot parameters
spacing = rep(c(0.5,0),7)
cols = rep(c("deepskyblue2","firebrick3"),7)
lab = c("2016","2017","2018","2019","2020","2021","2022")
ats = c(1.5,4,6.5,9,11.5,14,16.5)

### Make bar plots
# Plot Rock Creek built
barplot(rocr$built*100, space=spacing,col = NA, border = NA,
        xlab="Year",ylab="Built LULC (%)",ylim=c(50,70),xpd=FALSE); grid() # Add grid
barplot(rocr$built*100, space=spacing,col=cols,add=T,xpd=FALSE)
axis(side=1,at=ats,labels=lab)
title("c)",adj=0.03, line=-1.2, cex.main=1.5)
box()

# Plot Difficult Run built
barplot(diru$built*100, space=spacing,col = NA, border = NA,
        xlab="Year",ylab="Built LULC (%)",ylim=c(30,60),xpd=FALSE); grid() # Add grid
barplot(diru$built*100, space=spacing,col=cols,add=T,xpd=FALSE)
axis(side=1,at=ats,labels=lab)
title("d)",adj=0.03, line=-1.2, cex.main=1.5)
box()

# Plot Rock Creek trees
barplot(rocr$trees*100, space=spacing,col = NA, border = NA,
        xlab="Year",ylab="Trees LULC (%)",ylim=c(20,40),xpd=FALSE); grid() # Add grid
barplot(rocr$trees*100, space=spacing,col=cols,add=T,xpd=FALSE)
axis(side=1,at=ats,labels=lab)
title("e)",adj=0.03, line=-1.2, cex.main=1.5)
box()
legend("bottomright",legend=c("Non-growing season","Growing season"),fill=c("deepskyblue2","firebrick3"),
       bg="white",y.intersp=0.8,cex=1)

# Plot Difficult Run trees
barplot(diru$trees*100, space=spacing,col = NA, border = NA,
        xlab="Year",ylab="Trees LULC (%)",ylim=c(40,62),xpd=FALSE); grid() # Add grid
barplot(diru$trees*100, space=spacing,col=cols,add=T,xpd=FALSE)
axis(side=1,at=ats,labels=lab)
title("f)",adj=0.03, line=-1.2, cex.main=1.5)
box()
