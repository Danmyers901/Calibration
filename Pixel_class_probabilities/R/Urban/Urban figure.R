# Pixel probabilities figure 5 - urban
# Dan Myers, 4/14/2023

# First, align the DW pixel probabilities, DW composite, and NLCD rasters in QGIS.

# Set working directory
setwd("Urban/")

# Load packages
library(raster)
library(terra)
library(unikn) # for text mark
library(FedData) # NLCD palette
library(rasterVis) # for levelplot
library(sf)
library(tmap)
library(tmaptools)


### a) NLCD ###########################################################
# Load data
nlcd <- raster("align_NLCD_allrocr_mask.tif")
shed <- st_read("shed_rocr.shp")

nlcd_open <- reclassify(nlcd, matrix(c(0,0,0,
                                       0,20,0,
                                       20,21,1,
                                       21,100,0),ncol=3, byrow=T))

nlcd_low <- reclassify(nlcd, matrix(c(0,0,0,
                                      0,21,0,
                                      21,22,2,
                                      22,100,0),ncol=3, byrow=T))

nlcd_med <- reclassify(nlcd, matrix(c(0,0,0,
                                      0,22,0,
                                      22,23,3,
                                      23,100,0),ncol=3, byrow=T))

nlcd_high <- reclassify(nlcd, matrix(c(0,0,0,
                                       0,23,0,
                                       23,24,4,
                                       24,100,0),ncol=3, byrow=T))

nlcd_urb <- nlcd_open + nlcd_low + nlcd_med + nlcd_high

# Plot it
plot(nlcd_urb, col=c("#FFFFFF","#E8D1D1","#E29E8C","#ff0000","#B50000"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend=c("Open","Low","Medium","High"), fill=c("#E8D1D1","#E29E8C","#ff0000","#B50000"),bg="white",cex=0.8)
title("(i)",adj=0.02, line=-1.2, cex.main=1.5)
title("NLCD19 urban classes",adj=0.02, line=-13.9, cex.main=1)
box()


### b) DW original ###########################################################
# Load data
dw_comp <- raster("align_DWcomp_allROCR_mask.tif")

# Extract urban from DW composite
dw_comp_urb <- reclassify(dw_comp, matrix(c(0,0,NA,
                                            0,5,NA,
                                            5,6,1,
                                            6,10,NA),ncol=3, byrow=T))

# Plot it
plot(dw_comp_urb, col='#C4281B',legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend="Built", fill=c('#C4281B'),bg="white")
title("(j)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 built class",adj=0.02, line=-13.9, cex.main=1)
box()


### c) DW pixel probs##########################################################
# Load data
dw <- raster("align_DWprobs_allROCR_mask.tif")

# Mask tree land in DW probs
dw_urb <- dw * dw_comp_urb

# Set colors and plot it
plot(dw_urb,legend=T,axes=FALSE)
plot(shed$geometry,add=T)
grid()
title("(k)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 built probability",adj=0.02, line=-13.9, cex.main=1)
box()


### d) DW sub-classified#######################################################
##### Set Bins #####
bin_open_low <-53 # highest value in lower bin, 53 is good
bin_low_med <-66 # 66 is good
bin_med_high <-70 # 70 is good

# Extract forest types
dw_open <- reclassify(dw_urb, matrix(c(0,0,0,
                                       0,0,0,
                                       0,bin_open_low,1,
                                       bin_open_low,100,0),ncol=3, byrow=T))

dw_low <- reclassify(dw_urb, matrix(c(0,0,0,
                                      0,bin_open_low,0,
                                      bin_open_low,bin_low_med,2,
                                      bin_low_med,100,0),ncol=3, byrow=T))

dw_med <- reclassify(dw_urb, matrix(c(0,0,0,
                                      0,bin_low_med,0,
                                      bin_low_med,bin_med_high,3,
                                      bin_med_high,100,0),ncol=3, byrow=T))

dw_high <- reclassify(dw_urb, matrix(c(0,0,0,
                                       0,bin_med_high,0,
                                       bin_med_high,100,4,
                                       100,101,0),ncol=3, byrow=T))
dw_pp_urb <- dw_open + dw_low + dw_med + dw_high

# Plot it
plot(dw_pp_urb, col=c("#E8D1D1","#E29E8C","#ff0000","#B50000"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend=c("Open","Low","Medium","High"), fill=c("#E8D1D1","#E29E8C","#ff0000","#B50000"),bg="white",cex=0.8)
title("(l)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 sub-classified",adj=0.02, line=-13.9, cex.main=1)
box()


### e) Watershed areas ########################################################
# Assign DW bins and reclassify
dw_all <- reclassify(dw_comp, matrix(c(0,0,NA,
                                       0,101,1),ncol=3,byrow=T))

dw_all_urb <- dw_comp_urb

dw_open <- reclassify(dw_urb, matrix(c(0,0,NA,
                                       0,0,NA,
                                       0,bin_open_low,1,
                                       bin_open_low,100,NA),ncol=3, byrow=T))

dw_low <- reclassify(dw_urb, matrix(c(0,0,NA,
                                      0,bin_open_low,NA,
                                      bin_open_low,bin_low_med,1,
                                      bin_low_med,100,NA),ncol=3, byrow=T))

dw_med <- reclassify(dw_urb, matrix(c(0,0,NA,
                                      0,bin_low_med,NA,
                                      bin_low_med,bin_med_high,1,
                                      bin_med_high,100,NA),ncol=3, byrow=T))

dw_high <- reclassify(dw_urb, matrix(c(0,0,NA,
                                       0,bin_med_high,NA,
                                       bin_med_high,100,1,
                                       100,101,NA),ncol=3, byrow=T))

# Extract NLCD classifications
nlcd_all <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,255,1),ncol=3,byrow=T))

