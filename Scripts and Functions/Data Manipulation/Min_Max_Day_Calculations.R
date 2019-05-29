# Min Max Days Calculations

packages <- c("data.table","ggplot2", "grid", "gridExtra","ggvis", "abind", "scales")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

setwd("/home/accon/GIZ/MAy/Data/")
wd_load <- "Demand/Courbes de charge_LoadProfile_2010.csv"
wd_feed_in <- "Feed-in-Profiles/Tunisia_Wind_PV_Feed-in_Series_synthesized_2014.csv"
seasons <- c("winter", "intermediary", "summer", "ramadan")

#Input of data
load_raw <- read.csv(wd_load, skip=1, header=TRUE)
feed_in_raw <- read.csv(wd_feed_in, skip=2, header=TRUE)

load_w_day <- cbind(load_raw, c(1:365))
vec_winter <- vector(length=365)
vec_winter[which(load_raw$mois %in% c(1,2) | (load_raw$mois == 3 & load_raw$jour < 21) | 
                   (load_raw$mois == 12 & load_raw$jour >= 21))] <- "winter"
vec_intermediary <- vector(length=365)
vec_intermediary[which(load_raw$mois %in% c(4,5,10,11) | (load_raw$mois == 3 & load_raw$jour >= 21) | 
                   (load_raw$mois == 6 & load_raw$jour < 21) | (load_raw$mois == 9 & load_raw$jour >= 21) |
                     (load_raw$mois == 12 & load_raw$jour < 21))] <- "intermediary"
vec_summer <- vector(length=365)
vec_summer[which(load_raw$mois %in% c(7) | (load_raw$mois == 6 & load_raw$jour >= 21) | 
                         (load_raw$mois == 8 & load_raw$jour < 10) | 
                   (load_raw$mois == 9 & load_raw$jour > 9 & load_raw$jour < 21))] <- "summer"
vec_ramadan <- vector(length=365)
vec_ramadan[which((load_raw$mois == 8 & load_raw$jour >= 10) | 
                   (load_raw$mois == 9 & load_raw$jour <= 9))] <- "ramadan"
vec_season <- vector(length=365)
vec_season[which(vec_winter != "FALSE")] <- vec_winter[which(vec_winter != "FALSE")]
vec_season[which(vec_intermediary != "FALSE")] <- vec_intermediary[which(vec_intermediary != "FALSE")]
vec_season[which(vec_summer != "FALSE")] <- vec_summer[which(vec_summer != "FALSE")]
vec_season[which(vec_ramadan != "FALSE")] <- vec_ramadan[which(vec_ramadan != "FALSE")]

load_w_season <- cbind(load_w_day, vec_season)
df_data_season <- load_w_season[which(load_w_season$jour <= 28), c("mois", "jour", "vec_season")]
dt_data_season <- as.data.table(df_data_season)

plot_season <- ggplot(data=dt_data_season, aes(x=mois, y=jour, fill=factor(vec_season)))
plot_season <- plot_season + geom_tile(color="black", size=0.5)
plot_season <- plot_season + scale_x_continuous("Months", breaks=seq(0,12,2))
plot_season <- plot_season + scale_y_continuous("Days of Months", breaks=c(seq(0,25,5), 28))
plot_season <- plot_season + scale_fill_discrete(name="Seasons")
plot_season <- plot_season + ggtitle("Depiction of Season Allocation")
plot_season <- plot_season + theme (axis.text = element_text(size=14), 
                                    axis.title = element_text(size=16, face="bold"),
                                    legend.text= element_text(size=14),
                                    legend.title = element_text(size=14, face="bold"),
                                    plot.title = element_text(size=18, face="bold"))
dev.new()
plot(plot_season)

png("Time/Seasons_TN_2010.png",width=500, height=500)
plot(plot_season)
dev.off()

mat_pjour_winter <- load_w_season[which(load_w_season$vec_season == "winter"), 
                                  c("mois", "jour", "P.jour", "c(1:365)", "vec_season")]
