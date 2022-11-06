# Hydrology results figure script
# Dan Myers, 10/25/2022

# Set working directory
setwd("C:/GIS/Projects/AGU_study/Myers et al. Mendeley Data/Hydrologic analyses")

### Step 1: Load data
# Load water quality data
medians_all <- read.csv("Water_quality_median_values_2005-2018_all_seasons.csv")

# Load LULC data
lulc_grow <- read.csv("Dynamic_World_LULC_percent_area_growing_season.csv")
lulc_non <- read.csv("Dynamic_World_LULC_percent_area_Nongrowing_season.csv")
nlcd <- read.csv("watersheds_nlcd16_stats.csv")


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
windows(8.5,10)

# Layout
nf <- layout(matrix(c(1,1,2, # top
                      3,4,5, # middle
                      6,6,6), # bottom
                    nrow=3, ncol=3,byrow=TRUE))

## Specific conductance
# Growing season points
plot(lulc_grow$built, medians_all$Specific.conductance, type="n",
     xlab = "Built or developed landuse (%)", ylab="Specific conductance (uS/cm)",
     ylim=c(0,1050))
grid()
points(lulc_grow$built, medians_all$Specific.conductance,col="red")
title("a)",adj=0, cex.main=2)

# Nongrowing season points
points(lulc_non$built, medians_all$Specific.conductance, col="blue")

# NLCD 2016 points
points(nlcd$urb_tot_OLMH, medians_all$Specific.conductance, col="gold")

# Legend
legend("topleft",legend=c("Growing Season", "Non-growing Season", "NLCD"), col=c("red", "blue","gold"),pch=1,
       bg="white")


## Plot 95% confidence intervals
# Growing
x=lulc_grow$built
model= lm_SpeCond_growing
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col=2,lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col=2,lty=3,lwd=0.5)

# Nongrowing
x=lulc_non$built
model= lm_SpeCond_nongrowing
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="blue",lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="blue",lty=3,lwd=0.5)

# NLCD
x=nlcd$urb_tot_OLMH
model= lm_nlcd
pr <- predict(model, interval='confidence')
xpr <- data.frame(x=x,pr=pr) %>% arrange(x)
lines(xpr$x, xpr$pr.lwr,col="gold",lty=3,lwd=0.5)
lines(xpr$x, xpr$pr.upr,col="gold",lty=3,lwd=0.5)

# Add models
lines((lulc_grow$built), lm_SpeCond_growing$fitted.values, col="red") 
lines((lulc_non$built), lm_SpeCond_nongrowing$fitted.values, col="blue")
lines((nlcd$urb_tot_OLMH), lm_nlcd$fitted.values, col="gold")

## MONO BUCK barcharts
data1 <- data.frame(model=c("Dyn. World\ngrowing","Dyn. World\nnon-growing","NLCD"), 
                    surfQmm = c(242.59, 289.58,307.07),
                    Nyield_kgHa = c(0.753, 1.139,2.847),
                    SOPyield_kgHa = c(0.053, 0.075,0.209))

# Make barplots
# Runoff
barplot(data1$surfQmm ~ data1$model, xlab="",
        ylab="Surface runoff (mm)",col=c("firebrick3","deepskyblue2","gold"),las=2)
grid()
barplot(data1$surfQmm ~ data1$model, xlab="",
        ylab="Surface runoff (mm)",col=c("firebrick3","deepskyblue2","gold"),las=2,add=T)
title("b)",adj=0, cex.main=2)

# Nitrate yield
barplot(data1$Nyield_kgHa ~ data1$model, xlab="",
        ylab="Nitrate yield (kg N/ha)",col=c("firebrick3","deepskyblue2","gold"),las=2)
grid()
barplot(data1$Nyield_kgHa ~ data1$model, xlab="",
        ylab="Nitrate yield (kg N/ha)",col=c("firebrick3","deepskyblue2","gold"),las=2,add=T)

title("c)",adj=0, cex.main=2)

# SOP yield
barplot(data1$SOPyield_kgHa ~ data1$model, xlab="",
        ylab="Soluble phosphorus yield (kg P/ha)",col=c("firebrick3","deepskyblue2","gold"),las=2)
grid()
barplot(data1$SOPyield_kgHa ~ data1$model, xlab="",
        ylab="Soluble phosphorus yield (kg P/ha)",col=c("firebrick3","deepskyblue2","gold"),las=2,add=T)
title("d)",adj=0, cex.main=2)


## Calibrated results

# Load data
data1 <- read.csv("obs_sim_data.csv")
obs <- data1$Flow_cms_obs
grow <- data1$Flow_growing
non <- data1$Flow_nongrowing
Flow_NLCD16 <- data1$Flow_NLCD16
date <- as.Date(data1$Date, format="%m/%d/%Y")

### Obs/sim plot
plot(log(obs), log(grow), col="red",xlab="log(Observed data (cms))",
     ylab="log(Model result (cms))",pch=20)
title("e)",adj=0, cex.main=2)
grid()
points(log(obs),log(non),col="blue",pch=20)
points(log(obs),log(Flow_NLCD16),col="gold",pch=20)
abline(0,1, lwd=2, col="darkgrey", lty=2)
legend("bottomright",legend=c("Grow.","Non-g.","NLCD"), col=c("red","blue","gold"), pch=16,bg="white")

# Plot it (10/1/2015 to 9/30/2016)
start <- "2015-10-01"
end <- "2016-09-30"

### Time series plot
plot(date,obs, type='n', xlim=c(as.Date(start, format="%Y-%m-%d"),as.Date(end, format="%Y-%m-%d")),
     ylim=c(0,30), xlab="Date (2016 water year)",
     ylab="Discharge (cms)")
grid()
lines(date,obs,col="black", lwd=4)
lines(date,grow, col="red", lwd=3)
lines(date,non, col="blue", lwd=3, lty=2)
lines(date,Flow_NLCD16,col="gold",lwd=3,lty=3)
title("f)",adj=0, cex.main=2)

# Add legend
legend("topleft", legend=c("Observed","Growing season model", "Non-grow. season model","NLCD model"), 
       lty=c(1,1,2,3), lwd=c(4,3,3,3), col=c("black","red","blue","gold"),bg="white")