nlcd_all_urb <- reclassify(nlcd, matrix(c(0,0,NA,
                                          0,20,NA,
                                          20,24,1,
                                          25,255,NA),ncol=3,byrow=T))

nlcd_open <- reclassify(nlcd, matrix(c(0,0,NA,
                                       0,20,NA,
                                       20,21,1,
                                       21,100,NA),ncol=3, byrow=T))

nlcd_low <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,21,NA,
                                      21,22,1,
                                      22,100,NA),ncol=3, byrow=T))

nlcd_med <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,22,NA,
                                      22,23,1,
                                      23,100,NA),ncol=3, byrow=T))

nlcd_high <- reclassify(nlcd, matrix(c(0,0,NA,
                                       0,23,NA,
                                       23,24,1,
                                       24,100,NA),ncol=3, byrow=T))

# Calculate area proportions
nlcd_high_area <- round((cellStats(nlcd_high,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_high_area <- round((cellStats(dw_high,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_med_area <- round((cellStats(nlcd_med,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_med_area <- round((cellStats(dw_med,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_low_area <- round((cellStats(nlcd_low,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_low_area <- round((cellStats(dw_low,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_open_area <- round((cellStats(nlcd_open,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_open_area <- round((cellStats(dw_open,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_all_area <- round((cellStats(nlcd_all_urb,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_all_area <- round((cellStats(dw_all_urb,'sum') / cellStats(dw_all,'sum') * 100),1)

areas_df <- data.frame(NLCD = c(nlcd_high_area, nlcd_med_area, nlcd_low_area, nlcd_open_area, nlcd_all_area),
                       DW = c(dw_high_area, dw_med_area, dw_low_area, dw_open_area, dw_all_area))
rownames(areas_df) <- c("High","Med","Low","Open","All urban")

# Print areas
print(areas_df)


### Create accuracy matrix ####################################################

#### Evaluations: Calculate performance of pixel probs against NLCD urban
# NLCD#_DW# is the name format

open_open <- cellStats(nlcd_open*dw_open,'sum')
open_low <- cellStats(nlcd_open*dw_low,'sum')
open_med <- cellStats(nlcd_open*dw_med,'sum')
open_high <- cellStats(nlcd_open*dw_high,'sum')
open_other <- cellStats(nlcd_open, 'sum') - open_open - open_low - open_med - open_high

low_open <- cellStats(nlcd_low*dw_open,'sum')
low_low <- cellStats(nlcd_low*dw_low,'sum')
low_med <- cellStats(nlcd_low*dw_med,'sum')
low_high <- cellStats(nlcd_low*dw_high,'sum')
low_other <- cellStats(nlcd_low, 'sum') - low_open - low_low - low_med - low_high

med_open <- cellStats(nlcd_med*dw_open,'sum')
med_low <- cellStats(nlcd_med*dw_low,'sum')
med_med <- cellStats(nlcd_med*dw_med,'sum')
med_high <- cellStats(nlcd_med*dw_high,'sum')
med_other <- cellStats(nlcd_med, 'sum') - med_open - med_low - med_med - med_high

high_open <- cellStats(nlcd_high*dw_open,'sum')
high_low <- cellStats(nlcd_high*dw_low,'sum')
high_med <- cellStats(nlcd_high*dw_med,'sum')
high_high <- cellStats(nlcd_high*dw_high,'sum')
high_other <- cellStats(nlcd_high, 'sum') - high_open - high_low - high_med - high_high

other_open <- cellStats(dw_open,'sum') - open_open - low_open - med_open - high_open
other_low <- cellStats(dw_low,'sum') - open_low - low_low - med_low - high_low
other_med <- cellStats(dw_med,'sum') - open_med - low_med - med_med - high_med
other_high <- cellStats(dw_high,'sum') - open_high - low_high - med_high - high_high

# Create a table
col1 <- c(open_open, open_low, open_med, open_high, open_other)
col2 <- c(low_open, low_low, low_med, low_high, low_other)
col3 <- c(med_open, med_low, med_med, med_high, med_other)
col4 <- c(high_open, high_low, high_med, high_high, high_other)
col5 <- c(other_open, other_low, other_med, other_high, NA) # no other-other

df <- data.frame(NLCD_open=col1, NLCD_low=col2, NLCD_med=col3, NLCD_high=col4, NLCD_other=col5)
rownames(df) <- c("DW_open", "DW_low", "DW_med", "DW_high","DW_other")
df

# Create accuracy matrix and calculate overall, producer's, and user's accuracies
acc_mat <- df[1:4,1:4]
correct_class <- acc_mat[1,1] + acc_mat[2,2] + acc_mat[3,3] + acc_mat[4,4]
overall_acc <- correct_class / sum(acc_mat) * 100
producers_acc <- round(data.frame(open = (acc_mat[1,1] / sum(acc_mat[,1]) * 100), 
                                  low = (acc_mat[2,2] / sum(acc_mat[,2]) * 100),
                                  med = (acc_mat[3,3] / sum(acc_mat[,3]) * 100),
                                  high = (acc_mat[4,4] / sum(acc_mat[,4]) * 100)),2)

users_acc <- round(data.frame(open = (acc_mat[1,1] / sum(acc_mat[1,]) * 100), 
                              low = (acc_mat[2,2] / sum(acc_mat[2,]) * 100),
                              med = (acc_mat[3,3] / sum(acc_mat[3,]) * 100),
                              high = (acc_mat[4,4] / sum(acc_mat[4,]) * 100)),2)

# Make the matrix for display
acc_mat_dis <- acc_mat
acc_mat_dis[5,] <- colSums(acc_mat)
acc_mat_dis[6,] <- producers_acc
acc_mat_dis[,5] <- c(rowSums(acc_mat[1:4,]),sum(acc_mat),NA)
acc_mat_dis[,6] <- round(c(t(users_acc),NA,overall_acc),2)
colnames(acc_mat_dis) <- c("NLCD_open", "NLCD_low", "NLCD_med", "NLCD_high","Total","User's Accuracy")
rownames(acc_mat_dis) <- c("DW_open","DW_low","DW_med","DW_high","Total", "Producer's Accuracy")

print(acc_mat_dis)
setwd("../")
