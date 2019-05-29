trim_data <- function(data_raw, trim_front, trim_rear)
{
  if(is.null(dim(data_raw)))
  {
    data <- data_raw[-c(trim_front,trim_rear)]  
  }
  else
  {
    data <- data_raw[,-c(trim_front,trim_rear)]
  }
  return(data)
}

# Sandbox

# as.numeric(as.character(data)) and then trim out all 1s