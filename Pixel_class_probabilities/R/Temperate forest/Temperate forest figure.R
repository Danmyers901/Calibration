# Pixel probabilities figure 3 - temperate forest
# Dan Myers, 4/13/2023

# First, align the DW pixel probabilities, DW composite, and NLCD rasters in QGIS.

# Set working directory
setwd("R:/NPS_NCRN_VitalSigns/Analyses/Projects/AGU23/Scripts/R/Temperate forest/")

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


### a) NLCD ###########################################################
# Load data
nlcd_c <- raster("align_NLCD_allSFQC_mask.tif")
shed <- st_read("shed_sfqc.shp")
# Crop to watershed
# nlcd_m <- crop(nlcd,shed)
# nlcd_c <- mask(nlcd_m,shed)

# Extract forest and reclassify
nlcd_dec <- reclassify(nlcd_c, matrix(c(0,0,0,
                                      0,40,0,
                                      40,41,1,
                                      41,100,0),ncol=3, byrow=T))

nlcd_eve <- reclassify(nlcd_c, matrix(c(0,0,0,
                                      0,41,0,
                                      41,42,2,
                                      42,100,0),ncol=3, byrow=T))

nlcd_mix <- reclassify(nlcd_c, matrix(c(0,0,0,
                                      0,42,0,
                                      42,43,3,
                                      43,100,0),ncol=3, byrow=T))
nlcd_for <- nlcd_dec + nlcd_eve + nlcd_mix

# Plot it
plot(nlcd_for, col=c("#FFFFFF","#85C77E","#38814E","#D4E7B0"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend=c("Deciduous","Evergreen","Mixed"), fill=c("#85C77E","#38814E","#D4E7B0"),bg="white")
title("a)",adj=0.02, line=-1.2, cex.main=1.5)
title("NLCD19 forest classes",adj=0.02, line=-13.9, cex.main=1)


### b) DW original ###########################################################
# Load data
dw_comp <- raster("align_DWcomp_allSFQC_mask.tif")

# Extract tree from DW composite
dw_comp_for <- reclassify(dw_comp, matrix(c(0,0,NA,
                                             0,0,NA,
                                             0,1,1,
                                             1,10,NA),ncol=3, byrow=T))

# Plot it
plot(dw_comp_for, col="#397D49",legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend="Trees", fill=c("#397D49"),bg="white")
title("b)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 tree class",adj=0.02, line=-13.9, cex.main=1)


### c) DW pixel probs##########################################################
# Load data
dw <- raster("align_DWprob_allSFQC_mask.tif")

# Mask tree land in DW probs
dw_tree <- dw * dw_comp_for

# Set colors and plot it
plot(dw_tree,legend=T,axes=FALSE)
plot(shed$geometry,add=T)
grid()
title("c)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 tree probability",adj=0.02, line=-13.9, cex.main=1)



### d) DW sub-classified#######################################################
##### Set Bins #####
bin_dec_mix <-61 # highest value in lower bin # 61 is good
bin_mix_eve <-65                              # 65 is good

# Extract forest types
dw_dec <- reclassify(dw_tree, matrix(c(0,0,0,
                                       0,0,0,
                                       0,bin_dec_mix,1,
                                       bin_dec_mix,100,0),ncol=3, byrow=T))

dw_eve <- reclassify(dw_tree, matrix(c(0,0,0,
                                       0,bin_mix_eve,0,
                                       bin_mix_eve,100,2,
                                       100,101,0),ncol=3, byrow=T))

dw_mix <- reclassify(dw_tree, matrix(c(0,0,0,
                                       0,bin_dec_mix,0,
                                       bin_dec_mix,bin_mix_eve,3,
                                       bin_mix_eve,100,0),ncol=3, byrow=T))
dw_pp_for <- dw_dec + dw_eve + dw_mix


# Plot it
plot(dw_pp_for, col=c("#85C77E","#38814E","#D4E7B0"),legend=FALSE,axes=FALSE)
plot(shed$geometry,add=T)
grid()
legend("topright",legend=c("Deciduous","Evergreen","Mixed"), fill=c("#85C77E","#38814E","#D4E7B0"),bg="white")
title("d)",adj=0.02, line=-1.2, cex.main=1.5)
title("DW22 sub-classified",adj=0.02, line=-13.9, cex.main=1)



### e) Watershed areas ########################################################

# Assign DW bins and reclassify
dw_all <- reclassify(dw_comp, matrix(c(0,0,NA,
                                       0,101,1),ncol=3,byrow=T))


dw_dec <- reclassify(dw_tree, matrix(c(0,0,NA,
                                       0,0,NA,
                                       0,bin_dec_mix,1,
                                       bin_dec_mix,100,NA),ncol=3, byrow=T))

dw_mix <- reclassify(dw_tree, matrix(c(0,0,NA,
                                       0,bin_dec_mix,NA,
                                       bin_dec_mix,bin_mix_eve,1,
                                       bin_mix_eve,100,NA),ncol=3, byrow=T))

dw_eve <- reclassify(dw_tree, matrix(c(0,0,NA,
                                       0,bin_mix_eve,NA,
                                       bin_mix_eve,100,1,
                                       100,101,NA),ncol=3, byrow=T))
dw_all_tree <- dw_comp_for

# Extract NLCD classifications
nlcd <- nlcd_c
nlcd_all <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,255,1),ncol=3,byrow=T))

nlcd_all_tree <- reclassify(nlcd, matrix(c(0,0,NA,
                                           0,40,NA,
                                           40,43,1,
                                           43,255,NA),ncol=3,byrow=T))

