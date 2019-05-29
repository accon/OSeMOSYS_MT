# -------------------------------------------------------------------
# Plotting Routine for OSeMOSYS Input File
# -------------------------------------------------------------------
# Created by Niklas Wulff in the course of his Master Thesis between 01-01-2017 and 9-11-2017.

#-------Introductory Section-------------------------------------------------------------

# Initializing Packages
packages <- c("data.table","ggplot2", "grid", "gridExtra","ggvis", "abind", "RColorBrewer")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

wd_func <- "/home/accon/GIZ/MAy/R/functions/"
# Initializing User-Defined-Functions (UDFs)
source(paste(wd_func, "data_extraction.R", sep=""))
source(paste(wd_func, "trim_data.R", sep=""))

# Define scaling function for decimal places for axes in ggplot2()
scaleFUN <- function(x) sprintf("%.6f", x)

setwd("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_MR2/")
filename_input <- "OSeMOSYS_input_MR2_1c_TSP.txt"

#-------Read in Sets and Time Information-------------------------------------------------------------

emissions_raw <- read.table(file=filename_input, header=F, 
                            skip = grep("set EMISSION", readLines(filename_input))-1, nrow=1, fill=T)
emissions <- as.character(emissions_raw[,-c(1:3,length(emissions_raw))])


technologies_raw <- read.table(file=filename_input, header=F, 
                               skip = grep("set TECHNOLOGY", readLines(filename_input))-1, nrow=1, fill=T)
technologies <- as.character(lapply(technologies_raw[,-c(1:3,length(technologies_raw))],as.character))


fuel_raw <- read.table(file=filename_input, header=F, 
                               skip = grep("set FUEL", readLines(filename_input))-1, nrow=1, fill=T)
fuel <- fuel_raw[,-c(1:3,length(fuel_raw))]

years_raw <- read.table(file=filename_input, header=F, 
                        skip = grep("set YEAR", readLines(filename_input))-1, nrow=1, fill=T)
years <- as.character(years_raw[-c(1:3,ncol(years_raw))])
no_years <- length(years)

timeslices_raw <- read.table(file=filename_input, header=F, 
                       skip = grep("set TIMESLICE", readLines(filename_input))-1, nrow=1, fill=T)
timeslices_wDu <- as.character(lapply(timeslices_raw[-c(1:3,ncol(timeslices_raw))],as.character)) #a little bit complicated but I had to convert factors to characters
timeslices <- timeslices_wDu[-c(length(timeslices_wDu))]
timeslices_ord <- timeslices[c(grep("Wi", timeslices), grep("In", timeslices), grep("Su", timeslices), 
                               grep("Ra", timeslices))]
no_timeslices <- length(timeslices)

operationmode_raw <- read.table(file=filename_input, header=F, 
                        skip = grep("set MODE_OF_OPERATION", readLines(filename_input))-1, nrow=1, fill=T)
operationmode <- as.character(operationmode_raw[-c(1:3,ncol(operationmode_raw))])

regions_raw <- read.table(file=filename_input, header=F, 
                          skip = grep("set REGION", readLines(filename_input))-1, nrow=1, fill=T)
regions <- as.character(regions_raw[,-c(1:3,ncol(regions_raw))])

seasons_raw <- read.table(file=filename_input, header=F, 
                          skip = grep("set SEASON", readLines(filename_input))-1, nrow=1, fill=T)
seasons <- as.character(seasons_raw[,-c(1:3,ncol(seasons_raw))])

#-------Set Manual Labels, Synonyms and Color Vectors---------------------

vec_seasons <- c("1" = "Winter","2" = "Intermediary", "3" = "Summer","4" = "Ramadan")
vec_linetypes <- c("solid", "solid", "twodash", "twodash", "twodash", "solid", 
                   "solid", "longdash", "solid", "twodash", "twodash", "solid", 
                   "longdash")
names(vec_linetypes) <- technologies[which(technologies != "backup_electricity")]
vec_synonyms_tech <- c("Wind Onshore", "PV Utility-Scale", "Steam Turbine", 
                       "OCGT", "CCGT", "Hydro - Run of River", "Hydro - Storage", 
                       "Supply of Natural Gas", "Backup Electricity", "CSP Collector", 
                       "CSP Gas Firing", "CSP Steam Turbine", "PV Decentralized", "Battery Converter")
names(vec_synonyms_tech) <- technologies
vec_colors <- c(brewer.pal(8, "Set1"), brewer.pal(5, "Dark2"))
names(vec_colors) <- technologies[which(technologies != "backup_electricity")]
#-------Initialize Empty Lines and Square-bracket-lines----------------------------------------------

