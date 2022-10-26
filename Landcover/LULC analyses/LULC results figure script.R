# LULC results figure script
# Dan Myers, 10/25/22

library(raster)
library(sf)
library(dplyr)

# Set working directory
setwd("C:/GIS/Projects/AGU_study/Myers et al. Mendeley Data/LULC analyses")

# Start plot
windows(8,10)
nf2 <- layout(matrix(c(1,2, # top (boxplot)
                      3,3, # middle (time series bars)
                      4,5), # bottom (maps)
                    nrow=3, ncol=2,byrow=TRUE))

### Top Row (boxplot)
par(mar=c(5,4,4,0)+0.1) # (bottom, left, top, right)

# Read and extract data
lulc_data <- read.csv("Difference in land cover proportion for each watershed.csv")
lulc_dif <- lulc_data[,-c(1,2,5,10)] * -1

# Create palette
dw_pal2 <- c('#397D49', '#88B053', '#E49635', '#DFC35A',
             '#C4281B', '#A59B8F')

# Make boxplot
boxplot(lulc_dif, ylab = "Seasonal difference (% area)*", xaxt="n",
        sub="*Positive is larger during non-growing season", col=dw_pal2)
grid()
abline(h=0)
title("a)",adj=0, cex.main=2)
axis(1, at=c(1:6),
  labels=c("Trees","Grass","Crops","Shrub/\nScrub","Built","Bare"),las=2)

## Built plot
# Load data
par(mar=c(5,6,4,2)+0.1)
lulc_grow <- read.csv("Dynamic_World_areas_in_watersheds_growingSeason_cleaned.csv", header=T)
lulc_dif <- read.csv("Difference in land cover proportion for each watershed.csv", header=T)
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
title("b)",adj=0, cex.main=2)


## Plot 95% confidence intervals
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col=2,lty=2)
lines(xpr$x, xpr$pr.upr,col=2,lty=2)

### Middle Row: LULC time series (Bush Creek)
par(mar=c(5,4,4,2)+0.1)

# Read data
data1 <- read.csv("time_series.csv")
buck <- data1[data1$site=="11NPSWRD_WQX-NCRN_MONO_BUCK",]
buck_grow <- data1[data1$site=="11NPSWRD_WQX-NCRN_MONO_BUCK" & data1$Season=="grow",]
buck_non <- data1[data1$site=="11NPSWRD_WQX-NCRN_MONO_BUCK" & data1$Season=="non",]

# Adjust barplot parameters
spacing = rep(c(0.5,0),6)
cols = rep(c("deepskyblue2","firebrick3"),6)
lab = c("2016","2017","2018","2019","2020","2021")
ats = c(1.5,4,6.5,9,11.5,14)

# Make bar plots
# Plot MONO_BUCK built
barplot(buck$built*100, space=spacing,col = NA, border = NA,
        xlab="Year",ylab="Built LULC (%)",); grid() # Add grid
barplot(buck$built*100, space=spacing,col=cols,add=T)
axis(side=1,at=ats,labels=lab)
legend("bottomright",legend=c("Non-growing","Growing"),fill=c("deepskyblue2","firebrick3"),
       bg="white",title="Season")
title("c)",adj=0, cex.main=2)


### Bottom row (maps)

# Load data
grow <- raster("mono_buck_dw_growing_season.tif")
non <- raster("mono_buck_dw_nongrowing_season.tif")
shed = st_read("MONO_BUCK_shed.shp")

# Mask the rasters
grow_e <- raster::mask(grow, shed)
non_e <- raster::mask(non, shed)

# Create Dynamic World palette and class labels (0=water, etc.)
dw_pal1 <- c('#419BDF', '#397D49', '#88B053', '#7A87C6', '#E49635', '#DFC35A',
             '#C4281B', '#A59B8F')
dw_labs1 <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub","Built","Bare")

dw_pal2 <- c('#419BDF', '#397D49', '#88B053', '#7A87C6', '#E49635', '#DFC35A',
             '#C4281B', '#A59B8F', '#B39FE1')
dw_labs2 <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub","Built","Bare","Snow/Ice")

# Growing season plot
plot(grow_e, col=dw_pal1,legend=FALSE, xlab="Growing season LULC\n\n",
     xaxt='n', yaxt='n') # Plot with DW colors
grid()
title("d)",adj=0, cex.main=2)
par(xpd=NA) # Allow plotting outside figure area
legend("right",legend=dw_labs2, fill=dw_pal2,inset=c(-0.48,0), title="LULC class")

# Non-growing season plot
par(mar=c(5,4,4,0)+0.1)
plot(non_e, col=dw_pal2,legend=FALSE, xlab="Non-growing season LULC\n\n",
     xaxt='n', yaxt='n') # Plot with DW colors
grid()
title("e)",adj=0, cex.main=2)
