# Plot Capital Expenditures of Wind, PV US and PV Dec


#------Introductory Section------

setwd("/home/accon/GIZ/MAy/Data/Economic_Data/")
wd_plots <- "/home/accon/GIZ/MAy/Data/Economic_Data/"

# Packages
packages <- c("data.table","ggplot2", "RColorBrewer", "grid", "gridExtra", "ggvis", "abind", "scales")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

# Initializing User-Defined-Functions (UDFs)
source("/home/accon/GIZ/MAy/R/functions/trim_data.R")


economic_data_raw <- read.csv("pp_cost_exchange_rates.csv", header=FALSE)
vec_colnames <- as.character(sapply(economic_data_raw[4,], function(x) as.character(x)))
capex_pv_us_raw <- economic_data_raw[c(165:216),]
capex_pv_dec_raw <- economic_data_raw[c(223:241),]
capex_wind_raw <- economic_data_raw[c(256:299),]
colnames(capex_pv_us_raw) <- as.character(vec_colnames)
colnames(capex_pv_dec_raw) <- as.character(vec_colnames)
colnames(capex_wind_raw) <- as.character(vec_colnames)

#------Preparing utility scale PV CAPEX plotting------
capex_pv_us <- capex_pv_us_raw[,c(2:4)]
capex_pv_us <- capex_pv_us[which(!is.na(capex_pv_us$`Investment cost / capex`) & 
                                   capex_pv_us$`Investment cost / capex` != ""),]
colnames(capex_pv_us) <- c("Year", "Region", "CAPEX")
capex_pv_us$CAPEX <- as.numeric(as.character(capex_pv_us$CAPEX))
dt_capex_pv_us <- melt(capex_pv_us)

#------Plotting CAPEX PV US------
plot_capex_pv_us <- ggplot(data=dt_capex_pv_us, aes(x=Year, y=value, color=Region)) +
  geom_point(size=8, shape=21, fill="white") +
  ylab("CAPEX in 2016-€/kW") +
  xlab("Year") +
  ggtitle("Literature Values of Capital Expenditures of Utility Scale PV") +
  theme (axis.text = element_text(size=14), 
      axis.title = element_text(size=16, face="bold"),
      legend.text= element_text(size=14),
      legend.title = element_text(size=14, face="bold"),
      plot.title = element_text(size=18, face="bold"))

#dev.new()
#plot(plot_capex_pv_us)
png(paste(wd_plots, "CAPEX_PV_US.png", sep=""), width=800, height=400)
plot(plot_capex_pv_us)
dev.off()


#------Preparing decentralized PV CAPEX plotting------
capex_pv_dec <- capex_pv_dec_raw[,c(2:4)]
capex_pv_dec <- capex_pv_dec[which(!is.na(capex_pv_dec$`Investment cost / capex`) & 
                                   capex_pv_dec$`Investment cost / capex` != ""),]
colnames(capex_pv_dec) <- c("Year", "Region", "CAPEX")
capex_pv_dec$CAPEX <- as.numeric(as.character(capex_pv_dec$CAPEX))
dt_capex_pv_dec <- melt(capex_pv_dec)

#------Plotting CAPEX PV decentralized------
plot_capex_pv_dec <- ggplot(data=dt_capex_pv_dec, aes(x=Year, y=value, color=Region)) +
  geom_point(size=8, shape=21, fill="white") +
  ylab("CAPEX in 2016-€/kW") +
  xlab("Year") +
  ggtitle("Literature Values of Capital Expenditures of Decentralized PV") +
  theme (axis.text = element_text(size=14), 
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=18, face="bold"))

#dev.new()
#plot(plot_capex_pv_dec)
png(paste(wd_plots, "CAPEX_PV_dec.png", sep=""), width=800, height=400)
plot(plot_capex_pv_dec)
dev.off()


#------Preparing Wind CAPEX plotting------
capex_wind <- capex_wind_raw[,c(2:4)]
capex_wind <- capex_wind[which(!is.na(capex_wind$`Investment cost / capex`) & 
                                     capex_wind$`Investment cost / capex` != ""),]
colnames(capex_wind) <- c("Year", "Region", "CAPEX")
capex_wind$CAPEX <- as.numeric(as.character(capex_wind$CAPEX))
dt_capex_wind <- melt(capex_wind)

#------Plotting CAPEX Wind Onshore------
plot_capex_wind <- ggplot(data=dt_capex_wind, aes(x=Year, y=value, color=Region)) +
  geom_point(size=8, shape=21, fill="white") +
  ylab("CAPEX in 2016-€/kW") +
  xlab("Year") +
  ggtitle("Literature Values of Capital Expenditures of Onshore Wind") +
  theme (axis.text = element_text(size=14), 
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=18, face="bold"))

dev.new()
plot(plot_capex_wind)
png(paste(wd_plots, "CAPEX_wind.png", sep=""), width=800, height=400)
plot(plot_capex_wind)
dev.off()
