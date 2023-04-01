# Hydrology results figure script
# Dan Myers, 10/25/2022

library(dplyr)
library(scales)

# Set working directory
setwd("R:/NPS_NCRN_VitalSigns/Data/GIS/Projects/AGU_study/Revision/Myers et al. Mendeley Data (revised)/Hydrologic analyses")
# setwd("C:/GIS/Projects/AGU_study/Revision/Myers et al. Mendeley Data (revised)/Hydrologic analyses")

### Step 1: Load data
# Load water quality data
medians_all <- read.csv("Water_quality_median_values_2005-2018_all_seasons.csv")

# Load LULC data
lulc_grow <- read.csv("Dynamic_World_LULC_percent_area_growing_season (revised 2023_02_09).csv")
lulc_non <- read.csv("Dynamic_World_LULC_percent_area_Nongrowing_season (revised 2023_02_09).csv")
nlcd <- read.csv("watersheds_nlcd16_stats (revised 2023_02_09).csv")


### Step 2: Create regression models
# Specific conductance
lm_SpeCond_growing <- lm(medians_all$Specific.conductance ~ lulc_grow$built) 
summary(lm_SpeCond_growing)
AIC(lm_SpeCond_growing)
round(confint(lm_SpeCond_growing,level=0.95),2)

lm_SpeCond_nongrowing <- lm(medians_all$Specific.conductance ~ lulc_non$built)
summary(lm_SpeCond_nongrowing)
AIC(lm_SpeCond_nongrowing)
round(confint(lm_SpeCond_nongrowing,level=0.95),2)

lm_nlcd <- lm(medians_all$Specific.conductance ~ nlcd$urb_tot_OLMH) 
summary(lm_nlcd)
AIC(lm_nlcd)
round(confint(lm_nlcd,level=0.95),2)


### Step 3: Make plots
# Start plots
windows(6.5,6.5)

# Layout
# nf <- layout(matrix(c(1,1,2, # top
#                       3,4,5, # middle
#                       6,6,6), # bottom
#                     nrow=3, ncol=3,byrow=TRUE))

nf <- layout(matrix(c(1,1,1,1,2,2, # top
                      1,1,1,1,2,2,
                      3,3,4,4,5,6, # middle
                      3,3,4,4,7,7,
                      8,8,8,8,8,8,
                      8,8,8,8,8,8), # bottom
                    nrow=6, ncol=6,byrow=TRUE))

## Specific conductance

# Set margins
par(mar=c(3,3,2,2) + 0.1, mgp=c(2,1,0))
# Growing season points
plot(lulc_grow$built, medians_all$Specific.conductance, type="n",
     xlab = "Built or developed landuse (%)", ylab="Specific conductance (uS/cm)",
     ylim=c(-100,900))
grid()
points(lulc_grow$built, medians_all$Specific.conductance,col="firebrick3")
title("a)",adj=0.02, line=-1.2, cex.main=1.5)

# Nongrowing season points
points(lulc_non$built, medians_all$Specific.conductance, col="deepskyblue2")

# NLCD 2016 points
points(nlcd$urb_tot_OLMH, medians_all$Specific.conductance, col="gold")

# Legend
legend("bottomright",legend=c("Dyn. World 2016 growing", "Dyn. World 2016 non-gro.", "NLCD 2016"), col=c("firebrick3", "deepskyblue2","gold"),pch=1,
       bg="white",y.intersp=0.9)


## Plot 95% confidence intervals
# Growing
x=lulc_grow$built
model= lm_SpeCond_growing
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="firebrick3",lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="firebrick3",lty=3,lwd=0.5)

# Nongrowing
x=lulc_non$built
model= lm_SpeCond_nongrowing
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="deepskyblue2",lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="deepskyblue2",lty=3,lwd=0.5)

# NLCD
x=nlcd$urb_tot_OLMH
model= lm_nlcd
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="gold",lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="gold",lty=3,lwd=0.5)

# Add models
lines((lulc_grow$built), lm_SpeCond_growing$fitted.values, col="firebrick3") 
lines((lulc_non$built), lm_SpeCond_nongrowing$fitted.values, col="deepskyblue2")
lines((nlcd$urb_tot_OLMH), lm_nlcd$fitted.values, col="gold")



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
par(mar=c(3,3,2,2) + 0.1, mgp=c(2,1,0))
plot(obs_Q[!is.na(obs_Q)], rch_nlcd_Q[!is.na(obs_Q)],xlim=c(0,10.5), ylim=c(0,10.5),pch=c(1),col="gold",
     xlab="Observed (m3/s)", 
     ylab="Model (m3/s)")
grid()
points(obs_Q[!is.na(obs_Q)], rch_n_Q[!is.na(obs_Q)],col="deepskyblue2", pch=c(1))
points(obs_Q[!is.na(obs_Q)], rch_g_Q[!is.na(obs_Q)],col="firebrick3", pch=c(1))
abline(0,1, lwd=2,col="darkgrey",lty=2)
# legend("bottomright",c("Grow.(C)", "Grow.(V)", "Non-g.(C)", "Non-g.(V)", "NLCD (C)", "NLCD (V)"), pch=c(1),
#        col=c("firebrick3","firebrick3","deepskyblue2","deepskyblue2","gold","gold"), bg="white")
title("b)",adj=0.03, line=-1.2, cex.main=1.5)

