# DB-Input: series capacity factors


setwd("/home/accon/GIZ/MAy/Data/Data-Base/DB_Input/db_input_data/") 

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")

drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

# Read in current db tables
db_demand_profile <- dbReadTable(db_TN_PSM, "demand_profile")
db_demand_profile_value <- dbReadTable(db_TN_PSM, "demand_profile_value")
db_mapping_demand_profile_value <- dbReadTable(db_TN_PSM, "mapping_demand_profile_value")
db_scenario_demand <- dbReadTable(db_TN_PSM, "scenario_demand")
db_mapping_modelling_year_demand_profile <- dbReadTable(db_TN_PSM, "mapping_modelling_year_demand_profile")
db_mapping_scenario_demand_map_modelling_year_demand_profile <- dbReadTable(db_TN_PSM, 
  "mapping_scenario_demand_map_modelling_year_demand_profile")


# Read in Data for DB Import
load_profile_annual_2008_raw <- read.csv("TN_hourly_electricity_demand_series_2008_corrected.csv", header=TRUE)
load_profile_annual_2009_raw <- read.csv("TN_hourly_electricity_demand_series_2009_corrected.csv", header=TRUE)
load_profile_annual_2010_raw <- read.csv("TN_hourly_electricity_demand_series_2010_corrected.csv", header=TRUE)
#load_profile_values_4days <- read.csv("Load_Profile_Peak_Days_Per_Season_normalized.csv", header=TRUE)
#load_profile_values_12days <- read.csv("Load_Profile_3_Peak_Days_Per_Season_normalized.csv", header=TRUE)
# Import Files for Demand Sums
#load_profile_sums_raw <- read.csv("Load_Profile_Sums_TimeSlices.csv", skip=1, header=TRUE) 

# Normalization of Load profile
load_profile_annual_2008 <- load_profile_annual_2008_raw
load_profile_annual_2008$normalized_load <- 0
load_profile_annual_2008$normalized_load <- load_profile_annual_2008$vec_load_values_08 / 
              sum(load_profile_annual_2008$vec_load_values_08)
load_profile_annual_2009 <- load_profile_annual_2009_raw
load_profile_annual_2009$normalized_load <- 0
load_profile_annual_2009$normalized_load <- load_profile_annual_2009$vec_load_values_09 / 
  sum(load_profile_annual_2009$vec_load_values_09)
load_profile_annual_2010 <- load_profile_annual_2010_raw
load_profile_annual_2010$normalized_load <- 0
load_profile_annual_2010$normalized_load <- load_profile_annual_2010$vec_load_values_10 / 
  sum(load_profile_annual_2010$vec_load_values_10)
annual_load_2040__GWh <-  49626
annual_load_2040__MWh <-  49626*1000



# DB Import Demand Profile Value 
db_demand_profile_value <- dbReadTable(db_TN_PSM, "demand_profile_value")
index_dpv <- max(db_demand_profile_value$id)
vec_dpv_2010 <- c(load_profile_annual_2010$normalized_load)
vec_dpv_pks <- c((index_dpv+1):(index_dpv+length(vec_dpv_2010)))
vec_dpv_timestep_fks <- vec_ts_pks
df_dpv_import <- as.data.frame(cbind(vec_dpv_pks, vec_dpv_timestep_fks, vec_dpv_2010))
dbWriteTable(db_TN_PSM, "demand_profile_value", df_dpv_import, row.names=FALSE, append=TRUE)


# DB Import Demand Profile
# load_profile_sums <- load_profile_sums_raw[which(load_profile_sums_raw$X>=2015 & load_profile_sums_raw$X<=2040 ),
#                                            c("X", "Load.Value.for.Timeslices.in.MWh", 
#                                              "Load.Value.for.Timeslices.in.MWh.1")]
vec_demprof_annual_demand <- annual_load_2040__MWh
index_demprof_pk <- max(db_demand_profile$id)
vec_demprof_pks <- c((index_demprof_pk+1):(index_demprof_pk+length(vec_demprof_annual_demand)))
vec_demprof_area_fk <- rep(1, length(vec_demprof_annual_demand))
vec_demprof_demand_type_fk <- rep(1, length(vec_demprof_annual_demand))
df_demprof_import <- as.data.frame(cbind(vec_demprof_pks, vec_demprof_area_fk, vec_demprof_demand_type_fk, 
                                     vec_demprof_annual_demand))

dbWriteTable(db_TN_PSM, "demand_profile", df_demprof_import, row.names=FALSE, append=TRUE)

# DB Import mapping_demand_profile_value
index_map_dpv_pk <- max(db_mapping_demand_profile_value$id)
vec_map_dpv_pk <- c((index_map_dpv_pk+1):(index_map_dpv_pk+length(vec_dpv_2010)))
indices_demprof_fks <- vec_demprof_pks
vec_map_dpv_demprof_fks <- c(rep(indices_demprof_fks, each=length(vec_dpv_2010)))
vec_map_dpv_dpv_fks <- c(18001:26760) # only associating 2010 profile
df_map_dpv_import <- as.data.frame(cbind(vec_map_dpv_pk, vec_map_dpv_demprof_fks, 
                                      vec_map_dpv_dpv_fks))
dbWriteTable(db_TN_PSM, "mapping_demand_profile_value", df_map_dpv_import, row.names=FALSE, append=TRUE)


# DB Import scenario_demand
# manual import

# DB Import mapping_modelling_year_demand_profile
index_map_mydp_pk <- max(db_mapping_modelling_year_demand_profile$id)
vec_map_mydp_pks <- c((index_map_mydp_pk+1):(index_map_mydp_pk+length(vec_demprof_pks)))
vec_map_mydp_modyear_fks <- rep(c(2:7), times=2)
vec_map_mydp_demprof_fks <- vec_demprof_pks
df_map_mydp_import <- as.data.frame(cbind(vec_map_mydp_pks, vec_map_mydp_modyear_fks, 
                                          vec_map_mydp_demprof_fks))
dbWriteTable(db_TN_PSM, "mapping_modelling_year_demand_profile", df_map_mydp_import, 
             row.names=FALSE, append=TRUE)

# DB Import mapping_scenario_demand_map_modelling_year_demand_profile (map_scdem)
index_map_scdem_pk <- max(db_mapping_scenario_demand_map_modelling_year_demand_profile$id)
vec_map_scdem_pks <- c((index_map_scdem_pk+1):(index_map_scdem_pk+length(vec_demprof_pks)))
indices_scdem_fk <- c(3:4)
vec_map_scdem_scdem_fks <- rep(indices_scdem_fk, each=6)
vec_map_scdem_mmydp_fks <- vec_map_mydp_pks
df_map_scdem_import <- as.data.frame(cbind(vec_map_scdem_pks, vec_map_scdem_scdem_fks, 
                                        vec_map_scdem_mmydp_fks))

dbWriteTable(db_TN_PSM, "mapping_scenario_demand_map_modelling_year_demand_profile", df_map_scdem_import, 
             row.names=FALSE, append=TRUE)