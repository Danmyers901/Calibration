# Figure S2
# Dan Myers, 4/6/2023

# Set working directory
setwd("R:/NPS_NCRN_VitalSigns/Analyses/Projects/AGU23/Scripts/R/Water quality/")

# Load packages
library(dplyr)
library(tidyr)


####### NCRN specific conductance ##############################################
# Load data
wdata <- read.csv("WQX_Water_Data_QC_removed.csv")
best37 <- read.csv("ROCR_SFQC_site_names.csv") # Sites monitored a long time
errors <- read.csv("data_errors.csv")

# Remove data with known errors
for (row in 1:nrow(errors)){
  rows <- (wdata$ActivityIdentifier == errors$Activity.Identifier[row] & wdata$CharacteristicName == errors$Characteristic.Name[row])
  rows[is.na(rows)] <- FALSE
  if (sum(rows, na.rm=T) >0){ # Find the discrepancy (skip if doesn't exist anymore)
    wdata <- wdata[-rows,]
  }
}

# Average separate measurements taken across stream at each event.
wdata_avgd <- wdata %>%
  group_by(MonitoringLocationIdentifier, .add=FALSE) %>%
  group_by(ActivityStartDate, .add=TRUE) %>%
  group_by(CharacteristicName, .add=TRUE) %>%
  summarise(
    avg_val = mean(as.numeric(ResultMeasureValue), na.rm=T),
    n = sum(as.numeric(ResultMeasureValue) >=-99, na.rm=T)
  )

# Assign time variables
wdata_avgd$year_wq <- as.numeric(format(as.Date(wdata_avgd$ActivityStartDate,format="%m/%d/%Y"), "%Y")) # May have to fool around with the data format if file read differently (%Y-%m-%d)
wdata_avgd$month_wq <- as.numeric(format(as.Date(wdata_avgd$ActivityStartDate,format="%m/%d/%Y"), "%m")) # May have to fool around with the data format if file read differently (%Y-%m-%d)
wdata_avgd$dec_yr <- wdata_avgd$year_wq + wdata_avgd$month_wq / 12 * 1.000

# Remove YSI events with no numeric values
wdata_avgd <- wdata_avgd[wdata_avgd$n > 0,]

# Remove extra sites
wdata_avgd <- wdata_avgd[wdata_avgd$MonitoringLocationIdentifier %in% best37$site,]

# Extract SC
wdata_avgd_SC <- wdata_avgd[wdata_avgd$CharacteristicName=="Specific conductance",] %>% arrange(dec_yr)
wdata_avgd_SC <- arrange(wdata_avgd_SC, wdata_avgd_SC$MonitoringLocationIdentifier)
ncrn_SC <- wdata_avgd_SC[,c(1,4)]
ncrn_SC <- ncrn_SC[ncrn_SC$MonitoringLocationIdentifier %in% best37$site,]
pw_ncrn_SC <- pivot_wider(ncrn_SC, names_from="MonitoringLocationIdentifier",
                          values_from="avg_val")

# Create a NA data frame to convert the list to
pw_ncrn_SC_df <- data.frame(matrix(nrow=20,ncol=ncol(pw_ncrn_SC))) # 20 years should cover it all

# Populate data frame
for (i in 1:ncol(pw_ncrn_SC)){
  site_data_SC <- unlist(pw_ncrn_SC[[i]])
  nrows <- length(site_data_SC) # Number of measurements for the site
  pw_ncrn_SC_df[1:nrows,i] <- site_data_SC # Add column to matrix
}
colnames(pw_ncrn_SC_df) <- colnames(pw_ncrn_SC)

# Sort data by median pixel probability
medians_SC <- apply(pw_ncrn_SC_df,2,median, na.rm=T)
medians_pp <- seq(1:length(medians_SC))
# medians_pp <- rev(medians_pp)
order1_SC <- row_number(medians_pp)
order1_SC_df <- data.frame(order1 = order1_SC, sort1 = 1:length(order1_SC)) %>% arrange(order1)
toPlot_SC <- pw_ncrn_SC_df[,order1_SC_df$sort1]


