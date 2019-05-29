# DB Input Fuel Cost

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
db_fuel_cost <- dbReadTable(db_TN_PSM, "fuel_cost")
db_scenario_fuel_cost <- dbReadTable(db_TN_PSM, "scenario_fuel_cost")
db_mapping_scenario_fuel_cost <- dbReadTable(db_TN_PSM, "mapping_scenario_fuel_cost")

# Input Data
natural_gas_scenarios_raw <- read.csv("Scenarios_fuels.csv", header=TRUE)

# Import Fuel Cost Values
index_fc_pk <- max(db_fuel_cost$id)
fuel_cost_values <- natural_gas_scenarios_raw[which(natural_gas_scenarios_raw$Scenario.Year >= 2015),
                                              c("Source","Scenario.Year", "Value")]
vec_fuel_cost_values <- fuel_cost_values$Value
vec_fc_pks <- c((index_fc_pk+1):(index_fc_pk+length(vec_fuel_cost_values)))
vec_fc_fuel_fks <- rep(1,length(vec_fc_pks))
vec_fc_modelling_year_fk <- rep(c(2:7), times=7)
df_fc_import <- as.data.frame(cbind(vec_fc_pks, vec_fc_fuel_fks, vec_fc_modelling_year_fk, 
                                    vec_fuel_cost_values))
dbWriteTable(db_TN_PSM, "fuel_cost", df_fc_import, row.names=FALSE, append=TRUE)

# Import Scenario Names
index_scfc_pk <- max(db_scenario_fuel_cost$id)
vec_scfc_names <- as.character(unique(fuel_cost_values$Source[which(fuel_cost_values$Source != "Extrapolation")]))
vec_scfc_pks <- c((index_scfc_pk+1):(index_scfc_pk+length(vec_scfc_names)))
vec_scfc_aa_fks <- rep(1, times=length(vec_scfc_names))
df_scfc_import <- as.data.frame(cbind(vec_scfc_pks, vec_scfc_names, vec_scfc_aa_fks))
dbWriteTable(db_TN_PSM, "scenario_fuel_cost", df_scfc_import, row.names=FALSE, append=TRUE)

# Import Mapping Scenario Fuel Cost
name_mscfc <- "mapping_scenario_fuel_cost"
vec_mscfc_fc_fks <- c(11:52)
vec_mscfc_scfc_fks <- rep(vec_scfc_pks, each=6)
vec_mscfc_pks <- db_input_mapping(db_TN_PSM, name_mscfc, vec_mscfc_fc_fks, vec_mscfc_scfc_fks, log_simple=TRUE)
