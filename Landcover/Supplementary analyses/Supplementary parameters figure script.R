# Supplementary parameters figure script
# Dan Myers, 10/25/2022

library(dplyr)

# Set working directory
setwd("C:/GIS/Projects/AGU_study/Myers et al. Mendeley Data/Supplementary analyses")

# Load data
SOL_Ks <- read.csv("Top_50percent_models_optimized_SOL_K_parameters.csv", header=T)
solk_grow <- SOL_Ks$SOL_K_growing
solk_non <- SOL_Ks$SOL_K_nongrowing
solk_nlcd <- SOL_Ks$SOL_K_NLCD16

# Create data frame
solk_df <- data.frame(solk_grow, solk_non, solk_nlcd)

# Create box plot
windows(6,6)
par(mar=c(7,4,4,2)) # c(bottom, left, top, right)
boxplot(solk_df*100,xlab=NA, ylab="Optimized SOL_K (% adjustment)",xaxt="n",col=NA,
        border=NA,ylim=c(-25,25)) # Convert to %
grid()
boxplot(solk_df*100, add=T,xaxt="n")
axis(1, at=c(1,2,3),labels=c("Dyn. World\ngrowing", "Dyn. World\nnon-growing", "NLCD 1016"),las=2)
