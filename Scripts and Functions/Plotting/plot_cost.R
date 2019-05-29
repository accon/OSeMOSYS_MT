# Display costs of OSeMOSYS result files 
# Author: Niklas Wulff
# Date: 2017-09-09

#------Introductory Section------

# Set Model Run Family
mr_f <- "MR2"
mr <- "1b"
mr_name <- "BAU"

# Set working directory
setwd(paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/", sep=""))
wd_input <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/", sep="")
wd_results <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/Results/", sep="")
wd_plots <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/Plots/", sep="")
wd_model <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/"
filename_output <- paste(mr_f, "_", mr, "_", "SelectedResults_Economic.csv", sep="")
filename_input <- paste("OSeMOSYS_input_", mr_f, "_", mr, "_", mr_name, ".txt", sep="")
wd_input_file <- paste(wd_input, filename_input, sep="")
wd_output_file <- paste(wd_results, filename_output, sep="")

line_nos <- c(grep("", readLines(wd_output_file)))

# Packages
packages <- c("data.table","ggplot2", "RColorBrewer", "grid", "gridExtra", "ggvis", "abind", "scales")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

# Initializing User-Defined-Functions (UDFs)
source("/home/accon/GIZ/MAy/R/functions/data_extraction.R")
source("/home/accon/GIZ/MAy/R/functions/trim_data.R")

#------Initialize empty lines and square-bracket-lines in input-file----------------------------------------------

empty_lines <- grep("^$", readLines(wd_input_file))
sq_brac_lines <- grep("\\[", readLines(wd_input_file))

#------Read-in sets ---------------------------------------------------------

emissions_raw <- data_extraction(file=filename_input, "set EMISSION", no_rows=1, log_head=FALSE)
emissions <- trim_data(emissions_raw, c(1:3), length(emissions_raw))

technologies_raw <- data_extraction(file=filename_input, pattern="set TECHNOLOGY", 
                                    no_rows=1)
technologies <- trim_data(technologies_raw, c(1:3), length(technologies_raw))
technologies <- as.character(lapply(technologies,as.character))
no_technologies <- length(technologies)

fuels_raw <- data_extraction(file=filename_input, pattern="set FUEL", 
                             no_rows=1)
fuels <- trim_data(fuels_raw, c(1:3), length(fuels_raw))
fuels <- as.character(lapply(fuels,as.character))
no_fuels <- length(fuels)

years_raw <- data_extraction(file=filename_input, pattern="set YEAR", 
                             no_rows=1)
years <- trim_data(years_raw, c(1:3), length(years_raw))
years <- as.numeric(lapply(years,as.character))
no_years <- length(years)

all_years <- c(min(years):max(years))
no_all_years <- length(all_years)

timeslices_raw <- data_extraction(file=filename_input, pattern="set TIMESLICE", 
                                  no_rows=1)
timeslices <- trim_data(timeslices_raw, c(1:3), length(timeslices_raw))
timeslices <- as.character(lapply(timeslices,as.character))[-length(timeslices)]
timeslices_ord <- timeslices[c(grep("Wi", timeslices), grep("In", timeslices), grep("Su", timeslices), 
                               grep("Ra", timeslices))]
no_timeslices <- length(timeslices)

operationmodes_raw <- data_extraction(file=filename_input, pattern="set MODE_OF_OPERATION", 
                                      no_rows=1)
operationmodes <- trim_data(operationmodes_raw, c(1:3), length(operationmodes_raw))
operationmodes <- as.character(lapply(operationmodes,as.character))
no_operationmodes <- length(operationmodes)

regions_raw <- data_extraction(file=filename_input, pattern="set REGION", 
                               no_rows=1)
regions <- trim_data(regions_raw, c(1:3), length(regions_raw))
regions <- as.character(lapply(regions,as.character))
no_regions <- length(regions)

seasons_raw <- read.table(file=wd_input_file, header=F, 
                          skip = grep("set SEASON", readLines(wd_input_file))-1, nrow=1, fill=T)
seasons <- as.character(seasons_raw[,-c(1:3,ncol(seasons_raw))])

#------Set Colors, Linetypes and Synonyms for Plotting---------------------------

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
vec_colors <- c(brewer.pal(8, "Set1"), brewer.pal(6, "Dark2"))
names(vec_colors) <- technologies

# Vector to exclude supporting modeling technologies
vec_tech_excl <- c("backup_electricity", "supply_natural_gas", "hydro_stor", "battery_converter")


#------Read-in cost information-----

setwd(wd_results)
line_actual <- grep("Capital Investment", readLines(filename_output))[c(1:2)]
capital_investment_raw <- read.csv(filename_output, header=TRUE, sep=",", 
                                skip = line_actual[1], nrows = no_years)
capital_investment <- capital_investment_raw[,which(!colnames(capital_investment_raw) %in% vec_tech_excl)]
capital_investment$X <- as.character(capital_investment$X)
dt_capital_investment <- melt(capital_investment)
dt_capital_investment$disc <- c("undiscounted")

disc_capital_investment_raw <- read.csv(filename_output, header=TRUE, sep=",", 
                                        skip = line_actual[2], nrows = no_years)
disc_capital_investment <- disc_capital_investment_raw[,which(!colnames(disc_capital_investment_raw) %in% 
                                                                vec_tech_excl)]
disc_capital_investment$X <- as.character(disc_capital_investment$X)
dt_disc_capital_investment <- melt(disc_capital_investment)
dt_disc_capital_investment$disc <- c("discounted")
dt_capex <- rbind(dt_capital_investment, dt_disc_capital_investment)
# Converting from k€ to M€
dt_capex$value <- dt_capex$value/1000

#------Plot CAPEX------
plot_capex <- ggplot(data=dt_capex, aes(x=variable, y=value, fill=disc)) +
  geom_bar(stat="identity", position="dodge") +
  facet_grid(X~., scales="free") +
  ylab("CAPEX in M€ (2016)") +
  xlab("Modeling Years") +
  ggtitle("CAPEX Undiscounted and Discounted in 2016-€") +
  scale_color_discrete("Modeling Year") +
  theme (axis.text.x = element_text(size=12, angle=90, hjust=1),
         axis.text.y = element_text(size=14),
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=18, face="bold"),
         strip.text.x=element_text(size=12))
