# DB Input Technology Efficiencies

setwd("/home/accon/GIZ/MAy/Data/Data-Base/DB_Input/db_input_data/") 
func_wd <- "/home/accon/GIZ/MAy/R/functions/"

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")
source(paste(func_wd, "db_input_mapping.R", sep=""))

drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

# Extract current DB Reserve Margin Tables
db_scenario_efficiency <- dbReadTable(db_TN_PSM, "scenario_efficiency")
db_power_plant_efficiency <- dbReadTable(db_TN_PSM, "power_plant_efficiency")
db_storage_efficiency <- dbReadTable(db_TN_PSM, "storage_efficiency")
db_mapping_scenario_efficiency <- dbReadTable(db_TN_PSM, "mapping_scenario_efficiency")

# Input Data 
technology_efficiencies_raw <- read.csv("technology_efficiencies.csv", skip=2, header=TRUE)

# Import Scenario Efficiency
index_sceff_pk <- max(db_scenario_efficiency$id)
vec_sceff_names <- ("BAU")
vec_sceff_pks <- c((index_sceff_pk+1):(index_sceff_pk+length(vec_sceff_names)))
vec_sceff_area_fks <- rep(1, length(vec_sceff_names))
df_sceff_import <- as.data.frame(cbind(vec_sceff_pks, vec_sceff_names, vec_sceff_area_fks))
dbWriteTable(db_TN_PSM, "scenario_efficiency", df_sceff_import, row.names=FALSE, append=TRUE)

# Import Storage Efficiencies
index_steff_pk <- max(db_storage_efficiency$id)
vec_steff_cheff <- c(technology_efficiencies_raw$Hydro.Storage, technology_efficiencies_raw$Battery.Storage,
                     technology_efficiencies_raw$Csp.thermal.Storage)/100
vec_steff_dcheff <- vec_steff_cheff
vec_steff_stt_fks <- rep(c(1:3), each=6)
vec_steff_modyr_fks <- rep(c(2:7), times=3)
vec_steff_pks <- c((index_steff_pk+1):(index_steff_pk+length(vec_steff_cheff)))
df_steff_import <- as.data.frame(cbind(vec_steff_pks, vec_steff_stt_fks, vec_steff_modyr_fks, vec_steff_cheff,
                                       vec_steff_dcheff))
dbWriteTable(db_TN_PSM, "storage_efficiency", df_steff_import, row.names=FALSE, append=TRUE)

# Import Power Plant Efficiencies
index_ppeff_pk <- max(db_power_plant_efficiency$id)
vec_ppeff_values <- c(technology_efficiencies_raw$steam.turbine, technology_efficiencies_raw$ocgt,
                     technology_efficiencies_raw$ccgt, technology_efficiencies_raw$Csp...steam.turbine)/100
vec_ppeff_ppt_fks <- rep(c(3:5,13), each=6)
vec_ppeff_modyr_fks <- rep(c(2:7), times=4)
vec_ppeff_pks <- c((index_ppeff_pk+1):(index_ppeff_pk+length(vec_ppeff_values)))
df_ppeff_import <- as.data.frame(cbind(vec_ppeff_pks, vec_ppeff_ppt_fks, vec_ppeff_modyr_fks, vec_ppeff_values))
dbWriteTable(db_TN_PSM, "power_plant_efficiency", df_ppeff_import, row.names=FALSE, append=TRUE)

# Import Mapping Scenario Efficiency
name_msceff <- "mapping_scenario_efficiency"
vec_msceff_sceff_fks <- rep(vec_sceff_pks, length=max(length(vec_steff_pks), length(vec_ppeff_pks)))
vec_msceff_ppeff_fks <- vec_ppeff_pks
vec_msceff_steff_fks <- numeric(length=length(vec_ppeff_pks))
vec_msceff_steff_fks <- rep(NA, times=length(vec_ppeff_pks))
vec_msceff_steff_fks[c(1:length(vec_steff_pks))] <- vec_steff_pks
vec_msceff_pks <- db_input_mapping(db_TN_PSM, name_msceff, vec_msceff_sceff_fks, vec_msceff_ppeff_fks,
                                    vec_msceff_steff_fks, log_simple = TRUE)