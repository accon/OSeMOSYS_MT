# --------------------------------------------------------------------------
# Creation of input for OSeḾOSYS optimization problem
# --------------------------------------------------------------------------
# Author: Niklas Wulff 
# Date: 2017-09-01
# Description: This script file creates and OSeMOSYS input file from power system
# data stored in a PostgreSQL database. It was written in the course of the Master
# thesis of Niklas Wulff to analyze the Tunisian electricity system.

#-------Introductory Section---------------------------------------------------------------------

# Packages
library("DBI")
library("RPostgreSQL")
library("data.table")

# Self-written Functions
func_wd <- "/home/accon/GIZ/MAy/R/functions/"
source(paste(func_wd, "write_matrix_to_file.R", sep=""))
source(paste(func_wd, "write_array_to_file.R", sep=""))
source(paste(func_wd, "phaseout.R", sep=""))


# DB-connection
drv <- dbDriver("PostgreSQL")
db_TN_PSM <- dbConnect(drv, user="postgres", dbname = "test_db", port="5432", password="Fantasy", host="localhost")

# Set working directory
setwd("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_MR2")
wdmodstruc <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Model-Structure/"
wdtech <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Technology/"
wdprofiles <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Profiles/"
wdeco <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Economic/"

filename <- "OSeMOSYS_input_MR2_1c_TSP.txt"

# Create File
write.table(filename)
fileConn <- file(filename)

# Start writing process

