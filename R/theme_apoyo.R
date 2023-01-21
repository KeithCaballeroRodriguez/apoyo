
theme_apoyo <- function(fuente="") {
  theme_light() +
    theme(
      text = element_text(size = 14, face = "bold",family = fuente),
      axis.text = element_text(size = 11,face = "bold",color = "black"),
      panel.border = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(colour = "black"),
      axis.ticks = element_line(colour = "black"),
      plot.title = element_text(hjust = 0.5)
    )
}
