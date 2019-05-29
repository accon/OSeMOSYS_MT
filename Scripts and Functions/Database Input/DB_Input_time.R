# DB Input Time :))

setwd("/home/accon/GIZ/MAy/Data/Data-Base/DB_Input/db_input_data/") 
func_wd <- "/home/accon/GIZ/MAy/R/functions/"

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")
source(paste(func_wd, "db_input_mapping.R", sep=""))

drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

# Extract current DB Time Tables
db_season <- dbReadTable(db_TN_PSM, "season")
db_daytype <- dbReadTable(db_TN_PSM, "daytype")
db_dailytimebracket <- dbReadTable(db_TN_PSM, "dailytimebracket")
db_timeslice <- dbReadTable(db_TN_PSM, "timeslice")
db_scenario_time <- dbReadTable(db_TN_PSM, "scenario_time")
db_hourly_time_block <- dbReadTable(db_TN_PSM, "hourly_time_block")
db_set_hourly_time_block <- dbReadTable(db_TN_PSM, "set_hourly_time_block")
db_mapping_set_hourly_time_blocks_htb <- dbReadTable(db_TN_PSM, "mapping_set_hourly_time_blocks_htb")
db_mapping_modelling_year_set_htb <- dbReadTable(db_TN_PSM, "mapping_modelling_year_set_htb")
db_mapping_hourly_time_blocks_timeslices <- dbReadTable(db_TN_PSM, "mapping_hourly_time_blocks_timeslices")
db_mapping_scenario_time_set_map_modyr_set_htb <- dbReadTable(db_TN_PSM, 
                                                              "mapping_scenario_time_set_map_modyr_set_htb")
db_modelling_year <- dbReadTable(db_TN_PSM, "modelling_year")
db_timestep <- dbReadTable(db_TN_PSM, "timestep")

# Import Load file for 2010 timestamps
load_profile_annual_2010_raw <- read.csv("TN_hourly_electricity_demand_series_2010_corrected.csv", header=TRUE)
vec_months <- substr(load_profile_annual_2010_raw$vec_timestamp_10, 6, 7)
timestamp_2040_raw <- read.csv("TN_hourly_electricity_demand_series_2010_corrected.csv", header=TRUE)

# DB Import Seasons
index_season_pk <- max(db_season$id)
vec_season_names <- c("intermediary", "ramadan")
vec_season_pks <- c((index_season_pk+1):(index_season_pk+length(vec_season_names)))
df_season_import <- as.data.frame(cbind(vec_season_pks, vec_season_names))
dbWriteTable(db_TN_PSM, "season", df_season_import, row.names=FALSE, append=TRUE)

# DB Import Timeslices
index_timeslice_pk <- max(db_timeslice$id)
timeslice_names <- c("Wi", "Su", "In", "Ra")

# Only for equal length of seasonal Timeslices
#timeslice_numbers <- c(1:24)
#vec_timeslice_names <- paste(rep(timeslice_names, each=length(timeslice_numbers)), 
#                             rep(timeslice_numbers, times=length(timeslice_names)), sep="")

# Importing a whole year without the seasonal timeslice naming
timeslice_numbers <- c(1:8760)
vec_timeslice_names <- paste(c("TS"), timeslice_numbers, sep="")
vec_timeslice_pks <- c((index_timeslice_pk+1):(index_timeslice_pk+length(vec_timeslice_names)))
vec_timeslice_season_fks <- rep(c(1,2,3,4), each=length(timeslice_numbers)/4)
vec_timeslice_daytype_fks <- rep(1, length(vec_timeslice_names))
vec_timeslice_dtb_fks <- rep(db_timeslice$dailytimebracket_fk[c(1:24)], times=365)
vec_timeslice_hpts <- rep(1, length(vec_timeslice_names))
df_timeslice_import <- as.data.frame(cbind(vec_timeslice_pks, vec_timeslice_names, vec_timeslice_season_fks, 
                                        vec_timeslice_daytype_fks, vec_timeslice_dtb_fks, vec_timeslice_hpts))
dbWriteTable(db_TN_PSM, "timeslice", df_timeslice_import, row.names=FALSE, append=TRUE)

# DB Import Scenario_Time
index_sc_time_pk <- max(db_scenario_time$id)
vec_sc_time_names <- c("Scenario_2040_8760h")
vec_sc_time_pks <- c((index_sc_time_pk+1):(index_sc_time_pk+length(vec_sc_time_names)))
df_sc_time_import <- as.data.frame(cbind(vec_sc_time_pks, vec_sc_time_names))
dbWriteTable(db_TN_PSM, "scenario_time", df_sc_time_import, row.names=FALSE, append=TRUE)

