# TimeStamp creation for UTZ+1

timestamp_creation <- function(year, is_gap=FALSE, timezone=NULL)
{

# ---------------------------------------------
# DATES 
# ---------------------------------------------

years <- year
vec_no_of_days <- c(365)
vec_years <- rep(years,vec_no_of_days)
months <- c(1:12)
mt <- c(28,29,30,31) #month-types for fast programming
if(!is_gap)
{
vec_days_month <- c(mt[4], mt[1], mt[4], mt[3], mt[4], mt[3], 
                    mt[4], mt[4], mt[3], mt[4], mt[3], mt[4])   #ny=normal year
}
if(is_gap)
{
vec_days_month <- c(mt[4], mt[2], mt[4], mt[3], mt[4], mt[3], 
                    mt[4], mt[4], mt[3], mt[4], mt[3], mt[4])     #gy=gapyear
}

vec_months <- rep(months, vec_days_month) #ny = normal year (365 days)
#vec_months_gy <- rep(months, vec_days_month_gy)
#vec_months <- c(vec_months_ny)
vec_months[which(vec_months < 10)] <- paste(0,vec_months[which(vec_months < 10)],sep='') 

vec_days <- unlist(sapply(vec_days_month,seq))
#vec_days_gy <- unlist(sapply(vec_days_month_gy,seq))
vec_days[which(vec_days < 10)] <- paste(0,vec_days[which(vec_days < 10)],sep='') 
vec_dates <- paste(vec_years, vec_months, vec_days, sep='-')

# ---------------------------------------------
# TIMES + TIME ZONE
# ---------------------------------------------

hours <- c(1:24)
hours[which(hours < 10)] <- paste(0,hours[which(hours < 10)],sep='') 

if(is.null(timezone))
{
  vec_hours <- paste(hours,':00:00', sep='')
}
if(!is.null(timezone))
{
  vec_hours <- paste(hours,':00:00 ', timezone, sep='')
}

vec_hours_complete <- rep(vec_hours, length(vec_dates))
vec_dates_complete <- rep(vec_dates, each=length(vec_hours))

vec_timestamps <- paste(vec_dates_complete, vec_hours_complete, sep=" ")

return(vec_timestamps)

}  
