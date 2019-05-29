# Explanation: This function writes multiple matrices based on an array to a textfile.
# Each 3rd-dimension-matrix is written via write_matrix_to_file and dimnames(arr_data)[,,3] are
# put into the string_def where XXX-placeholder marks replacement position.
# the function is written for use with apply()

write_array_to_file <- function(arr_data, vec_rownames, vec_colnames, vec_3dnames, string_init, string_def, filename, multi=FALSE)
{
    if(!missing(string_init)){write(string_init, file=filename, append=TRUE)}	
    apply(arr_data, MARGIN=3, function(x) write_matrix_to_file(x, vec_rownames, vec_colnames, 
                                                               string_def=string_def, filename=filename, 
                                                               multi=TRUE))
    string_def_regexp <- gsub("\\[", "\\\\[", string_def)
    string_def_regexp <- gsub("\\]", "\\\\]", string_def_regexp)
    string_def_regexp <- gsub("\\*", "\\\\*", string_def_regexp)
    lines_replacement <- grep(string_def_regexp, readLines(filename))
    document <- readLines(filename)
    new_lines_raw <- readLines(filename)[lines_replacement] 
    new_lines <- sapply(seq_along(new_lines_raw), function(x) sub("XXX", vec_3dnames[x], new_lines_raw[x]))
    document[lines_replacement] <- new_lines
    last_line_raw <- document[length(document)-1]
    if(!multi){last_line <- paste(last_line_raw, ";", sep="")}
    if(multi){last_line <- last_line_raw}
    document[length(document)-1] <- last_line
    writeLines(document, filename)
}

# Sandbox

# as.numeric(as.character(data)) and then trim out all 1s