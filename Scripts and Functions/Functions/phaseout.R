phaseout <- function(year, vec_instcap, vec_decom, vec_pptype)
{
  year <- as.numeric(as.character(year))
  vec_instcap <- as.numeric(as.character(vec_instcap))
  vec_decom <- as.numeric(as.character(vec_decom))
  vec_pptype <- as.character(vec_pptype)
  log_yrs <- year > max(vec_decom)
  years_run <- as.numeric(as.character(year[which(!log_yrs)]))
  years_norun <- as.numeric(as.character(year[which(log_yrs)]))
  if (length(years_run) > 0)
  {
    result <- aggregate(vec_instcap[which(vec_decom >= years_run)], 
                        by=list(vec_pptype[which(vec_decom >= years_run)]), FUN=sum)
    colnames(result) <- c("type", "residual_capacity")
  }
  if (length(years_run) == 0)
  {
    result <- 0
    print(paste("All capacities within the specified input-data already phased out in specified year ", 
                years_norun, ".", sep=""))
    result <- matrix(0, nrow=1, ncol=2)
    colnames(result) <- c("type_fk", "residual_capacity")
  }
  return(result)
}