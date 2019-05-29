# Plot PV and Wind Feed-in profiles from renewables.ninja



# Packages
packages <- c("data.table","ggplot2", "RColorBrewer", "grid", "gridExtra", "ggvis", 
              "abind", "scales", "lubridate", "gridExtra", "ggpubr")
lapply(packages, function(x){
  if(!require(x,character.only=T)){
    install.packages(x)
    library(x,character.only=T)
  }
})

setwd("/home/accon/GIZ/MAy/Data/Feed-in-Profiles/")
wd_plots <- "/home/accon/GIZ/MAy/Data/Feed-in-Profiles/"

df_feedin_raw <- read.csv("Tunisia_Wind_PV_Feed-in_Series_synthesized_2014.csv", skip=3, header=TRUE)
df_feedin <- df_feedin_raw[,c("Africa.Tunis", "STEG..2017.", "STEG..2017..1")]
vec_months <- strftime(df_feedin$Africa.Tunis, format="%m")
ix_dupl <- which(!duplicated(vec_months))
vec_ix <- as.vector(sapply(ix_dupl, function(x) c(x:(x+168))))
df_feedin$months <- vec_months 
df_feedin_p <- df_feedin[vec_ix,]

dt_feedin <- melt(df_feedin_p)
dt_feedin$Day_Hours <- strftime(dt_feedin_p$Africa.Tunis, format="%d-%H")

x_breaks <- unique(dt_feedin$Day_Hours)[round(seq(1,length(unique(dt_feedin$Day_Hours)), 
                                          length(unique(dt_feedin$Day_Hours))/16), 0)]

facet_label <- c("Wind Onshore", "PV")
names(facet_label) <- unique(dt_feedin$variable)

# Plotting
plot_feedin <- ggplot(data=dt_feedin, aes(x=Day_Hours, y=value)) +
  geom_line(aes(color=months, group=months)) +
  facet_grid(variable~., scale="free", labeller=as_labeller(facet_label)) +
  scale_x_discrete(breaks=x_breaks) +
  ylab("Capacity Factor in MWh/MW") + xlab("Time") +
  ggtitle("Capacity Factors of PV and Wind Feedin") +
  theme (axis.text = element_text(size=14), 
         axis.title = element_text(size=16, face="bold"),
         legend.text= element_text(size=14),
         legend.title = element_text(size=14, face="bold"),
         plot.title = element_text(size=18, face="bold"),
         axis.text.x = element_text(angle = 90, hjust = 1),
         strip.text.x=element_text(size=12), strip.text.y=element_text(size=12))
dev.new()
plot(plot_feedin)
png(paste(wd_plots, "Feed-in-Profiles_TN_2014_overview.png", sep=""), width=800, height=400)
plot(plot_feedin)
dev.off()
