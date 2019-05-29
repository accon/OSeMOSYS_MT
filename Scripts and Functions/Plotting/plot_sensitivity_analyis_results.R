# Display sensitivity analysis results of OSeMOSYS result files 
# Author: Niklas Wulff
# Date: 2017-09-09

#------Introductory Section------

# Set Model Run Family
mr_f <- "MR2"
mr <- "3"
mr_name <- "newpolicies"

# Set working directory
setwd(paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/", sep=""))
wd_input <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/", sep="")
wd_results <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/Results/", sep="")
wd_plots <- paste("/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/TUNISIA_", mr_f, "/Plots/", sep="")
wd_model <- "/home/accon/GIZ/MAy/Models/OSeMOSYS/Model/"
filename_output <- paste(mr_f, "_", mr, "_", "results.txt", sep="")
filename_input <- paste("OSeMOSYS_input_", mr_f, "_", mr, "_", mr_name, ".txt", sep="")
wd_input_file <- paste(wd_input, filename_input, sep="")
wd_output_file <- paste(wd_results, filename_output, sep="")

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

#------support vectors------
vec_tec_plot <- c("wind_onshore","pv_utility_scale", "pv_decentralized", "ccgt")
vec_mr <- c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j")
vec_input_files <- paste(mr_f, "_", mr, vec_mr, "_results.txt", sep="")
wds_output_file <- paste(wd_results, vec_input_files, sep="")
wds_output_file_test <- paste(wd_results, vec_input_files[c(1,2)], sep="")
vec_label_tec <- c("Wind", "PV US", "PV Dec", "CCGT")
names(vec_label_tec) <- vec_tec_plot
vec_name_load <- paste(mr_f, "_", mr, c("d", "e", "i", "j"), sep="")

vec_label_mr <- paste("MR2_3", vec_mr, sep="")
names(vec_label_mr) <- c(1:10)

#------Data Read-in------
mat_results_raw1 <- cbind(sapply(wds_output_file[c(1:5)], readLines))
mat_results_raw2 <- cbind(sapply(wds_output_file[c(6:10)], readLines))
line_nos_instcap <- c(grep("TotalCapacityAnnual", mat_results_raw1)+1)
mat_results_instcap_raw1 <- mat_results_raw1[line_nos_instcap,]
mat_results_instcap_raw2 <- mat_results_raw2[line_nos_instcap,]
mat_defstrings <- mat_results_raw1[line_nos_instcap-1,1]
vec_years <- substr(mat_defstrings, nchar(mat_defstrings)-4, nchar(mat_defstrings)-1)
vec_technologies <- substr(mat_defstrings, 36, nchar(mat_defstrings)-6)

# Extracting numeric values from string vectors avoiding working with regular expressions
mat_results_instcap1 <- apply(mat_results_instcap_raw1, MARGIN=2, function(x) as.numeric(substr(x, 26, 36)))
mat_results_instcap2 <- apply(mat_results_instcap_raw2, MARGIN=2, function(x) as.numeric(substr(x, 26, 36)))
mat_results_instcap <- cbind(mat_results_instcap1, mat_results_instcap2)
colnames(mat_results_instcap) <- paste("MR2_3", vec_mr, sep="")
df_results_instcap <- data.frame(vec_technologies, vec_years, mat_results_instcap)
df_results_rel <- df_results_instcap[which(df_results_instcap$vec_technologies %in% vec_tec_plot),]
dt_instcap <- melt(df_results_rel)
dt_instcap_load <- melt(df_results_rel[,c("vec_technologies","vec_years", vec_name_load)])

#------Plotting of Sensitivities of Installed Capacities-------------------
plot_sensitivities <- ggplot(data=dt_instcap, aes(x=vec_years, y=value)) + 
  geom_boxplot() + 
  geom_point(data=dt_instcap_load, aes(x=vec_years, y=value, color=variable), size=5, 
             shape=21, fill="white") +
  #geom_point(size=3, shape=21, fill="white") + 
  facet_grid(vec_technologies~., scale="free", labeller=as_labeller(vec_label_tec)) +
  ylab("Installed Capacity in MW") + 
  xlab("Modelling Year") +
  ggtitle("Sensitivities of Installed Capacities \nfor Different CAPEX and Load Developments") +
  theme (axis.text = element_text(size=14), 
    axis.title = element_text(size=16, face="bold"),
    legend.text= element_text(size=14),
    legend.title = element_text(size=14, face="bold"),
    plot.title = element_text(size=16, face="bold"),
    strip.text.y=element_text(size=11))

dev.new()
plot(plot_sensitivities)
png(paste(wd_plots, "Sensitivities_installed_capacity.png", sep=""), width=600, height=800)
plot(plot_sensitivities)
dev.off()


#------Snapshot Electricity Production by Technology------
line_nos_prod <- c(grep("TotalTechnologySnapshotActivity", mat_results_raw1[,1])+1)
mat_results_prod_raw1 <- mat_results_raw1[line_nos_prod,]
mat_results_prod_raw2 <- mat_results_raw2[line_nos_prod,]
mat_defstrings_prod <- mat_results_raw1[line_nos_prod-1,1]
vec_years <- substr(mat_defstrings_prod, nchar(mat_defstrings_prod)-4, 
                    nchar(mat_defstrings_prod)-1)
vec_technologies <- substr(mat_defstrings_prod, 48, nchar(mat_defstrings_prod)-6)
mat_results_prod1 <- apply(mat_results_prod_raw1, MARGIN=2, function(x) as.numeric(substr(x, 26, 36))/1000)
mat_results_prod2 <- apply(mat_results_prod_raw2, MARGIN=2, function(x) as.numeric(substr(x, 26, 36))/1000)
mat_results_prod <- cbind(mat_results_prod1, mat_results_prod2)
colnames(mat_results_prod) <- paste("MR2_3", vec_mr, sep="")
df_results_prod <- data.frame(vec_technologies, vec_years, mat_results_prod)
df_prod_rel <- df_results_prod[which(df_results_prod$vec_technologies %in% vec_tec_plot),]
dt_production <- melt(df_prod_rel)
dt_production_load <- melt(df_prod_rel[,c("vec_technologies","vec_years", vec_name_load)])

#------Plotting of Sensitivities of Electricity Production-------------------
plot_sens_prod <- ggplot(data=dt_production, aes(x=vec_years, y=value)) + 
  geom_boxplot() + 
  geom_point(data=dt_production_load, aes(x=vec_years, y=value, color=variable), size=5, 
             shape=21, fill="white") +
  #scale_colour_manual("Demand Scenario", labels=c("Low Demand", "High Demand")) +
  facet_grid(vec_technologies~., scale="free", labeller=as_labeller(vec_label_tec)) +
  ylab("Electricity Production in GWh") + 
  xlab("Modeling Year") +
  ggtitle("Sensitivities of Snapshot Electricity Production \nfor Different CAPEX and Load Developments") +
  theme (axis.text = element_text(size=14), 
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=16, face="bold"),
         strip.text.y=element_text(size=11))

