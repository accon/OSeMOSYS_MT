# DB Input Reserve Margin

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
db_reserve_margin <- dbReadTable(db_TN_PSM, "reserve_margin")
db_reserve_margin_value <- dbReadTable(db_TN_PSM, "reserve_margin_value")
db_scenario_reserve_margin <- dbReadTable(db_TN_PSM, "scenario_reserve_margin")
db_mapping_reserve_margin_value <- dbReadTable(db_TN_PSM, "mapping_reserve_margin_value")
db_mapping_scenario_reserve_margin <- dbReadTable(db_TN_PSM, "mapping_scenario_reserve_margin")

# Input Reserve Margin
# not needed

# Import Reserve Margin Names
index_rm_pk <- max(db_reserve_margin$id)
rm_values <- seq(from=1.1, to=1.4, by=0.05)
vec_rm_names <- paste("electricity_reserve_margin_", rm_values, sep="")
vec_rm_fuel_fks <- rep(2, length(vec_rm_names))
vec_rm_area_aggregated_fks <- rep(1, length(vec_rm_names))
vec_rm_pks <- c((index_rm_pk+1):(index_rm_pk+length(vec_rm_names)))
df_rm_import <- as.data.frame(cbind(vec_rm_pks, vec_rm_names, vec_rm_fuel_fks, vec_rm_area_aggregated_fks))
dbWriteTable(db_TN_PSM, "reserve_margin", df_rm_import, row.names=FALSE, append=TRUE)

# Import Reserve Margin Values
name_rmv <- "reserve_margin_value"
vec_rm_values <- rm_values
vec_rm_modyears <- c(2:7)
vec_rmv_pks <- db_input_mapping(db_TN_PSM, name_rmv, vec_rm_values, vec_rm_modyears)
  
# Import Scenario Reserve margin
index_scrm_pk <- max(db_scenario_reserve_margin$id)
vec_scrm_names <- paste("sc_", vec_rm_names, sep="") 
vec_scrm_pks <- c((index_scrm_pk+1):(index_scrm_pk+length(vec_scrm_names)))
df_scrm_import <- as.data.frame(cbind(vec_scrm_pks, vec_scrm_names))
dbWriteTable(db_TN_PSM, "scenario_reserve_margin", df_scrm_import, row.names=FALSE, append=TRUE)

# Import Mapping Reserve Margin Value
name_map_rmv <- "mapping_reserve_margin_value"
vec_map_rmv_rm_fks <- vec_rm_pks
vec_imp_map_rmv_rm_fks <- rep(vec_rm_pks, each=6)
vec_map_rmv_rmv_fks <- vec_rmv_pks
vec_map_rmv_pks <- db_input_mapping(db_TN_PSM, name_map_rmv, vec_imp_map_rmv_rm_fks, 
                                    vec_map_rmv_rmv_fks, log_simple = TRUE)

# Import Mapping Scenario Reserve Margin 
name_mscrm <- "mapping_scenario_reserve_margin"
vec_mscrm_scrm_fks <- vec_scrm_pks
vec_mscrm_rm_fks <- vec_rm_pks
vec_mscrm_pks <- db_input_mapping(db_TN_PSM, name_mscrm, vec_mscrm_scrm_fks, 
                                    vec_mscrm_rm_fks, log_simple = TRUE)