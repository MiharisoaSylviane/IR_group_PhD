# mapping from the allele fequency of different markers into the survival proportion
# for one insecticide resistance
# load library
library(greta)
library(tidyverse)

# generate data_template
data_template <- expand_grid(
  allele = seq_len(1),
  proportion_with_allele =NA,
  proportion_without_allele = NA,
  time_series = seq_len(100),
  strength = NA,
  allele_frequency = NA)
  

# # to run the simulation
# prior_hist <- function(x){
#   sims <- calculate(x, nsim = 1000)
#   hist(sims$x, breaks = 100)
# }
# Define priors
# # Number of time series
# time_series <- 100 

# Number of allele
# type_of_allele <- 1

# number of mosquitoes
n <- 100
# this will be the initial value of allele frequency 
p0 <- uniform(0, 1) 

#  relative fitness of mosquitoes with allele resistant R/S
w <- lognormal(0, 1)

# define proportion without allele
p1 <- p0  / (p0 + (1 - p0) * w)
p2 <- p1  / (p1 + (1 - p1) * w)


calculate(p0, p1, p2, w, nsim = 1)



