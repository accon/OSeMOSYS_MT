create_array <- function(data_raw, cname_dim1, cname_dim2, cname_dim3, cname_values, byrow_log=FALSE)
{
  names_dim1 <- unique(data_raw[,cname_dim1])  
  no_names_dim1 <- length(names_dim1)
  names_dim2 <- unique(data_raw[,cname_dim2])  
  no_names_dim2 <- length(names_dim2)
  names_dim3 <- unique(data_raw[,cname_dim3])  
  no_names_dim3 <- length(names_dim3)
  
  vec_dim <- c(no_names_dim1, no_names_dim2, no_names_dim3)
  arr <- array(NA, dim=vec_dim, dimnames=list(names_dim1, names_dim2,names_dim3))
  for (i in dimnames(arr)[[3]])
  {
    arr[,,i] <- matrix(data_raw[which(data_raw[,cname_dim3] == i),cname_values], 
                                     nrow=no_names_dim1, ncol=no_names_dim2, byrow=byrow_log)
  }
  return(arr)
}