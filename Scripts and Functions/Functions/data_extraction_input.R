data_extraction <- function(filename, pattern, no_rows, end_pattern, log_head=FALSE, is_array=FALSE)

{
  line_actual <- grep(pattern, readLines(filename))
  line_switch <- length(read.table(file=filename, header=FALSE, 
                            skip = line_actual-1, 
                            nrow=1, fill=F)) > 5 
  if(line_switch)       # Is Header already in "param"-line?
  {
    line_actual <- line_actual - 1
  }
  
  if (missing(no_rows))
  {
    if(missing(end_pattern))
    {
      lines_bracket <- grep("\\[", readLines(filename))
      lines_param <- grep("param", readLines(filename))
      
      line_bracket_next <- min(lines_bracket[which(lines_bracket > line_actual+2)])
      line_param_next <- min(lines_param[which(lines_param > line_actual+1)])
      
      line_next <- min(line_bracket_next, line_param_next)
      
      data_uncut <- read.table(file=filename, header=log_head, 
                               skip = line_actual, 
                               nrow=(line_next-line_actual), fill=T, skipNul=T) 
      
      #The following is neccessary because read.table automatically skips comment and blank lines
      data <- data_uncut[-c(min(grep("\\[", data_uncut[,1]), 
                                grep("param",data_uncut[,1]),
                                grep(";", data_uncut[,1])):nrow(data_uncut)),]
    }
    else
    {
      line_end_pattern <- grep(end_pattern, readLines(filename))
      data_raw <- read.table(file=filename, header=FALSE, skip = line_actual, 
                               nrow=(line_end_pattern - line_actual - 4), fill=T, blank.lines.skip=FALSE) #Yeah, 4 in the code sucks. Hope I will make it better later
      no_matrices <- length(grep("\\[", data_raw[,1]))
      
      data <- data_raw[which(!is.na(data_raw[,1]) & data_raw[,1] != ""),] #dangerous becaus trimming only refers to column 1
      
      if(is_array)
      {
        # Abstrakter schreiben, so dass es nicht vom Einzelfall abhängt
        vec_data_id <- as.character(data[c(seq(from=1, to=nrow(data)-no_timeslices-1, 
                                                 by=no_timeslices+2)),1])
        vec_data_id <- strsplit(x=vec_data_id, split=",")
        mat_data_id_raw <- matrix(unlist(vec_data_id), ncol=length(vec_data_id[[1]]), byrow=TRUE)
        mat_data_id <- sub("\\]", "", sub("\\[", "", mat_data_id_raw))
      
        data_neat <- trim_data(data_raw, 1, c(no_years+2, no_years+3))
        data <- sapply(data_neat, function(x) as.numeric(as.character(x)))
      
        vec_split <- rep(c(1:no_matrices), each=no_timeslices+2)
        mat_split <- matrix(vec_split, nrow=(no_timeslices+2)*no_matrices, ncol=no_years)
      
      
        data_arr_raw <- do.call(abind, c(lapply(split(data,mat_split), 
                                          function(x) matrix(x, ncol=no_years)), along=3))
        data_arr <- data_arr_raw[-c(1,no_timeslices+2),,]
        dimnames(data_arr) <- list(timeslices, years, mat_data_id[,2]) #include 4th dimension, this is not pretty right now
        data <- data_arr
      }
    }
  }
  else
  {
    data <- read.table(file=filename, header=log_head, skip = line_actual, 
                                          nrow=no_rows, blank.lines.skip = F, fill = T)  
  }

  return (data)
}