### Nitrogen ###################################################################
# Average separate measurements taken across stream at each event.
wdata_avgd <- wdata %>%
  group_by(MonitoringLocationIdentifier, .add=FALSE) %>%
  group_by(ActivityStartDate, .add=TRUE) %>%
  group_by(CharacteristicName, .add=TRUE) %>%
  group_by(ResultAnalyticalMethod.MethodIdentifier, .add=TRUE) %>%
  summarise(
    avg_val = mean(as.numeric(ResultMeasureValue), na.rm=T),
    n = sum(as.numeric(ResultMeasureValue) >=-99, na.rm=T)
  )

# Remove extra sites
wdata_avgd <- wdata_avgd[wdata_avgd$MonitoringLocationIdentifier %in% best37$site,]

# Assign time variables
wdata_avgd$year_wq <- as.numeric(format(as.Date(wdata_avgd$ActivityStartDate,format="%m/%d/%Y"), "%Y")) # May have to fool around with the data format if file read differently (%Y-%m-%d)
wdata_avgd$month_wq <- as.numeric(format(as.Date(wdata_avgd$ActivityStartDate,format="%m/%d/%Y"), "%m")) # May have to fool around with the data format if file read differently (%Y-%m-%d)
wdata_avgd$dec_yr <- wdata_avgd$year_wq + wdata_avgd$month_wq / 12 * 1.000

# Remove YSI events with no numeric values
wdata_avgd <- wdata_avgd[wdata_avgd$n > 0,]

# Extract N
wdata_avgd_N <- wdata_avgd[wdata_avgd$CharacteristicName=="Nitrate",] %>% arrange(dec_yr)
N_hach_8039 <- wdata_avgd_N[wdata_avgd_N$ResultAnalyticalMethod.MethodIdentifier=="NCRN_HACH_8039",]
N_hach_8171 <- wdata_avgd_N[wdata_avgd_N$ResultAnalyticalMethod.MethodIdentifier=="NCRN_HACH_8171",]
N_hach_10020 <- wdata_avgd_N[wdata_avgd_N$ResultAnalyticalMethod.MethodIdentifier=="NCRN_HACH_10020",]
N_hach_10206 <- wdata_avgd_N[wdata_avgd_N$ResultAnalyticalMethod.MethodIdentifier=="NCRN_HACH_10206",]
N_cbl_353_2<- wdata_avgd_N[wdata_avgd_N$ResultAnalyticalMethod.MethodIdentifier=="NCRN_CBL_EPA_353.2",]
N_cbl_353_2 <- arrange(N_cbl_353_2, N_cbl_353_2$MonitoringLocationIdentifier)

N_short <- N_cbl_353_2[,c(1,5)]
pw_N <- pivot_wider(N_short, names_from="MonitoringLocationIdentifier",
                    values_from="avg_val")

# Create a NA data frame to convert the list to
pw_N_df <- data.frame(matrix(nrow=20,ncol=ncol(pw_N))) # 20 years should cover it all

# Populate data frame
for (i in 1:ncol(pw_N)){
  site_data_N <- unlist(pw_N[[i]])
  nrows <- length(site_data_N) # Number of measurements for the site
  pw_N_df[1:nrows,i] <- site_data_N # Add column to matrix
}
colnames(pw_N_df) <- colnames(pw_N)

# Sort data by median
medians_N <- apply(pw_N_df,2,median, na.rm=T)
order1_N <- row_number(medians_pp)
order1_N_df <- data.frame(order1 = order1_N, sort1 = 1:length(order1_N)) %>% arrange(order1)
toPlot_N2 <- pw_N_df[,order1_N_df$sort1]


### Phosphorus #################################################################
# Extract P
wdata_avgd_P <- wdata_avgd[wdata_avgd$CharacteristicName=="Total Phosphorus, mixed forms" |
                             wdata_avgd$CharacteristicName=="Orthophosphate",] %>% arrange(dec_yr)
