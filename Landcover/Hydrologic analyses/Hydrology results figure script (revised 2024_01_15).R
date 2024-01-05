# Hydrology results figure script
# Dan Myers, 10/25/2022

library(dplyr)
library(scales)
library(Metrics)

# Set working directory
# setwd("R:/NPS_NCRN_VitalSigns/Data/GIS/Projects/AGU_study/Revision/Myers et al. Mendeley Data (revised)/Hydrologic analyses")
# setwd("C:/GIS/Projects/AGU_study/Revision/Myers et al. Mendeley Data (revised)/Hydrologic analyses")

### Step 1: Load data
# Load water quality data
medians_all <- read.csv("Water_quality_median_values_2005-2018_all_seasons.csv")

# Load LULC data
lulc_grow <- read.csv("Dynamic_World_LULC_percent_area_growing_season (revised 2023_02_09).csv")
lulc_non <- read.csv("Dynamic_World_LULC_percent_area_Nongrowing_season (revised 2023_02_09).csv")
nlcd <- read.csv("watersheds_nlcd16_stats (revised 2023_02_09).csv")


### Step 2: Create regression models (quadratic)
# Growing
x1 <- lulc_grow$built
y <- medians_all$Specific.conductance
lm_SpeCond_growing <- lm(y ~ x1+I(x1^2))
myPredict1 <- predict(lm_SpeCond_growing) 
ix1 <- sort(x1,index.return=T)$ix
summary(lm_SpeCond_growing)
AIC(lm_SpeCond_growing)
rmse(medians_all$Specific.conductance, lm_SpeCond_growing$fitted.values)
round(confint(lm_SpeCond_growing,level=0.95),2)

# Non-growing
x2 <- lulc_non$built
y <- medians_all$Specific.conductance
lm_SpeCond_nongrowing <- lm(y ~ x2+I(x2^2))
myPredict2 <- predict(lm_SpeCond_nongrowing) 
ix2 <- sort(x2,index.return=T)$ix
summary(lm_SpeCond_nongrowing)
AIC(lm_SpeCond_nongrowing)
rmse(medians_all$Specific.conductance, lm_SpeCond_nongrowing$fitted.values)
round(confint(lm_SpeCond_nongrowing,level=0.95),2)

# NLCD
x3 <- nlcd$urb_tot_OLMH
y <- medians_all$Specific.conductance
lm_nlcd <- lm(y ~ x3+I(x3^2))
myPredict3 <- predict(lm_nlcd) 
ix3 <- sort(x3,index.return=T)$ix
summary(lm_nlcd)
AIC(lm_nlcd)
rmse(medians_all$Specific.conductance, lm_nlcd$fitted.values)
round(confint(lm_nlcd,level=0.95),2)

### Step 3: Make plots
# Start plots
windows(6.5,4)

## Specific conductance

# Set margins
par(mar=c(3,3,2,2) + 0.1, mgp=c(2,1,0))
# Growing season points
plot(lulc_grow$built, medians_all$Specific.conductance, type="n",
     xlab = "Built or developed landuse (%)", ylab="Specific conductance (uS/cm)",
     ylim=c(0,900),yaxs="i")
grid()
points(lulc_grow$built, medians_all$Specific.conductance,col="firebrick4")

# Nongrowing season points
points(lulc_non$built, medians_all$Specific.conductance, col="deepskyblue3")

# NLCD 2016 points
points(nlcd$urb_tot_OLMH, medians_all$Specific.conductance, col="darkgoldenrod2")

# Legend
legend("bottomright",legend=c("Dyn. World 2016 growing", "Dyn. World 2016 non-gro.", "NLCD 2016"), 
       col=c("firebrick4", "deepskyblue3","darkgoldenrod2"),pch=1, bg="white",y.intersp=0.9)


## Plot 95% confidence intervals
# Growing
x=lulc_grow$built
model= lm_SpeCond_growing
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="firebrick4",lty=2,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="firebrick4",lty=2,lwd=0.5)

# Nongrowing
x=lulc_non$built
model= lm_SpeCond_nongrowing
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="deepskyblue3",lty=2,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="deepskyblue3",lty=2,lwd=0.5)

# NLCD
x=nlcd$urb_tot_OLMH
model= lm_nlcd
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="darkgoldenrod2",lty=2,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="darkgoldenrod2",lty=2,lwd=0.5)

