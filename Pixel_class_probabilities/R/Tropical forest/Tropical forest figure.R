# Pixel probabilities figure 4 - tropical forest
# Dan Myers, 4/14/23

# First, align the DW pixel probabilities, DW composite, and NLCD rasters in QGIS.

# Set working directory
setwd("R:/NPS_NCRN_VitalSigns/Analyses/Projects/AGU23/Scripts/R/Tropical forest/")

# Load packages
library(raster)
library(terra)
library(unikn) # for text mark
library(FedData) # NLCD palette
library(rasterVis) # for levelplot
library(sf)
library(tmap)
library(tmaptools)

# Start plot
windows(6.5,6.5)
par(mar=c(1,1,1,1))
nf <- layout(matrix(c(1,2, # top
                      3,4, # middle
                      5,5), # bottom
                    nrow=3, ncol=2,byrow=TRUE))


### a) SINAC ###########################################################
# Load data
sinac_unmask <- raster("align2_sinac.tif")

# Load DW 2022 composite raster
dw_comp_unmask <- raster("align2_cr_dwcomp.tif")

# Mask the layers to only zones with DW data (no cloudy mountains; DM 2/15/23)
dw_mask <- reclassify(dw_comp_unmask, matrix(c(0,0,NA,
                                               0,101,1),ncol=3,byrow=T))
sinac_mask <- sinac_unmask * dw_mask
sinac <- sinac_unmask

# Add park boundary
shed <- st_read("guan_np_fixed_geoms.shp")

