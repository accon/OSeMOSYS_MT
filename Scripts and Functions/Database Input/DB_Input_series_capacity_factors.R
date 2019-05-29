# DB-Input: series capacity factors


setwd("/home/accon/GIZ/MAy/Data/Data-Base/DB_Input/db_input_data/") 

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")

drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

# Read in current db tables
db_series_capacity_factor <- dbReadTable(db_TN_PSM, "series_capacity_factor")
db_series_capacity_factor_value <- dbReadTable(db_TN_PSM, "series_capacity_factor_value")
db_mapping_series_capacity_factor <- dbReadTable(db_TN_PSM, "mapping_series_capacity_factor")
db_scenario_series_capacity_factor <- dbReadTable(db_TN_PSM, "scenario_series_capacity_factor")
db_mapping_scenario_series_capacity_factor <- dbReadTable(db_TN_PSM, "mapping_scenario_series_capacity_factor")

# Read in Data for DB Import
# pv_feed_in_4days <- read.csv("PV_Feed_in_Capacity_Factors_Peak_Load_Days.csv", header=TRUE)
# pv_feed_in_12days <- read.csv("PV_Feed_in_Capacity_Factors_Peak_Load_3Days.csv", header=TRUE)
# wind_feed_in_4days <- read.csv("Wind_Feed_in_Capacity_Factors_Peak_Load_Days.csv", header=TRUE)
# wind_feed_in_12days <- read.csv("Wind_Feed_in_Capacity_Factors_Peak_Load_3Days.csv", header=TRUE)
pv_wind_feed_in_raw <- read.csv("Tunisia_Wind_PV_Feed-in_Series_synthesized_2014.csv", skip=3, header=TRUE)

# vec_timestamp_fks_4days <- c(8665:8688, 3840:3863, 4872:4895, 5544:5567)
# vec_timestamp_4days <- rep(vec_timestamp_fks_4days, times=12)
# vec_timestamp_fks_12days <- c(8641:8712, 3816:3887, 4848:4919, 5520:5591)
# vec_timestamp_12days <- rep(vec_timestamp_fks_12days, times=12)
# vec_timestamp_fk <- c(vec_timestamp_4days, vec_timestamp_12days)
vec_timestamp_fk <- rep(vec_dpv_timestep_fks, times=4)

# vec_pv_feed_in_4days <- c(as.matrix(pv_feed_in_4days))
# vec_wind_feed_in_4days <- c(as.matrix(wind_feed_in_4days))
# vec_pv_feed_in_12days <- c(as.matrix(pv_feed_in_12days))
# vec_wind_feed_in_12days <- c(as.matrix(wind_feed_in_12days))

vec_capacity_factors <- c(pv_wind_feed_in_raw$STEG..2017., rep(pv_wind_feed_in_raw$STEG..2017..1, times=3))

vec_power_plant_type_fk_raw <- c(1,2,11,14)
vec_power_plant_type_fk <- rep(vec_power_plant_type_fk_raw, each=length(vec_timestamp_fk)/4)
vec_area_fk <- rep(1, length(vec_capacity_factors))

index_current <- max(db_series_capacity_factor_value$id)
vec_scfv_pk <- c((index_current+1): (index_current+length(vec_capacity_factors)))

df_scfv_import <- as.data.frame(cbind(vec_scfv_pk, vec_timestamp_fk, vec_capacity_factors, 
                                                 vec_power_plant_type_fk, vec_area_fk))

dbWriteTable(db_TN_PSM, "series_capacity_factor_value", df_scfv_import, row.names=FALSE, append=TRUE)

# DB Import series_capacity_factor
index_scf_pk <- max(db_series_capacity_factor$id)
vec_scf_index_pk <- c((index_scf_pk+1):(index_scf_pk+12))
vec_scf_area_fk <- rep(1, 12)
vec_scf_modyear_fk <- rep(c(2:7), times=2)
name_scf_raw <- "_4_Seasons_Peak_Load_3Days_"
vec_tecs <- c(rep("CSP", 6), rep("PV_decentralized", 6))
vec_years <- rep(seq(from=2015, to=2040, by=5), 2)
vec_scf_name <- paste(vec_tecs, name_scf_raw, vec_years, sep="")
df_scf_import <- as.data.frame(cbind(vec_scf_index_pk, vec_scf_name, vec_scf_area_fk, vec_scf_modyear_fk))

dbWriteTable(db_TN_PSM, "series_capacity_factor", df_scf_import, row.names=FALSE, append=TRUE)

# DB Import mapping_series_capacity_factor
index_mapping_scf_pk <- max(db_mapping_series_capacity_factor$id)
vec_map_scf_pk <- c((index_mapping_scf_pk+1):(index_mapping_scf_pk+length(vec_capacity_factors)))
indices_scfs <- c(79:82) #not nice
vec_map_scf_series_capacity_factor_fk <- rep(indices_scfs, each=(length(vec_capacity_factors)/4))
df_map_scf_import <- data.frame(cbind(vec_map_scf_pk, vec_map_scf_series_capacity_factor_fk, vec_scfv_pk))

dbWriteTable(db_TN_PSM, "mapping_series_capacity_factor", df_map_scf_import, row.names=FALSE, append=TRUE)


# DB Import scenario_series_capacity_factor
# manually
  
# DB Import mapping_scenario_series_capacity_factor (mscscf)

index_mscscf_scscf_fk <- max(db_scenario_series_capacity_factor$id)
no_scfs <- 4
vec_mscscf_scscf_fk <- rep(index_mscscf_scscf_fk, no_scfs)
vec_mscscf_scf_fk <- indices_scfs
index_mscscf_pk <- max(db_mapping_scenario_series_capacity_factor$id)
vec_mscscf_pks <- c((index_mscscf_pk+1):(index_mscscf_pk+no_scfs))

df_mscscf_import <- as.data.frame(cbind(vec_mscscf_pks, vec_mscscf_scscf_fk, vec_mscscf_scf_fk))

dbWriteTable(db_TN_PSM, "mapping_scenario_series_capacity_factor", df_mscscf_import, 
             row.names=FALSE, append=TRUE)