# Add models
lines(x1[ix1], myPredict1[ix1], col="firebrick4", lwd=2 ) 
lines(x2[ix2], myPredict2[ix2], col="deepskyblue3", lwd=2 )  
lines(x3[ix3], myPredict3[ix3], col="darkgoldenrod2", lwd=2 )  


### Rock Creek charts
# load output.rch (growing)
rch_g <- read.table("output_grow.rch",header=T)
rch_g <- rch_g[rch_g$MON<13,] # Remove month 13
rch_g_Q <- rch_g$FLOW_OUTcms[rch_g$RCH==13]
rch_g_N <- rch_g$NO3_OUTkg[rch_g$RCH==13] + rch_g$NO2_OUTkg[rch_g$RCH==13]

# load output.rch (non-growing)
rch_n <- read.table("output_non.rch",header=T)
rch_n <- rch_n[rch_n$MON<13,] # Remove month 13
rch_n_Q <- rch_n$FLOW_OUTcms[rch_n$RCH==13]
rch_n_N <- rch_n$NO3_OUTkg[rch_n$RCH==13] + rch_n$NO2_OUTkg[rch_n$RCH==13]

# load output.rch (nlcd)
rch_nlcd <- read.table("output_nlcd.rch",header=T)
rch_nlcd <- rch_nlcd[rch_nlcd$MON<13,] # Remove month 13
rch_nlcd_Q <- rch_nlcd$FLOW_OUTcms[rch_nlcd$RCH==13]
rch_nlcd_N <- rch_nlcd$NO3_OUTkg[rch_nlcd$RCH==13] + rch_nlcd$NO2_OUTkg[rch_nlcd$RCH==13]

# load obs
obs_Q_all <- read.table("obs_var_1.txt",header=T)
obs_Q <- obs_Q_all$Qobs
obs_N_all <- read.table("obs_var_2.txt",header=T)
obs_N <- obs_N_all$N_kg.mo
obs_date <- as.Date(obs_Q_all$Date, format="%Y-%m-%d") + 15 # add 15 days to display at middle of month


# Make scatterplots (Q)
windows(6.5,2.6)
par(mar=c(6,3,2,2) + 0.1, mgp=c(2,1,0),mfrow=c(1,3))
plot(obs_Q[!is.na(obs_Q)], rch_nlcd_Q[!is.na(obs_Q)],xlim=c(0,10.5), ylim=c(0,10.5),pch=c(1),col="gold",
     xlab="Observed discharge (m3/s)", 
     ylab="Model discharge (m3/s)")
grid()
points(obs_Q[!is.na(obs_Q)], rch_n_Q[!is.na(obs_Q)],col="deepskyblue2", pch=c(1))
points(obs_Q[!is.na(obs_Q)], rch_g_Q[!is.na(obs_Q)],col="firebrick3", pch=c(1))
abline(0,1, lwd=2,col="darkgrey",lty=2)
legend("bottomright",legend=c("Growing","Non-gro.","NLCD"),pch=1,col=c("firebrick3","deepskyblue2","gold"),bg="white")
title("a)",adj=0.03, line=-1.2, cex.main=1.5)

# Make scatterplots (N)
plot(obs_N[!is.na(obs_N)], rch_nlcd_N[!is.na(obs_N)],xlim=c(0,15000), ylim=c(0,15000),pch=c(1),col="gold",
     xlab="Observed N (kg N/month)", 
     ylab="Model N (kg N/month)")
grid()
points(obs_N[!is.na(obs_N)], rch_n_N[!is.na(obs_N)],col="deepskyblue2", pch=c(1))
points(obs_N[!is.na(obs_N)], rch_g_N[!is.na(obs_N)],col="firebrick3", pch=c(1))
abline(0,1, lwd=2,col="darkgrey",lty=2)
title("b)",adj=0.03, line=-1.2, cex.main=1.5)


### Rock Creek barchart
# Calculate average annual nitrate yield
N_yield_g <- sum(rch_g_N) / 9 # 9 years
N_yield_n <- sum(rch_n_N) / 9 # 9 years
N_yield_nlcd <- sum(rch_nlcd_N) / 9 # 9 years

# Place in data frame
data1 <- data.frame(model=c("Dyn. World\ngrowing","Dyn. World\nnon-growing","NLCD"), 
                    Nyield = c(N_yield_g, N_yield_n, N_yield_nlcd) / 1000) # Since y axis unit is 1000 kg

