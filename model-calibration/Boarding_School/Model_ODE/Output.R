Output <- function(out, path) {
  
  Susceptibles <- data.frame("time"  = out[ , 1],
                             "S"  = out[ , 2]) #1 is time
  
  
  # plotting ode solution with ggplot
  S <- ggplot(melt(Susceptibles, "time"), aes(x=time, y=value, color=variable)) + geom_line(linewidth=1) +
    scale_colour_manual("Sh",values=c("goldenrod4")) + 
    ylab("Susceptible population") + xlab("Time (Days)") 
  
  S
  print(S)
  
  Infected <- data.frame("time"  = out[ , 1],
                         "I"  = out[ , 3]) #1 is time
  
  
  # plotting ode solution with ggplot
  I <- ggplot(melt(Infected, "time"), aes(x=time, y=value, color=variable)) + geom_line(linewidth=1) +
    scale_colour_manual("Infected",values=c("red")) + 
    ylab("Infected population") + xlab("Time (Days)") 
  
  I
  print(I)
  
  # Saving the ode output and 
  pathss = "C:/Users/rabiu/OneDrive/Documents/R_code/Boarding_School/Model_ODE/"
  
  plotpathss = "C:/Users/rabiu/OneDrive/Documents/R_code/Boarding_School/Model_ODE/"
  
  
  csv_filename = paste(pathss, "infected_data.csv", sep="")
  write.csv(Infected, file=csv_filename, row.names = FALSE)
  
  filename = paste(path, "Infected.png", sep="")
  png(filename)
  plot(Infected)
  dev.off()
  
  print(Infected)
  
  
  Recovered <- data.frame("time"  = out[ , 1],
                          "R"  = out[ , 4]) #1 is time
  
  
  # plotting ode solution with ggplot
  R <- ggplot(melt(Recovered, "time"), aes(x=time, y=value, color=variable)) + geom_line(linewidth=1) +
    scale_colour_manual("Recovered",values=c("black")) + 
    ylab("Recovered population") + xlab("Time (Days)") 
  
  R
  print(R)
  
  # CumInci <- data.frame("time" = out[ , 1],
  #                       "Incidence" = out[ ,5])
  # 
  # # plotting ode solution with ggplot
  # CumInci_Plot <- ggplot(melt(CumInci, "time"), aes(x=time, y=value, color=variable)) + geom_line(linewidth=1) +
  #   scale_colour_manual(values=c("magenta2")) +
  #   ylab("Cum. incidence class") + xlab("Time (weeks)")
  # 
  # CumInci_Plot
  # 
  # # incidence
  # Cum_Inci <- cbind(out[ , 1], out[ , 5])
  # 
  # 
  # # compute incidence
  # Incidence <-  diff(Cum_Inci)
  # 
  # lenOut = dim(out)
  # lenOut = lenOut[1]
  # 
  # 
  # Incidence_df <- data.frame("time" = out[2:lenOut , 1],
  #                            "Inc_data" = Incidence[ ,2])
  # 
  # 
  # # plotting ode solution with ggplot
  # Incidence <- ggplot(melt(Incidence_df, "time"), aes(x=time, y=value, color=variable)) + geom_line(linewidth=1) +
  #   scale_colour_manual("Incidence",values=c("magenta2")) +
  #   ylab("Incidence") + xlab("Time (Days)")
  # 
  # 
  # 
  #Use this print function if you wish to see the plot outside in the plot region, else it appears in the path
  # print(Incidence)
  # pathss = "C:/Users/rabiu/OneDrive/Documents/R_code/Boarding_School/Model_ODE/"
  # 
  # # Saving the ode output and plot
  # csv_filename = paste(pathss, "incidence_data.csv", sep="")
  # write.csv(Incidence_df, file=csv_filename, row.names = FALSE)
  # 
  # filename = paste(path, "Incidence.png", sep="")
  # png(filename)
  # plot(Incidence)
  # dev.off()
  # 
  # print(Incidence)
  # 
  
}





