# DB Input Power Plant List

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
db_power_plant <- dbReadTable(db_TN_PSM, "power_plant")

# Input Data
power_plant_list_raw <- read.csv("power_plant_list_TN_2017-08.csv", header=TRUE, skip=3)

# Import Scenario power_plant_existing
# done manually 

# Import power_plant_list
index_pp_pk <- max(db_power_plant$id)
mat_name_owner_type <- power_plant_list_raw[,c(2:5)]
vec_pp_a_fk <- rep(1, nrow(power_plant_list_raw))
vec_pp_ft_fk <- as.character(power_plant_list_raw$Fuel)
vec_pp_ft_fk[which(vec_pp_ft_fk != "")] <- 1
vec_pp_ft_fk[which(vec_pp_ft_fk == "")] <- NA
vec_pp_comyr <- power_plant_list_raw$Commissioning.year
vec_pp_comyr[which(is.na(vec_pp_comyr))] <- 1990
df_pp_type <- power_plant_list_raw[,c("Number", "pp.type")]
df_lifetime <- as.data.frame(cbind(c("Wind-Onshore", "Steam Turbine", "OCGT", "CCGT", "Hydro", "Decentralized PV", 
                         "Utility-Scale PV"), c(20,30,25,30,99,20,20)))
df_merge <- setorder(merge(df_pp_type, df_lifetime, by.x="pp.type", by.y="V1", all.x=TRUE), "Number")
vec_pp_lifetime <- df_merge$V2
vec_pp_instcap <- power_plant_list_raw$Total.Installed.Capacity..MW.
vec_pp_eff <- as.numeric(as.character(power_plant_list_raw$Efficiency))
vec_pp_eff[which(is.na(vec_pp_eff))] <- 0 
df_pp_type <- power_plant_list_raw[,c("Number", "pp.type")]
df_ppt_fk <- as.data.frame(cbind(c("Wind-Onshore", "Steam Turbine", "OCGT", "CCGT", "Hydro", "Decentralized PV", 
                                     "Utility-Scale PV"), c(1,3,4,5,6,14,2)))
df_merge_ppt_fk <- setorder(merge(df_pp_type, df_ppt_fk, by.x="pp.type", by.y="V1", all.x=TRUE), "Number")
vec_pp_type <- df_merge$V2
vec_pp_trumin <- rep(NA, nrow(power_plant_list_raw))
vec_pp_trdmin <- rep(NA, nrow(power_plant_list_raw))
vec_pp_mainten_time <- rep(100, nrow(power_plant_list_raw))
vec_pp_mrt <- rep(0, nrow(power_plant_list_raw))
vec_pp_suc <- rep(NA, nrow(power_plant_list_raw))
vec_ppt_secure <- c("Steam Turbine", "OCGT", "CCGT", "Hydro")
vec_pp_securcap <- rep(0, nrow(power_plant_list_raw))
vec_pp_securcap[which(power_plant_list_raw$pp.type %in% vec_ppt_secure)] <- 1
vec_pp_gridconlvl <- rep(NA, nrow(power_plant_list_raw))
vec_pp_optfuel_1 <- rep(NA, nrow(power_plant_list_raw))
vec_pp_optfuel_2 <- rep(NA, nrow(power_plant_list_raw))
vec_pp_annprod <- rep(NA, nrow(power_plant_list_raw))
vec_pp_notes <- power_plant_list_raw$Notes
vec_pp_pks <- c((index_pp_pk+1):(index_pp_pk+nrow(power_plant_list_raw)))
df_pp_import <- as.data.frame(cbind(vec_pp_pks, mat_name_owner_type, vec_pp_a_fk, vec_pp_ft_fk, vec_pp_comyr, 
                                    vec_pp_lifetime, vec_pp_instcap, vec_pp_eff, vec_pp_type, vec_pp_trumin, 
                                    vec_pp_trdmin, vec_pp_mainten_time, vec_pp_mrt, vec_pp_suc, vec_pp_securcap, 
                                    vec_pp_gridconlvl, vec_pp_optfuel_1,vec_pp_optfuel_2, vec_pp_annprod, 
                                    vec_pp_notes))
dbWriteTable(db_TN_PSM, "power_plant", df_pp_import, row.names=FALSE, append=TRUE)

# Import Mapping power_plant list
name_mscppex <- "mapping_scenario_power_plant_existing"
vec_mscppex_scppex_fks <- c(1)
vec_mscppex_pp_fks <- vec_pp_pks
vec_mscppex_pks <- db_input_mapping(db_TN_PSM, name_mscppex, vec_mscppex_scppex_fks, vec_mscppex_pp_fks)