P_hach_8190 <- wdata_avgd_P[wdata_avgd_P$ResultAnalyticalMethod.MethodIdentifier=="8190",]
P_hach_8048 <- wdata_avgd_P[wdata_avgd_P$ResultAnalyticalMethod.MethodIdentifier=="8048",]
P_hach_8178 <- wdata_avgd_P[wdata_avgd_P$ResultAnalyticalMethod.MethodIdentifier=="NCRN_HACH_8178",]
P_hach_10210 <- wdata_avgd_P[wdata_avgd_P$ResultAnalyticalMethod.MethodIdentifier=="NCRN_HACH_10210",]
P_cbl_365_1<- wdata_avgd_P[wdata_avgd_P$ResultAnalyticalMethod.MethodIdentifier=="NCRN_CBL_EPA_365.1",]
P_cbl_365_1 <- arrange(P_cbl_365_1, P_cbl_365_1$MonitoringLocationIdentifier)

P_short <- P_cbl_365_1[,c(1,5)]
pw_P <- pivot_wider(P_short, names_from="MonitoringLocationIdentifier",
                    values_from="avg_val")

# Create a NA data frame to convert the list to
pw_P_df <- data.frame(matrix(nrow=20,ncol=ncol(pw_P))) # 20 years should cover it all

# Populate data frame
for (i in 1:ncol(pw_P)){
  site_data_P <- unlist(pw_P[[i]])
  nrows <- length(site_data_P) # Number of measurements for the site
  pw_P_df[1:nrows,i] <- site_data_P # Add column to matrix
}
colnames(pw_P_df) <- colnames(pw_P)

# Sort data by median
medians_P <- apply(pw_P_df,2,median, na.rm=T)
order1_P <- row_number(medians_pp)
order1_P_df <- data.frame(order1 = order1_P, sort1 = 1:length(order1_P)) %>% arrange(order1)
toPlot_P2 <- pw_P_df[,order1_P_df$sort1]


################################################################################
### Quantitative analyses ######################################################
################################################################################

# Load watershed DW22 composite areas data
comp_areas <- read.csv("Watershed conditions table 1.csv")
colnames(comp_areas)[1] <- "site"

# Format watershed probabilities
probs <- best37
probs$site <- substr(probs$site,19,27)
probs$site[probs$site=="ROCR_HACR"] <- "ROCR_R630"

# Join probability and composite data
probs_comps <- left_join(probs, comp_areas, by="site")

# Set up plot
windows(6.5,6.5)
par(mfrow=c(3,2),mgp=c(2,1,0),
    mar=c(3,3,1,1))

### Plot relationships (SC tree)
plot(probs_comps$Trees, medians_SC,col="blue", xlab="Trees class probability or watershed area (%)",
     ylab = "Specific conductance (uS/cm)")
points(probs_comps$mean_trees, medians_SC, col="red")

# Add models (SC tree)
lm1 <- lm(medians_SC ~ probs_comps$Trees) 
abline(lm1, col="blue")
lm2 <- lm(medians_SC ~ probs_comps$mean_trees)
abline(lm2, col="red")
summary(lm1)
summary(lm2)

# Add legend and R2
legend("topright",legend=c("Watershed area model", "Class probability model"), col=c("blue","red"),pch=1,bg="white")
text(60,500,c(expression(R^2 ~ "=")),col="blue")     
text(71,493,round(summary(lm1)$r.squared,2),col="blue")    
text(20,300,c(expression(R^2 ~ "=")),col="red")     
text(31,293,round(summary(lm2)$r.squared,2),col="red")    
title("a)",adj=0.01, line=-1.2, cex.main=1.5)

# Add Morgan 2007 line
abline(h=171, col="grey",lty=2)


### Plot relationships (SC urb)
plot(probs_comps$Built, medians_SC,col="blue", xlab="Built class probability or watershed area (%)",
     ylab = "Specific conductance (uS/cm)")
points(probs_comps$mean_urb, medians_SC, col="red")

# Add models (SC urb)
lm1 <- lm(medians_SC ~ probs_comps$Built) 
abline(lm1, col="blue")
lm2 <- lm(medians_SC ~ probs_comps$mean_urb)
abline(lm2, col="red")
summary(lm1)
summary(lm2)

# Add legend and R2
text(50,350,c(expression(R^2 ~ "=")),col="blue")     
text(61,343,round(summary(lm1)$r.squared,2),col="blue")    
text(10,500,c(expression(R^2 ~ "=")),col="red")     
text(21,493,round(summary(lm2)$r.squared,2),col="red")
title("b)",adj=0.01, line=-1.2, cex.main=1.5)

