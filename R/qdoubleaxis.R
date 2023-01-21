
qdoubleaxis <- function(data,x_axis,y_axis,y2_axis,t1,t2,coeff,zero=F,color1='#1f497d',color2='#4ba3e7'){

  transformer <- data %>%
    transformer_dual_y_axis(
      primary_column   = {{y_axis}},
      secondary_column = {{y2_axis}},
      include_y_zero   = zero)

  ggplot(data=datos,aes(x={{x_axis}}))+
    geom_line(aes(y={{y_axis}}),color = color1,linewidth=1.2,alpha=0.8)+
    geom_line(aes(y=transformer$inv_func({{y2_axis}}) ), color = color2 ,linewidth=1.2,alpha=0.8)+
    scale_y_continuous(
      name = t1,labels = scales::comma_format(),
      sec.axis = sec_axis(trans = ~ transformer$scale_func(.),name  = t2,labels   = scales::comma_format())) #+
    #scale_x_date(date_labels = "%b\n%y", date_breaks = "10 months",expand=c(0,0))
}

#
# datasets::co2 %>%
#   as_tibble()
#
#
# qdoubleaxis
