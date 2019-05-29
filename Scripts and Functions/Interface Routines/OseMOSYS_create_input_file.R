# --------------------------------------------------------------------------
# Creation of input for OSeḾOSYS optimization problem
# --------------------------------------------------------------------------

# Introductory Section
# --------------------------------------------------------------------------

# Set working directory
setwd("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_MR1")
wdmodstruc <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Model-Structure/"
wdtech <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Technology/"
wdprofiles <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Profiles/"
wdeco <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Data/Economic/"

filename <- "OSeMOSYS_input_fromDB.txt"

# Create File
write.table(filename)
fileConn <- file(filename)

# Start writing process
#----------------------------------------------------------------------------

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
#	Energy and demands in PJ/a																							
#	Power plants in GW																							
#	Investment and Fixed O&M Costs: Power plant: Million $ / GW (//$/kW)																							
#	Other plant costs: Million $/PJ/a																							
#	Variable O&M (& Import) Costs: Million $ / PJ (//$/GJ)																							
#
#****************************************		", fileConn)

write("
param	AnnualExogenousEmission			default	0		:=	; 
param	AnnualEmissionLimit				default	9999	:=	;
param	ModelPeriodExogenousEmission	default	0		:=	;
param	ModelPeriodEmissionLimit		default	9999	:=	;

#****************************************																							
set	EMISSION			:=	CO2	;", file=filename, append=TRUE)	


# Write the Set of all Technologies including Resource- and Fuel-Supply, Power-Plants and Demands
pp_list_raw <- read.csv(paste(wdtech, "Tech_PP-List_MR0.csv", sep=""), skip=3, header=TRUE, sep=",")
pp_types_raw <- unique(as.character(pp_list_raw$pp.type))
pp_types <- pp_types_raw[-which(pp_types_raw == "")]
fuels_raw <- read.csv(paste(wdtech, "Tech_Resources-List_MR0.csv", sep=""), skip=3, header=TRUE, sep=",")
fuels_name <- paste("Supply_",as.character(fuels_raw$Name), sep="")

demand_raw <- read.csv(paste(wdtech, "Tech_Set_Demand_MR0.csv", sep=""), skip=3, header=TRUE, sep=",") 
demand <- as.character(demand_raw$Name)
technologies_raw <- c(unique(as.character(pp_list_raw$pp.type)), fuels_name,
                  as.character(demand_raw$Name))
technologies <- technologies_raw[-which(technologies_raw == "")]

technology_str <- paste(technologies, collapse="\t")
technology_str <- paste("set TECHNOLOGY\t:=\t", technology_str, ";", sep="")
write(technology_str, file=filename, append=TRUE)


# Write the Set of Fuels
fuels <- as.character(fuels_raw$Name)
fuels_str <- paste(fuels, collapse="\t")
fuels_str <- paste("set FUEL\t:=\t", fuels_str, ";", sep="")
write(fuels_str, file=filename, append=TRUE)

years_raw <- read.csv(paste(wdmodstruc, "Time_Set_Years.csv", sep=""), header=TRUE, sep=",")
years <- as.character(years_raw$Years)
years_str <- paste(years_raw, sep="", collapse="")
years_str <- gsub("c\\(", "", years_str)
years_str <- gsub("\\)", "", years_str)
years_str <- gsub(", ", "\t", years_str)
years_str <- paste("set YEAR\t:=\t", years_str, ";", sep="")

write(years_str, file=filename, append=TRUE)

timeslices_raw <- read.csv(paste(wdmodstruc, "Time_Set_TimeSlice.csv", sep=""), header=TRUE, sep=",")
timeslices <- as.character(timeslices_raw$TimeSlices)
timeslices_str <- paste(timeslices_raw$TimeSlices, collapse="\t")
timeslices_str <- paste("set TIMESLICE\t:=\t", timeslices_str, ";", sep="")

write(timeslices_str, file=filename, append=TRUE)


write("							
set	MODE_OF_OPERATION	:=	1 2	;", file=filename, append=TRUE)

# Write Region-Set
regions_raw <- read.csv(paste(wdmodstruc, "Space_Set_Regions.csv", sep=""), header=TRUE, sep=",")
regions <- as.character(regions_raw$Regions)
regions_str <- paste(regions_raw$Regions, collapse="\t")
regions_str <- paste("set REGION\t:=\t", regions_str, ";", sep="")
write(regions_str, file=filename, append=TRUE)

# Write Time Info - Sets
timeinfo_raw <- read.csv(paste(wdmodstruc, "Time_Info.csv", sep=""), header=FALSE, sep=",")
no_seasons <- timeinfo_raw$V2[1]
no_daytypes <- timeinfo_raw$V2[2]
no_dailybrackets <- timeinfo_raw$V2[3]

seasons_vec <- c(1:no_seasons)
seasons_str <- paste(seasons_vec, collapse="\t")
seasons_str <- paste("set SEASON\t:=\t", seasons_str, ";", sep="")
write(seasons_str, file=filename, append=TRUE)

daytypes_vec <- c(1:no_daytypes)
daytypes_str <- paste(daytypes_vec, collapse="\t")
daytypes_str <- paste("set DAYTYPE\t:=\t", daytypes_str, ";", sep="")
write(daytypes_str, file=filename, append=TRUE)

dailybrackets_vec <- c(1:no_dailybrackets)
dailybrackets_str <- paste(dailybrackets_vec, collapse="\t")
dailybrackets_str <- paste("set DAILYTIMEBRACKET\t:=\t", dailybrackets_str, ";", sep="")
write(dailybrackets_str, file=filename, append=TRUE)


storage_vec <- unique(as.character(pp_list_raw$pp.type[which(pp_list_raw$Fuel == "Storage")]))
storage_str <- paste(storage_vec, collapse="\t")
storage_str <- paste("set STORAGE\t:=\t", storage_str, ";", sep="")
write(storage_str, file=filename, append=TRUE)

write("	
param DiscountRate default 0.05 :=;
#
# DepreciationMethod; equal to 1 for Sinking Fund and 2 for Straight Line Depreciation
param DepreciationMethod default 1 :=;
      
#
# YearSplit{l in TIMESLICE, y in YEAR}  Units: Fraction of 8760 hours
# The fraction of the year in each time slice.", file=filename, append=TRUE)

# Create and Write YearSplit to define the yearly amount of each TimeSlice
# In this script all timeslices have equal length

length_timeslice <- 1/nrow(timeslices_raw)
yearsplit_mat <- matrix(c(length_timeslice), nrow=nrow(timeslices_raw)+1, ncol=nrow(years_raw)+1)
yearsplit_mat[2:nrow(yearsplit_mat),1] <- paste(as.character(timeslices_raw$TimeSlices), 
                                                paste(rep("\t", 5),collapse=""), sep="")
yearsplit_mat[1,2:ncol(yearsplit_mat)] <- as.character(years_raw$Years)
yearsplit_mat[1,1] <- "param\tYearSplit\t:"
yearsplit_mat[nrow(yearsplit_mat), ncol(yearsplit_mat)] <- 
  paste(yearsplit_mat[nrow(yearsplit_mat), ncol(yearsplit_mat)],"; \n \n",sep="")

write.table(yearsplit_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)

write("
#
# AccumulatedAnnualDemand{r in REGION, f in FUEL, y in YEAR}  Units: PJ
# This type of demand can be satisfied at any time of the year, as long as the total is met.
param	AccumulatedAnnualDemand	default	0	:=	;
      																								
#
# SpecifiedAnnualDemand{r in REGION, f in FUEL, y in YEAR}  Units: PJ
# The annual requirement for each output fuel.", file=filename, append=TRUE)

load_profile_raw <- read.csv(paste(wdprofiles, "Profiles_LoadProfile.csv", sep=""), 
                             header=TRUE, skip=1, sep=",")
yearly_demand_raw <- sapply(load_profile_raw[,2:ncol(load_profile_raw)], function(x) sum(x, na.rm=TRUE))
names(yearly_demand_raw) <- years_raw$Years
yearly_demand_mat <- matrix(NA, ncol=nrow(years_raw)+1, nrow=2)
yearly_demand_mat[1,2:ncol(yearly_demand_mat)] <- as.character(years_raw$Years)
yearly_demand_mat[2,2:ncol(yearly_demand_mat)] <- yearly_demand_raw
yearly_demand_mat[1,1] <- paste("[", regions_raw$Regions, ",*,*]\t:", sep="")
yearly_demand_mat[2,1] <- as.character(demand_raw$Name)
yearly_demand_mat[2,1] <- as.character(demand_raw$Name)
yearly_demand_mat[nrow(yearly_demand_mat), ncol(yearly_demand_mat)] <- 
  paste(yearly_demand_mat[nrow(yearly_demand_mat), ncol(yearly_demand_mat)],"; \n \n",sep="")

write.table(yearly_demand_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", 
            row.names=F, col.names=F)

write("
#
# SpecifiedDemandProfile{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR} Units: Fraction
# Indicates the proportion of energy demand required in each time slice. For each year the sum must be equal to 1.
param	SpecifiedDemandProfile	default	0	:=", file=filename, append=TRUE)		

load_profiles_df <- load_profile_raw[c(2:nrow(load_profile_raw)), c(2:ncol(load_profile_raw))]
load_profiles <- matrix(unlist(lapply(load_profiles_df,as.numeric)), 
                        ncol=ncol(load_profiles_df), byrow=FALSE)
rownames(load_profiles) <- as.character(timeslices_raw$TimeSlices)
colnames(load_profiles) <- as.character(years_raw$Years)

load_profiles_mat <- matrix(NA, ncol=nrow(years_raw)+1, nrow=nrow(timeslices_raw)+1)
load_profiles_mat[c(2:nrow(load_profiles_mat)), c(2:ncol(load_profiles_mat))] <- load_profiles
load_profiles_mat[c(2:nrow(load_profiles_mat)),1] <- paste(timeslices, 
                                                          paste(rep("\t", 8),collapse=""), sep="")
load_profiles_mat[1,c(2:ncol(load_profiles_mat))] <- years
load_profiles_mat[1,1] <- paste("[", regions, ",", demand, ",*,*] :", sep="")  # bind together different matricies for more than one region
load_profiles_mat[nrow(load_profiles_mat), ncol(load_profiles_mat)] <- 
  paste(load_profiles_mat[nrow(load_profiles_mat), ncol(load_profiles_mat)], ";", sep="")
write.table(load_profiles_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", 
            row.names=F, col.names=F)

write("
																								
#
# CapacityToActivityUnit{r in REGION, t in TECHNOLOGY};  Units: MWh/MW-YR
# Thus here we use a factor of 8760, which is the level of energy production in MWh produced from 1 MW operating for 1 year (1MW * 8760h)", file=filename, append=TRUE)	

captoactunit <- 8760
captoactunit_mat <- matrix(c(captoactunit), nrow=2, ncol=length(pp_types)+1)
captoactunit_mat[1, 2:ncol(captoactunit_mat)] <- pp_types
captoactunit_mat[1,ncol(captoactunit_mat)] <- paste(captoactunit_mat[1,ncol(captoactunit_mat)], 
                                                    "\t:=", sep="")
captoactunit_mat[1,1] <- "param\tCapacityToActivityUnit default 1 :"
captoactunit_mat[2,1] <- paste(regions, paste(rep("\t", 9), collapse=""), sep="")
captoactunit_mat[nrow(captoactunit_mat), ncol(captoactunit_mat)] <- 
  paste(captoactunit_mat[nrow(captoactunit_mat), ncol(captoactunit_mat)],"; \n \n",sep="")

write.table(captoactunit_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)

write("																								
#
# TechWithCapacityNeededToMeetPeakTS{r in Region, t in Technology}  Units: 1=yes, 0=no
# Flags the technologies that can be used to meet the peak demand for the fuel they produce.", file=filename, append=TRUE)


peakflag_mat <- matrix(1, nrow=2, ncol=length(pp_types)+1)
peakflag_mat[1, 2:ncol(peakflag_mat)] <- pp_types
peakflag_mat[1,ncol(peakflag_mat)] <- paste(peakflag_mat[1,ncol(peakflag_mat)], 
                                                    "\t:=", sep="")
peakflag_mat[1,1] <- "param TechWithCapacityNeededToMeetPeakTS default 0 :"
peakflag_mat[2,1] <- paste(regions, paste(rep("\t", 9), collapse=""), sep="")
peakflag_mat[nrow(peakflag_mat), ncol(peakflag_mat)] <- 
  paste(peakflag_mat[nrow(peakflag_mat), ncol(peakflag_mat)],"; \n \n",sep="")

write.table(peakflag_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)

write("
#
# InputActivityRatio{r in REGION, t in TECHNOLOGY, f in FUEL, m in MODE_OF_OPERATION, y in YEAR}  Units: Ratio
# The input (use) of fuel per unit of activity for each technology.
param	InputActivityRatio	default	0	:=	", file=filename, append=TRUE)		

list_efficiencies_raw <- pp_list_raw[-which(is.na(pp_list_raw$Efficiency)), 
                                 c("pp.type", "Fuel", "Efficiency")]
list_efficiencies <- list_efficiencies_raw[which(!duplicated(list_efficiencies_raw$pp.type)),]
for (f in unique(list_efficiencies$Fuel))
{
  list_actual_raw <- list_efficiencies[which(list_efficiencies$Fuel == f),]
  inputratio <- round(1/(list_actual_raw$Efficiency/100), digits=2)
  list_actual <- cbind(list_actual_raw, inputratio)
  inpact_mat <- matrix(1, nrow=nrow(list_actual)+1, ncol=length(years)+1)
  inpact_mat[1, 2:ncol(inpact_mat)] <- years
  inpact_mat[1,ncol(inpact_mat)] <- paste(inpact_mat[1,ncol(inpact_mat)], 
                                              "\t:=", sep="")
  inpact_mat[1,1] <- paste("[", regions, ",*,", f, ",1,*]\t:", sep="")
  inpact_mat[c(2:nrow(inpact_mat)),1] <- paste(as.character(list_actual$pp.type), 
                                                paste(rep("\t", 5), collapse=""), sep="")

  efficiencies_vec <- rep(list_actual$inputratio, times=length(years))
  efficiencies_mat <- matrix(efficiencies_vec, nrow=nrow(list_actual), ncol=length(years))  
  
  inpact_mat[c(2:nrow(inpact_mat)),c(2:ncol(inpact_mat))] <- efficiencies_mat
    
  inpact_mat[nrow(inpact_mat), ncol(inpact_mat)] <- 
    paste(inpact_mat[nrow(inpact_mat), ncol(inpact_mat)],"; \n \n",sep="")
  
  write.table(inpact_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)
}

write("
      																								
# 
# OutputActivityRatio{r in Region, t in Technology, f in Fuel, m in ModeOfOperation, y in Year}  Units: Ratio
# Ratio of output to activity.
# Should be 1 for power plants/electricity, 1 for supply technologies and their respective fuels and zero for rest.
param	OutputActivityRatio	default	0	:=		;	
      
      																								
#	
# FixedCost{r in Region, t in Technology, y in Year} Units: k€/MW of Capacity
# The annual cost per unit of capacity of a technology.
param	FixedCost	default	0	:=						", file=filename, append=TRUE)

costs_raw <- read.csv(paste(wdeco, "cost_MR0.csv", sep=""), skip=3, header=TRUE, sep=",")

fixedcosts_mat <- matrix(1, nrow=nrow(costs_raw)+1, ncol=length(years)+1)
fixedcosts_mat[1, 2:ncol(fixedcosts_mat)] <- years
fixedcosts_mat[1,1] <- paste("[", regions, ",*,*]", sep="")
fixedcosts_mat[c(2:nrow(fixedcosts_mat)),1] <- paste(as.character(costs_raw$pp.type), 
                                                     paste(rep("\t", 5), collapse=""), sep="")

fixedcosts_vec <- rep(costs_raw$Fix.Costs.in.k..MW, times=length(years))
fixedcosts_values <- matrix(fixedcosts_vec, nrow=nrow(costs_raw), ncol=length(years))  

fixedcosts_mat[c(2:nrow(fixedcosts_mat)),c(2:ncol(fixedcosts_mat))] <- fixedcosts_values

fixedcosts_mat[nrow(fixedcosts_mat), ncol(fixedcosts_mat)] <- 
  paste(fixedcosts_mat[nrow(fixedcosts_mat), ncol(fixedcosts_mat)],"; \n \n",sep="")

write.table(fixedcosts_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)

write("
#	
# CapitalCost{r in Region, t in Technology, y in Year} Units: k€/MW Capacity
# Total capital cost (including interest paid during construction)per unit of capacity for new capacity additions
param	CapitalCost	default	0	:=", file=filename, append=TRUE)

capcosts_mat <- matrix(1, nrow=nrow(costs_raw)+1, ncol=length(years)+1)
capcosts_mat[1, 2:ncol(capcosts_mat)] <- years
capcosts_mat[1,1] <- paste("[", regions, ",*,*]", sep="")
capcosts_mat[c(2:nrow(capcosts_mat)),1] <- paste(as.character(costs_raw$pp.type), 
                                                 paste(rep("\t", 5), collapse=""), sep="")

capcosts_vec <- rep(costs_raw$Capital.Costs.in...MW, times=length(years))
capcosts_values <- matrix(capcosts_vec, nrow=nrow(costs_raw), ncol=length(years))  

capcosts_mat[c(2:nrow(capcosts_mat)),c(2:ncol(capcosts_mat))] <- capcosts_values

capcosts_mat[nrow(capcosts_mat), ncol(capcosts_mat)] <- 
  paste(capcosts_mat[nrow(capcosts_mat), ncol(capcosts_mat)],"; \n \n",sep="")

write.table(capcosts_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)

write("
#
# VariableCost{r in Region, t in Technology, m in ModeOfOperation, y in Year} Units: €/MWh 
# Cost per unit of activity of the technology
# This variable records both the nonfuel O&M costs of processes and fuel costs of each fuel supplied to those processes.
param	VariableCost	default	0.00001	:=	", file=filename, append=TRUE)

varcosts_mat <- matrix(1, nrow=nrow(costs_raw)+1, ncol=length(years)+1)
varcosts_mat[1, 2:ncol(varcosts_mat)] <- years
varcosts_mat[1,1] <- paste("[", regions, ",*,*]", sep="")
varcosts_mat[c(2:nrow(varcosts_mat)),1] <- paste(as.character(costs_raw$pp.type), 
                                                 paste(rep("\t", 5), collapse=""), sep="")

varcosts_vec <- rep(costs_raw$Variable.Costs.in...Mwh, times=length(years))
varcosts_values <- matrix(varcosts_vec, nrow=nrow(costs_raw), ncol=length(years))  

varcosts_mat[c(2:nrow(varcosts_mat)),c(2:ncol(varcosts_mat))] <- varcosts_values

varcosts_mat[nrow(varcosts_mat), ncol(varcosts_mat)] <- 
  paste(varcosts_mat[nrow(varcosts_mat), ncol(varcosts_mat)],"; \n \n",sep="")

write.table(varcosts_mat, file=filename, append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)

write("
#	
# ResidualCapacity{r in Region, t in Technology, y in Year} Units: GW
# The capacity left over from periods prior to the modeling period.
param	ResidualCapacity 	default	0	:=", file=filename, append=TRUE)	



# Sandbox
#------------------------------------------------
#pp_type_agg <- aggregate(pp_list_raw, by=pp_list_raw$pp.type, FUN=sum)