# DB Import hourly_time_block
index_htb_pk <- max(db_hourly_time_block$id)
vec_htb_names <- c("htb_2040_whole_year")
vec_htb_pks <- c((index_htb_pk+1):(index_htb_pk+length(vec_htb_names)))
vec_htb_yhs <- c(3841,4873,5545,8665)-24
vec_htb_length <- rep(72, 4)
df_htb_import <- as.data.frame(cbind(vec_htb_pks, vec_htb_names, vec_htb_yhs, vec_htb_length))
dbWriteTable(db_TN_PSM, "hourly_time_block", df_htb_import, row.names=FALSE, append=TRUE)

# DB Import set_hourly_time_block
index_set_htb_pk <- max(db_set_hourly_time_block$id)
vec_set_htb_names <- c("4_Days_Seasonal_Peak", "3_Days_Around_4_Seasonal_Peak_Days")
vec_set_htb_pks <- c((index_set_htb_pk+1):(index_set_htb_pk+length(vec_set_htb_names)))
df_set_htb_import <- as.data.frame(cbind(vec_set_htb_pks, vec_set_htb_names))
dbWriteTable(db_TN_PSM, "set_hourly_time_block", df_set_htb_import, row.names=FALSE, append=TRUE)

# DB Import mapping_modelling_year_set_hourly_time_block
mmyshtb_name <- "mapping_modelling_year_set_htb"
vec_mmyshtb_set_htb_fk <- rep(2, times=8760)
vec_mmyshtb_my_fk <- rep(7, times=8760)
names_mmyshtb <- rep(c("All_hours"), times=length(vec_mmyshtb_set_htb_fk))
years_mmyshtb <- rep(2040, times=length(vec_mmyshtb_set_htb_fk))
vec_names_mmyshtb <- paste(names_mmyshtb, years_mmyshtb, sep="_")

vec_mmyshtb_pks <- db_input_mapping(db_TN_PSM, mmyshtb_name, vec_mmyshtb_my_fk, vec_mmyshtb_set_htb_fk, 
                 vec_fk_three = vec_names_mmyshtb, log_simple = TRUE, pos_vec_three = "front")

# DB Import mapping_set_hourly_time_blocks_htb
map_shtb_name <- "mapping_set_hourly_time_blocks_htb"
vec_map_shtb_shtb_fk <- c(2)
vec_map_shtb_htb_fk <- c(5)
vec_map_shtb_pks <- db_input_mapping(db_TN_PSM, map_shtb_name, vec_map_shtb_shtb_fk, vec_map_shtb_htb_fk)

# DB Import mapping_hourly_time_blocks_timeslices
map_htbts_name <- "mapping_hourly_time_blocks_timeslices"
vec_map_htbts_htb_fks <- rep(c(14), each=8760)
vec_map_htbts_ts_fks <- c(10515:19274)
vec_map_htbts_pks <- db_input_mapping(db_TN_PSM, map_htbts_name, vec_map_htbts_htb_fks, vec_map_htbts_ts_fks,
                                      log_simple=TRUE)

# DB Import mapping_scenario_time_set_map_modyr_set_htb
map_map_sct_name <- "mapping_scenario_time_set_map_modyr_set_htb"
vec_map_sct_sct_fks <- vec_sc_time_pks
vec_map_sct_mmyshtb_fks <- vec_mmyshtb_pks
vec_map_sct_pks <- db_input_mapping(db_TN_PSM, map_map_sct_name, vec_map_sct_sct_fks, 
                                    vec_map_sct_mmyshtb_fks)

# DB Import Time
timestamps_name <- "timestep"
index_ts_pk <- max(db_timestep$id)
vec_ts_unixtime <- seq(from=2208988800, to=2240607600, by=3600)
vec_ts_unixtime_ny <- vec_unixtime[which(!(vec_unixtime <= 2214169200 & vec_unixtime >= 2214086400))]
vec_ts_timestamp <- vec_timestamps
vec_ts_unixtime_du <- rep(999, times=length(vec_ts_timestamp))
vec_ts_pks <- c((index_ts_pk+1):(index_ts_pk+length(vec_ts_timestamp)))
vec_ts_tz <- (1)
df_ts_import <- as.data.frame(cbind(vec_ts_pks, vec_ts_unixtime_du, vec_ts_timestamp, vec_ts_tz))

dbWriteTable(db_TN_PSM, timestamps_name, df_ts_import, row.names=FALSE, append=TRUE)