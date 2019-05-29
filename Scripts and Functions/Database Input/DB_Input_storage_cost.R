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
db_scenario_storage_cost <- dbReadTable(db_TN_PSM, "scenario_storage_cost")
db_storage_cost <- dbReadTable(db_TN_PSM, "storage_cost")
db_mapping_scenario_storage_cost <- dbReadTable(db_TN_PSM, "mapping_scenario_storage_cost")

# Input Data
storage_cost_raw <- read.csv("Storage_Cost_Data.csv", header=TRUE, skip=5)

# Import Scenario Storage Cost
# done manually 

# Import storage_cost values. Only capital storage costs can be given in OSeMOSYS since fix and variable O&M 
# costs are given in coverter (power plant / technology) units

index_stcv_pk <- max(db_storage_cost$id)
vec_stcv_capital_cost <- storage_cost_raw$Capital.Cost.in...MWh
vec_stcv_stt_fks <- rep(c(1:3), each=6)
vec_stcv_modyr_fks <- rep(c(2:7), times=3)
vec_stcv_pks <- c((index_stcv_pk+1):(index_stcv_pk+length(vec_stcv_capital_cost)))
vec_stcv_cc_dummy <- rep(0, times=18)
matrix_stcv_cost_dummy <- matrix(0, nrow=18, ncol=4)
df_stcv_import <- as.data.frame(cbind(vec_stcv_pks, vec_stcv_stt_fks, vec_stcv_modyr_fks, vec_stcv_cc_dummy,
                                      vec_stcv_capital_cost, matrix_stcv_cost_dummy))
dbWriteTable(db_TN_PSM, "storage_cost", df_stcv_import, row.names=FALSE, append=TRUE)

# Import Mapping Storage Cost
name_mscstc <- "mapping_scenario_storage_cost"
vec_mscstc_scstc_fks <- c(4)
vec_mscstc_stc_fks <- vec_stcv_pks
vec_mscstc_pks <- db_input_mapping(db_TN_PSM, name_mscstc, vec_mscstc_scstc_fks, vec_mscstc_stc_fks, 
                                 log_switch = TRUE)
