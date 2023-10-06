# Dynamic World time series post-processing
# Dan Myers, 6/13/2013

# Load packages
library(ggplot2)
library(dplyr)

# Set working directory
setwd("R:/NPS_NCRN_VitalSigns/Analyses/Projects/AGU23/Scripts/R/Time series/")

### Based on pixel probabilities ##############################################
# Too visualize how pixel probabilities change over time, run the GEE script 
# "0_Generate_time_series_probabilities". This outputs just the raw pixel probabilities.

# Load data
dw <- read.csv("ee-chart - composite pixel probs by date.csv")

# Add dates
# First, in Excel, change csv date format to Date: Short Date (e.g., 8/5/2015)
dw$dates <- as.Date(dw$system.time_start, format="%m/%d/%Y")

# Remove partial images (with less than 99% of watershed)
dw <- dw[dw$Count > (max(dw$Count, na.rm=T)*0.99),]

# Remove snow heavy images (>0.1 snow probability)
dw <- dw[dw$snow<0.1,]


### Plot pixel probs time series
windows(6.5,5)

# set span
span = 0.2

# Plot time series
gg1 <- ggplot(dw, aes(x=dates)) +
  
  # Trees
  geom_point(aes(y=trees,col="Trees")) +
  geom_smooth(aes(y=trees),method="loess",se=F,col="darkgreen",span=span) +
  
  # Built
  geom_point(aes(y=built,col="Built")) +
  geom_smooth(aes(y=built),method="loess",se=F,col="grey40",span=span) +
  
  # Crops
  geom_point(aes(y=crops, col="Crops")) +
  geom_smooth(aes(y=crops),method="loess",se=F,col="orange3",span=span) +
  
  theme_bw() +
  labs(title="Bush Creek Watershed-average land cover pixel probabilities", subtitle="From Dynamic World dataset", y="Average pixel probability (%)", x="Date") +
  scale_color_manual(name="Type",values=c("Trees" = "forestgreen",
                                          "Built" = "darkgrey",
                                          "Crops" = "orange"))

plot(gg1)

### Based on proportion watershed areas #######################################
# To visualize how dominant pixel landcover types change over time, run the GEE
# script "0_Generate_time_series_dominant_class". The exported file from the top
# chart (choose this as csv) contains the sum of pixels for each class. Each field
# is the number of pixels classified as that class for each day. Remove that field
# Calculate the proportion area by dividing each cell by
# the sum of all pixels in that day. Then it should be analysis ready. 

# Load data
dw2 <- read.csv("percent areas GEE - composite pixel probs by date.csv")
dw2$dates <- as.Date(dw2$system.time_start, format="%m/%d/%Y")

# Remove partial images (with less than 99% of watershed)
dw2 <- dw2[dw2$Count > (max(dw2$Count, na.rm=T)*0.99),]

# Remove snow heavy images (>5% snow dominated)
dw2 <- dw2[dw2$snow8<5,]


# set span
windows(6.5,5)
span = 0.5

# Plot time series
gg2 <- ggplot(dw2, aes(x=dates)) +
  
  # Trees
  geom_point(aes(y=trees1,col="Trees")) +
  geom_smooth(aes(y=trees1),method="loess",se=F,col="darkgreen",span=span) +
  
  # Built
  geom_point(aes(y=built6,col="Built")) +
  geom_smooth(aes(y=built6),method="loess",se=F,col="grey40",span=span) +
  
  # Crops
  geom_point(aes(y=crops4, col="Crops")) +
  geom_smooth(aes(y=crops4),method="loess",se=F,col="orange3",span=span) +
  
  theme_bw() +
  labs(title="Bush Creek Watershed land cover estimates", subtitle="From Dynamic World dataset", y="% watershed area", x="Date") +
  scale_color_manual(name="Type",values=c("Trees" = "forestgreen",
                              "Built" = "darkgrey",
                              "Crops" = "orange"))

plot(gg2)