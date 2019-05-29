# Load Duration Curves for TN
#------Introduction -----------------------
packages <- c("data.table","ggplot2", "grid", "gridExtra","ggvis", "abind")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

setwd("/home/accon/GIZ/MAy/Data/")
wd_load_08 <- "Demand/TN_hourly_electricity_demand_series_2008_corrected.csv"
wd_load_09 <- "Demand/TN_hourly_electricity_demand_series_2009_corrected.csv"
wd_load_10 <- "Demand/TN_hourly_electricity_demand_series_2010_corrected.csv"
wd_feed_in <- "Feed-in-Profiles/Tunisia_Wind_PV_Feed-in_Series_synthesized_2014.csv"

#------Input of data-------
load_08_raw <- read.csv(wd_load_08, header=TRUE)
load_09_raw <- read.csv(wd_load_09, header=TRUE)
load_10_raw <- read.csv(wd_load_10, header=TRUE)
arr_load <- abind(load_08_raw, load_09_raw, load_10_raw, along=3)
dimnames(arr_load)[c(2:3)] <- list(c("vec_timestamp", "vec_load_values"),c("2008", "2009", "2010"))
feed_in_raw <- read.csv(wd_feed_in, skip=2, header=TRUE)
cnames_wind <- c("Wind_Based_on_STEG_2017", "Wind_Based_on_GIZ_2013")
cnames_pv <- c("PV_Based_on_STEG_2017", "PV_Based_on_GIZ_2013")

#------PV and Wind Feed-in Duration Curve Plotting -----------------------
feed_in <- feed_in_raw[-1,]
colnames(feed_in) <- c(colnames(feed_in_raw)[c(1,2)], cnames_wind, cnames_pv)
timestamps <- feed_in$local_time

data_feed_in <- feed_in[,c(3:6)]
data_feed_in_ordered <- sapply(data_feed_in, function(x) sort(x, decreasing=TRUE))
data_feed_in_dt <- cbind(melt(data_feed_in_ordered), rep(c(1:8760), 4))
colnames(data_feed_in_dt)[4] <- "Hours"

plot_ldc_PV_wind <- ggplot(data=data_feed_in_dt)
plot_ldc_PV_wind <- plot_ldc_PV_wind + geom_line(aes(x=Hours, y=value, colour=Var2))
plot_ldc_PV_wind <- plot_ldc_PV_wind + labs(x = "Hours of one year", y="PV and Wind Capacity Factors",
                                            col = "Technologies and Weighing of Profiles")
plot_ldc_PV_wind <- plot_ldc_PV_wind + scale_colour_manual(values=c("red", "green", "blue", "yellow"))
plot_ldc_PV_wind <- plot_ldc_PV_wind + ggtitle("Feed-in Duration Curves, PV and Wind, Tunisia, 2014, normalized")
plot_ldc_PV_wind <- plot_ldc_PV_wind + theme (axis.text = element_text(size=14), 
                                    axis.title = element_text(size=16, face="bold"),
                                    legend.text= element_text(size=14),
                                    legend.title = element_text(size=14, face="bold"),
                                    plot.title = element_text(size=18, face="bold"))
png("Feed-in-Profiles/PV_wind_Feed-in_Duration_Curve.png",width=1000, height=500)
plot(plot_ldc_PV_wind)
dev.off()

#------Load Duration Curve Plotting -----------------------
mat_load_ord <- matrix(NA, nrow=8760, ncol=3)
mat_load_ord[,1] <- sort(as.numeric(arr_load[,2,1]), decreasing=TRUE)
mat_load_ord[,2] <- sort(as.numeric(arr_load[,2,2]), decreasing=TRUE)
mat_load_ord[,3] <- sort(as.numeric(arr_load[,2,3]), decreasing=TRUE)
colnames(mat_load_ord) <- c(2008:2010)

#vec_load_ordered_corrected <- sort(load_raw_corrected$vec_load_values, decreasing=TRUE)
#df_load_ordered <- cbind(vec_load_ordered, vec_load_ordered_corrected)
#colnames(df_load_ordered) <- c("wrong", "corrected")
dt_load_raw <- melt(mat_load_ord)
dt_load <- cbind(dt_load_raw, rep(c(1:8760),3))
colnames(dt_load)[4] <- "Hours"
dt_load$Var2 <- factor(dt_load$Var2, levels=c(2010:2008))


