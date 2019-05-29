




#-------Introductory Section---------------------------------------------------------------

# Set Model Run Family
mr_f <- "MR2"
mr <- "2b"
mr_name <- "FullYear2040_TSP"

# Set working directory
setwd(paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/", sep=""))
wd_input <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/", sep="")
wd_results <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/Results/", sep="")
wd_plots <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/Plots/", sep="")
wd_model <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/"
filename_output <- paste(mr_f, "_", mr, "_", "SelectedResults.csv", sep="")
filename_input <- paste("OSeMOSYS_input_", mr_f, "_", mr, "_", mr_name, ".txt", sep="")
wd_input_file <- paste(wd_input, filename_input, sep="")
wd_output_file <- paste(wd_results, filename_output, sep="")

# Move files from model directory to results directory
# filenames_results <- c("SelectedResults.csv","SelectedResults_Economic.csv", "StorageResults.csv")
# for (i in filenames_results)
# {
#   file.rename(from = paste(wd_model, i, sep=""), 
#               to = paste(wd_results, mr_f, "_", mr, "_", i, sep=""))
# }

line_nos <- c(grep("", readLines(wd_output_file)))

# Packages
packages <- c("data.table","ggplot2", "RColorBrewer", "grid", "gridExtra", "ggvis", 
              "abind", "scales", "lubridate", "gridExtra", "ggpubr")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

# Initializing User-Defined-Functions (UDFs)
source("/home/accon/GIZ/MAy/R/functions/data_extraction.R")
source("/home/accon/GIZ/MAy/R/functions/trim_data.R")
source("/home/accon/GIZ/MAy/R/functions/timestamp_creation.R")

#-------Initialize empty lines and square-bracket-lines in input-file----------------------------------------------

empty_lines <- grep("^$", readLines(wd_input_file))
sq_brac_lines <- grep("\\[", readLines(wd_input_file))

#-------Read-in sets ---------------------------------------------------------

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

timeslices_raw <- data_extraction(file=filename_input, pattern="set TIMESLICE", 
                                  no_rows=1)
timeslices <- trim_data(timeslices_raw, c(1:3), length(timeslices_raw))
timeslices <- as.character(lapply(timeslices,as.character))[-length(timeslices)]
#timeslices_ord <- timeslices[c(grep("Wi", timeslices), grep("In", timeslices), grep("Su", timeslices), 
#                               grep("Ra", timeslices))]
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

#-------Set Colors, Linetypes and Synonyms for Plotting---------------------------

vec_seasons <- c("1" = "Jan-Mar","2" = "April-Jun", "3" = "Jul-Sept","4" = "Okt-Dez")
vec_linetypes <- c("solid", "solid", "twodash", "twodash", "twodash", "solid",  #solid = Renewable, twodash = Natural Gas, longdash = supporting technologies
                   "longdash", "solid", "twodash", "twodash", "solid")
names(vec_linetypes) <- technologies[which(technologies != "backup_electricity")]
vec_synonyms_tech <- c("Wind Onshore", "PV Utility-Scale", "Steam Turbine", 
                       "OCGT", "CCGT", "Hydro - Run of River",  
                       "Supply of Natural Gas", "Backup Electricity", "CSP Collector", 
                       "CSP Gas Firing", "CSP Steam Turbine", "PV Decentralized")
names(vec_synonyms_tech) <- technologies
vec_colors <- c(brewer.pal(8, "Set1"), brewer.pal(6, "Dark2"))
names(vec_colors)[c(1:6, 8:13)] <- technologies

# Vector to exclude supporting modeling technologies
vec_tech_excl <- c("backup_electricity", "supply_natural_gas")

#-------X-Breaks for over-specified x-axis-------------------------------------

x_breaks <- timeslices[round(seq(1,length(timeslices), length(timeslices)/16), 0)]

#-------Total Annual Capacity in GW---------------------------

setwd(wd_results)
line_actual <- grep("TotalAnnualCapacity", readLines(filename_output))
annual_capacity_raw <- read.csv(filename_output, header=TRUE, sep=",", 
                                skip = line_actual, nrows = no_years)
annual_capacity <- annual_capacity_raw[,-1]
rownames(annual_capacity) <- years
annual_capacity_dt <- melt(as.matrix(annual_capacity))
annual_capacity_sort <- annual_capacity_dt[order(as.character(annual_capacity_dt$Var2), annual_capacity_dt$Var1),]
col_id <- rep("annual_capacity", nrow(annual_capacity_sort))
annual_capacity_sort <- cbind(annual_capacity_sort, col_id)

# Extract Newly Built Capacity in GW
line_actual <- grep("NewCapacity", readLines(filename_output))
new_capacity_raw <- read.csv(filename_output, header=TRUE, sep=",", 
                             skip = line_actual, nrows = no_years)
new_capacity <- new_capacity_raw[,-1]
rownames(new_capacity) <- years

new_capacity_dt <- melt(as.matrix(new_capacity))
new_capacity_sort <- new_capacity_dt[order(as.character(new_capacity_dt$Var2), new_capacity_dt$Var1),]
col_id <- rep("new_capacity_cumulated", nrow(annual_capacity_sort))
new_capacity_sort <- cbind(new_capacity_sort, col_id)

# Extract Residual Capacity from Input-File
residual_capacity_raw <- data_extraction(paste(wd_input, filename_input, sep=""), pattern="param ResidualCapacity", 
                                         end_pattern="param AvailabilityFactor", log_head=TRUE) 
residual_capacity <- as.matrix(trim_data(residual_capacity_raw, 1, c(no_years+2,no_years+3))[-1])
residual_capacity <- as.matrix(as.numeric(as.character(residual_capacity)))
colnames(residual_capacity) <- years
rownames(residual_capacity) <- residual_capacity_raw[c(2:nrow(residual_capacity_raw)),1]

mat_append <- matrix(0, ncol=length(years), nrow=length(technologies[which(!technologies %in% rownames(residual_capacity))]))
colnames(mat_append) <- colnames(residual_capacity)
rownames(mat_append) <- technologies[which(!technologies %in% rownames(residual_capacity))]

residual_capacity_all <- rbind(residual_capacity, mat_append)
#residual_capacity_num <- sapply(residual_capacity_all, function(x) as.numeric(as.character(x)))
#rownames(residual_capacity_num) <- rownames(residual_capacity_all)
residual_capacity_dt <- melt(as.matrix(residual_capacity_all))
residual_capacity_dt <- setcolorder(residual_capacity_dt, c("Var2", "Var1", "value"))
colnames(residual_capacity_dt) <- c("Var1", "Var2", "value")
residual_capacity_sort <- residual_capacity_dt[order(as.character(residual_capacity_dt$Var2), 
                                                     residual_capacity_dt$Var1),]
col_id <- rep("residual_capacity", nrow(residual_capacity_sort))
residual_capacity_sort <- cbind(residual_capacity_sort, col_id)

# Synthesize the newly installed capacities (minus faded newly built) 
added_capacity <- annual_capacity_sort
added_capacity$value <- annual_capacity_sort$value - residual_capacity_sort$value 
added_capacity$col_id <- rep("added_capacity", nrow(annual_capacity_sort))
data_capacity_unsorted <- rbind(added_capacity, residual_capacity_sort)
data_capacity <- data_capacity_unsorted[order(as.character(data_capacity_unsorted$Var2), 
                                              data_capacity_unsorted$Var1),]
color_count <- length(unique(data_capacity$Var2))
get_palette <- colorRampPalette(brewer.pal(12, "Paired"))

# Plot Installed Capacity
plot_tech_raw <- technologies
plot_tech <- rep(plot_tech_raw, 2)
plot_order_status <- c("added_capacity", "residual_capacity")
plot_order_tech <- rev(plot_tech_raw)
data_capacity$col_id <- factor(data_capacity$col_id, levels=plot_order_status) 
data_capacity$Var2 <- factor(data_capacity$Var2, levels=plot_order_tech)

# Exclude supporting technologies
data_capacity <- data_capacity[which(!data_capacity$Var2 %in% vec_tech_excl),]

# Plot
plot_capacity <- ggplot(data=data_capacity[which(data_capacity$Var2 %in% plot_tech),], 
                        aes(x=Var1, y=value, alpha=col_id, fill=Var2, label=value, position='identity'))
plot_capacity <- plot_capacity + geom_bar(stat="identity")
plot_capacity <- plot_capacity + scale_alpha_manual("Power Plant Status", 
                                                    values=c("added_capacity" = 1, "residual_capacity" = 0.5))
plot_capacity <- plot_capacity + geom_text(data=subset(data_capacity, value != 0), 
                                           size = 5, check_overlap=TRUE, 
                                           position = position_stack(vjust = 0.5))  
plot_capacity <- plot_capacity + scale_fill_manual("Power Plant Technologies", labels = vec_synonyms_tech, 
                                                   values= vec_colors)
plot_capacity <- plot_capacity + ylab("Installed Capacity in MW")
plot_capacity <- plot_capacity + scale_x_continuous("Modelling Year", breaks=unique(data_capacity$Var1),
                                                    labels=as.character(unique(data_capacity$Var1)))
plot_capacity <- plot_capacity + ggtitle("Residual and Added Capacity \nover Modelling Period")
plot_capacity <- plot_capacity + labs(fill="Power Plants")
plot_capacity <- plot_capacity + theme (axis.text = element_text(size=14), 
                                        axis.title = element_text(size=16, face="bold"),
                                        legend.text= element_text(size=14),
                                        legend.title = element_text(size=14, face="bold"),
                                        plot.title = element_text(size=18, face="bold"))
dev.new()
plot(plot_capacity)
png(paste(wd_plots, substr(filename_output, 1, (nchar(filename_output)-4)), "_installed_capacity.png", sep=""), 
    width=500, height=700)
plot(plot_capacity)
dev.off()

# ------Annual Fuel Production By Technology-----------------------------------------------

line_actual <- grep("Snapshot Production", readLines(filename_output))
snapshot_production_raw <- read.csv(filename_output, header=FALSE, sep=",", 
                                    skip = line_actual, nrows = ((no_years+1)*no_technologies)+1)

# Piece of script taken from data_extraction.R and adjusted
# no_regions <- length(which(snapshot_production_raw[,1] %in% regions))
region_lines <- which(snapshot_production_raw[,2] %in% regions) # Regions are stored in column 2 in the .csv-file..
production_regions <- snapshot_production_raw[region_lines,2]
snapshot_production <- snapshot_production_raw[-region_lines,-1] #without first column (years) and regions

no_matrices <- length(which(snapshot_production_raw[,1] %in% technologies))
vec_split <- rep(c(1:no_matrices), each=no_years+1)
mat_split <- matrix(vec_split, nrow=(no_years+1)*no_matrices, ncol=no_fuels)
data_arr_raw <- abind(split(snapshot_production,mat_split), along=3)
data_arr <- data_arr_raw[-1,,]
dimnames(data_arr) <- list(fuels, technologies) #include 4th dimension, this is not pretty right now
snapshot_production_arr <- apply(data_arr, MARGIN=c(1,2), as.numeric)

# possibility to plot the production of different fuels (electricity, transport, heat/cold,...)
data_snapshot_production <- melt(snapshot_production_arr)

#data_snapshot_production <- data_snapshot_production[which(!data_snapshot_production$Var2 %in% vec_tech_excl),]
#dt_snapshot_production <- data_snapshot_production[which(data_snapshot_production$Var1 == "electricity"),]
#dt_snapshot_production$Var1 <- as.factor(2040)

plot_production <- ggplot(data=data_snapshot_production, aes(x=Var1, y=value, fill=Var2, label=value, 
                                                             position='identity'))
plot_production <- plot_production + geom_bar(stat="identity")
plot_production <- plot_production + geom_text(data=subset(data_snapshot_production, value != 0), 
                                               size = 5, check_overlap=TRUE, 
                                               position = position_stack(vjust = 0.5))  
plot_production <- plot_production + scale_fill_manual("Power Plant Technologies", labels = vec_synonyms_tech,
                                                       values = vec_colors)
plot_production <- plot_production + scale_x_discrete("Modelling Year", 
                                                        breaks=unique(data_snapshot_production$Var1),
                                                        labels=as.character(unique(data_snapshot_production$Var1)))
plot_production <- plot_production + scale_y_continuous(labels=comma)
plot_production <- plot_production + ylab("Energy Supplied in MWh")
plot_production <- plot_production + xlab("Modelling Year")
plot_production <- plot_production + ggtitle("Electricity Produced by different \nPower Plants in the Modeling Years")
plot_production <- plot_production + theme (axis.text = element_text(size=14),
                                            axis.text.x = element_text(size=14, angle=45, hjust=1),
                                            axis.title = element_text(size=16, face="bold"),
                                            legend.text= element_text(size=14),
                                            legend.title = element_text(size=14, face="bold"),
                                            plot.title = element_text(size=18, face="bold"))
dev.new()
plot(plot_production)
png(paste(wd_plots, substr(filename_output, 1, (nchar(filename_output)-4)), 
          "_annual_fuel_production_by_technology.png", sep=""), width=600, height=600)
plot(plot_production)
dev.off()

# ------Production Profiles- TESTING DEMAND! ----------------------------------------------

setwd(wd_results)
line_actual <- grep("ProductionByTechnology", readLines(filename_output))
production_profiles_raw <- read.csv(wd_output_file, header=FALSE, sep=",", 
                                    skip = line_actual, nrows = ((no_years+1)*no_technologies)+1)

region_lines <- which(production_profiles_raw[,2] %in% regions) # Regions are stored in column 2 in the .csv-file..
elc_col <- which(production_profiles_raw[2,] == "electricity")
production_regions <- production_profiles_raw[region_lines,2]
production_profiles <- trim_data(production_profiles_raw, c(1:elc_col), 
                                 c(elc_col+no_timeslices+1:ncol(production_profiles_raw)))[-1,]

no_matrices <- length(which(production_profiles_raw[,1] %in% technologies))
vec_split <- rep(c(1:no_matrices), each=no_years+1)
mat_split <- matrix(vec_split, nrow=(no_years+1)*no_matrices, ncol=no_timeslices)

array_production_profiles_raw <- abind(split(production_profiles,mat_split), along=3)
array_production_profiles <- array_production_profiles_raw[2,,]
dimnames(array_production_profiles) <- list(timeslices, technologies) #include 4th dimension, this is not pretty right now
array_production_profiles <- apply(array_production_profiles, MARGIN=c(1,2), as.numeric)

# possibility to plot the production of different fuels (electricity, transport, heat/cold,...)

data_feedin_profiles_dt <- melt(array_production_profiles)

# Add Timestamps
vec_timestamps_raw <- timestamp_creation(2040)
vec_timestamps <- rep(vec_timestamps_raw, times=no_technologies)
data_feedin_profiles_dt$Var3 <- as.POSIXct(vec_timestamps)

# Labels
facet_labeller_years <- as.character(years)
names(facet_labeller_years) <- as.character(years)

# Change plotting order by re-ordering factor levels
data_feedin_profiles_dt$Var1 <- factor(data_feedin_profiles_dt$Var1, 
                                             levels=sort(unique(data_feedin_profiles_dt$Var1), 
                                                         decreasing=TRUE))
data_feedin_profiles_dt <- data_feedin_profiles_dt[which(!data_feedin_profiles_dt$Var2 
                                                                     %in% vec_tech_excl),]

start_date_w1 <- as.POSIXct("2040-07-19 01:00:00") 
start_date_w2 <- as.POSIXct("2040-12-24 01:00:00")
start_date_w3 <- as.POSIXct("2040-06-06 01:00:00")
start_date_w4 <- as.POSIXct("2040-08-16 01:00:00")

dt_profiles_w1 <- data_feedin_profiles_dt[which(data_feedin_profiles_dt$Var3 > start_date_w1 & 
                                                  data_feedin_profiles_dt$Var3 < start_date_w1 + days(7)),]
dt_profiles_w1$Var4 <- c("Week 1")
dt_profiles_w2 <- data_feedin_profiles_dt[which(data_feedin_profiles_dt$Var3 > start_date_w2 & 
                                                  data_feedin_profiles_dt$Var3 < start_date_w2 + days(7)),]
dt_profiles_w2$Var4 <- c("Week 2")
dt_profiles_w3 <- data_feedin_profiles_dt[which(data_feedin_profiles_dt$Var3 > start_date_w3 & 
                                                  data_feedin_profiles_dt$Var3 < start_date_w3 + days(7)),]
dt_profiles_w3$Var4 <- c("Week 3")
dt_profiles_w4 <- data_feedin_profiles_dt[which(data_feedin_profiles_dt$Var3 > start_date_w4 & 
                                                  data_feedin_profiles_dt$Var3 < start_date_w4 + days(7)),]
dt_profiles_w4$Var4 <- c("Week 4")

dt_profiles_extr <- rbind(dt_profiles_w1, dt_profiles_w2, dt_profiles_w3, dt_profiles_w4)

top_theme <-  theme (axis.text = element_text(size=9), 
              axis.title = element_text(size=9, face="bold"),
              legend.text= element_text(size=7),
              legend.title = element_text(size=8, face="bold"),
              legend.position = "top",
              plot.title = element_text(size=10, face="bold"),
              axis.text.x = element_text(angle = 20, hjust = 1),
              strip.text.x=element_text(size=9), strip.text.y=element_text(size=9))

rest_theme <-  theme (axis.text = element_text(size=9), 
                   axis.title.y = element_blank(),
                   legend.text= element_text(size=6),
                   legend.title = element_text(size=8, face="bold"),
                   plot.title = element_text(size=10, face="bold"),
                   axis.text.x = element_text(angle = 20, hjust = 1),
                   strip.text.x=element_text(size=9), strip.text.y=element_text(size=9))


# Plotting
# put in [which(data_feedin_profiles_dt$Var3 %in% plot_tech & data_feedin_profiles_dt$Var1 %in% plotting_years),] 
# in the following line if a specific plotting choice of technologies or years is demanded
plot_production_w1 <- ggplot(data=dt_profiles_w1, aes(x=Var3, y=value)) +
                            geom_bar(aes(fill=Var2), stat='identity') +
                            scale_fill_manual("Power Plant \nTechnologies", labels = vec_synonyms_tech,
                                                                         values = vec_colors) +
                            scale_x_datetime("", breaks=dt_profiles_w1$Var3[seq(1,length(dt_profiles_w1$Var3), 
                                round((length(dt_profiles_w1$Var3)-1)/7,0))], labels = date_format("%Y-%m-%d")) +
                            ylab("Electricity Production in MWh") + xlab("Time") +
                            ggtitle("Weekly Dispatch of Power Plants in 2040") +
                            top_theme
# dev.new()
# plot(plot_production_w1)


plot_production_w2 <- ggplot(data=dt_profiles_w2, aes(x=Var3, y=value)) +
  geom_bar(aes(fill=Var2),stat='identity',show.legend = F) +
  scale_fill_manual("Power Plant Technologies", labels = vec_synonyms_tech,
                    values = vec_colors) +
  scale_x_datetime("", breaks=dt_profiles_w2$Var3[seq(1,length(dt_profiles_w2$Var3), 
    round((length(dt_profiles_w2$Var3)-1)/7,0))], labels = date_format("%Y-%m-%d")) +
  rest_theme

plot_production_w3 <- ggplot(data=dt_profiles_w3, aes(x=Var3, y=value)) +
  geom_bar(aes(fill=Var2),stat='identity',show.legend = F) +
  scale_fill_manual("Power Plant Technologies", labels = vec_synonyms_tech,
                    values = vec_colors) +
  scale_x_datetime("", breaks=dt_profiles_w3$Var3[seq(1,length(dt_profiles_w3$Var3), 
    round((length(dt_profiles_w3$Var3)-1)/7,0))], labels = date_format("%Y-%m-%d")) +
  rest_theme

plot_production_w4 <- ggplot(data=dt_profiles_w4, aes(x=Var3, y=value)) +
  geom_bar(aes(fill=Var2),stat='identity', show.legend = FALSE) +
  scale_fill_manual("Power Plant Technologies", labels = vec_synonyms_tech,
                    values = vec_colors) +
  scale_x_datetime("", breaks=dt_profiles_w4$Var3[seq(1,length(dt_profiles_w4$Var3), 
    round((length(dt_profiles_w4$Var3)-1)/7,0))], labels = date_format("%Y-%m-%d")) +
  rest_theme



#dev.new()

png(paste(wd_plots, substr(filename_input, 16, (nchar(filename_input)-4)), "Weekly_Dispatch_maxload.png", sep=""), 
   width=500, height=600)
grid.arrange(plot_production_w1, plot_production_w2, plot_production_w3, plot_production_w4, nrow=4, heights=c(8,5,5,5)) 
dev.off()
