# DB Input capacity restrictions

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
db_modelling_annual_capacity_restrictions <- dbReadTable(db_TN_PSM, "modelling_annual_capacity_restrictions")
db_scenario_capacity_restrictions <- dbReadTable(db_TN_PSM, "scenario_capacity_restrictions")
db_mapping_scenario_capacity_restrictions <- dbReadTable(db_TN_PSM, "mapping_scenario_capacity_restrictions")

# Input Data 
capacity_restrictions_raw <- read.csv("capacity_restrictions.csv", skip=1, header=TRUE)
dimnames_cap_rest <- c("years", "pp_types", "scenarios_min_max")
dimlength_cap_rest <- c(6, 1, 2)
arr_cr <- array(0, dim=dimlength_cap_rest, dimnames=list(seq(from=2015, to=2040, by=5), 
                                                        c("hydro_ror"),
                                                        c("TSP - min", "TSP - max")))
arr_cr[c(1:6), 1, 1] <- c(0)
arr_cr[c(1:6), 1, 2] <- c(1000)

# Import modelling annual capacity restriction
index_macr_pk <- max(db_modelling_annual_capacity_restrictions$id)
vec_hydro_cr <- as.vector(arr_cr[,1,])
vec_macr_values <- rep(999, 2*14)  # synthesize multiple previous vectors if needed 
vec_macr_pks <- c((index_macr_pk+1):(index_macr_pk+length(vec_macr_values)))
vec_macr_pptype_fks <- rep(c(1:14), each=2)
vec_macr_modyr_fks <- rep(7, times=length(vec_macr_pptype_fks))
vec_macr_aa_fks <- rep(1, times=length(vec_macr_pptype_fks))
vec_macr_minmax <- rep(c("min", "max"), times=14)
df_macr_import <- as.data.frame(cbind(vec_macr_pks, vec_macr_pptype_fks, vec_macr_modyr_fks, 
                                      vec_macr_aa_fks, vec_macr_values, vec_macr_minmax))
dbWriteTable(db_TN_PSM, "modelling_annual_capacity_restrictions", df_macr_import, row.names=FALSE, append=TRUE)

# Import scenario capacity Restrictions
index_sccr_pk <- max(db_scenario_capacity_restrictions$id)
vec_sccr_names <- c("scenario_unconstrained", "scenario_Tunisian_Solar_Plan", 
                    "scenario_Forced_PV_decentralized_expansion")
vec_sccr_pks <- c((index_sccr_pk+1):(index_sccr_pk+length(vec_sccr_names)))
df_sccr_import <- as.data.frame(cbind(vec_sccr_pks, vec_sccr_names))
dbWriteTable(db_TN_PSM, "scenario_capacity_restrictions", df_sccr_import, row.names=FALSE, append=TRUE)

# Import mapping scenario capacity restrictions
name_msccr <- "mapping_scenario_capacity_restrictions"
vec_msccr_sccr_fks_raw <- c(6)
vec_msccr_sccr_fks_single <- rep(vec_msccr_sccr_fks_raw, each=14)
vec_msccr_sccr_fks <- rep(vec_msccr_sccr_fks_single, 2)  
vec_msccr_macr_fks <- vec_macr_pks
vec_msccr_pks <- db_input_mapping(db_TN_PSM, name_msccr, vec_msccr_sccr_fks, vec_msccr_macr_fks,
                                    log_simple = TRUE)