# HRUs charts
# Dan Myers, 4/6/2024

# Load packages
library(openxlsx)
library(tidyr)
library(dplyr)
library(FedData) # For NLCD legend

# Read data
DIRUgrow <- read.xlsx("HRUs.xlsx", sheet="DIRUgrow")
DIRUnon <- read.xlsx("HRUs.xlsx", sheet="DIRUnon")
DIRUnlcd <- read.xlsx("HRUs.xlsx", sheet="DIRUnlcd")
ROCRgrow <- read.xlsx("HRUs.xlsx", sheet="ROCRgrow")
ROCRnon <- read.xlsx("HRUs.xlsx", sheet="ROCRnon")
ROCRnlcd <- read.xlsx("HRUs.xlsx", sheet="ROCRnlcd")

# Format for barplots
dg <- DIRUgrow %>%
  group_by(ID) %>%
  summarise(pct = sum(pct_shed,na.rm=T))

dn <- DIRUnon %>%
  group_by(ID) %>%
  summarise(pct = sum(pct_shed,na.rm=T))

dnl <- DIRUnlcd %>%
  group_by(ID) %>%
  summarise(pct = sum(pct_shed,na.rm=T))

rg <- ROCRgrow %>%
  group_by(ID) %>%
  summarise(pct = sum(pct_shed,na.rm=T))

rn <- ROCRnon %>%
  group_by(ID) %>%
  summarise(pct = sum(pct_shed,na.rm=T))

rnl <- ROCRnlcd %>%
  group_by(ID) %>%
  summarise(pct = sum(pct_shed,na.rm=T))

# Make DW barplots
windows(6.5,6.5)
par(mfrow=c(2,1),mgp=c(2,1,0),mar=c(3,3,1,1))
y <- c(rg$pct, rn$pct, dg$pct[c(1,5)],dn$pct[c(1,5)])
x <- c(rg$ID, rn$ID, dg$ID[c(1,5)],dn$ID[c(1,5)])
cols <- rep(c("#397D49","darkgrey"),times=4)

barplot(y, names.arg=x,col=cols, ylab="HRU area (% watershed)",xaxt="n",
        space=c(0,0,1,0,3,0,1,0),ylim=c(0,100))
grid()
barplot(y, names.arg=x,col=cols, ylab="HRU area (% watershed)",xaxt="n",
        space=c(0,0,1,0,3,0,1,0),ylim=c(0,100),add=T)
axis(1, at=c(2.5,10.5), labels = c("     Growing          Non-growing\nRock Creek",
                              "     Growing          Non-growing\nDifficult Run"),
     tick=F)
box()
legend("topright",legend=c("Trees","Built area"), fill=c("#397D49","darkgrey"),bg="white",
       title="Dynamic World 2016")
title("a)",adj=0.02, line=-1.2, cex.main=1.5)

# Make NLCD barplot
y2 <- c(rnl$pct, dnl$pct)
x2 <- c(rnl$ID, dnl$ID)
y2 <- y2[x2 %in% c(21:24,41:43)]
x2 <- x2[x2 %in% c(21:24,41:43)]
cols2 <- left_join(data.frame(ID=x2),pal_nlcd(),by="ID")$Color
names2 <- left_join(data.frame(ID=x2),pal_nlcd(),by="ID")$Class

barplot(y2, names.arg=x2, col=cols2, ylab="HRU area (% watershed)",xaxt="n", ylim=c(0,65),
        space=c(rep(0,5),3,rep(0,6)))
grid()
barplot(y2, names.arg=x2, col=cols2, ylab="HRU area (% watershed)",xaxt="n", ylim=c(0,65),
        space=c(rep(0,5),3,rep(0,6)), add=T)
axis(1, at=c(2.5,11.5), labels = c("Rock Creek", "Difficult Run"),tick=F)
box()
legend("topright",legend=c("Developed, Open Space","Developed, Low Intensity",
                           "Developed, Medium Intensity","Developed High Intensity",
                           "Deciduous Forest","Evergreen Forest","Mixed Forest"),
       fill=c("#E8D1D1","#E29E8C","#ff0000","#B50000","#85C77E","#38814E","#D4E7B0"),
       bg="white",cex=0.75, title="NLCD 2016")
title("b)",adj=0.02, line=-1.2, cex.main=1.5)