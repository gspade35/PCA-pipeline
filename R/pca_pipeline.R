pca_df <- function(df,id_col="SUBJID",group,names_col="LBTESTCD",values_col="AVAL"){
  cols <- c(id_col,group,names_col,values_col)
  dfpca <- df %>%
    select(all_of(cols)) %>%
    tidyr::pivot_wider(names_from = names_col, values_from = values_col)
  return(dfpca)
}

pca_mat <- function(df,id_col,group,log_trans){
  id <- paste0(id_col)
  group_str <- paste0(group)
  new_col_name <- paste0(id, "_", group)
  
  #define encapsulated log transform function
  log_transform <- possibly(function(x) {
    if (any(x <= 0, na.rm = TRUE)) {
      warning("1 was added to all numeric values before log10 transformation.")
      return(ifelse(is.na(x), NA, log10(x + 1)))
    } else {
      return(ifelse(is.na(x), NA, log10(x)))
    }
  }, otherwise = NA_real_)
  
  # browser()
  mat_pca <- df %>%
    tidyr::unite(!!sym(new_col_name), c(id, group), remove = TRUE) %>%
    tibble::column_to_rownames(new_col_name)
  
  if (log_trans) {
    mat_pca <- mat_pca %>% mutate(across(where(is.numeric), ~ log_transform(.)))
  }
  mat_pca <- mat_pca[complete.cases(mat_pca), ] #ensure completeness before prcomp
  return(mat_pca)
}

#just use pmqts::save_plots?
print_plots <- function(plot_list, filetype=".pdf", print.args=list()){

  print.args$height <- ifelse(is.null(print.args$height),4.3*1.5,print.args$height)
  print.args$width <- ifelse(is.null(print.args$width),9.3*1.5,print.args$width)
  print.args$useDingbats <- ifelse(is.null(print.args$useDingbats),F,print.args$useDingbats)
  
  if(tolower(filetype) %in% c("pdf",".pdf")){do.call(pdf,print.args)}
  #add additional file types?
  else{stop("Invalid file type. Try pdf")}
  map(plot_list,function(plot){
    suppressMessages(print(plot))})
  dev.off()
}

plot_pca <- function(pca_res,id_col,group,plot.args=list()){
  id <- paste0(id_col)
  group_str <- paste0(group)
  new_col_name <- paste0(id, "_", group)

  # browser()
  ggplot.args <- ifelse(is.null(plot.args$ggplot.args),
                        list(data = pca_res$x %>% as.data.frame() %>% 
                               tibble::rownames_to_column(new_col_name) %>% 
                               tidyr::separate(col = !!sym(new_col_name), into = c(id, group_str), sep = "_") %>% 
                               dplyr::rename_with(~(.[1]), !!rlang::sym(group_str)),
                             mapping = aes(x=PC1, y=PC2)),
                        plot.args$ggplot.args)
  geom_point.args <- ifelse(is.null(plot.args$geom_point.args),
                            list(mapping = aes(x=PC1, y=PC2, fill = !!rlang::sym(group), color = !!rlang::sym(group)),
                                               # , 
                                 size=6, pch=21, alpha=1.2, color = "black"),
                            plot.args$geom_point.args)
  stat_ellipse.args <- ifelse(is.null(plot.args$stat_ellipse.args),
                              list(mapping = aes(x=PC1, y=PC2, color = !!rlang::sym(group)), 
                                   linewidth = 2, level = 0.95, alpha = 1, show.legend = F),
                              plot.args$stat_ellipse.args)
  labs.args <- ifelse(is.null(plot.args$labs.args),
                      list(x="Principal Component 1",y="Principal Component 2"),
                      plot.args$labs.args)
  if(is.null(plot.args$theme.args)) {
    theme.args <- list(legend.position="right",
                       axis.text    = element_text(size = 16),
                       axis.title   = element_text(size = 18),
                       legend.title = element_text(size = 18),
                       legend.text  = element_text(size = 16))
  } else {
    theme.args <- plot.args$theme.args
  }
    plot <- do.call(ggplot,ggplot.args) +
      do.call(geom_point,geom_point.args) + 
      do.call(stat_ellipse,stat_ellipse.args) +
      do.call(labs,labs.args) +
      theme_classic() +
      do.call(theme,theme.args)
  return(plot)
}


pca_pipeline <- function(df,id_col="SUBJID",group,names_col="LBTESTCD",values_col="AVAL",log_trans = T,file=NULL,...){
  params <- list(...)
  print.args <- c(file=file,params$print.args)
  plot.args <- params$plot.args
  scale <- ifelse(is.null(params$scale),F,params$scale)
  # browser()
  
  #define encapsulated that summarizes incomplete rows lost during PCA
  complete_data_info <- function(df) {
    complete_data <- df[complete.cases(df), ]
    removed_rows <- df[!complete.cases(df), ]
    
    if (nrow(removed_rows) > 0) {
      warning(paste(nrow(removed_rows), "rows were removed due to missing values. Summary of removed rows:"))
      print(removed_rows)
    }
    return(complete_data)
  }
  
  plot <- df %>% filter(!is.na(group)) %>%
    pca_df(id_col,group,names_col,values_col) %>% 
    pca_mat(id_col,group,log_trans) %>%
    complete_data_info() %>%
    prcomp(scale) %>% 
    plot_pca(id_col,group,params)
  if(is.null(file)){
    return(plot)}
  
  print_plots(list(plot),print.args)
}
