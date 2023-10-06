# Evaluations of DW 2019 composite against DW training data
# Dan Myers, 4/11/23

# Load packages
library(raster)
library(rgdal) # metadata info

# Set wd
setwd("R:/NPS_NCRN_VitalSigns/Analyses/Projects/AGU23/Scripts/R/Training comparison/")

### Do East image #############################################################
# Load DW 2019 composite
dw19 <- raster("align_dw19comp_east.tif") + 1 # Add 1 to align with training dataset classes

# Load DW training
train <- raster("align_training_east.tif")

# Create matrix
mat1 <- matrix(nrow=11,ncol=11)

# Loop to populate it
for (i_t in 1:9){ # Training value
  for (i_d in 1:9){ # DW19 value
    
    # Extract the values that match the criteria (DW19)
    yes_d <- reclassify(dw19, matrix(c(0,(i_d-1),0,
                                       (i_d-1),i_d,1,
                                       i_d,100,0),ncol=3, byrow=T))
    
    # Do same for training data
    yes_t <- reclassify(train, matrix(c(0,(i_t-1),0,
                                       (i_t-1),i_t,1,
                                       i_t,100,0),ncol=3, byrow=T))
    # Fill the matrix cell
    mat1[i_d,i_t] <- cellStats(yes_d * yes_t,"sum")
  }
}

# Calculate stats
overall_acc <- round((mat1[1,1] + mat1[2,2] + mat1[3,3] + mat1[4,4] + mat1[5,5] + mat1[6,6] +
  mat1[7,7] + mat1[8,8] + mat1[9,9]) / sum(mat1,na.rm=T) * 100,2)

producers_acc <- round(c(mat1[1,1] / sum(mat1[,1], na.rm=T),
                         mat1[2,2] / sum(mat1[,2], na.rm=T),
                         mat1[3,3] / sum(mat1[,3], na.rm=T),
                         mat1[4,4] / sum(mat1[,4], na.rm=T),
                         mat1[5,5] / sum(mat1[,5], na.rm=T),
                         mat1[6,6] / sum(mat1[,6], na.rm=T),
                         mat1[7,7] / sum(mat1[,7], na.rm=T),
                         mat1[8,8] / sum(mat1[,8], na.rm=T),
                         mat1[9,9] / sum(mat1[,9], na.rm=T),
                         NA,NA),2)

users_acc <- round(c(mat1[1,1] / sum(mat1[1,], na.rm=T),
                     mat1[2,2] / sum(mat1[2,], na.rm=T),
                     mat1[3,3] / sum(mat1[3,], na.rm=T),
                     mat1[4,4] / sum(mat1[4,], na.rm=T),
                     mat1[5,5] / sum(mat1[5,], na.rm=T),
                     mat1[6,6] / sum(mat1[6,], na.rm=T),
                     mat1[7,7] / sum(mat1[7,], na.rm=T),
                     mat1[8,8] / sum(mat1[8,], na.rm=T),
                     mat1[9,9] / sum(mat1[9,], na.rm=T)),2)

# Make for display
mat1_dis <- mat1
mat1_dis[10,] <- colSums(mat1, na.rm=T)
mat1_dis[11,] <- c(producers_acc)
mat1_dis[,10] <- c(rowSums(mat1[1:9,], na.rm=T),sum(mat1, na.rm=T),NA)
mat1_dis[,11] <- round(c(t(users_acc),NA,overall_acc),2)

# Add row/column names
colnames(mat1_dis) <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub",
                        "Built","Bare","Snow/Ice","Total","User's Accuracy")
rownames(mat1_dis) <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub",
                        "Built","Bare","Snow/Ice","Total","Producer's Accuracy")

# Export csv
# write.csv(mat1_dis,"East.csv")



### Do West image #############################################################
# Load DW 2019 composite
dw19 <- raster("align_dw19comp_west.tif") + 1 # Add 1 to align with training dataset classes

# Load DW training
train <- raster("align_training_west.tif")

# Create matrix
mat1 <- matrix(nrow=11,ncol=11)

# Loop to populate it
for (i_t in 1:9){ # Training value
  for (i_d in 1:9){ # DW19 value
    
    # Extract the values that match the criteria (DW19)
    yes_d <- reclassify(dw19, matrix(c(0,(i_d-1),0,
                                       (i_d-1),i_d,1,
                                       i_d,100,0),ncol=3, byrow=T))
    
    # Do same for training data
    yes_t <- reclassify(train, matrix(c(0,(i_t-1),0,
                                        (i_t-1),i_t,1,
                                        i_t,100,0),ncol=3, byrow=T))
    # Fill the matrix cell
    mat1[i_d,i_t] <- cellStats(yes_d * yes_t,"sum")
  }
}

# Calculate stats
overall_acc <- round((mat1[1,1] + mat1[2,2] + mat1[3,3] + mat1[4,4] + mat1[5,5] + mat1[6,6] +
                        mat1[7,7] + mat1[8,8] + mat1[9,9]) / sum(mat1,na.rm=T) * 100,2)

producers_acc <- round(c(mat1[1,1] / sum(mat1[,1], na.rm=T),
                         mat1[2,2] / sum(mat1[,2], na.rm=T),
                         mat1[3,3] / sum(mat1[,3], na.rm=T),
                         mat1[4,4] / sum(mat1[,4], na.rm=T),
                         mat1[5,5] / sum(mat1[,5], na.rm=T),
                         mat1[6,6] / sum(mat1[,6], na.rm=T),
                         mat1[7,7] / sum(mat1[,7], na.rm=T),
                         mat1[8,8] / sum(mat1[,8], na.rm=T),
                         mat1[9,9] / sum(mat1[,9], na.rm=T),
                         NA,NA),2)