# Make barplot
par(mar=c(6,3.5,2,2) + 0.1, mgp=c(2.5,1,0))
barplot(data1$Nyield ~ data1$model, xlab="", ylim=c(0,115),
        ylab="Annual N yield (*1000 kg)",col=c("firebrick3","deepskyblue2","gold"),las=2)
grid()
barplot(data1$Nyield ~ data1$model, xlab="",
        ylab="Annual N yield (*1000 kg)",col=c("firebrick3","deepskyblue2","gold"),las=2,add=T)
title("c)",adj=0.03, line=-1.2, cex.main=1.5)
box()



### Difficult Run results
# Load data
data1 <- read.csv("obs_sim_data (revised).csv")
obs <- round(data1$Flow_cms_obs,2) 
grow <- round(data1$Flow_growing,2) 
non <- round(data1$Flow_nongrowing,2) 
Flow_NLCD16 <- round(data1$Flow_NLCD16,2)
date <- as.Date(data1$Date, format="%m/%d/%Y")


## Obs/sim plots
# Start printing
png("case3.png",bg="white",res=600,width=6.5,height=6.5,units="in")

# Growing
# windows(6.5,6.5)
nf <- layout(matrix(c(1,2,3, # top
                      4,4,4,
                      4,4,4), # bottom
                    nrow=3, ncol=3,byrow=TRUE))

par(mar=c(3,3,2,1)+0.1, mgp=c(2,1,0)) # bottom, left, top, right
plot(log10(obs), log10(grow), col=alpha("firebrick3",0.1),pch=16,
     xlim=c(-2,2.1), ylim=c(-2,2.1),xlab="log(Observed discharge (m3/s))",
     ylab="log(Model discharge (m3/s))")
title("a)",adj=0.05, line=-1.2, cex.main=1.5)
grid()
abline(0,1, lwd=2, col="darkgrey", lty=2)
legend("bottomright",legend="Growing",col="firebrick3",pch=16,bg="white")

# Non-growing
plot(log10(obs),log10(non),col=alpha("deepskyblue2",0.1),pch=16,
     xlim=c(-2,2.1), ylim=c(-2,2.1),xlab="log(Observed discharge (m3/s))",
     ylab="log(Model discharge (m3/s))")
grid()
abline(0,1, lwd=2, col="darkgrey", lty=2)
title("b)",adj=0.05, line=-1.2, cex.main=1.5)
legend("bottomright",legend="Non-gro.",col="deepskyblue2",pch=16,bg="white")

# NLCD
plot(log10(obs),log10(Flow_NLCD16),col=alpha("darkgoldenrod2",0.2),pch=16,
     xlim=c(-2,2.1), ylim=c(-2,2.1),xlab="log(Observed discharge (m3/s))",
     ylab="log(Model discharge (m3/s))")
grid()
abline(0,1, lwd=2, col="darkgrey", lty=2)
title("c)",adj=0.05, line=-1.2, cex.main=1.5)
legend("bottomright",legend="NLCD",col="darkgoldenrod2",pch=16,bg="white")


## Time series plot (10/1/2015 to 9/30/2016)
par(mar= c(3, 3, 1, 2) + 0.1, mgp=c(2,1,0)) # restore default margins
start <- "2015-10-01"
end <- "2016-09-30"

### Time series plot
plot(date,obs, type='n', xlim=c(as.Date(start, format="%Y-%m-%d"),as.Date(end, format="%Y-%m-%d")),
     ylim=c(0,22), xlab="Date (2016 water year)",
     ylab="Discharge (m3/s)")

grid()
lines(date,obs,col="darkgrey", lwd=4)
lines(date,Flow_NLCD16,col="darkgoldenrod2",lwd=1.5,lty=1)
lines(date,grow, col="firebrick3", lwd=1.5,lty=2)
lines(date,non, col="deepskyblue2", lwd=1.5, lty=3)
title("d)",adj=0.01, line=-1.2, cex.main=1.5)

# Add legend
legend("topright", inset=c(0.658,0),legend=c("Observed","Dyn. World 2016 growing", "Dyn. World 2016 non-gro.","NLCD 2016"), 
       lty=c(1,2,3,1), lwd=c(4,1.5,1.5,1.5), col=c("darkgrey","firebrick3","deepskyblue2","darkgoldenrod2"),bg="white")

# Stop printing
dev.off()