dev.new()
plot(plot_sens_prod)
png(paste(wd_plots, "Sensitivities_Electricity_Production.png", sep=""), width=600, height=800)
plot(plot_sens_prod)
dev.off()



#------Total System Cost-TSC-----
line_nos_tsc <- c(grep("------", mat_results_raw1[,1])+1)[1]
mat_results_tsc_raw1 <- mat_results_raw1[line_nos_tsc,]
mat_results_tsc_raw2 <- mat_results_raw2[line_nos_tsc,]
mat_results_tsc_raw <- cbind(mat_results_tsc_raw1, mat_results_tsc_raw2)
mat_results_tsc <- as.matrix(as.numeric(substr(mat_results_tsc_raw, 26, 36))/(1000*1000))
#mat_results_tsc <- apply(mat_results_tsc_raw, MARGIN=2, 
#                             function(x) as.numeric(gsub(".*?([0-9]+).*", "\\1", x))/1000)
colnames(mat_results_tsc) <- "Total System Cost"
dt_tsc <- melt(mat_results_tsc)
dt_tsc_load <- melt(mat_results_tsc)[c(4:5, 9:10),]

#------Plotting of Sensitivities of Total System Cost-------------------
plot_sens_tsc <- ggplot(data=dt_tsc, aes(x=Var1, y=value)) + 
  geom_point(size=8, shape=21, fill="white") +
  scale_x_continuous("Model Run", breaks=c(1:10), labels=as_labeller(vec_label_mr)) +
  ylim(0,24)+
  ylab("Cost in 10⁹ 2016-€") + 
  ggtitle("Sensitivities of Total System Cost") +
  theme (axis.text = element_text(size=14), 
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=16, face="bold"),
         strip.text.y=element_text(size=11))

#dev.new()
#plot(plot_sens_tsc)
png(paste(wd_plots, "Sensitivities_Total_System_Cost.png", sep=""), width=800, height=400)
plot(plot_sens_tsc)
dev.off()



#------Total OPEX-----
line_nos_tsc <- c(grep("DiskountedOperationalkostTotal", mat_results_raw[,1])+1)[1]
mat_results_tsc_raw <- mat_results_raw[line_nos_tsc,]
mat_results_tsc <- as.matrix(as.numeric(substr(mat_results_tsc_raw, 26, 36))/(1000*1000))
#mat_results_tsc <- apply(mat_results_tsc_raw, MARGIN=2, 
#                             function(x) as.numeric(gsub(".*?([0-9]+).*", "\\1", x))/1000)
colnames(mat_results_tsc) <- "Total OPEX"
dt_tsc <- melt(mat_results_tsc)
dt_tsc_load <- melt(mat_results_tsc)[c(7:8),]

#------Plotting of Sensitivities of Total System Cost-------------------
plot_sens_tsc <- ggplot(data=dt_tsc, aes(x=Var2, y=value)) + 
  geom_boxplot() + 
  geom_point(data=dt_tsc_load, aes(x=Var2, y=value, color=Var1), size=8, 
             shape=21, fill="white") +
  #scale_colour_manual("Demand Scenario", labels=c("Low Demand", "High Demand")) +
  ylab("Cost in 10³ 2016-€") + 
  ggtitle("Sensitivity of Total OPEX") +
  theme (axis.text = element_text(size=14), 
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=16, face="bold"),
         strip.text.y=element_text(size=11))

dev.new()
plot(plot_sens_tsc)
png(paste(wd_plots, "Sensitivity OPEX.png", sep=""), width=600, height=800)
plot(plot_sens_prod)
dev.off()