vec_max_winter <- vector(length=nrow(mat_pjour_winter))
vec_max_winter[which(mat_pjour_winter$P.jour == max(mat_pjour_winter$P.jour))] <- 1
mat_pjour_max_winter <- cbind(mat_pjour_winter, vec_max_winter)

mat_pjour_intermediary <- load_w_season[which(load_w_season$vec_season == "intermediary"), 
                                  c("mois", "jour", "P.jour", "c(1:365)", "vec_season")]
vec_max_intermediary <- vector(length=nrow(mat_pjour_intermediary))
vec_max_intermediary[which(mat_pjour_intermediary$P.jour == max(mat_pjour_intermediary$P.jour))] <- 1
mat_pjour_max_intermediary <- cbind(mat_pjour_intermediary, vec_max_intermediary)

mat_pjour_summer <- load_w_season[which(load_w_season$vec_season == "summer"), 
                                  c("mois", "jour", "P.jour", "c(1:365)", "vec_season")]
vec_max_summer <- vector(length=nrow(mat_pjour_summer))
vec_max_summer[which(mat_pjour_summer$P.jour == max(mat_pjour_summer$P.jour))] <- 1
mat_pjour_max_summer <- cbind(mat_pjour_summer, vec_max_summer)

mat_pjour_ramadan <- load_w_season[which(load_w_season$vec_season == "ramadan"), 
                                  c("mois", "jour", "P.jour", "c(1:365)", "vec_season")]
vec_max_ramadan <- vector(length=nrow(mat_pjour_ramadan))
vec_max_ramadan[which(mat_pjour_ramadan$P.jour == max(mat_pjour_ramadan$P.jour))] <- 1
mat_pjour_max_ramadan <- cbind(mat_pjour_ramadan, vec_max_ramadan)

vec_pjour_max_season <- vector(length=365)
load_pjour_max_season <- cbind(load_w_season, vec_pjour_max_season)
load_pjour_max_season[which(load_pjour_max_season$vec_season == "winter"), "vec_pjour_max_season"] <- 
  vec_max_winter

load_pjour_max_season[which(load_pjour_max_season$vec_season == "intermediary"), "vec_pjour_max_season"] <- 
  vec_max_intermediary

load_pjour_max_season[which(load_pjour_max_season$vec_season == "summer"), "vec_pjour_max_season"] <- 
  vec_max_summer

load_pjour_max_season[which(load_pjour_max_season$vec_season == "ramadan"), "vec_pjour_max_season"] <- 
  vec_max_ramadan

peak_load_days_in_season_full <- load_pjour_max_season[which(load_pjour_max_season$vec_pjour_max_season == 1),]
peak_load_days_in_season <- load_pjour_max_season[which(load_pjour_max_season$vec_pjour_max_season == 1),
                                                       c("mois", "jour", "Creux", "P.jour", "Psoir", "c(1:365)", 
                                                         "vec_season")]
write.csv(peak_load_days_in_season_full, file="Demand/Peak_Load_Days_in_Seasons_full.csv", row.names=F)
write.csv(peak_load_days_in_season, file="Demand/Peak_Load_Days_in_Seasons.csv", row.names=F)

#---Normalized Profiles---
wd_load <- "Demand/TN_hourly_electricity_demand_series_2010_corrected.csv"
wd_feed_in <- "Feed-in-Profiles/Tunisia_Wind_PV_Feed-in_Series_synthesized_2014.csv"

#Input of data
load_raw <- read.csv(wd_load, header=TRUE)
feed_in_raw <- read.csv(wd_feed_in, skip=2, header=TRUE)
feed_in <- feed_in_raw[c(2:nrow(feed_in_raw)), c("local_time", "STEG..2017.", "STEG..2017..1")]

mat_indices_seasons_start <- matrix(0, nrow=1, ncol=4)
colnames(mat_indices_seasons_start) <- seasons

mat_indices_seasons_start[1,1] <- which(load_raw$vec_timestamp == "2010-12-28 01:00")
mat_indices_seasons_start[1,2] <- which(load_raw$vec_timestamp == "2010-06-10 01:00")
mat_indices_seasons_start[1,3] <- which(load_raw$vec_timestamp == "2010-07-23 01:00")
mat_indices_seasons_start[1,4] <- which(load_raw$vec_timestamp == "2010-08-20 01:00")