# Add Morgan 2007 line
abline(h=171, col="grey",lty=2)


### Plot relationships (N tree)
plot(probs_comps$Trees, medians_N,col="blue", xlab="Trees class probability or watershed area (%)",
     ylab = "Total Nitrogen (mg/L)")
points(probs_comps$mean_trees, medians_N, col="red")

# Add models (N tree)
lm1 <- lm(medians_N ~ probs_comps$Trees) 
abline(lm1, col="blue")
lm2 <- lm(medians_N ~ probs_comps$mean_trees)
abline(lm2, col="red")
summary(lm1)
summary(lm2)

# Add legend and R2
text(40,2.5,c(expression(R^2 ~ "=")),col="blue")     
text(51,2.46,round(summary(lm1)$r.squared,2),col="blue")    
text(20,1,c(expression(R^2 ~ "=")),col="red")     
text(31,0.96,round(summary(lm2)$r.squared,2),col="red")    
title("c)",adj=0.01, line=-1.2, cex.main=1.5)

abline(h=1.3,col="grey",lty=2) # Morgan et al. 2007 TN critical value for BIBI

### Plot relationships (N urb)
plot(probs_comps$Built, medians_N,col="blue", xlab="Built class probability or watershed area (%)",
     ylab = "Total Nitrogen (mg/L)")
points(probs_comps$mean_urb, medians_N, col="red")

# Add models (N urb)
lm1 <- lm(medians_N ~ probs_comps$Built) 
abline(lm1, col="blue")
lm2 <- lm(medians_N ~ probs_comps$mean_urb)
abline(lm2, col="red")
summary(lm1)
summary(lm2)

# Add legend and R2
text(40,1,c(expression(R^2 ~ "=")),col="blue")     
text(51,0.96,round(summary(lm1)$r.squared,2),col="blue")    
text(20,2,c(expression(R^2 ~ "=")),col="red")     
text(31,1.92,round(summary(lm2)$r.squared,2),col="red")   
title("d)",adj=0.01, line=-1.2, cex.main=1.5)

abline(h=1.3,col="grey",lty=2) # Morgan et al. 2007 TN critical value for BIBI

### Plot relationships (P tree)
plot(probs_comps$Trees, medians_P,col="blue", xlab="Trees class probability or watershed area (%)",
     ylab = "Total Phosphorus (mg/L)")
points(probs_comps$mean_trees, medians_P, col="red")

# Add models (P tree)
lm1 <- lm(medians_P ~ probs_comps$Trees) 
abline(lm1, col="blue")
lm2 <- lm(medians_P ~ probs_comps$mean_trees)
abline(lm2, col="red")
summary(lm1)
summary(lm2)

# Add legend and R2
text(40,0.06,c(expression(R^2 ~ "=")),col="blue")     
text(51,0.059,round(summary(lm1)$r.squared,2),col="blue")    
text(20,0.03,c(expression(R^2 ~ "=")),col="red")     
text(31,0.029,round(summary(lm2)$r.squared,2),col="red")    
title("e)",adj=0.01, line=-1.2, cex.main=1.5)

abline(h=0.043,col="grey",lty=2) # Morgan et al. 2007 TP critical value for BIBI

### Plot relationships (P urb)
plot(probs_comps$Built, medians_P,col="blue", xlab="Built class probability or watershed area (%)",
     ylab = "Total Phosphorus (mg/L)")
points(probs_comps$mean_urb, medians_P, col="red")

# Add models (P urb)
lm1 <- lm(medians_P ~ probs_comps$Built) 
abline(lm1, col="blue")
lm2 <- lm(medians_P ~ probs_comps$mean_urb)
abline(lm2, col="red")
summary(lm1)
summary(lm2)

# Add legend and R2
text(40,0.025,c(expression(R^2 ~ "=")),col="blue")     
text(51,0.0245,round(summary(lm1)$r.squared,2),col="blue")    
text(10,0.04,c(expression(R^2 ~ "=")),col="red")     
text(21,0.039,round(summary(lm2)$r.squared,2),col="red") 
title("f)",adj=0.01, line=-1.2, cex.main=1.5)

abline(h=0.043,col="grey",lty=2) # Morgan et al. 2007 TP critical value for BIBI