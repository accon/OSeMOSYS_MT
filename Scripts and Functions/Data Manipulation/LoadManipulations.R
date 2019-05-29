#Load Manipulations

setwd("/home/accon/GIZ/MAy/Data/Demand/")
load_2008_raw <- read.csv("Courbes de charge_LoadProfile_2008.csv", skip=1, header=TRUE)
load_2009_raw <- read.csv("Courbes de charge_LoadProfile_2009.csv", skip=1, header=TRUE)
load_2010_raw <- read.csv("Courbes de charge_LoadProfile_2010.csv", skip=1, header=TRUE)

vec_year <- rep(load_2010_raw$annee, each=24)
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
vec_date <- paste(vec_year, vec_month, vec_day, sep="-")
vec_timestamp <- paste(vec_date, vec_hour_ts, sep=" ")

vec_heading <- paste("X", vec_hour_day, sep="")
df_load_values <- load_2010_raw[, vec_heading]
mat_load_values <- as.matrix(df_load_values)
mat_load_values_transp <- t(mat_load_values)
vec_load_values <- as.vector(mat_load_values_transp)

mat_load <- cbind(vec_timestamp, vec_load_values)
write.csv(mat_load, file="TN_hourly_electricity_demand_series_2010_corrected.csv", row.names=F, col.names=T)
