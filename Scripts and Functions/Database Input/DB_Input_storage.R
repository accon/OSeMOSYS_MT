


#-------INTRODUCTORY-SECTION---------------------------------------------------------------------

setwd("/home/accon/GIZ/MAy/Data/Data-Base/DB_Input/db_input_data/") 

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")

drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

storage_type <- 3
storage_type_name <- "csp_thermal_storage"

# add storage type to table "storage_type"

db_storage_efficiency <- dbReadTable(db_TN_PSM, "storage_efficiency")
db_storage_efficiency_index <- db_storage_efficiency$id[nrow(db_storage_efficiency)]
db_storage_cost <- dbReadTable(db_TN_PSM, "storage_cost")
db_storage_cost_index <- db_storage_cost$id[nrow(db_storage_cost)]
db_modeling_years <- dbReadTable(db_TN_PSM, "modelling_year")
db_area_aggregated <- dbReadTable(db_TN_PSM, "area_aggregated")

storage_cost <- read.csv("storage_cost.csv", header=T)
storage_efficiency <- read.csv("storage_efficiency.csv", header=T)

modeling_years_indices_cost <- db_modeling_years$id[which(db_modeling_years$year %in% storage_cost$modeling_years)]
modeling_years_indices_efficiency <- db_modeling_years$id[which(db_modeling_years$year %in% 
                                                                  storage_efficiency$modeling_years)]
vec_storage_cost_index <- c((db_storage_cost_index+1) : (db_storage_cost_index + nrow(storage_cost)))
vec_storage_type_cost <- rep(storage_type, nrow(storage_cost))
mat_storage_cost <- cbind(vec_storage_cost_index, vec_storage_type_cost, modeling_years_indices_cost, 
                          storage_cost[,-c(1:2)])
dbWriteTable(db_TN_PSM, "storage_cost", mat_storage_cost, row.names=FALSE, append=TRUE)

vec_storage_efficiency_index <- c((db_storage_efficiency_index+1) : (db_storage_efficiency_index + 
                                                                       nrow(storage_efficiency)))
vec_storage_type_efficiency <- rep(storage_type, nrow(storage_efficiency))
mat_storage_efficiency <- cbind(vec_storage_efficiency_index, vec_storage_type_efficiency, 
                                modeling_years_indices_efficiency, storage_efficiency[,-c(1:2)])

dbWriteTable(db_TN_PSM, "storage_efficiency", mat_storage_efficiency, row.names=FALSE, append=TRUE)

###
# Input Scenarios and Mappings
###

# Scenario
scenarios <- read.csv("scenarios.csv", header=T)
scenario_storage_cost_name <- as.character(scenarios$scneario_name[which(scenarios$scenario_type == 
                                                                      "scenario_storage_cost")])
db_scenarios_storage_cost <- dbReadTable(db_TN_PSM, "scenario_storage_cost")
db_scenarios_storage_cost_index <- db_scenarios_storage_cost$id[nrow(db_scenarios_storage_cost)]
id_area_aggregated_sc_stc <- db_area_aggregated$id[which(db_area_aggregated$name == scenarios$area_aggregated[
  which(scenarios$scenario_type == "scenario_storage_cost")])]
mat_scenario_storage_cost <- as.data.frame(cbind(db_scenarios_storage_cost_index+1, scenario_storage_cost_name, 
                              id_area_aggregated_sc_stc))

dbWriteTable(db_TN_PSM, "scenario_storage_cost", mat_scenario_storage_cost, row.names=FALSE, append=TRUE)

# Mapping
db_mapping_sc_stc <- dbReadTable(db_TN_PSM, "mapping_scenario_storage_cost")
index_db_mapping_sc_stc <- db_mapping_sc_stc$id[nrow(db_mapping_sc_stc)]

# All elements of storage_cost are chosen within the mapping
vec_storage_cost_indices <- c(1:db_storage_cost_index, vec_storage_cost_index)

vec_sc_stc <- rep(db_scenarios_storage_cost_index+1, length(vec_storage_cost_indices))
vec_indices_mapping_sc_stc <- c((index_db_mapping_sc_stc+1) : (index_db_mapping_sc_stc + 
                                                                     length(vec_sc_stc)))
mat_mapping_sc_stc <- as.data.frame(cbind(vec_indices_mapping_sc_stc, vec_storage_cost_indices, vec_sc_stc))

dbWriteTable(db_TN_PSM, "mapping_scenario_storage_cost", mat_mapping_sc_stc, row.names=FALSE, append=TRUE)