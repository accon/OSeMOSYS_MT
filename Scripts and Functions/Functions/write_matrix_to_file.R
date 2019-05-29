write_matrix_to_file <- function(mat_data, vec_rownames, vec_colnames, string_init, string_def, filename, multi=FALSE)
{
  if(length(mat_data) > 0)
  {
    if(missing(string_init))
    {
      mat_write <- matrix("", nrow=nrow(mat_data)+1, ncol=ncol(mat_data)+2)  
      mat_write[1,c(2:(ncol(mat_write)-1))] <- vec_colnames
      mat_write[2:(nrow(mat_write)),1] <- vec_rownames
      mat_write[1,1] <- string_def
      if(!multi){mat_write[,ncol(mat_write)] <- c(":=", rep("", nrow(mat_write)-2), "; \n")}
      if(multi){mat_write[,ncol(mat_write)] <- c(":=", rep("", nrow(mat_write)-2), "\n")}
      mat_write[c(2:nrow(mat_write)),c(2:(ncol(mat_write)-1))] <- mat_data 
    }
    else
    {
      mat_write <- matrix("", nrow=nrow(mat_data)+2, ncol=ncol(mat_data)+2)  
      mat_write[1,1] <- string_init
      mat_write[2,1] <- string_def
      mat_write[2,2:c(ncol(mat_write)-1)] <- vec_colnames
      mat_write[c(3:(nrow(mat_write))),1] <- vec_rownames
      if(!multi){mat_write[,ncol(mat_write)] <- c("", ":=", rep("", nrow(mat_write)-3), "; \n")}
      if(multi){mat_write[,ncol(mat_write)] <- c("", ":=", rep("", nrow(mat_write)-3), "\n")}
      mat_write[c(3:nrow(mat_write)),c(2:(ncol(mat_write)-1))] <- mat_data 
    }
  }
  else if(length(mat_data) == 0)
  {
    mat_write <- matrix("", nrow=1, ncol=1)  
    string_init_new <- paste(string_init, ";\n", sep="\t")
    mat_write[1,1] <- string_init_new
  }
  write.table(mat_write, file=filename, 
              append=TRUE, quote=FALSE, sep="\t", row.names=F, col.names=F)  
}

# Sandbox

# as.numeric(as.character(data)) and then trim out all 1s