# Plot it
plot(sinac, col=c("#FFFFFF","#33a02c","#fdbf6f","#b2df8a"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend=c("Mature","Deciduous","Secondary"), fill=c("#33a02c","#fdbf6f","#b2df8a"),bg="white")
title("a)",adj=0.02, line=-1.2, cex.main=1.5)
title("SINAC topical forest classes",adj=0.98, line=-13.9, cex.main=1)



### b) DW original ###########################################################
# Load data
dw_comp <- dw_comp_unmask

# Extract tree from DW composite
dw_comp_for <- reclassify(dw_comp, matrix(c(0,0,0,
                                            0,1,1,
                                            1,10,0),ncol=3, byrow=T))

# Plot it
plot(dw_comp_for, col=c("#FFFFFF","#397D49"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend="Trees", fill=c("#397D49"),bg="white")
title("b)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 trees",adj=0.98, line=-13.9, cex.main=1)
title("No \ndata",adj=0.8, line=-7, cex.main=1)



### c) DW pixel probs##########################################################
# Load DW 2022 tree probability raster
dw <- raster("align2_cr_dwprob.tif")
NAvalue(dw) <- 0 # Set NA value

# Mask tree land in DW probs
dw_tree <- dw * dw_comp_for

# Set colors and plot it
plot(dw_tree,legend=T,axes=FALSE)
plot(shed$geometry,add=T)
grid()
title("c)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 tree probability",adj=0.98, line=-13.9, cex.main=1)
title("No \ndata",adj=0.8, line=-7, cex.main=1)



### d) DW sub-classified#######################################################
##### Set Bins #####
bin_dec_sec <-34 # highest value in lower bin #
bin_sec_mad <-71                              #

dw_dec <- reclassify(dw_tree, matrix(c(0,0,0,
                                        0,bin_dec_sec,2,
                                        bin_dec_sec,100,0),ncol=3, byrow=T))

dw_sec <- reclassify(dw_tree, matrix(c(0,0,0,
                                        0,bin_dec_sec,0,
                                        bin_dec_sec,bin_sec_mad,3,
                                        bin_sec_mad,100,0),ncol=3, byrow=T))

dw_mad <- reclassify(dw_tree, matrix(c(0,0,0,
                                        0,bin_sec_mad,0,
                                        bin_sec_mad,100,1,
                                        100,101,0),ncol=3, byrow=T))

dw_pp_for <- dw_dec + dw_sec + dw_mad


# Plot it
plot(dw_pp_for, col=c("#FFFFFF","#33a02c","#fdbf6f","#b2df8a"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend=c("Mature","Deciduous","Secondary"), fill=c("#33a02c","#fdbf6f","#b2df8a"),bg="white")
title("d)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 sub-classified",adj=0.98, line=-13.9, cex.main=1)
title("No \ndata",adj=0.8, line=-7, cex.main=1)



### e) Watershed areas ########################################################
# Extract DW data
dw_all <- reclassify(dw_comp, matrix(c(0,0,NA,
                                       0,101,1),ncol=3,byrow=T))

dw_dec <- reclassify(dw_tree, matrix(c(0,0,NA,
                                       0,bin_dec_sec,1,
                                       bin_dec_sec,100,NA),ncol=3, byrow=T))

dw_sec <- reclassify(dw_tree, matrix(c(0,0,NA,
                                       0,bin_dec_sec,NA,
                                       bin_dec_sec,bin_sec_mad,1,
                                       bin_sec_mad,100,NA),ncol=3, byrow=T))

dw_mad <- reclassify(dw_tree, matrix(c(0,0,NA,
                                       0,bin_sec_mad,NA,
                                       bin_sec_mad,100,1,
                                       100,101,NA),ncol=3, byrow=T))
dw_all_tree <- dw_comp_for

# Extract SINAC data
sinac_mad <- reclassify(sinac_mask, matrix(c(0,0,NA,
                                      0,1,1,
                                      1,100,NA),ncol=3, byrow=T))

sinac_dec <- reclassify(sinac_mask, matrix(c(0,0,NA,
                                      0,1,NA,
                                      1,2,1,
                                      2,100,NA),ncol=3, byrow=T))

sinac_sec <- reclassify(sinac_mask, matrix(c(0,0,NA,
                                      0,2,NA,
                                      2,3,1,
                                      3,100,NA),ncol=3, byrow=T))

sinac_all_tree <- reclassify(sinac_mask, matrix(c(0,0,NA,
                                             0,3,1,
                                             3,100,NA),ncol=3, byrow=T))


# Calculate area proportions
sinac_dec_area <- round((cellStats(sinac_dec,'sum') / cellStats(dw_all,'sum') * 100),1)
dw_dec_area <- round((cellStats(dw_dec,'sum') / cellStats(dw_all,'sum') * 100),1)

sinac_mad_area <- round((cellStats(sinac_mad,'sum') / cellStats(dw_all,'sum') * 100),1)
dw_mad_area <- round((cellStats(dw_mad,'sum') / cellStats(dw_all,'sum') * 100),1)

sinac_sec_area <- round((cellStats(sinac_sec,'sum') / cellStats(dw_all,'sum') * 100),1)
dw_sec_area <- round((cellStats(dw_sec,'sum') / cellStats(dw_all,'sum') * 100),1)

sinac_all_area <- round((cellStats(sinac_all_tree,'sum') / cellStats(dw_all,'sum') * 100),1)
dw_all_area <- round((cellStats(dw_all_tree,'sum') / cellStats(dw_all,'sum') * 100),1)

# Put in data frame
areas_df <- data.frame(SINAC = c(sinac_dec_area, sinac_mad_area, sinac_sec_area, sinac_all_area),
                       DW = c(dw_dec_area, dw_mad_area, dw_sec_area, dw_all_area))
rownames(areas_df) <- c("Deciduous","Mature","Secondary","All tree")

# Make barplot
par(mar=c(3,3,1,3.5) + 0.1,mgp=c(2,1,0))
graphics::barplot(t(as.matrix(areas_df)),beside=T,col=NA,border=NA,xlab="Forest type",ylab="% park area (with DW22 coverage)",
                  ylim=c(0,100))
grid()
box()
graphics::barplot(t(as.matrix(areas_df)),beside=T,legend=T,add=T,
                  args.legend = list(bg="white",x="topleft",inset=c(0.1,0)))
title("e)",adj=0.02, line=-1.2, cex.main=1.5)



### Make accuracy matrix ######################################################

dec_dec <- cellStats(sinac_dec*dw_dec,'sum')
dec_sec <- cellStats(sinac_dec*dw_sec,'sum')
dec_mad <- cellStats(sinac_dec*dw_mad,'sum')
dec_other <- cellStats(sinac_dec, 'sum') - dec_dec - dec_sec - dec_mad

sec_dec <- cellStats(sinac_sec*dw_dec,'sum')
sec_sec <- cellStats(sinac_sec*dw_sec,'sum')
sec_mad <- cellStats(sinac_sec*dw_mad,'sum')
sec_other <- cellStats(sinac_sec, 'sum') - sec_dec - sec_sec - sec_mad

mad_dec <- cellStats(sinac_mad*dw_dec,'sum')
mad_sec <- cellStats(sinac_mad*dw_sec,'sum')
mad_mad <- cellStats(sinac_mad*dw_mad,'sum')
mad_other <- cellStats(sinac_mad, 'sum') - mad_dec - mad_sec - mad_mad

other_dec <- cellStats(dw_dec,'sum') - dec_dec - sec_dec - mad_dec
other_sec <- cellStats(dw_sec,'sum') - dec_sec - sec_sec - mad_sec
other_mad <- cellStats(dw_mad,'sum') - dec_mad - sec_mad - mad_mad

# Create a table
col1 <- c(dec_dec, dec_sec, dec_mad, dec_other)
col2 <- c(sec_dec, sec_sec, sec_mad, sec_other)
col3 <- c(mad_dec, mad_sec, mad_mad, mad_other)
col4 <- c(other_dec, other_sec, other_mad, NA) # no other-other

df <- data.frame(sinac_dec=col1, sinac_sec=col2, sinac_mad=col3, sinac_other=col4)
rownames(df) <- c("DW_dec", "DW_sec", "DW_mad", "DW_other")
df


# Create accuracy matrix and calculate overall, producer's, and user's accuracies
acc_mat <- df[1:3,1:3]
correct_class <- acc_mat[1,1] + acc_mat[2,2] + acc_mat[3,3]
overall_acc <- correct_class / sum(acc_mat) * 100
producers_acc <- round(data.frame(dec = (acc_mat[1,1] / sum(acc_mat[,1]) * 100), 
                                  sec = (acc_mat[2,2] / sum(acc_mat[,2]) * 100),
                                  mad = (acc_mat[3,3] / sum(acc_mat[,3]) * 100)),2)

users_acc <- round(data.frame(dec = (acc_mat[1,1] / sum(acc_mat[1,]) * 100), 
                              sec = (acc_mat[2,2] / sum(acc_mat[2,]) * 100),
                              mad = (acc_mat[3,3] / sum(acc_mat[3,]) * 100)),2)

# Make the matrix for display
acc_mat_dis <- acc_mat
acc_mat_dis[4,] <- colSums(acc_mat)
acc_mat_dis[5,] <- producers_acc
acc_mat_dis[,4] <- c(rowSums(acc_mat[1:3,]),sum(acc_mat),NA)
acc_mat_dis[,5] <- round(c(t(users_acc),NA,overall_acc),2)
colnames(acc_mat_dis) <- c("SINAC_deciduous", "SINAC_secondary", "SINAC_mature","Total","User's Accuracy")
rownames(acc_mat_dis) <- c("DW_deciduous","DW_secondary","DW_mature","Total", "Producer's Accuracy")