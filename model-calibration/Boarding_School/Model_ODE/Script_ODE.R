#Monkeypox_Baseline Model SEIR Baseline, no demograpghy
# loading libraries
library(deSolve)
library(Matrix)
library(rTensor)
library(pillar)
library(tidyverse)
library(reshape2)
library(matlib)
library("readxl")
setwd("C:/Users/rabiu/OneDrive/Documents/R_code/Boarding_School/Model_ODE/")
plot_path = "C:/Users/rabiu/OneDrive/Documents/R_code/Boarding_School/Model_ODE/"
                                    
source("Odefun.R")
source("Output.R")

N <- 763;
beta <- 1.73
gamma<- 0.54;#0.8799; incubation

IC = c(762,1,0);  # include one compartment for incidence
X0 = IC;  
params  <- c(beta = beta,
             N = N,
             gamma=gamma)  # rate of going from I2 to R (recovery rate/2)

times <- seq(0, 20, by = 1) #values of alpha_vec affects the time here


out<-ode(X0, times, SEIR, params)
# summary(out)
# Calling the function that processes the ode solutions, save them in a file for each compartment, and save their corresponding plots
Output(out, plot_path)




