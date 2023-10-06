# Pixel probs study Figure 2 diagram
# Dan Myers, 4/13/2023

# Set working directory
setwd("R:/NPS_NCRN_VitalSigns/Analyses/Projects/AGU23/Scripts/R/Annual chart/")

# Load packages
library(raster)
library(terra)
library(unikn) # for text mark

### a) NAIP image #############################################################
# Load image
naip <- rast("m_3907746_nw_18_060_20210616.tif")


# Start plot
windows(6.5,4.33)
# par(mfrow=c(3,2))

nf <- layout(matrix(c(1,1,1,2,2,2, # top
                      3,3,4,4,5,5), # bottom
                    nrow=2, ncol=6,byrow=TRUE))

mars <- c(0,2,0,3) # margins (bottom, left, top, right)

# Crop NAIP image
xl <- c(297500, 298150) #NAD83 UTM 18N
yl <- c(4356350,4356900)
naip_c <- crop(naip, extent(xl[1],xl[2],yl[1],yl[2]))

# Plot NAIP image
plotRGB(naip_c, main="",axes=FALSE,mar=mars)

# Add point locations
mark(x=297708,y=4356631,labels="I",col_bg="white")
mark(297750,4356554,labels="II",col_bg="white")
mark(297964,4356837,labels="III",col_bg="white")

# Add reference
mark(xl[1],yl[2]-28,labels="    ",col_bg="white")
title("a)",adj=0.02, line=-1.2, cex.main=1.5)


### b) DW22 hillshade##########################################################
# Load image
dw <- rast("Chart_DW22_hillshade_grey_26918.tif")

# Transform projection
# dw_p <- projectRaster(dw,crs="+init=epsg:26918")

# Crop image
dw_c <- crop(dw, extent(xl[1],xl[2],yl[1],yl[2]))

# Plot DW image
plotRGB(dw_c, main="",axes=FALSE,mar=mars)

# Add point locations
mark(x=297708,y=4356631,labels="I",col_bg="white")
mark(297750,4356554,labels="II",col_bg="white")
mark(297964,4356837,labels="III",col_bg="white")

# Add reference
mark(xl[1]-5,yl[2]-28,labels="    ",col_bg="white")
title("b)",adj=0.02, line=-1.2, cex.main=1.5)

# Add legend
legend("bottomright",legend=c("Built","Trees","Crops"),fill=c('#A9A9A9','#397D49',
                                                              '#E49635'),bg="white")

### c) DW22 forest ############################################################
# Load data
data1 <- read.csv("ee-chart A 2022 data.csv",header=T)

# Assign dates
dates <- read.csv("dates.csv")
date1 <- as.Date(dates$dates,format="%m/%d/%Y")

# Remove NAs
date2 <- date1[!is.na(data1$built)]
data2 <- data1[!is.na(data1$built),]

# Plot it
par(mar=c(3,3,1,3),mgp=c(2,1,0))
plot(date2,data2$built,type="n",ylab="Class probability",xlab="",
     ylim=c(0,0.75))
lines(date2,data2$built,col='darkgrey')
lines(date2,data2$trees,col="#397D49")

# Add reference
title("c) I",adj=0.02, line=-1.2, cex.main=1.5)

# Add labels
mark(as.Date("2022-06-15",format="%Y-%m-%d"),0.6,labels='trees',col="#397D49",col_bg="white")
mark(as.Date("2022-08-01",format="%Y-%m-%d"),0.10,labels='built',col="darkgrey",col_bg="white")



### d) DW22 mixed #############################################################
# Load data
data1 <- read.csv("ee-chart B 2022 data.csv",header=T)

# Assign dates
dates <- read.csv("dates.csv")
date1 <- as.Date(dates$dates,format="%m/%d/%Y")

# Remove NAs
date2 <- date1[!is.na(data1$built)]
data2 <- data1[!is.na(data1$built),]

# Plot it
plot(date2,data2$built,type="n",ylab="Class probability",xlab="",
     ylim=c(0,0.75))
lines(date2,data2$built,col='darkgrey')
lines(date2,data2$trees,col="#397D49")

# Add reference
title("d) II",adj=0.02, line=-1.2, cex.main=1.5)



### e) DW22 mixed #############################################################
# Load data
data1 <- read.csv("ee-chart C 2022 data.csv",header=T)

# Assign dates
dates <- read.csv("dates.csv")
date1 <- as.Date(dates$dates,format="%m/%d/%Y")

# Remove NAs
date2 <- date1[!is.na(data1$built)]
data2 <- data1[!is.na(data1$built),]

# Plot it
plot(date2,data2$built,type="n",ylab="Class probability",xlab="",
     ylim=c(0,0.75))
lines(date2,data2$built,col='darkgrey')
lines(date2,data2$trees,col="#397D49")

# Add reference
title("e) III",adj=0.02, line=-1.2, cex.main=1.5)
