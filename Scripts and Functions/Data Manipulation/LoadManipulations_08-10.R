#Load Manipulations

setwd("/home/accon/GIZ/MAy/Data/Demand/")
load_2008_raw <- read.csv("Courbes de charge_LoadProfile_2008.csv", skip=0, header=TRUE)
load_2008_comp <- load_2008_raw[-c(367:nrow(load_2008_raw)),]
load_2008 <- load_2008_comp[which(!(load_2008_comp$jour == 29 & load_2008_comp$mois == 2)),]
load_2009_raw <- read.csv("Courbes de charge_LoadProfile_2009.csv", skip=0, header=TRUE)
load_2009 <- load_2009_raw[-c(366:nrow(load_2009_raw)),]
load_2010_raw <- read.csv("Courbes de charge_LoadProfile_2010.csv", skip=1, header=TRUE)


vec_year_08 <- rep(load_2008$annee, each=24)
vec_year_09 <- rep(load_2009$annee, each=24)
vec_year_10 <- rep(load_2010_raw$annee, each=24)
vec_month_raw <- rep(load_2010_raw$mois, each=24)
vec_month <- vec_month_raw
vec_month[which(vec_month_raw < 10)] <- paste(0, vec_month_raw[which(vec_month_raw<10)], sep="")
vec_day_raw <- rep(load_2010_raw$jour, each=24)
vec_day <- vec_day_raw
vec_day[which(vec_day_raw < 10)] <- paste(0, vec_day_raw[which(vec_day_raw<10)], sep="")
vec_hour_day <- c(1:24) 
vec_hour_raw <- rep(vec_hour_day, times=365)
vec_hour <- vec_hour_raw
vec_hour[which(vec_hour_raw < 10)] <- paste(0, vec_hour_raw[which(vec_hour_raw<10)], sep="")
vec_hour_ts <- paste(vec_hour, ":00", sep="")
vec_date_08 <- paste(vec_year_08, vec_month, vec_day, sep="-")
vec_date_09 <- paste(vec_year_09, vec_month, vec_day, sep="-")
vec_date_10 <- paste(vec_year_10, vec_month, vec_day, sep="-")
vec_timestamp_08 <- paste(vec_date_08, vec_hour_ts, sep=" ")
vec_timestamp_09 <- paste(vec_date_09, vec_hour_ts, sep=" ")
vec_timestamp_10 <- paste(vec_date_10, vec_hour_ts, sep=" ")

vec_heading <- paste("X", vec_hour_day, sep="")
df_load_values_08 <- load_2008[, vec_heading]
df_load_values_09 <- load_2009[, vec_heading]
df_load_values_10 <- load_2010_raw[, vec_heading]
mat_load_values_08 <- as.matrix(df_load_values_08)
mat_load_values_09 <- as.matrix(df_load_values_09)
mat_load_values_10 <- as.matrix(df_load_values_10)
mat_load_values_transp_08 <- t(mat_load_values_08)
mat_load_values_transp_09 <- t(mat_load_values_09)
mat_load_values_transp_10 <- t(mat_load_values_10)
vec_load_values_08 <- as.vector(mat_load_values_transp_08)
vec_load_values_09 <- as.vector(mat_load_values_transp_09)
vec_load_values_10 <- as.vector(mat_load_values_transp_10)

mat_load_08 <- cbind(vec_timestamp_08, vec_load_values_08)
mat_load_09 <- cbind(vec_timestamp_09, vec_load_values_09)
mat_load_10 <- cbind(vec_timestamp_10, vec_load_values_10)
write.csv(mat_load_08, file="TN_hourly_electricity_demand_series_2008_corrected.csv", row.names=F, col.names=T)
write.csv(mat_load_09, file="TN_hourly_electricity_demand_series_2009_corrected.csv", row.names=F, col.names=T)
write.csv(mat_load_10, file="TN_hourly_electricity_demand_series_2010_corrected.csv", row.names=F, col.names=T)