nlcd_dec <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,40,NA,
                                      40,41,1,
                                      41,100,NA),ncol=3, byrow=T))

nlcd_eve <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,41,NA,
                                      41,42,1,
                                      42,100,NA),ncol=3, byrow=T))

nlcd_mix <- reclassify(nlcd, matrix(c(0,0,NA,
                                      0,42,NA,
                                      42,43,1,
                                      43,100,NA),ncol=3, byrow=T))


# Calculate area proportions
nlcd_eve_area <- round((cellStats(nlcd_eve,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_eve_area <- round((cellStats(dw_eve,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_mix_area <- round((cellStats(nlcd_mix,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_mix_area <- round((cellStats(dw_mix,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_dec_area <- round((cellStats(nlcd_dec,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_dec_area <- round((cellStats(dw_dec,'sum') / cellStats(dw_all,'sum') * 100),1)

nlcd_all_area <- round((cellStats(nlcd_all_tree,'sum') / cellStats(nlcd_all,'sum') * 100),1)
dw_all_area <- round((cellStats(dw_all_tree,'sum') / cellStats(dw_all,'sum') * 100),1)

# Put in data frame
areas_df <- data.frame(NLCD = c(nlcd_eve_area, nlcd_mix_area, nlcd_dec_area, nlcd_all_area),
                       DW = c(dw_eve_area, dw_mix_area, dw_dec_area, dw_all_area))
rownames(areas_df) <- c("Evergreen","Mixed","Deciduous","All tree")

# Make barplot
par(mar=c(3,3,1,3.5) + 0.1,mgp=c(2,1,0))
graphics::barplot(t(as.matrix(areas_df)),beside=T,col=NA,border=NA,xlab="Forest type",ylab="% watershed area",
        ylim=c(0,100))
grid()
box()
graphics::barplot(t(as.matrix(areas_df)),beside=T,legend=T,add=T,
        args.legend = list(bg="white",x="topleft",inset=c(0.1,0)))
title("e)",adj=0.02, line=-1.2, cex.main=1.5)



### Create accuracy matrix ####################################################
#### Evaluations: Calculate performance of pixel probs against NLCD
# NLCD#_DW# is the name format

dec_dec <- cellStats(nlcd_dec*dw_dec,'sum')
dec_mix <- cellStats(nlcd_dec*dw_mix,'sum')
dec_eve <- cellStats(nlcd_dec*dw_eve,'sum')
dec_other <- cellStats(nlcd_dec, 'sum') - dec_dec - dec_mix - dec_eve

mix_dec <- cellStats(nlcd_mix*dw_dec,'sum')
mix_mix <- cellStats(nlcd_mix*dw_mix,'sum')
mix_eve <- cellStats(nlcd_mix*dw_eve,'sum')
mix_other <- cellStats(nlcd_mix, 'sum') - mix_dec - mix_mix - mix_eve

eve_dec <- cellStats(nlcd_eve*dw_dec,'sum')
eve_mix <- cellStats(nlcd_eve*dw_mix,'sum')
eve_eve <- cellStats(nlcd_eve*dw_eve,'sum')
eve_other <- cellStats(nlcd_eve, 'sum') - eve_dec - eve_mix - eve_eve

other_dec <- cellStats(dw_dec,'sum') - dec_dec - mix_dec - eve_dec
other_mix <- cellStats(dw_mix,'sum') - dec_mix - mix_mix - eve_mix
other_eve <- cellStats(dw_eve,'sum') - dec_eve - mix_eve - eve_eve

# Create a table
col1 <- c(dec_dec, dec_mix, dec_eve, dec_other)
col2 <- c(mix_dec, mix_mix, mix_eve, mix_other)
col3 <- c(eve_dec, eve_mix, eve_eve, eve_other)
col4 <- c(other_dec, other_mix, other_eve, NA) # no other-other

df <- data.frame(NLCD_dec=col1, NLCD_mix=col2, NLCD_eve=col3, NLCD_other=col4)
rownames(df) <- c("DW_dec", "DW_mix", "DW_eve", "DW_other")
df

# Create accuracy matrix and calculate overall, producer's, and user's accuracies
acc_mat <- df[1:3,1:3]
correct_class <- acc_mat[1,1] + acc_mat[2,2] + acc_mat[3,3]
overall_acc <- correct_class / sum(acc_mat) * 100
producers_acc <- round(data.frame(dec = (acc_mat[1,1] / sum(acc_mat[,1]) * 100), 
                                  mix = (acc_mat[2,2] / sum(acc_mat[,2]) * 100),
                                  eve = (acc_mat[3,3] / sum(acc_mat[,3]) * 100)),2)

users_acc <- round(data.frame(dec = (acc_mat[1,1] / sum(acc_mat[1,]) * 100), 
                              mix = (acc_mat[2,2] / sum(acc_mat[2,]) * 100),
                              eve = (acc_mat[3,3] / sum(acc_mat[3,]) * 100)),2)

# Make the matrix for display
acc_mat_dis <- acc_mat
acc_mat_dis[4,] <- colSums(acc_mat)
acc_mat_dis[5,] <- producers_acc
acc_mat_dis[,4] <- c(rowSums(acc_mat[1:3,]),sum(acc_mat),NA)
acc_mat_dis[,5] <- round(c(t(users_acc),NA,overall_acc),2)
colnames(acc_mat_dis) <- c("NLCD_deciduous", "NLCD_mixed", "NLCD_evergreen","Total","User's Accuracy")
rownames(acc_mat_dis) <- c("DW_deciduous","DW_mixed","DW_evergreen","Total", "Producer's Accuracy")
acc_mat_dis