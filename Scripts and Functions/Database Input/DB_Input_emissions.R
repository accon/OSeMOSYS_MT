# DB Input Emissions

setwd("/home/accon/GIZ/MAy/Data/Data-Base/DB_Input/db_input_data/") 
func_wd <- "/home/accon/GIZ/MAy/R/functions/"

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")
source(paste(func_wd, "db_input_mapping.R", sep=""))

drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

# Extract current DB Emission Tables
db_scenario_emission <- dbReadTable(db_TN_PSM, "scenario_emission")
db_power_plant_emission <- dbReadTable(db_TN_PSM, "power_plant_emission")
db_mapping_scenario_emission <- dbReadTable(db_TN_PSM, "mapping_scenario_emission")

# Input Data
power_plant_emissions_raw <- read.csv("power_plant_emissions.csv", header=TRUE, skip=3)

# Import Scenario Emission
# done manually 

# Import power_plant_emission values
index_ppe_pk <- max(db_power_plant_emission$id)
vec_ppe_ppt_fks <- rep(c(3:5, 12), each=6)
vec_ppe_modyr_fks <- rep(c(2:7), times=4)
vec_ppe_values <- c(as.matrix(power_plant_emissions_raw[,c(2:5)]))
vec_ppe_pks <- c((index_ppe_pk+1):(index_ppe_pk+length(vec_ppe_values)))
df_ppe_import <- as.data.frame(cbind(vec_ppe_pks, vec_ppe_ppt_fks, vec_ppe_modyr_fks, vec_ppe_values))
dbWriteTable(db_TN_PSM, "power_plant_emission", df_ppe_import, row.names=FALSE, append=TRUE)

# Import Mapping Scenario Emission
name_mppe <- "mapping_scenario_emission"
vec_mppe_sce_fks <- c(3)
vec_mppe_ppe_fks <- vec_ppe_pks
vec_mppe_pks <- db_input_mapping(db_TN_PSM, name_mppe, vec_mppe_sce_fks, vec_mppe_ppe_fks)