writeLines("
#
#	To run the model, copy and paste the following line into the command prompt, after replacing ...FILEPATH... with your folder structure.
#
# Links didn't work. See original utopia.txt-file for complete comments
#
#  Alternatively, install GUSEK (http://gusek.sourceforge.net/gusek.html) and run the model within this integrated development environment (IDE). 
#  To do so, open the .dat file within GUSEK and select \"Use External .dat file\" from the Options menu. Then go to the .mod file and select the \"Go\" icon or press F5.
#
#	Based on UTOPIA version 5: BASE - Utopia Base Model	
#	The following are DEFAULT units, but they can be changed by users to their comfort. When doing so, users are advised to check the consistency of their choices though.
#	Energy and demands in MWh																							
#	Power plants in MW																							
#	Investment and Fixed O&M Costs: Power plant: € / MW																							
#	Other plant costs: € / (MW*a)																							
#	Variable O&M (& Import) Costs: € / MWh
#
#****************************************		", fileConn)

write("
param AnnualExogenousEmission			default	0		:=	; 
param AnnualEmissionLimit				default	999999999	:=	;
param ModelPeriodExogenousEmission	default	0		:=	;
param ModelPeriodEmissionLimit		default	999999999	:=	;

#**************************************** \n \n", file=filename, append=TRUE)	



#-------Set-Definition----------------------

# Emissions
emission_info <- dbReadTable(db_TN_PSM, "view_set_emissions")
emissions <- emission_info$emission_name
emissions_conc <- paste(emissions, collapse="\t")
emissions_str <- paste("set EMISSION\t:=", emissions_conc, ";", sep="\t")
write(emissions_str, file=filename, append=TRUE)

power_plant_cost_raw <- dbReadTable(db_TN_PSM, "view_power_plant_costs")
power_plant_types <- unique(power_plant_cost_raw$power_plant_type)
power_plant_types_conc <- paste(power_plant_types, collapse="\t")
power_plant_types_str <- paste("set TECHNOLOGY\t:=", power_plant_types_conc, ";", sep="\t")
write(power_plant_types_str, file=filename, append=TRUE)
supply_technologies <- power_plant_types[grep("supply", power_plant_types)]

fuels_info <- dbReadTable(db_TN_PSM, "view_fuels_choice")
fuels <- fuels_info$fuel_name
fuels_conc <- paste(fuels, collapse="\t")
fuels_str <- paste("set FUEL\t:=", fuels_conc, ";", sep="\t")
write(fuels_str, file=filename, append=TRUE)

time_info <- dbReadTable(db_TN_PSM, "time_information_complete")
years <- unique(time_info$modelling_year)
numvec_years <- as.numeric(years)
years_conc <- paste(years, collapse="\t")
years_str <- paste("set YEAR\t:=", years_conc, ";", sep="\t")
write(years_str, file=filename, append=TRUE)
timeslices <- unique(time_info$timeslice_name)
timeslices_snapshot <- c(timeslices, "Du")
timeslices_conc <- paste(timeslices_snapshot, collapse="\t")
timeslices_str <- paste("set TIMESLICE\t:=", timeslices_conc, ";", sep="\t")
write(timeslices_str, file=filename, append=TRUE)

write("set MODE_OF_OPERATION\t:=\t1\t2\t;", file=filename, append=TRUE)

regions_info <- dbReadTable(db_TN_PSM, "view_regions_choice")
regions <- regions_info$aggregated_area_name
regions_conc <- paste(regions, collapse="\t")
regions_str <- paste("set REGION\t:=", regions_conc, ";", sep="\t")
write(regions_str, file=filename, append=TRUE)

seasons <- unique(time_info$season_id)
model_seasons <- c(1:length(seasons))
seasons_conc <- paste(model_seasons, collapse="\t")
seasons_str <- paste("set SEASON\t:=", seasons_conc, ";", sep="\t")
write(seasons_str, file=filename, append=TRUE)

daytypes <- unique(time_info$daytype_id)
daytypes_conc <- paste(daytypes, collapse="\t")
daytypes_str <- paste("set DAYTYPE\t:=", daytypes_conc, ";", sep="\t")
write(daytypes_str, file=filename, append=TRUE)

dtb <- sort(unique(time_info$dtb_id))
dtb_conc <- paste(dtb, collapse="\t")
dtb_str <- paste("set DAILYTIMEBRACKET\t:=", dtb_conc, ";", sep="\t")
write(dtb_str, file=filename, append=TRUE)

storage_raw <- dbReadTable(db_TN_PSM, "view_storage_type")
storage_types <- storage_raw$storage_type_name
storage_types_conc <- paste(storage_types, collapse="\t")
storage_types_str <- paste("set STORAGE\t:=", storage_types_conc, "; \n\n", sep="\t")
write(storage_types_str, file=filename, append=TRUE)


#-------Discount Rate and Depreciation Method-----------------------------------------------------

write("	
#
# DiscountRate {r in REGION}; System discount rate given for different modeling regions.",
      file=filename, append=TRUE)

discount_rate_raw <- dbReadTable(db_TN_PSM, "view_discount_rate") #abbreviation of discount_rate is dr
dr_vec_rownames <- discount_rate_raw$area_aggregated
dr_vec_colnames <- " "
mat_dr <- matrix(discount_rate_raw$discount_rate)
dr_string_def <- "param DiscountRate default 0.05"
write_matrix_to_file(mat_dr, dr_vec_rownames, dr_vec_colnames, 
                     string_def=dr_string_def, filename=filename)

write("	
#
# DepreciationMethod; equal to 1 for Sinking Fund and 2 for Straight Line Depreciation
param DepreciationMethod default 1 :=;\n", file=filename, append=TRUE)


#-------YearSplit---------------------------------------------------

write("
#
# YearSplit{l in TIMESLICE, y in YEAR}  Units: Fraction of 8760 hours
# The fraction of the year in each time slice.", file=filename, append=TRUE)
no_seasons <- length(seasons)
no_daytypes <- length(daytypes)
no_dtb <- length(dtb)
no_timeslices <- length(timeslices)   # no_timeslices represents the timeslices without the Dummy-Timeslice.
no_years <- length(years)
yearsplit_value <- round(unique(time_info$hours_per_timeslice)/8760, digits=6)
value_dummy_timeslice <- 1-yearsplit_value*length(timeslices)

mat_yearsplit <- matrix(c(rep(yearsplit_value, no_timeslices), value_dummy_timeslice), 
                        nrow=length(timeslices_snapshot), ncol=no_years) #additional row for columnames, additional 2 columns for rownames (including param-definition) and := ; signs 
string_def_yearsplit <- "param YearSplit\t:"

write_matrix_to_file(mat_yearsplit, timeslices_snapshot, years, string_def=string_def_yearsplit, filename=filename)

#-------Demand--------TimeSlice Adjustment maybe needed-----------------------------------

write("
#
# AccumulatedAnnualDemand{r in REGION, f in FUEL, y in YEAR}  Units: MWh
# This type of demand can be satisfied at any time of the year, as long as the total is met.
param AccumulatedAnnualDemand	default	0	:=	;

#
# SpecifiedAnnualDemand{r in REGION, f in FUEL, y in YEAR}  Units: MWh
# The annual requirement for each output fuel.", file=filename, append=TRUE)

specified_annual_demand <- dbReadTable(db_TN_PSM, "view_demand_profiles")
vec_annual_demand <- specified_annual_demand$annual_demand__mwh
mat_annual_demand <- matrix(vec_annual_demand, nrow=length(regions), ncol=no_years, byrow=TRUE)
string_init_demand <- "param SpecifiedAnnualDemand\tdefault\t0\t:="
string_def_demand <- "[*,electricity,*] :"
write_matrix_to_file(mat_annual_demand, regions, years, string_init_demand, string_def_demand, filename)

write("
#
# SpecifiedDemandProfile{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR} Units: Fraction
# Indicates the proportion of energy demand required in each time slice. For each year the sum must be equal to 1.",
      file=filename, append=TRUE)

demand_profiles_raw <-  dbReadTable(db_TN_PSM, "view_demand_profile_values") 
demand_years <- unique(demand_profiles_raw$modelling_year)
demand_regions <- unique(demand_profiles_raw$aggregated_area)
no_demand_regions <- length(demand_regions)
vec_dim_demand <- c(no_timeslices, no_years, no_demand_regions)
#timeslices<-(Winter, Intermediary, Summer, Ramadan)
timeslices_ord <- timeslices[c(grep("Wi", timeslices), grep("In", timeslices), grep("Su", timeslices), 
                             grep("Ra", timeslices))]
timeslices_order <- timeslices_ord[c(1:72, 73:144,145:216,217:288)]
arr_demand <- array(NA, dim=vec_dim_demand, 
                              dimnames=list(timeslices_ord, demand_years, demand_regions)) #possibly change timeslice order
for (i in dimnames(arr_demand)[[3]])
{
  arr_demand[,,i] <- matrix(round(demand_profiles_raw$demand_normalized, 6)
                                      [which(demand_profiles_raw$aggregated_area == i)], 
                                      nrow=no_timeslices, ncol=no_years, byrow=FALSE)
}

demand_series_string_init <- "param SpecifiedDemandProfile\tdefault\t0\t:="
demand_series_string_def <- "[XXX,electricity,*,*]\t:"

write_array_to_file(arr_demand, timeslices_ord, years, demand_regions, 
                    demand_series_string_init, demand_series_string_def, filename)


#-------CapacityToActivityUnit-------------------------------------------------------------------
 
write("
#
# CapacityToActivityUnit{r in REGION, t in TECHNOLOGY};  Units: MWh/MW-YR
# Thus here we use a factor of 8760, which is the level of energy production in MWh produced from 1 MW operating for 1 year (1MW * 8760h)", file=filename, append=TRUE)	

hours_modyr <- aggregate(hours_per_timeslice ~ modelling_year, time_info, FUN=sum)
colnames(hours_modyr)[2] <- "hours_per_modelling_year"
no_power_plant_types <- length(power_plant_types)
vec_capacity_to_activity_unit <- rep(8760, no_power_plant_types)

if (length(unique(hours_modyr$hours_per_modelling_year)) > 1)
{
  warning("Warning! There are different amounts of yearly hours defined which can not be taken into account in the model. The first value is taken.")    
  vec_capacity_to_activity_unit <- rep(hours_modyr$hours_per_modelling_year[1], no_power_plant_types)
}

mat_capacity_to_activity_unit <- matrix(vec_capacity_to_activity_unit, ncol=no_power_plant_types, nrow=1) 
string_def_capacity_to_activity_unit <- "param CapacityToActivityUnit\tdefault\t1\t:" 
write_matrix_to_file(mat_capacity_to_activity_unit, "TUNISIA", power_plant_types, 
                     string_def=string_def_capacity_to_activity_unit, filename=filename)


#-------PEAK-TIMESLICE--------------------------------------------------------------

write("
#
# TechWithCapacityNeededToMeetPeakTS{r in Region, t in Technology}  Units: 1=yes, 0=no
# Flags the technologies that can be used to meet the peak demand for the fuel they produce."
      , file=filename, append=TRUE)	

flag_peak_pps <- 1
vec_flag_peak_pps <- rep(flag_peak_pps, no_power_plant_types)
mat_flag_peak_pps <- matrix(vec_flag_peak_pps, ncol=no_power_plant_types, nrow=1) 
string_def_flag_peak_pps <- "param TechWithCapacityNeededToMeetPeakTS\tdefault\t0\t:" 
write_matrix_to_file(mat_flag_peak_pps, "TUNISIA", power_plant_types, 
                     string_def=string_def_flag_peak_pps, filename=filename)


#-------INPUT-ACTIVITY-UNIT---------------------------------------------------

write("
#
# InputActivityRatio{r in REGION, t in TECHNOLOGY, f in FUEL, m in MODE_OF_OPERATION, y in YEAR}  Units: Ratio
# The input (use) of fuel per unit of activity for each technology."
      , file=filename, append=TRUE)	

pp_efficiency_raw <-  dbReadTable(db_TN_PSM, "view_power_plant_efficiency") 
storage_efficiency_raw <- dbReadTable(db_TN_PSM, "view_storage_efficiency") 
power_plants_fossil <- unique(pp_efficiency_raw$pp_type[which(!is.na(pp_efficiency_raw$fuel) & 
                                                                pp_efficiency_raw$fuel != "csp_heat" )])
no_fossil_pp <- length(power_plants_fossil)
mat_pp_efficiency <- matrix(pp_efficiency_raw$pp_efficiency[which(!is.na(pp_efficiency_raw$fuel) & 
                            pp_efficiency_raw$fuel != "csp_heat")], ncol=no_years, nrow=no_fossil_pp, byrow=TRUE)
mat_pp_inputactivityratio <- round(1/mat_pp_efficiency, 2)
iau_string_init <- "param InputActivityRatio\tdefault\t0\t:="
iau_string_def <- paste("[TUNISIA,*,", fuels[1],",1,*]\t:", sep="")
write_matrix_to_file(mat_pp_inputactivityratio, power_plants_fossil, years, 
                     iau_string_init, iau_string_def, filename, multi=TRUE)

# CSP steam turbine input activity ratio
csp_pps <- unique(storage_efficiency_raw$power_plant_type_discharge
                  [which(storage_efficiency_raw$storage_type_id == 3)])
no_csp_pps <- length(csp_pps)
mat_csp_efficiency <- matrix(pp_efficiency_raw$pp_efficiency[which(pp_efficiency_raw$fuel == "csp_heat")], 
                             ncol=no_years, nrow=no_csp_pps, byrow=TRUE)
mat_csp_inputactivityratio <- round(1/mat_csp_efficiency, 2)
iau_string_def_csp <- paste("[TUNISIA,*,", fuels[3],",1,*]\t:", sep="")
write_matrix_to_file(mat_csp_inputactivityratio, csp_pps, years, 
                     string_def=iau_string_def_csp, filename=filename) #add multi=TRUE if storage is activated

# Input Activity Ratios for Charging of Electricity Storages

# iau_string_def_2 <- paste("[TUNISIA,*,", fuels[2],",2,*]\t:", sep="")
# storage_pps <- unique(storage_efficiency_raw$power_plant_type_charge
#                       [which(storage_efficiency_raw$storage_type_id != 3)])
# no_storage_pps <- length(storage_pps)
# storage_reservoirs <- unique(storage_efficiency_raw$storage_type)
# no_storage_reservoirs <- length(storage_reservoirs)
# mat_storage_pps_efficiency <- round(1/matrix(storage_efficiency_raw$storage_charge_efficiency
#                                              [which(storage_efficiency_raw$storage_type_id != 3)], ncol=no_years, 
#                                              nrow=no_storage_pps, byrow=TRUE), 2)
# write_matrix_to_file(mat_storage_pps_efficiency, storage_pps, years, 
#                      string_def=iau_string_def_2, filename=filename)

#-------OUTPUT-ACTIVITY-UNIT---------------------------------------------------

pp_types_wo_supply <- power_plant_types[which(!power_plant_types %in% supply_technologies)]
pp_types_elec_output <- pp_types_wo_supply[which(pp_types_wo_supply != "csp_collector" & 
                                                   pp_types_wo_supply != "csp_gas_firing")]
mat_oau <-  matrix(1, ncol=no_years, nrow=length(pp_types_elec_output))  #oau = output activity unit
oau_string_init = "param OutputActivityRatio\tdefault\t0\t:="
oau_string_def = paste("[TUNISIA,*,", fuels[2],",1,*]\t:", sep="")

mat_oau_supplies <- matrix(1, nrow=length(supply_technologies), ncol=no_years)
oau_supplies_string_def <- paste("[TUNISIA,*,", fuels[1],",1,*]\t:", sep="")

write("
# 
# OutputActivityRatio{r in Region, t in Technology, f in Fuel, m in ModeOfOperation, y in Year}  Units: Ratio
# Ratio of output to activity.
# Should be 1 for power plants/electricity, 1 for supply technologies and their respective fuels and zero for rest."
      , file=filename, append=TRUE)
write_matrix_to_file(mat_oau, pp_types_elec_output, years, oau_string_init, 
                     oau_string_def, filename=filename, multi=TRUE)

write_matrix_to_file(mat_oau_supplies, supply_technologies, years, string_def=oau_supplies_string_def, 
                     filename=filename, multi=TRUE)

oau_string_def_csp = paste("[TUNISIA,*,", fuels[3],",1,*]\t:", sep="")
pps_csp_heat <- pp_types_wo_supply[which(!pp_types_wo_supply %in% pp_types_elec_output)]
mat_csp_heat <- matrix(1, nrow=length(pps_csp_heat), ncol=length(years))

write_matrix_to_file(mat_csp_heat, pps_csp_heat, years, string_def=oau_string_def_csp, filename=filename)

#-------COST---------------------------------------------------------------------

power_plant_costs_raw <- dbReadTable(db_TN_PSM, "view_power_plant_costs") 
storage_costs_raw <- dbReadTable(db_TN_PSM, "view_storage_costs") 

mat_fix_costs_pp <- matrix(power_plant_costs_raw$fix_cost__k_euro_mw_a
                           [which(power_plant_costs_raw$modelling_year %in% years )], 
                               ncol=no_years, nrow=no_power_plant_types, byrow=TRUE)
fixcost_string_init <- "param FixedCost\tdefault\t0\t:=" 
fixcost_string_def <- "[TUNISIA,*,*]\t:\t"

write("
#	
# FixedCost{r in Region, t in Technology, y in Year} Units: k€/(MW*a) of Capacity
# The annual cost per unit of capacity of a technology.", file=filename, append=TRUE)	
write_matrix_to_file(mat_fix_costs_pp, power_plant_types, years, fixcost_string_init, 
                     fixcost_string_def, filename)


mat_capital_costs_pp <- matrix(power_plant_costs_raw$capital_cost__k_euro_mw
                               [which(power_plant_costs_raw$modelling_year %in% years)], 
                               ncol=no_years, nrow=no_power_plant_types, byrow=TRUE)
capcost_string_init <- "param CapitalCost\tdefault\t0\t:=" 
capcost_string_def <- "[TUNISIA,*,*]\t:\t"

write("
#	
# CapitalCost{r in Region, t in Technology, y in Year} Units: k€/MW Capacity
# Total capital cost (including interest paid during construction)per unit of capacity for new capacity additions", 
      file=filename, append=TRUE)	
write_matrix_to_file(mat_capital_costs_pp, power_plant_types, years, capcost_string_init, 
                     capcost_string_def, filename)


mat_variable_costs_pp <- matrix(power_plant_costs_raw$variable_cost__k_euro_mwh
                                [which(power_plant_costs_raw$modelling_year %in% years)], 
                               ncol=no_years, nrow=no_power_plant_types, byrow=TRUE)
varcost_string_init <- "param VariableCost\tdefault\t0.00001\t:=" 
varcost_string_def <- "[TUNISIA,*,1,*]\t:\t"

write("
#
# VariableCost{r in Region, t in Technology, m in ModeOfOperation, y in Year} Units: k€/MWh 
# Cost per unit of activity of the technology
# This variable records both the nonfuel O&M costs of processes and fuel costs of each fuel supplied to those processes.", 
      file=filename, append=TRUE)	
write_matrix_to_file(mat_variable_costs_pp, power_plant_types, years, varcost_string_init, 
                     varcost_string_def, filename)


#-------RESIDUAL-PP-CAPACITY-+-AVAILABILITY----------------------------------------------------------

write("
#	
# ResidualCapacity{r in Region, t in Technology, y in Year} Units: MW
# The capacity left over from periods prior to the modeling period.", 
      file=filename, append=TRUE)	

power_plants_raw <- dbReadTable(db_TN_PSM, "view_power_plant_list") 
vec_decommissioning_year <- power_plants_raw$commissioning_year + power_plants_raw$lifetime__a
power_plants_lifeinfo <- as.data.frame(cbind(power_plants_raw$id, power_plants_raw$name, power_plants_raw$commissioning_year,
                               power_plants_raw$lifetime__a, power_plants_raw$installed_capacity__mw, 
                               power_plants_raw$power_plant_type_fk, vec_decommissioning_year)) 
colnames(power_plants_lifeinfo) <- c(colnames(power_plants_raw[,c(1,2,8,9,10,12)]), "decommissioning_year")

power_plants_lifeinfo$decommissioning_year <- as.numeric(as.character(power_plants_lifeinfo$decommissioning_year))
power_plants_lifeinfo$installed_capacity__mw <- as.numeric(as.character(power_plants_lifeinfo$installed_capacity__mw))

power_plant_type_raw <- dbReadTable(db_TN_PSM, "power_plant_type") 
power_plant_type <- power_plant_type_raw[which(power_plant_type_raw$name %in% 
                                                 unique(power_plant_cost_raw$power_plant_type)),]
power_plant_type_ord <- setorder(power_plant_type, "id")
vec_phaseout_pp_type_fks <- sort(as.numeric(as.character(unique(power_plants_lifeinfo$power_plant_type_fk)))) 
vec_phaseout_pp_types <- power_plant_type_ord$name[which(power_plant_type_ord$id %in% 
                                                           vec_phaseout_pp_type_fks)]

mat_write_pp_phaseout <- matrix(0, nrow=length(vec_phaseout_pp_type_fks), ncol=no_years)
rownames(mat_write_pp_phaseout) <- vec_phaseout_pp_type_fks
colnames(mat_write_pp_phaseout) <- years
for (y in numvec_years)
{
  mat_phaseout <- phaseout(y, vec_instcap=power_plants_lifeinfo$installed_capacity__mw, 
                           vec_decom=power_plants_lifeinfo$decommissioning_year, 
                           vec_pptype=power_plants_lifeinfo$power_plant_type_fk)  
  mat_write_pp_phaseout[mat_phaseout$type, which(colnames(mat_write_pp_phaseout) == as.character(y))] <-
    mat_phaseout$residual_capacity
}

phaseout_string_init <- "param ResidualCapacity\tdefault\t0\t:=\t"
phaseout_string_def <- "[TUNISIA,*,*]\t:\t"
write_matrix_to_file(mat_write_pp_phaseout, vec_phaseout_pp_types, years, phaseout_string_init,
                     phaseout_string_def, filename)


write("
#
# AvailabilityFactor{r in Region, t in Technology, y in Year} Units: Fraction of Hours in Year
# Maximum time technology may run for the whole year. Often used to simulate planned outages. OSeMOSYS will choose when to run or not run.
param AvailabilityFactor\tdefault\t1\t:=\t;\n", 
      file=filename, append=TRUE)	


#-------CAPACITY FACTORS---------------------------------------------------------------------------

series_capacity_factors_raw <- dbReadTable(db_TN_PSM, "view_series_capacity_factors") 
tech_scf <- unique(series_capacity_factors_raw$power_plant_type)
no_tech_scf <- length(tech_scf)
vec_dim_scf <- c(no_timeslices, no_years, no_tech_scf)
arr_capacity_factors <- array(NA, dim=vec_dim_scf, 
                              dimnames=list(timeslices_ord, years, tech_scf))

# Wi, In, Su, Ra

for (i in dimnames(arr_capacity_factors)[[3]])
{
  arr_capacity_factors[,,i] <- matrix(series_capacity_factors_raw$available_capacity
                                      [which(series_capacity_factors_raw$power_plant_type == i)], 
                                      nrow=no_timeslices, ncol=no_years, byrow=FALSE)
}

cfs_string_init <- "param CapacityFactor\tdefault\t1\t:="
cfs_string_def <- "[TUNISIA,XXX,*,*]\t:"

write("
#	
# CapacityFactor{r in Region, t in Technology, l in TIMESLICE, y in Year} Units: Fraction of Hours in Year
# Indicates the maximum time technology may run in a given time slice.", 
      file=filename, append=TRUE)	
write_array_to_file(arr_capacity_factors, timeslices_ord, years, tech_scf, 
                    cfs_string_init, cfs_string_def, filename)


#-------EMISSION-INFOS-------------------------------------------------------------------------------------------------



power_plant_emissions_raw <- dbReadTable(db_TN_PSM, "view_power_plant_emission") 

vec_pp_emissions <- unique(power_plant_emissions_raw$pp_type)

mat_pp_emissions <- matrix(power_plant_emissions_raw$emission_factor__tco2e_mwh, 
                           nrow=length(vec_pp_emissions), ncol=no_years, byrow=TRUE)
ppem_string_init <- "param EmissionActivityRatio\tdefault\t0\t:=\t"
ppem_string_def <- "[TUNISIA,*,co2,1,*]\t:"

write("
#
# EmissionActivityRatio{r in Region, t in Technology, e in Emission, m in ModeOfOperation, y in Year}  Units: Tonnes/MWh Output
# Emissions factor per unit of activity.", file=filename, append=TRUE)	
write_matrix_to_file(mat_pp_emissions, vec_pp_emissions, years, ppem_string_init, 
                     ppem_string_def, filename)

write("
#	
# EmissionsPenalty{r in Region, e in Emission, y in Year} Units: Million €/Tonne of Pollutant (or per t co2-eq)
# Externality cost per unit of emission", 
      file=filename, append=TRUE)	

empen_string_init <- "param EmissionsPenalty\tdefault\t0\t:=\t"
empen_string_def <- "[TUNISIA,*,*]\t:\t"
mat_empen_values <- matrix(0, nrow=length(emissions), ncol=no_years)
write_matrix_to_file(mat_empen_values, emissions, years, empen_string_init, empen_string_def, filename)

#-------RESERVE-MARGIN----------------------------------------------------------------------------------------------------

reserve_margins_raw <- dbReadTable(db_TN_PSM, "view_reserve_margin") 
fuels_reservemar <- unique(reserve_margins_raw$fuel_name)
areas_reservemar <- unique(reserve_margins_raw$area_aggregated)
mat_tagreservemar <- matrix(1, nrow=length(fuels_reservemar), ncol=no_years)  
mat_reserve_margins <- matrix(reserve_margins_raw$reserve_margin_value, 
                              nrow=length(areas_reservemar), ncol=no_years)
trm_string_init <- "param ReserveMarginTagFuel\tdefault\t0\t:=\t"     # trm = tag reserve margin
trm_string_def <- "[TUNISIA,*,*]\t:"
rm_string_def <- "param ReserveMargin\tdefault\t0\t:\t"

write("
#	
# ReserveMarginTagFuel{r in Region,f in Fuel, y in Year} Units: 1=yes, 0=no
# Indicates if the output fuel has a reserve margin associated with it.", file=filename, append=TRUE)
write_matrix_to_file(mat_tagreservemar, fuels_reservemar, years, trm_string_init, 
                     trm_string_def, filename)
write("
#	
# ReserveMargin{r in Region, y in Year} Units: Ratio (Installed/Peak)
# The reserve (installed) capacity required relative to the peak demand for the specified fuel.", 
      file=filename, append=TRUE)
write_matrix_to_file(mat_reserve_margins, areas_reservemar, years, string_def=rm_string_def, filename=filename)


mat_secured_capacity <- matrix(power_plant_type$secured_capacity, 
                               nrow=no_power_plant_types, ncol=no_years, byrow=FALSE)
rmtt_string_init <- "param ReserveMarginTagTechnology\tdefault\t0\t:="
rmtt_string_def <- "[TUNISIA,*,*]\t:"

write("
#
# ReserveMarginTagTechnology{r in Region,t in Technology, y in Year} Units: fraction
# Amount the technology contributes to the reserve margin 1=100%  0.2=20%.", 
      file=filename, append=TRUE)
write_matrix_to_file(mat_secured_capacity, power_plant_types, years, 
                     rmtt_string_init, rmtt_string_def, filename)


#-------PP-LIFE---------------------------------------------------------------------------------------------

mat_power_plant_lifetime <- matrix(power_plant_type$lifetime__a, 
                                   nrow=length(regions), ncol=no_power_plant_types)
pp_life_string_def <- "param OperationalLife\tdefault\t20\t:" 

write("
#
# param OperationalLife{r in Region, t in Technology};  Units: years
# Operational lifespan of a process in years.", 
      file=filename, append=TRUE)
write_matrix_to_file(mat_power_plant_lifetime, regions, power_plant_types, 
                     string_def=pp_life_string_def, filename=filename)


#-------TOTAL-ANNUAL-CAPACITY-RESTRICTIONS------------------------------------------------------------------------------------------------

modelling_capacity_restrictions <- dbReadTable(db_TN_PSM, "view_modelling_capacity_restrictions")
pps_capacity_restrictions_max <- unique(modelling_capacity_restrictions$power_plant_type
                                        [which(modelling_capacity_restrictions$min_max == "max")]) 

pps_capacity_restrictions_min <- unique(modelling_capacity_restrictions$power_plant_type
                                        [which(modelling_capacity_restrictions$min_max == "min")]) 

years_capacity_restrictions_max <- unique(modelling_capacity_restrictions$modelling_year
                                        [which(modelling_capacity_restrictions$min_max == "max")]) 

years_capacity_restrictions_min <- unique(modelling_capacity_restrictions$modelling_year
                                        [which(modelling_capacity_restrictions$min_max == "min")]) 

mat_totannmaxcap <- matrix(modelling_capacity_restrictions$capacity__mw
                                        [which(modelling_capacity_restrictions$min_max == "max")], 
                                        nrow=length(pps_capacity_restrictions_max), 
                                        ncol=length(years_capacity_restrictions_max), byrow=TRUE)

mat_totannmincap <- matrix(modelling_capacity_restrictions$capacity__mw
                                        [which(modelling_capacity_restrictions$min_max == "min")], 
                                        nrow=length(pps_capacity_restrictions_min), 
                                        ncol=length(years_capacity_restrictions_max), byrow=TRUE)

tamaxc_string_init <- "param TotalAnnualMaxCapacity\tdefault\t9999999999\t:="
tamaxc_string_def <- "[TUNISIA,*,*]\t:"

taminc_string_init <- "param TotalAnnualMinCapacity\tdefault\t0\t:="
taminc_string_def <- "[TUNISIA,*,*]\t:"

write("
#
# TotalAnnualMaxCapacity{r in Region, t in Technology, y in Year} Units: MW
# Maximum total (residual and new) capacity each year.", 
      file=filename, append=TRUE)
write_matrix_to_file(mat_totannmaxcap, pps_capacity_restrictions_max, years_capacity_restrictions_max,
                     tamaxc_string_init, tamaxc_string_def, filename)

write("
#
# TotalAnnualMinCapacity{r in Region, t in Technology, y in Year} Units: MW
# Minimum total (residual and new) capacity each year.", 
      file=filename, append=TRUE)
write_matrix_to_file(mat_totannmincap, pps_capacity_restrictions_min, years_capacity_restrictions_min,
                     taminc_string_init, taminc_string_def, filename)


#-------POLICY-TARGETS-------------------------------------------------------------

write("
#
# TotalAnnualMaxCapacityInvestment{r in Region, t in Technology, y in Year} Units: MW
# Maximum new capacity each year.  Use this to stop OSeMOSYS investing in existing technologies.
param TotalAnnualMaxCapacityInvestment	default	9999999	:=	;		
#	
# TotalAnnualMinCapacityInvestment{r in Region, t in Technology, y in Year} Units: MW
# Minimum new capacity each year.
param TotalAnnualMinCapacityInvestment	default	0	:=	;																			
#
# param TotalTechnologyAnnualActivityUpperLimit{r in Region, t in Technology, y in Year} Units: MWh
# Maximum amount of activity that a technology can perform each year.
param TotalTechnologyAnnualActivityUpperLimit	default	999999999	:=	;																			
#
# TotalTechnologyAnnualActivityLowerLimit{r in Region, t in Technology, y in Year} Units: MWh
# Minimum activity that a technology can perform each year. # must-run
param TotalTechnologyAnnualActivityLowerLimit	default	0	:=	;																			
#
# TotalTechnologyModelPeriodActivityUpperLimit{r in Region, t in Technology} Units: MWh
# Maximum level of activity by a technology over the whole model period.
param TotalTechnologyModelPeriodActivityUpperLimit	default	9999999999	:=	;																			
#
# TotalTechnologyModelPeriodActivityLowerLimit{r in Region, t in Technology} Units: MWh
# Minimum level of activity by a technology over the whole model period.
param TotalTechnologyModelPeriodActivityLowerLimit	default	0	:=	;																			
#
# RETagTechnology{r in Region, t in Technology, y in Year} Units: 1=yes, 0=no
# Flags technologies that are allowed to contribute to the renewable capacity of the system.", 
      file=filename, append=TRUE)																		

power_plant_types_re <- dbReadTable(db_TN_PSM, "view_re_power_plant_types")
policy_target_values <- dbReadTable(db_TN_PSM, "view_policy_target_values")

pp_types_re <- power_plant_types_re$power_plant_type
mat_ppt_re <- matrix(1, nrow=length(pp_types_re), ncol=no_years)
pptt_string_init <- "param RETagTechnology\tdefault\t0\t:=\t"
pptt_string_def <- "[TUNISIA,*,*]\t:"
write_matrix_to_file(mat_ppt_re, pp_types_re, years, 
                     pptt_string_init, pptt_string_def, filename)

write("
#
# RETagFuel{r in Region,f in Fuel, y in Year} Units: 1=yes, 0=no
# The fuels for which there is a renewable target.", 
      file=filename, append=TRUE)
fuels_target <- unique(policy_target_values$fuel_name)
mat_fuels_target <- matrix(1, nrow=length(fuels_target), ncol=no_years)
ft_string_init <- "param RETagFuel\tdefault\t0\t:=\t"
ft_string_def <- "[TUNISIA,*,*]\t:" 
write_matrix_to_file(mat_fuels_target, fuels_target, years, ft_string_init, 
                     ft_string_def, filename)

if (nrow(policy_target_values) > 0)
{
write("
#
# REMinProductionTarget{r in Region, f in Fuel, y in Year}  Units: Fraction
# What fraction of the fuels (tagged in the RETagFuel parameter) must come from the Renewable technologies (tagged in the RETagTechnology parameter)", 
      file=filename, append=TRUE)

re_targets_elecprod <- policy_target_values[which(policy_target_values$target_type_name 
                                                                     == "RE_electricity_production"),]
years_re_targets <- unique(policy_target_values$modelling_year)

mat_minprodtarg <- matrix(re_targets_elecprod$target_value, nrow=length(fuels_target), 
                          ncol=length(years_re_targets))
REt_string_init <- "param REMinProductionTarget\tdefault\t0\t:="
REt_string_def <- "[*,*]\t:" # watch out here! in the optimization code, REMinProductionTarget is defined {r in Region, y in Year} without the fuel right now!
write_matrix_to_file(mat_minprodtarg, regions, years_re_targets, REt_string_init, REt_string_def, filename=filename)
} else {
  write("
#
# REMinProductionTarget{r in Region, f in Fuel, y in Year}  Units: Fraction
# What fraction of the fuels (tagged in the RETagFuel parameter) must come from the Renewable technologies (tagged in the RETagTechnology parameter)
param REMinProductionTarget\tdefault\t0\t:= ;", 
        file=filename, append=TRUE)
}

#-------TIME-ASSOCIATIONS----------------------------------------------------------------------------------

# Association of timeslice and season

write("
#																								
# Conversionls{l in TIMESLICE, ls in SEASON}																											
# Set equal to 1 to assign a particular time slice to a season. Set equal to 0 in order not to assign a particular time slice to a season.", 
      file=filename, append=TRUE)

mat_conversionls <- matrix(NA, nrow=no_timeslices+2, ncol=no_seasons+2) #additional rows for param-definition and columnames, additional 2 columns for rownames (including param-definition) and := ; signs 
mat_conversionls[2,2:(ncol(mat_conversionls)-1)] <- model_seasons
mat_conversionls[3:(nrow(mat_conversionls)),1] <- timeslices
mat_conversionls[1,1] <- "param Conversionls\tdefault\t0\t:="
mat_conversionls[2,1] <- "[*,*] :"
mat_conversionls[,ncol(mat_conversionls)] <- c("", ":=", rep("", nrow(mat_conversionls)-3), "; \n")

#fill in matrix
mat_cls <- unique(cbind(time_info$timeslice_name,time_info$season_id))
no_ts_per_season <- table(mat_cls)[1:4]
rows_cls <- c(1,sum(1,no_ts_per_season[1]), sum(1,no_ts_per_season[1:2]), sum(1,no_ts_per_season[1:3]))

for (s in c(1:length(seasons)))
{
  mat_conversionls[c((2+rows_cls[s]):as.numeric(rows_cls[s]+table(mat_cls)[s]+1)),s+1] <- rep(1, table(mat_cls)[s]) 
}

mat_conversionls[is.na(mat_conversionls)] <- 0
mat_conversionls[1,c(2:5)] <- ""
mat_conls <- mat_conversionls[c(3:(no_timeslices+2)),c(2:(no_seasons+1))]

string_init_cls <- "param Conversionls\tdefault\t0\t:="
string_def_cls <- "[*,*] :"

#write.table(mat_conversionls, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)
write_matrix_to_file(mat_conls, timeslices, as.character(c(1:4)), string_init_cls, string_def_cls, 
                     filename)

# Write conversionld

write("
# Conversionld{l in TIMESLICE, ld in DAYTYPE}				
# Set equal to 1 to assign a particular time slice to a day type. Set equal to 0 in order not to assign a particular time slice to a day type.", 
      file=filename, append=TRUE)

mat_conversionld <- matrix(NA, nrow=no_timeslices+2, ncol=no_daytypes+2) #additional rows for param-definition and columnames, additional 2 columns for rownames (including param-definition) and := ; signs 
mat_conversionld[2,2:(ncol(mat_conversionld)-1)] <- daytypes
mat_conversionld[3:(nrow(mat_conversionld)),1] <- timeslices
mat_conversionld[1,1] <- "param Conversionld\tdefault\t0\t:="
mat_conversionld[2,1] <- "[*,*] :"
mat_conversionld[,ncol(mat_conversionld)] <- c("", ":=", rep("", nrow(mat_conversionld)-3), "; \n")
mat_conversionld[is.na(mat_conversionld)] <- 1
mat_conversionld[1,2] <- ""

mat_conld <- as.matrix(mat_conversionld[c(3:(no_timeslices+2)), c(2:(no_daytypes+1))], nrow=no_timeslices, 
                       ncol=no_daytypes)
string_init_cld <- "param Conversionld\tdefault\t0\t:="
string_def_cld <- "[*,*] :"

#write.table(mat_conversionld, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)
write_matrix_to_file(mat_conld, timeslices, daytypes, string_init_cld, string_def_cld, filename)

# conversionlh association of timeslice and dailytimebracket

write("
# Conversionlh{l in TIMESLICE, lh in DAILYTIMEBRACKET} 				
# Set equal to 1 to assign a particular time slice to a daily time bracket. Set equal to 0 in order not to assign a particular time slice to a daily time bracket.", 
      file=filename, append=TRUE)

mat_conversionlh <- matrix(NA, nrow=no_timeslices+2, ncol=no_dtb+2) #additional rows for param-definition and columnames, additional 2 columns for rownames (including param-definition) and := ; signs 
mat_conversionlh[2,2:(ncol(mat_conversionlh)-1)] <- sort(dtb)
mat_conversionlh[3:(nrow(mat_conversionlh)),1] <- timeslices
mat_conversionlh[1,1] <- "param Conversionlh\tdefault\t0\t:="
mat_conversionlh[2,1] <- "[*,*] :"
mat_conversionlh[,ncol(mat_conversionlh)] <- c("", ":=", rep("", nrow(mat_conversionlh)-3), "; \n")

#fill in matrix
mat_clh <- unique(cbind(time_info$timeslice_name,time_info$dtb_id))

dtb_rows <- c(3:nrow(mat_conversionlh))
dtb_columns <- 1+as.numeric(mat_clh[,2])
dtb_index <- cbind(dtb_rows,dtb_columns)
mat_conversionlh[dtb_index] <- 1

mat_conversionlh[is.na(mat_conversionlh)] <- 0
mat_conversionlh[1,c(2:5)] <- ""

mat_conlh <- mat_conversionlh[c(3:(no_timeslices+2)), c(2:(no_seasons+1))]
string_init_clh <- "param Conversionlh\tdefault\t0\t:="
string_def_clh <- "[*,*] :"

#write.table(mat_conversionlh, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)
write_matrix_to_file(mat_conlh, timeslices, dtb, string_init_clh, string_def_clh, 
                     filename)
# DaySplit

write("
#
# DaySplit{lh in DAILYTIMEBRACKET, y in YEAR};																											
# The length of one time bracket in one specific day as a fraction of the year, e.g., when distinguishing between days and night: 12h/(24h*365d)",
      file=filename, append=TRUE)

value_daysplit <- 1/(no_dtb*365)

write(paste("param DaySplit\tdefault\t",value_daysplit, ":=;"),
      file=filename, append=TRUE)

# DaysInDayType is somewhere else in the original input-file - shouldnt be a problem

write("
# DaysInDayType{ls in SEASON, ld in DAYTYPE, y in YEAR};
# Number of days for each day type within a week, i.e., out of 7",
      file=filename, append=TRUE)
write(paste("param DaysInDayType\tdefault\t7\t:=\t;"), file=filename, append=TRUE)


#-------STORAGE-----------------------------------------------------  	

storage_list_raw <- dbReadTable(db_TN_PSM, "view_storage_list")
storage_type_raw <- dbReadTable(db_TN_PSM, "view_storage_type")

vec_st_ppt_ch <- unique(storage_type_raw$power_plant_type_charge)
vec_st_ppt_dch <- unique(storage_type_raw$power_plant_type_discharge)
vec_st_type <- unique(storage_type_raw$storage_type_name)
vec_st_type_exist <- unique(storage_list_raw$storage_type_name)

mat_techtostorage <- diag(nrow(storage_type_raw))
  
tts_string_init <- "param TechnologyToStorage\tdefault\t0\t:="
tts_string_def <- "[TUNISIA,*,*,2]\t:"

write("
#
# TechnologyToStorage{r in REGION, t in TECHNOLOGY, s in STORAGE, m in MODE_OF_OPERATION}",
      file=filename, append=TRUE)
write_matrix_to_file(mat_techtostorage, vec_st_ppt_ch, vec_st_type, 
                     tts_string_init, tts_string_def, filename)

tfs_string_init <- "param TechnologyFromStorage\tdefault\t0\t:="
tfs_string_def <- "[TUNISIA,*,*,1]\t:"

write("
#
# TechnologyFromStorage{r in REGION, t in TECHNOLOGY, s in STORAGE, m in MODE_OF_OPERATION}",
      file=filename, append=TRUE)
write_matrix_to_file(mat_techtostorage, vec_st_ppt_dch, vec_st_type, 
                     tfs_string_init, tfs_string_def, filename)

write("
#																										
# StorageLevelStart{r in REGION, s in STORAGE}																											
# At beginning of first year. Attention: if zero, OSeMOSYS will use the first time slices in the entire first day type in the entire first season to fill the storage. 																											
# To avoid OSeMOSYS taking a whole part of a season to fill up the storage, and to avoid defining smaller seasons, set it to zero, run the model, and check the StorageLevelYearStart 																											
# variable of the following year and use a similar value for StorageLevelStart. Alternatively, model a few years before the first year of your interest.", file=filename, append=TRUE)																											

string_init_st_lvl_start <- "param StorageLevelStart\tdefault\t0\t:="
string_def_st_lvl_start <- "[*,*]:"
mat_st_lvl_start <- matrix(5, nrow=length(regions), ncol= length(vec_st_type)) # completely random number (5).
write_matrix_to_file(mat_st_lvl_start, regions, vec_st_type, string_init_st_lvl_start, 
                     string_def_st_lvl_start, filename)

if (nrow(storage_type_raw) > 0)
{
  mat_storage_max_chargerate <- matrix(storage_type_raw$max_charge_rate_average__mw, 
                                     nrow=length(regions), ncol=length(vec_st_type))
  stmaxcr_string_init <- "param StorageMaxChargeRate\tdefault\t99\t:="
  stmaxcr_string_def <- "[*,*]\t:"
  
  write("
  # StorageMaxChargeRate{r in REGION, s in STORAGE}; Unit: MW",
        file=filename, append=TRUE)
  write_matrix_to_file(mat_storage_max_chargerate, regions, vec_st_type, 
                       stmaxcr_string_init, stmaxcr_string_def, filename)
  
  
  mat_storage_max_dischargerate <- matrix(storage_type_raw$max_discharge_rate_average__mw, 
                                          nrow=length(regions), ncol=length(vec_st_type))
  stmaxdcr_string_init <- "param StorageMaxDischargeRate\tdefault\t99\t:="
  stmaxdcr_string_def <- "[*,*]\t:"
  
  write("
  # StorageMaxDischargeRate{r in REGION, s in STORAGE}; Unit: MW",
        file=filename, append=TRUE)
  write_matrix_to_file(mat_storage_max_dischargerate, regions, vec_st_type, 
                       stmaxdcr_string_init, stmaxdcr_string_def, filename)
  
  
  
  mat_mincharge <- matrix(storage_type_raw$min_storage_charge, nrow=length(vec_st_type), ncol=no_years)
  mat_mincharge[which(is.na(mat_mincharge))] <- 0
  
  mcr_string_init <- "param MinStorageCharge\tdefault\t0\t:="
  mcr_string_def <- "[TUNISIA,*,*]\t:"
  
  write("
        # MinStorageCharge{r in REGION, s in STORAGE, y in YEAR}; Unit: fraction of MaxStorageCharge, i.e., between 0.00 and 0.99.",
        file=filename, append=TRUE)
  write_matrix_to_file(mat_mincharge, vec_st_type, years, mcr_string_init, mcr_string_def, filename)
  
  
  mat_storage_lifetime <- matrix(storage_type_raw$storage_lifetime, 
                                 nrow=length(regions), ncol=length(vec_st_type))
  olst_string_init <- "param OperationalLifeStorage\tdefault\t99\t:="
  olst_string_def <- "[*,*]\t:"
  
  write("
  # OperationalLifeStorage{r in REGION, s in STORAGE}; Unit: years",
        file=filename, append=TRUE)
  write_matrix_to_file(mat_storage_lifetime, regions, vec_st_type, 
                       olst_string_init, olst_string_def, filename)
  
  mat_capital_costs_st <- matrix(storage_costs_raw$capital_cost__k_euro_mwh, nrow=length(vec_st_type), ncol=no_years,
                                 byrow=T)
  
  ccst_string_init <- "param CapitalCostStorage\tdefault\t99999\t:="
  ccst_string_def <- "[TUNISIA,*,*]\t:"
  write("
  # CapitalCostStorage{r in REGION, s in STORAGE, y in YEAR}; Unit: k€/MWa",
        file=filename, append=TRUE)
  write_matrix_to_file(mat_capital_costs_st, vec_st_type, years, ccst_string_init, ccst_string_def, filename)
  
  #  ToDo! check units here! MWa???
  
  vec_st_decommissioning_year <- storage_list_raw$commissioning_year + storage_list_raw$storage_lifetime__a
  storage_lifeinfo <- as.data.frame(cbind(storage_list_raw$id, storage_list_raw$name, storage_list_raw$commissioning_year,
                                          storage_list_raw$storage_lifetime__a, storage_list_raw$capacity__mwh, 
                                          storage_list_raw$storage_type_name, vec_st_decommissioning_year)) 
  colnames(storage_lifeinfo) <- c(colnames(storage_list_raw[,c(1,2,6,10,3,9)]), "decommissioning_year")
  
  storage_lifeinfo$decommissioning_year <- as.numeric(as.character(storage_lifeinfo$decommissioning_year))
  storage_lifeinfo$capacity__mwh <- as.numeric(as.character(storage_lifeinfo$capacity__mwh))
  
  mat_write_st_phaseout <- matrix(0, nrow=length(vec_st_type_exist), ncol=no_years)
  rownames(mat_write_st_phaseout) <- vec_st_type_exist
  colnames(mat_write_st_phaseout) <- years
  
  for (y in numvec_years)
  {
    mat_storage_phaseout <- as.data.frame(phaseout(y, vec_instcap=storage_lifeinfo$capacity__mwh, 
                                                   vec_decom=storage_lifeinfo$decommissioning_year, 
                                                   vec_pptype=storage_lifeinfo$storage_type_name))  
    mat_write_st_phaseout[which(rownames(mat_write_st_phaseout) %in% mat_storage_phaseout$type),
                          which(colnames(mat_write_st_phaseout) == y)] <- mat_storage_phaseout$residual_capacity
  }
  
  stpo_string_init <- "param ResidualStorageCapacity\tdefault\t0\t:=\t"
  stpo_string_def <- "[TUNISIA,*,*]\t:\t"
  
  write("
  # ResidualStorageCapacity{r in REGION, s in STORAGE, y in YEAR}; 
  # Storage capacity which is available from before the modelling period, or which is know to become available in a specific year. Unit: MWa",
  file=filename, append=TRUE)
  write_matrix_to_file(mat_write_st_phaseout, vec_st_type_exist, years, stpo_string_init,
                       stpo_string_def, filename)
  
} else {
  write(" # StorageMaxChargeRate{r in REGION, s in STORAGE}; Unit: MW
        param StorageMaxChargeRate	default	0	:=	;",
        file=filename, append=TRUE)
  write(" # StorageMaxDischargeRate{r in REGION, s in STORAGE}; Unit: MW
param StorageMaxDischargeRate	default	0	:=	;
        
# MinStorageCharge{r in REGION, s in STORAGE, y in YEAR}; Unit: fraction of MaxStorageCharge, i.e., between 0.00 and 0.99.
param MinStorageCharge	default	0	:= ;
        
# OperationalLifeStorage{r in REGION, s in STORAGE}; Unit: years
param OperationalLifeStorage	default	99	:=	;
        
# CapitalCostStorage{r in REGION, s in STORAGE, y in YEAR}; Unit: k€/MWa
param CapitalCostStorage	default	99999	:=	;
        
# ResidualStorageCapacity{r in REGION, s in STORAGE, y in YEAR}; 
# Storage capacity which is available from before the modelling period, or which is know to become available in a specific year. Unit: MWa
param ResidualStorageCapacity	default	0	:= ;",
        file=filename, append=TRUE)

}




#-------MILP-CONSTRAINTS-----------------------------------------------------
write("
# CapacityOfOneTechnologyUnit{r in REGION, t in TECHNOLOGY, y in YEAR}; Unit: GW
# Defines the minimum size of one capacity addition. If set to zero, no mixed integer linear programming (MILP) is used and computational time will decrease.																		
param CapacityOfOneTechnologyUnit\tdefault\t0\t:=\t;",
      file=filename, append=TRUE)


#-------TRADE-ROUTES-----------------------------------------------------
write("
#
# TradeRoute{r in REGION, rr in REGION, f in FUEL, y in YEAR}
# Defines which region r is linked with which region rr in order to enable or disable trading of a specific fuel. Unit: Fraction, either 1 or 0
# 1 defines a trade link and 0 ensuring that no trade occurs. Values inbetween are not allowed. If r is linked to rr, rr has also to be linked with r.
# I.e., for one specific year and fuel, this parameter is entered as a symmetric matrix (with a diagonal of zeros).
param TradeRoute default	0 :=
  ;																											
end;", file=filename, append=TRUE)