users_acc <- round(c(mat1[1,1] / sum(mat1[1,], na.rm=T),
                     mat1[2,2] / sum(mat1[2,], na.rm=T),
                     mat1[3,3] / sum(mat1[3,], na.rm=T),
                     mat1[4,4] / sum(mat1[4,], na.rm=T),
                     mat1[5,5] / sum(mat1[5,], na.rm=T),
                     mat1[6,6] / sum(mat1[6,], na.rm=T),
                     mat1[7,7] / sum(mat1[7,], na.rm=T),
                     mat1[8,8] / sum(mat1[8,], na.rm=T),
                     mat1[9,9] / sum(mat1[9,], na.rm=T)),2)

# Make for display
mat1_dis <- mat1
mat1_dis[10,] <- colSums(mat1, na.rm=T)
mat1_dis[11,] <- c(producers_acc)
mat1_dis[,10] <- c(rowSums(mat1[1:9,], na.rm=T),sum(mat1, na.rm=T),NA)
mat1_dis[,11] <- round(c(t(users_acc),NA,overall_acc),2)

# Add row/column names
colnames(mat1_dis) <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub",
                        "Built","Bare","Snow/Ice","Total","User's Accuracy")
rownames(mat1_dis) <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub",
                        "Built","Bare","Snow/Ice","Total","Producer's Accuracy")

# Export csv
# write.csv(mat1_dis,"West.csv")


### Calculate no-data area in West image
west_nd <- reclassify(train, matrix(c(-1,0,1,
                                      0,100,0),ncol=3, byrow=T))
west_all <- reclassify(train, matrix(c(-1,100,1),ncol=3,byrow=T))
cellStats(west_nd,"sum") / cellStats(west_all,"sum") * 100

### Do South image #############################################################
# Load DW 2019 composite
dw19 <- raster("align_dw19comp_south.tif") + 1 # Add 1 to align with training dataset classes

# Load DW training
train <- raster("align_training_south.tif")

# Create matrix
mat1 <- matrix(nrow=11,ncol=11)

# Loop to populate it
for (i_t in 1:9){ # Training value
  for (i_d in 1:9){ # DW19 value
    
    # Extract the values that match the criteria (DW19)
    yes_d <- reclassify(dw19, matrix(c(0,(i_d-1),0,
                                       (i_d-1),i_d,1,
                                       i_d,100,0),ncol=3, byrow=T))
    
    # Do same for training data
    yes_t <- reclassify(train, matrix(c(0,(i_t-1),0,
                                        (i_t-1),i_t,1,
                                        i_t,100,0),ncol=3, byrow=T))
    # Fill the matrix cell
    mat1[i_d,i_t] <- cellStats(yes_d * yes_t,"sum")
  }
}

# Calculate stats
overall_acc <- round((mat1[1,1] + mat1[2,2] + mat1[3,3] + mat1[4,4] + mat1[5,5] + mat1[6,6] +
                        mat1[7,7] + mat1[8,8] + mat1[9,9]) / sum(mat1,na.rm=T) * 100,2)

producers_acc <- round(c(mat1[1,1] / sum(mat1[,1], na.rm=T),
                         mat1[2,2] / sum(mat1[,2], na.rm=T),
                         mat1[3,3] / sum(mat1[,3], na.rm=T),
                         mat1[4,4] / sum(mat1[,4], na.rm=T),
                         mat1[5,5] / sum(mat1[,5], na.rm=T),
                         mat1[6,6] / sum(mat1[,6], na.rm=T),
                         mat1[7,7] / sum(mat1[,7], na.rm=T),
                         mat1[8,8] / sum(mat1[,8], na.rm=T),
                         mat1[9,9] / sum(mat1[,9], na.rm=T),
                         NA,NA),2)

users_acc <- round(c(mat1[1,1] / sum(mat1[1,], na.rm=T),
                     mat1[2,2] / sum(mat1[2,], na.rm=T),
                     mat1[3,3] / sum(mat1[3,], na.rm=T),
                     mat1[4,4] / sum(mat1[4,], na.rm=T),
                     mat1[5,5] / sum(mat1[5,], na.rm=T),
                     mat1[6,6] / sum(mat1[6,], na.rm=T),
                     mat1[7,7] / sum(mat1[7,], na.rm=T),
                     mat1[8,8] / sum(mat1[8,], na.rm=T),
                     mat1[9,9] / sum(mat1[9,], na.rm=T)),2)

# Make for display
mat1_dis <- mat1
mat1_dis[10,] <- colSums(mat1, na.rm=T)
mat1_dis[11,] <- c(producers_acc)
mat1_dis[,10] <- c(rowSums(mat1[1:9,], na.rm=T),sum(mat1, na.rm=T),NA)
mat1_dis[,11] <- round(c(t(users_acc),NA,overall_acc),2)

# Add row/column names
colnames(mat1_dis) <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub",
                        "Built","Bare","Snow/Ice","Total","User's Accuracy")
rownames(mat1_dis) <- c("Water","Trees","Grass","Flooded Veg","Crops","Shrub/Scrub",
                        "Built","Bare","Snow/Ice","Total","Producer's Accuracy")

# Export csv
# write.csv(mat1_dis,"South.csv")