dev.new()
plot(plot_capex)
png(paste(wd_plots, substr(filename_input, 16, (nchar(filename_input)-4)), "_CAPEX_differentiated.png", sep=""), 
    width=600, height=600)
plot(plot_capex)
dev.off()


#-------OPEX-------
setwd(wd_results)
line_actual <- grep("Operating Cost", readLines(filename_output))
opex_annual_raw <- read.csv(filename_output, header=TRUE, sep=",", 
                                   skip = line_actual[1], nrows = no_years)
opex_annual <- opex_annual_raw[,which(!colnames(opex_annual_raw) %in% vec_tech_excl)]
opex_annual$X <- as.character(opex_annual$X)
dt_opex_annual <- melt(opex_annual)
dt_opex_annual$disc <- c("undiscounted")

disc_opex_annual_raw <- read.csv(filename_output, header=TRUE, sep=",", 
                                        skip = line_actual[3], nrows = no_years)
disc_opex_annual <- disc_opex_annual_raw[,which(!colnames(disc_opex_annual_raw) %in% 
                                                                vec_tech_excl)]
#disc_opex_annual <- disc_opex_annual[,-c(1)]
disc_opex_annual$X <- as.character(disc_opex_annual$X)
#colnames(disc_opex_annual)[1] <- "X"
dt_disc_opex_annual <- melt(disc_opex_annual)
dt_disc_opex_annual$disc <- c("discounted")
dt_opex <- rbind(dt_opex_annual, dt_disc_opex_annual)
# Converting from k€ to M€
dt_opex$value <- dt_opex$value/1000

plot_opex <- ggplot(data=dt_opex, aes(x=variable, y=value, fill=disc)) +
  geom_bar(stat="identity", position="dodge") +
  facet_grid(X~., scales="free") +
  ylab("OPEX in M€ (2016)") +
  xlab("Modeling Years") +
  ggtitle("Snapshot OPEX Undiscounted and Discounted in 2016-€") +
  scale_color_discrete("Modeling Year") +
  theme (axis.text.x = element_text(size=12, angle=90, hjust=1),
         axis.text.y = element_text(size=14),
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=18, face="bold"),
         strip.text.x=element_text(size=12))
dev.new()
plot(plot_opex)
png(paste("Plots/", substr(filename_input, 16, (nchar(filename_input)-4)), "_CAPEX_differentiated.png", sep=""), 
    width=600, height=600)
plot(plot_capex)
dev.off()