empty_lines <- grep("^$", readLines(filename_input))
sq_brac_lines <- grep("\\[", readLines(filename_input))
#-------Read in timeslice to season conversion-------------------------------------

line_conversionls <- grep("param Conversionls", readLines(filename_input))
no_lines_actual <- min((empty_lines - line_conversionls)[which(
  (empty_lines - line_conversionls) > 0)])-2 # -2 for parameter-line and header-line. This identifies only the number of lines of the data.

conversion_ts_season_raw <- read.table(file=filename_input, header=T, 
                                       skip = line_conversionls, 
                                       nrow=no_lines_actual, fill=T)
conversion_ts_season <- conversion_ts_season_raw[,-c(1,length(seasons)+2,length(seasons)+3)]
rownames(conversion_ts_season) <- timeslices
colnames(conversion_ts_season) <- seasons
#-------Plot YearSplit and TimeSlices-------------------------------------------------------------

data_YearSplit_raw <- read.table(file=filename_input, header=T, 
                skip = grep("param YearSplit", readLines(filename_input))-1, 
                nrow=no_timeslices, fill=T)    #readLines has to be reduced by 1 b/c the data already begins in the line with the string-identifier

data_YearSplit_neat <- data_YearSplit_raw[,-which(is.na(data_YearSplit_raw[1,]))]
colnames(data_YearSplit_neat)[c(2:length(data_YearSplit_neat))] <- as.character(years) 
colnames(data_YearSplit_neat)[1] <- "TimeSlice"
val_YS <- data_YearSplit_neat[1,2]

data_YearSplit_dt <- melt(data_YearSplit_neat)

plot_YearSplit <- ggplot(data_YearSplit_dt, aes(x=variable, y=value, fill=TimeSlice))
plot_YearSplit <- plot_YearSplit + geom_bar(stat="identity", colour="black")
plot_YearSplit <- plot_YearSplit + ylab("Yearly Share of TimeSlice")
plot_YearSplit <- plot_YearSplit + xlab("Modelling Year")
plot_YearSplit <- plot_YearSplit + ggtitle("Time Slicing")
plot_YearSplit <- plot_YearSplit + labs(fill="TimeSlice")
plot_YearSplit <- plot_YearSplit + scale_x_discrete(breaks=years)
plot_YearSplit <- plot_YearSplit + scale_y_continuous(breaks=c(0, val_YS, 3*val_YS, 
                          seq(from=val_YS, to=sum(data_YearSplit_neat[,2]), length.out = 4)), 
                          labels=scaleFUN)

png(paste("Plots/", substr(filename_input, 1, (nchar(filename_input)-4)), "_input_timeslicing.png", sep=""), 
    width=800, height=500)
plot(plot_YearSplit)
dev.off()

#-------Plot Demand-------------------------------------------------------------

line_actual_section <- grep("param AccumulatedAnnualDemand", readLines(filename_input))
line_stop <- grep("# SpecifiedAnnualDemand", readLines(filename_input))

line_actual_section <- grep("param SpecifiedAnnualDemand", readLines(filename_input))
no_lines_actual <- min((empty_lines - line_actual_section)[which(
  (empty_lines - line_actual_section) > 0)])-2 # -2 for parameter-line and header-line. This identifies only the number of lines of the data.

data_SpecAnnualDemand_raw <- read.table(file=filename_input, header=T, 
                                         skip = line_actual_section, 
                                         nrow=no_lines_actual, fill=T)  # -2 for param...-line and header-line. see above about numbers in code

technologies_SpecDemand <- data_SpecAnnualDemand_raw[,1]
no_SpecDemandProfiles <- length(technologies_SpecDemand)
data_SpecAnnualDemand_neat <- data_SpecAnnualDemand_raw[,-c(1,no_years+2,no_years+3)]
rownames(data_SpecAnnualDemand_neat) <- technologies_SpecDemand
colnames(data_SpecAnnualDemand_neat) <- years

line_actual_section <- grep("param SpecifiedDemandProfile", readLines(filename_input))
mat_sdp_raw <- as.matrix(read.table(file=filename_input, header=T,  # sdp = specific demand profile
                     skip = line_actual_section, 
                     nrow=no_timeslices, fill=T))  #see above about numbers in code
vec_timeslices_demand <- mat_sdp_raw[,1]

data_SpecDemandProfile_array <- array(0, dim=c(no_timeslices, no_years, no_SpecDemandProfiles),
                                    dimnames = list(vec_timeslices_demand, years, technologies_SpecDemand))