plot_ldc_TN <- ggplot(data=dt_load)
plot_ldc_TN <- plot_ldc_TN + geom_line(aes(x=Hours, y=value, linetype=Var2))
plot_ldc_TN <- plot_ldc_TN + ggtitle("Load Duration Curve, Tunisia, 2008-2010")
plot_ldc_TN <- plot_ldc_TN + scale_x_continuous("Hours of the year 2010", breaks=seq(0,8760,1000))
plot_ldc_TN <- plot_ldc_TN + scale_y_continuous("Load Duration Curve in MW", breaks=c(seq(0,4000,500)))
plot_ldc_TN <- plot_ldc_TN + scale_linetype_discrete("Year")
plot_ldc_TN <- plot_ldc_TN + theme (axis.text = element_text(size=14), 
                                    axis.title = element_text(size=16, face="bold"),
                                    legend.text= element_text(size=14),
                                    legend.title = element_text(size=14, face="bold"),
                                    plot.title = element_text(size=18, face="bold"))
png("Demand/LDC_TN_08-10.png",width=1000, height=500)
plot(plot_ldc_TN)
dev.off()


#------Residual Load-------

# Installed capacities corresponding to the Tunisian Solar Plan (in MW) 
pv_instcap_2025 <- 947
wind_instcap_2025 <- 1305

vec_pv_feed_in_absolute <- pv_instcap_2025*feed_in$PV_Based_on_STEG_2017
vec_wind_feed_in_absolute <- wind_instcap_2025*feed_in$Wind_Based_on_STEG_2017
vec_residual_load <- as.numeric(arr_load[,"vec_load_values","2010"]) - (vec_pv_feed_in_absolute + vec_wind_feed_in_absolute)
#df_load_feed_in <- cbind(load_10_raw, vec_wind_feed_in_absolute, vec_pv_feed_in_absolute, vec_residual_load, 
#                         vec_day_raw) #vec day raw vector taken from LoadManipulations.R
df_load_feed_in <- cbind(sort(load_10_raw$vec_load_values_10, decreasing=TRUE), sort(vec_wind_feed_in_absolute, decreasing=TRUE), 
                         sort(vec_pv_feed_in_absolute, decreasing=TRUE), sort(vec_residual_load, decreasing = TRUE))
colnames(df_load_feed_in) <- c("National Load TN 2010", "Simulated Wind Feed-in, 2014/2025", 
                               "Simulated PV Feed-in, 2014/2025", "Modeled 'Residual Load'")
dt_dcs <- melt(df_load_feed_in) #dcs = duration curves
colnames(dt_dcs)[2] <- "Duration_Curves" 

# Rearranging order of factor levels for plotting
dt_dcs$Duration_Curves <- factor(dt_dcs$Duration_Curves, levels=unique(dt_dcs$Duration_Curves)[c(1,4,2,3)])

plot_residual_ldc <- ggplot(data=dt_dcs)
plot_residual_ldc <- plot_residual_ldc + geom_line(aes(x=Var1, y=value, linetype=Duration_Curves))
plot_residual_ldc <- plot_residual_ldc + scale_linetype_manual(values=c("solid", "twodash", "dotted", 
                                                                        "longdash"))
plot_residual_ldc <- plot_residual_ldc + labs(x = "Hours of one year", y= "LDC, absolute in MW",
                                            linetypes = "Load, Feed-in and Residual Load")
plot_residual_ldc <- plot_residual_ldc + ggtitle("Duration Curves for Feed-in (2014/2025) and Load (2010)")
plot_residual_ldc <- plot_residual_ldc + theme (axis.text = element_text(size=14), 
                                    axis.title = element_text(size=16, face="bold"),
                                    legend.text= element_text(size=14),
                                    legend.title = element_text(size=14, face="bold"),
                                    plot.title = element_text(size=18, face="bold"))
png("Demand/Modeled_Residual_Load_DC_TN_highres.png", width=1000, height=500)
plot(plot_residual_ldc)
dev.off()
png("Demand/Modeled_Residual_Load_DC_TN_lowres.png", width=600, height=300)
plot(plot_residual_ldc)
dev.off()