mat_indices_days <- sapply(mat_indices_seasons_start, function(x) c(x:(x+23)))
mat_indices_3days <- sapply(mat_indices_seasons_start, function(x) c((x-24):(x+47)))

# Choosing Peak Demand Days in each season and normalizing
mat_load_values_days <- apply(mat_indices_days, MARGIN=2, function(x) load_raw$vec_load_values[x])
mat_load_values_days_normalized <- mat_load_values_days / sum(mat_load_values_days)
colnames(mat_load_values_days_normalized) <- seasons
mat_load_values_days_sum <- sum(mat_load_values_days) # --> write to file 
# Calculating Electricity Demand in Modeling Window over Annual Electricity Demand
load_factor_days <- mat_load_values_days_sum / sum(load_raw$vec_load_values)
vec_load_values_days <- sort(as.vector(mat_load_values_days), decreasing=TRUE)

mat_load_values_3days <- apply(mat_indices_3days, MARGIN=2, function(x) load_raw$vec_load_values[x])
mat_load_values_3days_normalized <- mat_load_values_3days / sum(mat_load_values_3days)
colnames(mat_load_values_3days_normalized) <- seasons
mat_load_values_3days_sum <- sum(mat_load_values_3days) # --> write to file
# Calculating Electricity Demand in Modeling Window over Annual Electricity Demand
load_factor_3days <- mat_load_values_3days_sum / sum(load_raw$vec_load_values)
vec_load_values_3days <- sort(as.vector(mat_load_values_3days), decreasing=TRUE)

mat_pv_feed_in_days <- apply(mat_indices_days, MARGIN=2, function(x) feed_in$STEG..2017..1[x])
mat_pv_feed_in_3days <- apply(mat_indices_3days, MARGIN=2, function(x) feed_in$STEG..2017..1[x])

mat_wind_feed_in_days <- apply(mat_indices_days, MARGIN=2, function(x) feed_in$STEG..2017.[x])
mat_wind_feed_in_3days <- apply(mat_indices_3days, MARGIN=2, function(x) feed_in$STEG..2017.[x])

# Plotting Load Duration Curve and Feed-in Duration Curve 
arr_4days <- abind(mat_load_values_days_normalized, mat_pv_feed_in_days, mat_wind_feed_in_days, along=3)
dimnames(arr_4days)[c(3)] <- list(c("Load", "PV", "Wind"))
arr_12days <- abind(mat_load_values_3days_normalized, mat_pv_feed_in_3days, mat_wind_feed_in_3days, along=3)
dimnames(arr_12days)[c(3)] <- list(c("Load", "PV", "Wind"))
mat_4days <- apply(arr_4days, MARGIN=3, function(x) sort(as.vector(x), decreasing=TRUE))
mat_12days <- apply(arr_12days, MARGIN=3, function(x) sort(as.vector(x), decreasing=TRUE))