# Allways run this for loop with the correct initial value of line_actual_section!!
for (i in c(1:no_SpecDemandProfiles))
{
  data_SpecDemandProfile_array[,,i] <- as.matrix(read.table(file=filename_input, header=T, 
                                                            skip = line_actual_section, 
                                                            nrow=no_timeslices, fill=T)[,-c(1,no_years+2,no_years+3)])  #see above about numbers in code
  data_SpecDemandProfile_array[,,i] <-  sweep(data_SpecDemandProfile_array[,,i], MARGIN=2, as.numeric(data_SpecAnnualDemand_neat[i,]),'*')
    
  line_actual_section <- line_actual_section + no_timeslices + 2
}

data_SpecDemandProfile_dt <- melt(data_SpecDemandProfile_array)

conversion_ts_season_new <- conversion_ts_season
conversion_ts_season_new <- sapply(as.numeric(colnames(conversion_ts_season)), function(x) conversion_ts_season[,x]*x)
vec_conversion_ts_season <- as.vector(conversion_ts_season_new)[which(as.vector(conversion_ts_season_new) != 0)]
#vec_conversion_ts_season_orddem <- vec_conversion_ts_season[c(25:48,49:72,1:24,73:96)]
vec_conversion_ts_season_all <- rep(vec_conversion_ts_season, no_years)

data_SpecDemandProfile_dt$season <- 0
data_SpecDemandProfile_dt$season <- vec_conversion_ts_season_all  
data_SpecDemandProfile_dt$Var2 <- as.factor(data_SpecDemandProfile_dt$Var2)
data_SpecDemandProfile_dt$Var2 <- factor(data_SpecDemandProfile_dt$Var2, 
                                         levels = rev(levels(data_SpecDemandProfile_dt$Var2)))
data_SpecDemandProfile_dt$season <- factor(data_SpecDemandProfile_dt$season, 
                                           levels = c(3,2,1,4))

plot_SpecDemandProfile <- ggplot(data=data_SpecDemandProfile_dt, aes(x=Var1, y=value))
plot_SpecDemandProfile <- plot_SpecDemandProfile + geom_line(aes(color=factor(Var2), group=factor(Var2)))

plot_SpecDemandProfile <- plot_SpecDemandProfile + facet_grid(.~season, scales="free", 
                                                              labeller = as_labeller(vec_seasons)) 
plot_SpecDemandProfile <- plot_SpecDemandProfile + ylab("Demand per TimeSlice in MWh")
x_breaks <- timeslices[round(seq(1,length(timeslices), length(timeslices)/16), 0)]
plot_SpecDemandProfile <- plot_SpecDemandProfile + scale_x_discrete(breaks=x_breaks)
plot_SpecDemandProfile <- plot_SpecDemandProfile + xlab("TimeSlice")
plot_SpecDemandProfile <- plot_SpecDemandProfile + ggtitle("Electricity Demand Profiles for Different Seasons and Modeling Years")
plot_SpecDemandProfile <- plot_SpecDemandProfile + scale_color_discrete("Modeling Year")
plot_SpecDemandProfile <- plot_SpecDemandProfile + theme (axis.text = element_text(size=14), 
                                                          axis.title = element_text(size=16, face="bold"),
                                                          legend.text= element_text(size=14),
                                                          legend.title = element_text(size=14, face="bold"),
                                                          plot.title = element_text(size=18, face="bold"),
                                                          strip.text.x=element_text(size=12))
# dev.new()
# plot(plot_SpecDemandProfile)
png(paste("Plots/", substr(filename_input, 16, (nchar(filename_input)-4)), "_input_demand_series.png", sep=""), 
    width=1000, height=500)
plot(plot_SpecDemandProfile)
dev.off()

#-------Plot Cost----------------------------------------------------------

# Fixed Costs
fixed_costs_raw <- data_extraction(filename_input, "param FixedCost", log_head=TRUE) 
technologies_fixedcosts <- fixed_costs_raw[,1]
fixed_costs <- trim_data(fixed_costs_raw, 1,c(length(years)+2, length(years)+3))
factor_index <- sapply(fixed_costs, is.factor)
fixed_costs[factor_index] <- lapply(fixed_costs[factor_index], 
                                        function(x) as.numeric(as.character(x)))
rownames(fixed_costs) <- technologies_fixedcosts
colnames(fixed_costs) <- years

