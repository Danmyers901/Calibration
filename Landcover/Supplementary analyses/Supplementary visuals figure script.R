# Supplementary visuals figure script
# Dan Myers, 10/25/2022

# Load packages
library(raster)
library(tmap)
library(ggplot2)
library(rasterVis)
library(sf)
library(RStoolbox)
library(dplyr)
library(terra)

# Set working directory
setwd("C:/GIS/Projects/AGU_study/Myers et al. Mendeley Data/Supplementary analyses")

# Load data
dw_grow <- raster("dw_growingSeason.tif")
dw_non <- raster("dw_nongrowingSeason.tif")
naip15 <- rast("naip_2015_07_22.tif") # uses terra
naip17 <- rast("naip_2017_06_28.tif") # uses terra


# Load sentinel bands and rescale 0-255 (https://stackoverflow.com/questions/31953180/rasterlayer-16-bits-into-a-rasterlayer-8-bits)
# Adjust image brightness and process images to RGB
br <- 75
sent_grow_2blue <- raster("sent_grow_2blue.tif") %>%
  calc(fun=function(x){((x - min(x)) * 255)/(max(x)- min(x)) + br})
sent_grow_2blue[sent_grow_2blue>255] <- 255 # remove unrealistic values after brightening
sent_grow_3green <- raster("sent_grow_3green.tif")  %>%
  calc(fun=function(x){((x - min(x)) * 255)/(max(x)- min(x)) + br})
sent_grow_3green[sent_grow_3green>255] <- 255 # remove unrealistic values after brightening
sent_grow_4red <- raster("sent_grow_4red.tif") %>%
  calc(fun=function(x){((x - min(x)) * 255)/(max(x)- min(x)) + br})
sent_grow_4red[sent_grow_4red>255] <- 255 # remove unrealistic values after brightening
sent_non_2blue <- raster("sent_non_2blue.tif") %>%
  calc(fun=function(x){((x - min(x)) * 255)/(max(x)- min(x)) + br})
sent_non_2blue[sent_non_2blue>255] <- 255 # remove unrealistic values after brightening
sent_non_3green <- raster("sent_non_3green.tif") %>%
  calc(fun=function(x){((x - min(x)) * 255)/(max(x)- min(x)) + br})
sent_non_3green[sent_non_3green>255] <- 255 # remove unrealistic values after brightening
sent_non_4red <- raster("sent_non_4red.tif") %>%
  calc(fun=function(x){((x - min(x)) * 255)/(max(x)- min(x)) + br})
sent_non_4red[sent_non_4red>255] <- 255 # remove unrealistic values after brightening

# Create Dynamic World palette and class labels (0=water, etc.)
dw_pal1 <- c('#397D49', '#88B053', '#7A87C6', '#E49635', '#DFC35A',
             '#C4281B')
dw_labs1 <- c('trees', 'grass', 'flooded_vegetation', 'crops', 'shrub_and_scrub',
              'built')


# Arrange sentinel images RGB
sent_grow_RGB <- stack(sent_grow_4red, sent_grow_3green, sent_grow_2blue) %>% rast() # convert to SpatRaster
sent_non_RGB <- stack(sent_non_4red, sent_non_3green, sent_non_2blue) %>% rast()

# Set up plot
windows(8,10)
par(mfrow=c(3,2))
mars <- c(0,2,0,3) # margins (bottom, left, top, right)

# Set limits
xl <- c(297500, 298150)
yl <- c(4356350,4356900)
sent_grow_RGB_c <- crop(sent_grow_RGB, extent(xl[1],xl[2],yl[1],yl[2]))
sent_non_RGB_c <- crop(sent_non_RGB, extent(xl[1],xl[2],yl[1],yl[2]))
naip15_nad83 <- terra::project(naip15,crs(naip17))
naip15_c <- crop(naip15_nad83, extent(xl[1],xl[2],yl[1],yl[2]))
naip17_c <- crop(naip17, extent(xl[1],xl[2],yl[1],yl[2]))

# Plot Dynamic World images
par(mar=c(0,2,0,0),bty="n")
plot(dw_grow, col=dw_pal1, legend=FALSE, main="\n\nDyn. World (growing)",bty="n",yaxt="n",xaxt="n",
     xlim=xl, ylim=yl)
title("\na)",adj=0, cex.main=2)
plot(dw_non, col=dw_pal1, legend=FALSE, main="\n\nDyn. World (non-growing)",yaxt="n",xaxt="n",bty="n",
     xlim=xl, ylim=yl)
title("\nb)",adj=0, cex.main=2)

# Plot sentinel RGB images
plotRGB(sent_grow_RGB_c,main="\n\nSentinel-2 (growing)",axes=FALSE,mar=mars)
title("\nc)",adj=0, cex.main=2)
plotRGB(sent_non_RGB_c,main="\n\nSentinel-2 (non-growing)",axes=FALSE,mar=mars)
title("\nd)",adj=0, cex.main=2)

# Plot NAIP images
plotRGB(naip15_c, main="\n\nNAIP before (July 2015)",axes=FALSE,mar=mars)
title("\ne)",adj=0, cex.main=2)
plotRGB(naip17_c, main="\n\nNAIP after (June 2017)",axes=FALSE,mar=mars)
title("\nf)",adj=0, cex.main=2)
