# The function import mappings based on two or more vectors to a database. It maps the values provided in 
# vector_two to each element in vector_one.
# The function needs the packages DBI and RPostgreSQL

db_input_mapping <- function(db_connection, name_mapping, vec_fk_one, vec_fk_two, vec_fk_three=NULL, pos_vec_three = "end", log_simple=FALSE, log_switch=FALSE)
{
  db_mapping <- dbReadTable(db_connection, name_mapping)
  index_mapping <- max(db_mapping$id)
  if(!log_simple)
  {
    vec_mapping_pks <- c((index_mapping+1):(index_mapping+(length(vec_fk_one)*length(vec_fk_two))))
    vec_fk_one_import <- rep(vec_fk_one, each=length(vec_fk_two))
    vec_fk_two_import <- rep(vec_fk_two, times=length(vec_fk_one))
    if(is.null(vec_fk_three))
    {
      if(!log_switch)
      {
        df_mapping_import <- as.data.frame(cbind(vec_mapping_pks, vec_fk_one_import, vec_fk_two_import))
      }
      if(log_switch)
      {
        df_mapping_import <- as.data.frame(cbind(vec_mapping_pks, vec_fk_two_import, vec_fk_one_import))
      }
    }
    if(!is.null(vec_fk_three))
    {
      vec_fk_three_import <- rep(vec_fk_three, each=length(vec_fk_one))
      df_mapping_import <- as.data.frame(cbind(vec_mapping_pks, vec_fk_one_import, 
                                             vec_fk_two_import, vec_fk_three_import))
    }
  }
  if(log_simple & length(vec_fk_one) == length(vec_fk_two))
  {
    vec_mapping_pks <- c((index_mapping+1):(index_mapping+length(vec_fk_one)))
    if(is.null(vec_fk_three))
    {
      df_mapping_import <- as.data.frame(cbind(vec_mapping_pks, vec_fk_one, vec_fk_two))
    }
    if(!is.null(vec_fk_three))
    {
      if(pos_vec_three == "end")
      {
        df_mapping_import <- as.data.frame(cbind(vec_mapping_pks, vec_fk_one, 
                                               vec_fk_two, vec_fk_three))
      }
      if(pos_vec_three == "front")
      {
        df_mapping_import <- as.data.frame(cbind(vec_mapping_pks, vec_fk_three, vec_fk_one, 
                                                 vec_fk_two))
      }
    }
  }
  else if(log_simple)
  {
    stop('length of vectors are not the same')
  }
  # Data-Base Import
  dbWriteTable(db_connection, name_mapping, df_mapping_import, row.names=FALSE, append=TRUE)
  print(paste('Table ', name_mapping, ' successfully updated. ', length(vec_mapping_pks), 
              ' observations imported.', sep=""))
  return(vec_mapping_pks)
}