mat_append <- matrix(NA, ncol=length(years), nrow=length(technologies[which(!technologies %in% rownames(fixed_costs))]))
colnames(mat_append) <- colnames(fixed_costs)
rownames(mat_append) <- technologies[which(!technologies %in% rownames(fixed_costs))]

fixed_costs_all <- rbind(fixed_costs, mat_append)
fixed_costs_melted <- melt(as.matrix(fixed_costs_all))
fixed_costs_melted <- cbind(fixed_costs_melted, "fix_costs")
colnames(fixed_costs_melted)[4] <- "Var3"


# Capital Costs
capital_costs_raw <- data_extraction(filename_input, "param CapitalCost\t", log_head=TRUE)
capital_costs <- trim_data(capital_costs_raw, 1,c(length(years)+2, length(years)+3))
factor_index <- sapply(capital_costs, is.factor)
capital_costs[factor_index] <- lapply(capital_costs[factor_index], 
                                    function(x) as.numeric(as.character(x)))
rownames(capital_costs) <- technologies
colnames(capital_costs) <- years

capital_costs_melted <- melt(as.matrix(capital_costs))
capital_costs_melted <- cbind(capital_costs_melted, "cap_costs")
colnames(capital_costs_melted)[4] <- "Var3"


# Variable Costs
variable_costs_raw <- data_extraction(filename_input, "param VariableCost", log_head=TRUE) 
technologies_varcosts <- as.character(variable_costs_raw[,1])
variable_costs <- trim_data(variable_costs_raw, 1,c(length(years)+2, length(years)+3))
factor_index <- sapply(variable_costs, is.factor)
variable_costs[factor_index] <- lapply(variable_costs[factor_index], 
                                        function(x) as.numeric(as.character(x)))

rownames(variable_costs) <- technologies_varcosts
colnames(variable_costs) <- years

mat_append <- matrix(NA, ncol=length(years), nrow=length(technologies[which(!technologies %in% rownames(variable_costs))]))
colnames(mat_append) <- colnames(variable_costs)
rownames(mat_append) <- technologies[which(!technologies %in% rownames(variable_costs))]

variable_costs_all <- rbind(variable_costs, mat_append)
variable_costs_melted <- melt(as.matrix(variable_costs_all))

variable_costs_melted <- cbind(variable_costs_melted, "var_costs")
colnames(variable_costs_melted)[4] <- "Var3"

data_costs_raw <- rbind(fixed_costs_melted, capital_costs_melted, variable_costs_melted)
data_costs <- data_costs_raw[which(data_costs_raw$Var1 != "backup_electricity"),]

# Reordering factor levels of cost types 
vec_lvl <- levels(data_costs$Var3)
data_costs$Var3 <- factor(data_costs$Var3, levels = vec_lvl[c(2,1,3)])

# Plot costs
plot_costs <- ggplot(data=data_costs, aes(x=Var2, y=value, group=factor(Var1), col=Var1, linetype=Var1))
plot_costs <- plot_costs + geom_line(aes(colour=factor(Var1)))
facet_labeller <- c("fix_costs" = "Fixed Costs in 10^3 €/MW","cap_costs" = "Capital Costs in 10^3 €/MW",
                                            "var_costs" = "Variable Costs in 10^3 €/MWh")
plot_costs <- plot_costs + facet_grid(Var3~., scales="free", labeller = as_labeller(facet_labeller)) 
plot_costs <- plot_costs + ylab("Costs in Different Units. Logarithmic Scale.")
plot_costs <- plot_costs + xlab("Modeling Year")
plot_costs <- plot_costs + ggtitle("Assumed Fixed, Capital and Variable Costs")
plot_costs <- plot_costs + scale_linetype_manual("Power Plant Technologies", labels = vec_synonyms_tech, values=vec_linetypes)
plot_costs <- plot_costs + scale_color_manual("Power Plant Technologies", labels = vec_synonyms_tech, values= vec_colors)
plot_costs <- plot_costs + theme (axis.text = element_text(size=14), 
                                  axis.title = element_text(size=16, face="bold"),
                                  legend.text= element_text(size=14),
                                  legend.title = element_text(size=14, face="bold"),
                                  plot.title = element_text(size=18, face="bold"),
                                  strip.text.x=element_text(size=12))
png(paste("Plots/", substr(filename_input, 16, (nchar(filename_input)-4)), "_input_costs.png", sep=""), 
    width=500, height=500)
plot(plot_costs)
dev.off()

#-------Residual capacity (not in use - plotted from output together with new capacity)-----------------------------------------------------------------------

