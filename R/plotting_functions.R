## Plot population history


## Helper function 

convert_to_broken_stick <- function(data, add_to_end = 50) {
  
  start_points <- data$generations
  end_points <- c(data$generations[-1], data$generations[nrow(data)] + add_to_end)
  
  tibble(start = start_points,
         end = end_points,
         Ne = data$Ne)  
  
}


plot_broken_stick <- function(plot_data) {
  
  qplot(x = start,
        y = Ne,
        xend = end,
        yend = Ne,
        data = plot_data,
        geom = "segment") +
    ylim(0, max(plot_data$Ne)) +
    theme_bw() +
    theme(panel.grid = element_blank()) +
    xlab("Generations ago") 
}


