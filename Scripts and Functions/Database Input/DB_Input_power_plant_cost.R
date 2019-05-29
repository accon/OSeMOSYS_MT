# DB Input Power Plant Costs

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
db_power_plant_cost <- dbReadTable(db_TN_PSM, "power_plant_cost")
db_scenario_power_plant_cost <- dbReadTable(db_TN_PSM, "scenario_power_plant_cost")
db_mapping_scenario_power_plant_cost <- dbReadTable(db_TN_PSM, "mapping_scenario_power_plant_cost")
db_power_plant_type <- dbReadTable(db_TN_PSM, "power_plant_type")

# Input Data
power_plant_cost_raw <- read.csv("Power_Plant_Cost_Data.csv", header=TRUE, skip=5)

# Import Scenario power_plant_cost
index_scppc_pk <- max(db_scenario_power_plant_cost$id)
st_scppc_names <- "BAU_WBG_NatGasPriceSc_"
vec_scppc_sc_names <- c("CurrentPolicies", "NewPolicies", "450", "LowOilPrice")
vec_scppc_names <- paste(st_scppc_names, vec_scppc_sc_names, sep="")
vec_scppc_pks <- c((index_scppc_pk+1):(index_scppc_pk+length(vec_scppc_names)))
df_scppc_import <- as.data.frame(cbind(vec_scppc_pks, vec_scppc_names))
dbWriteTable(db_TN_PSM, "scenario_power_plant_cost", df_scppc_import, row.names=FALSE, append=TRUE)

# Import power_plant_cost
index_ppc_pk <- max(db_power_plant_cost$id)
mat_merge_ppt <- db_power_plant_type[, c("id", "name")]
df_pp_cost <- cbind(power_plant_cost_raw, c(1:nrow(power_plant_cost_raw)))
df_power_plant_cost_merged <- setorder(merge(x=df_pp_cost, y=mat_merge_ppt, by.x="Technology", by.y="name", 
                                    all.x=TRUE), "c(1:nrow(power_plant_cost_raw))")

vec_ppc_pp_type_fks <- df_power_plant_cost_merged$id
vec_ppc_modyr_fks <- rep(c(2:7), times=length(vec_ppc_pp_type_fks)/6)
vec_ppc_cc <- df_power_plant_cost_merged$Capital.Cost.in.k..MW
vec_ppc_fixc <- df_power_plant_cost_merged$O.M.fix.cost.in.k...MW.a.
vec_ppc_varc <- df_power_plant_cost_merged$Variable.cost..including.fuel.cost..in.k..MWh
vec_ppc_pks <- c((index_ppc_pk+1):(index_ppc_pk+length(vec_ppc_pp_type_fks)))
df_ppc_import <- as.data.frame(cbind(vec_ppc_pks, vec_ppc_pp_type_fks, vec_ppc_modyr_fks, vec_ppc_cc, 
                                    vec_ppc_fixc, vec_ppc_varc))
dbWriteTable(db_TN_PSM, "power_plant_cost", df_ppc_import, row.names=FALSE, append=TRUE)

# Import Mapping power_plant cost
name_mscppc <- "mapping_scenario_power_plant_cost"
vec_mscppc_aa_fks <- rep(c(1), times=14*6*4)
vec_mscppc_scppc_fks <- rep(vec_scppc_pks, each=14*6)
vec_mscppc_ppc_fks_eq <- df_ppc_import$vec_ppc_pks[which(!df_ppc_import$vec_ppc_pp_type_fks %in% c(3:5, 12))]
vec_mscppc_ppc_fks_1 <- df_ppc_import$vec_ppc_pks[c(1:84)]
vec_mscppc_ppc_fks_2 <- c(vec_mscppc_ppc_fks_eq, df_ppc_import$vec_ppc_pks[c(85:108)])
vec_mscppc_ppc_fks_3 <- c(vec_mscppc_ppc_fks_eq, df_ppc_import$vec_ppc_pks[c(109:132)])
vec_mscppc_ppc_fks_4 <- c(vec_mscppc_ppc_fks_eq, df_ppc_import$vec_ppc_pks[c(133:nrow(df_ppc_import))])
vec_mscppc_ppc_fks <- c(vec_mscppc_ppc_fks_1, vec_mscppc_ppc_fks_2, vec_mscppc_ppc_fks_3, vec_mscppc_ppc_fks_4)
vec_mscppc_pks <- db_input_mapping(db_TN_PSM, name_mscppc, vec_mscppc_ppc_fks, vec_mscppc_scppc_fks,
                                   vec_mscppc_aa_fks, log_simple = TRUE)