# Make scatterplots (N)
plot(obs_N[!is.na(obs_N)], rch_nlcd_N[!is.na(obs_N)],xlim=c(0,15000), ylim=c(0,15000),pch=c(1),col="gold",
     xlab="Observed (kg N/month)", 
     ylab="Model (kg N/month)")
grid()
points(obs_N[!is.na(obs_N)], rch_n_N[!is.na(obs_N)],col="deepskyblue2", pch=c(1))
points(obs_N[!is.na(obs_N)], rch_g_N[!is.na(obs_N)],col="firebrick3", pch=c(1))
abline(0,1, lwd=2,col="darkgrey",lty=2)
title("c)",adj=0.03, line=-1.2, cex.main=1.5)


### Rock Creek barchart
# Calculate average annual nitrate yield
N_yield_g <- sum(rch_g_N) / 9 # 9 years
N_yield_n <- sum(rch_n_N) / 9 # 9 years
N_yield_nlcd <- sum(rch_nlcd_N) / 9 # 9 years

# Place in data frame
data1 <- data.frame(model=c("Dyn. World\ngrowing","Dyn. World\nnon-growing","NLCD"), 
                    Nyield = c(N_yield_g, N_yield_n, N_yield_nlcd) / 1000) # Since y axis unit is 1000 kg

# Make barplot
par(mar=c(3,3.5,2,2) + 0.1, mgp=c(2.5,1,0))
barplot(data1$Nyield ~ data1$model, xlab="", ylim=c(0,115),
        ylab="Annual N yield (*1000 kg)",col=c("firebrick3","deepskyblue2","gold"),las=2)
grid()
barplot(data1$Nyield ~ data1$model, xlab="",
        ylab="Annual N yield (*1000 kg)",col=c("firebrick3","deepskyblue2","gold"),las=2,add=T)
title("d)",adj=0.03, line=-1.2, cex.main=1.5)
box()

## Difficult Run results
# Load data
data1 <- read.csv("obs_sim_data (revised).csv")
obs <- round(data1$Flow_cms_obs,2) 
grow <- round(data1$Flow_growing,2) 
non <- round(data1$Flow_nongrowing,2) 
Flow_NLCD16 <- round(data1$Flow_NLCD16,2)
date <- as.Date(data1$Date, format="%m/%d/%Y")



### Obs/sim plots
# Growing
par(mar=c(1,3,2,0)+0.1, mgp=c(2,1,0)) # bottom, left, top, right
plot(log10(obs), log10(grow), col=alpha("firebrick3",1),pch=1,
     xlim=c(-2,2.1), ylim=c(-2,2.1),xaxt='n',
     ylab="log(Model (m3/s))")
title("e)",adj=0.05, line=-1.2, cex.main=1.5)
grid()
abline(0,1, lwd=2, col="darkgrey", lty=2)

# Non-growing
par(mar=c(1,1,2,2)+0.1) # bottom, left, top, right
plot(log10(obs),log10(non),col=alpha("deepskyblue2",1),pch=1,
     xlim=c(-2,2.1), ylim=c(-2,2.1),yaxt='n')
grid()
abline(0,1, lwd=2, col="darkgrey", lty=2)

# NLCD
par(mar=c(3,3,0,8)+0.1,mgp=c(2,1,0)) # bottom, left, top, right
plot(log10(obs),log10(Flow_NLCD16),col=alpha("gold",1),pch=1,
     xlim=c(-2,2.1), ylim=c(-2,2.1),xlab="log(Observed (m3/s))",ylab="")
grid()
abline(0,1, lwd=2, col="darkgrey", lty=2)

# Add legend
par(xpd=NA) # Allow plotting outside figure area
# legend("right",legend=c("Grow.", "Non-g.", "NLCD"), col=c("firebrick3", "deepskyblue2","gold"),pch=1,
#        bg="white",inset=c(-1,0))


# Time series plot (10/1/2015 to 9/30/2016)
par(mar= c(3, 3, 3, 2) + 0.1, mgp=c(2,1,0),xpd=FALSE) # restore default margins
start <- "2015-10-01"
end <- "2016-09-30"

### Time series plot
plot(date,obs, type='n', xlim=c(as.Date(start, format="%Y-%m-%d"),as.Date(end, format="%Y-%m-%d")),
     ylim=c(0,24), xlab="Date (2016 water year)",
     ylab="Discharge (m3/s)")
# axis(1,c(as.Date("2016-03-01", format="%Y-%m-%d"), as.Date("2016-04-01", format="%Y-%m-%d"),
#          as.Date("2016-05-01", format="%Y-%m-%d"), as.Date("2016-06-01", format="%Y-%m-%d")),
#      format("%m-%Y"),at=c(as.Date("2016-03-01", format="%Y-%m-%d"), as.Date("2016-04-01", format="%Y-%m-%d"),
#                           as.Date("2016-05-01", format="%Y-%m-%d"), as.Date("2016-06-01", format="%Y-%m-%d")))
grid()
lines(date,obs,col="grey", lwd=1)
lines(date,Flow_NLCD16,col="darkgoldenrod2",lwd=1,lty=1)
lines(date,grow, col="red", lwd=1,lty=2)
lines(date,non, col="blue", lwd=1, lty=3)
title("f)",adj=0.01, line=-1.2, cex.main=1.5)

# Add legend
legend("topright", inset=c(0.658,0),legend=c("Observed","Dyn. World 2016 growing", "Dyn. World 2016 non-gro.","NLCD 2016"), 
       lty=c(1,2,3,1), lwd=c(1,1,1,1), col=c("darkgrey","red","blue","darkgoldenrod2"),bg="white")