dt_series_4days_raw <- melt(mat_4days)
dt_series_4days_raw$value[c(1:96)] <- vec_load_values_days
dt_series_12days_raw <- melt(mat_12days)
dt_series_12days_raw$value[c(1:288)] <- vec_load_values_3days 
dt_series_4days <- cbind(dt_series_4days_raw, c("1 Day"), rep(c(1:96),3))
colnames(dt_series_4days)[4:5] <- c("Number_of_Days", "No_of_TimeSlice")
dt_series_12days <- cbind(dt_series_12days_raw, c("3 Days"), rep(c(1:288),3))
colnames(dt_series_12days)[4:5] <- c("Number_of_Days", "No_of_TimeSlice")
dt_series_4d_12d <- rbind(dt_series_4days, dt_series_12days)
dt_load_2010_raw <- dt_load[which(dt_load$Var2 == 2010),] 
dt_load_2010 <- cbind(dt_load_2010_raw[,c(1:3)],c("All Days"), dt_load_2010_raw[,c(4)])
colnames(dt_load_2010)[4:5] <- c("Number_of_Days", "No_of_TimeSlice")
dt_load_2010$Var2 <- as.factor(c("Load"))
dt_pv_2014_raw <- data_feed_in_dt[which(data_feed_in_dt$Var2 == "PV_Based_on_STEG_2017"),]
dt_pv_2014 <- cbind(dt_pv_2014_raw[,c(1:3)],c("All Days"), dt_pv_2014_raw[,c(4)])
colnames(dt_pv_2014)[4:5] <- c("Number_of_Days", "No_of_TimeSlice")
dt_pv_2014$Var2 <- as.factor(c("PV"))
dt_wind_2014_raw <- data_feed_in_dt[which(data_feed_in_dt$Var2 == "Wind_Based_on_STEG_2017"),]
dt_wind_2014 <- cbind(dt_wind_2014_raw[,c(1:3)],c("All Days"), dt_wind_2014_raw[,c(4)])
colnames(dt_wind_2014)[4:5] <- c("Number_of_Days", "No_of_TimeSlice")
dt_wind_2014$Var2 <- as.factor(c("Wind"))
dt_series <- rbind(dt_series_4d_12d, dt_load_2010, dt_pv_2014, dt_wind_2014)

#dt_series$No_of_TimeSlice <- as.factor(dt_series$No_of_TimeSlice)


plot_series <- ggplot(data=dt_series, aes(x=No_of_TimeSlice, y=value))
plot_series <- plot_series + geom_line(position="identity", stat="identity")
plot_series <- plot_series + facet_grid(Var2~Number_of_Days , scale="free")
plot_series <- plot_series + ylab("Normalized for PV and Wind, absolute (MW) for Load")
plot_series <- plot_series + xlab("Modelling Year")
#plot_series <- plot_series + scale_x_continuous("TimeSlices", breaks=seq(0,12,2))
#plot_series <- plot_series + scale_y_continuous("Capacity Factor", breaks=c(seq(0,25,5), 28))
#plot_series <- plot_series + scale_linetype_discrete(name="")
plot_series <- plot_series + ggtitle("Load, PV and Wind Feed-in")
plot_series <- plot_series + theme (axis.text = element_text(size=14), 
                                    axis.title = element_text(size=16, face="bold"),
                                    legend.text= element_text(size=14),
                                    legend.title = element_text(size=14, face="bold"),
                                    plot.title = element_text(size=18, face="bold"),
                                    strip.text.x=element_text(size=12),
                                    strip.text.y=element_text(size=12))
png("Demand/Duration_Curves_3D_12D_AllD_TN.png",width=1000, height=500)
plot(plot_series)
dev.off()

write.csv(mat_load_values_days_normalized, file="Demand/Load_Profile_Peak_Days_Per_Season_normalized.csv", row.names=F)
write.csv(mat_load_values_days_sums, file="Demand/Load_Sums_Peak_Days_Per_Season__MW.csv", row.names=F)
write.csv(mat_load_values_3days_normalized, file="Demand/Load_Profile_3_Peak_Days_Per_Season_normalized.csv", row.names=F)
write.csv(mat_load_values_3days_sums, file="Demand/Load_Sums_3_Peak_Days_Per_Season__MW.csv", row.names=F)
write.csv(mat_pv_feed_in_days, file="Feed-in-Profiles/PV_Feed_in_Capacity_Factors_4_Peak_Load_Days.csv", row.names=F)
write.csv(mat_pv_feed_in_3days, file="Feed-in-Profiles/PV_Feed_in_Capacity_Factors_Peak_Load_3Days.csv", row.names=F)
write.csv(mat_wind_feed_in_days, file="Feed-in-Profiles/Wind_Feed_in_Capacity_Factors_4_Peak_Load_Days.csv", row.names=F)
write.csv(mat_wind_feed_in_3days, file="Feed-in-Profiles/Wind_Feed_in_Capacity_Factors_Peak_Load_3Days.csv", row.names=F)