# residual_capacity_raw <- data_extraction(filename_input, "param\tResidualCapacity", log_head=T)
# technologies_residual_cap <- residual_capacity_raw[,1]
# residual_capacity <- trim_data(residual_capacity_raw, 1, c(no_years+2, no_years+3))
# colnames(residual_capacity) <- years
# rownames(residual_capacity) <- technologies_residual_cap
# 
# factor_index <- sapply(residual_capacity, is.factor)
# residual_capacity[factor_index] <- lapply(residual_capacity[factor_index], 
#                                           function(x) as.numeric(as.character(x)))
#-------Availability and capacity factors-----------------------------------------------------------------------

# Availability Factors
availability_factors_raw <- data_extraction(filename_input, "param AvailabilityFactor", log_head=F)   # Check if availability factors work if data is provieded
technologies_availability_fac <- availability_factors_raw[,1]
availability_factors <- trim_data(availability_factors_raw, 1, c(no_years+2, no_years+3))
colnames(availability_factors) <- years
rownames(availability_factors) <- technologies_availability_fac

factor_index <- sapply(availability_factors, is.factor)
availability_factors[factor_index] <- lapply(availability_factors[factor_index], 
                                             function(x) as.numeric(as.character(x)))

# capacity factors (cf)
line_init_cf <- grep("param CapacityFactor", readLines(filename_input))
line_next_section <- grep("param EmissionActivityRatio", readLines(filename_input))
lines_technology <- readLines(filename_input)[sq_brac_lines[which(sq_brac_lines > line_init_cf & sq_brac_lines < line_next_section)]]
index_technology_raw <- sapply(technologies, function(x) grep(x, lines_technology))
index_technology <- unlist(index_technology_raw[which(index_technology_raw > 0)])
cf_technologies <- sort(names(index_technology), index_technology, decreasing=FALSE)

capacity_factors_raw <- data_extraction(filename_input, pattern="param CapacityFactor", 
                                        end_pattern="param EmissionActivityRatio", log_head=T)
capacity_factors_trim <- trim_data(capacity_factors_raw, 1, c(no_years+2, 
                                                              no_years+3))[which(capacity_factors_raw[,2] != ":"),]
factor_index <- sapply(capacity_factors_trim, is.factor)
capacity_factors_trim[factor_index] <- lapply(capacity_factors_trim[factor_index], 
                                             function(x) as.numeric(as.character(x)))

no_matrices <- length(which(capacity_factors_raw[,2] == ":"))
vec_split <- rep(c(1:no_matrices), each=no_timeslices)
mat_split <- matrix(vec_split, ncol=no_years, nrow=no_timeslices*no_matrices)
arr_capacity_factors <- abind(split(capacity_factors_trim, mat_split), along=3)
dimnames(arr_capacity_factors) <- list(timeslices_ord, years, cf_technologies)

data_capacity_factor_series <- melt(arr_capacity_factors)

data_capacity_factor_series$season <- 0
data_capacity_factor_series$season <- rep(vec_conversion_ts_season_all,no_matrices)  

plot_cf <- ggplot(data=data_capacity_factor_series, aes(x=Var1, y=value))
plot_cf <- plot_cf + geom_line(aes(color=factor(Var2), group=factor(Var2)))
facet_labeller <- c(vec_seasons, vec_synonyms_tech)
plot_cf <- plot_cf + facet_grid(Var3~season, scales="free", labeller = as_labeller(facet_labeller)) 
plot_cf <- plot_cf + ylab("Demand per TimeSlice in MWh")
x_breaks <- timeslices[round(seq(1,length(timeslices), length(timeslices)/16), 0)]
plot_cf <- plot_cf + scale_x_discrete(breaks=x_breaks)
plot_cf <- plot_cf + xlab("TimeSlice")
plot_cf <- plot_cf + ggtitle("Demand Profiles for different Demands")
plot_cf <- plot_cf + scale_color_discrete("Modeling Year")
plot_cf <- plot_cf + theme (axis.text = element_text(size=14), 
                              axis.title = element_text(size=16, face="bold"),
                              legend.text= element_text(size=14),
                              legend.title = element_text(size=14, face="bold"),
                              plot.title = element_text(size=18, face="bold"),
                              strip.text.x=element_text(size=12),
                              strip.text.y=element_text(size=12))
# dev.new()
# plot(plot_cf)
png(paste("Plots/", substr(filename_input, 16, (nchar(filename_input)-4)), 
          "_input_capacity_factor_series.png", sep=""), width=800, height=400)
plot(plot_cf)
dev.off()


#-------SANDBOX-----------------------------------------

# # Reserve Margins