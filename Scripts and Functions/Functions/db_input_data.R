db_input_data <- function(filename_data, db_connection, db_tablename, ...)
{

  db_data <- dbReadTable(db_connection, db_tablename)
  db_data_index <- db_data$id[nrow(db_data)]
  
  db_modeling_years <- dbReadTable(db_TN_PSM, "modelling_year")
  db_area_aggregated <- dbReadTable(db_TN_PSM, "area_aggregated")

  data <- read.csv(filename_data, header=T)
  data_type_index <- 

  modeling_years_indices <- db_modeling_years$id[which(db_modeling_years$year %in% data$modeling_years)]

  vec_data_index <- c((db_data_index+1) : (db_data_index + nrow(data)))
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