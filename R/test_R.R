# mapping from the allele fequency of different markers into the survival proportion
# for one insecticide resistance
# load library
library(greta)
# library(tidyverse)
# n<-100
# data_template <- expand_grid(
#   allele = seq_len(3),
#   anopheles_indiv = seq_len(n),
#   # ratio_susceptible =0,
#   # ratio_resistant = 0,
#   time_series = seq_len(4),
#   allele_frequency = NA) %>%
#   mutate(
#     before_after = case_when(
#       time_series %in% 1:2 ~ "before",  # Time points 1 and 2 are "before"
#       time_series %in% 3:4 ~ "after"   # Time points 3 and 4 are "after"
#     )
#   )


# define the inital value of allele frequency
# set.seed(123)
# data_template <- data_template %>%
#   mutate(
#     allele_frequency = ifelse(
#       before_after == "before",
#       runif(n()),  
#       allele_frequency
#     )
#   )

# time series
time_series <- 10

# itns_covariates <- seq(0.1, 0.9, length.out = time_series)
intervention_times <- 4
itns_covariates <- c(rep(0.9, length.out = intervention_times),
                     rep(0.0, length.out = time_series - intervention_times))

# # "before" intervention, 10% of population using nets. "after" intervention, 90%
# # using nets
# itns_covariates <- c(0.1, 0.1, 0.9, 0.9)


# Define greta model
# Prior for proportion of susceptible
p0 <- uniform(0, 1)


# # Prior for selection pressure average
# s <- normal(0, 1, truncation =c(0,1))  

# coefficient of itns effect resistance
# beta <- log(gammax)

beta <- normal(0,1)
gammax <- exp(beta)

 
# selection pressure
st <- gammax*itns_covariates
 
# # relative fitness of mosquitoes with allele resistant R/S
w <- 1 + st

# calculate(w, nsim = 1)
 
  
# Simulate allele frequencies
# to assign it as varying with time
# p <- numeric(time_series)

# # proportion without resistance p where we will define the fraction of resistant
# for (t in 1:(time_series)) {
#   if (t >2) {
# p <- p[t] / p[t] + (1 - p[t]) * w 
# p_resist <- 1 - p # proportion of resistant
#   }
# }


# Probability of an allele to occur
p_susc <- zeros(time_series)
# p_susc <- as_data(rep(0, 4))
p_susc[1] <- p0
for (t in 1:(time_series-1)) {
  p_susc[t + 1] <- p_susc[t]/ (p_susc[t] + (1- p_susc[t]) * w[t])
  
}

p_resist <- 1 - p_susc


# simulate genotypic allele frequency data
n_tested <- rep(100, time_series)
n_positive <- binomial(size = n_tested, prob = p_resist)

# distribution(n_positive) <- binomial(size = n_tested, prob = p_resist)


observed_frequency <- n_positive / n_tested
sim<- calculate(p_resist, nsim=1)


sims <- calculate(gammax, p_resist,
                  n_positive,
                  observed_frequency,
                  nsim = 1,
                  values = list(p0 = 0.9))
sims

plot(sims$p_resist[1, , 1],
     ylim = c(0, 1),
     type = "b")

points(sims$observed_frequency,
       pch = 16)


### Sylviane has to determine the phenotype proportion by using the allele frequency

# to calculate the phenotype, we will use the equilibrum Hardy-Weinberg equilibrium
# Probability of an allele to occur
# phenotype <- zeros(time_series)
# ph_initial <- uniform(0,1)
# # phenotype <- as_data(rep(0, 10))
# phenotype [1] <- ph_initial
# for (t in 1:(time_series-1)) {
#   phenotype[t + 1] <- (p_resist[t] ^ 2) + (2 * p_susc[t] * p_resist[t])
#   
# }
# 
# # simulate genotypic allele frequency data
# n_tested <- rep(100, time_series)
# n_positive <- binomial(size = n_tested, prob = phenotype)
# 
# 
# # observed_frequency <- n_positive / n_tested
# 
# sims <- calculate(phenotype,
#                   n_positive,
#                   nsim = 1,
#                   values = list(p0 = 0.9))
# sims
# plot(sims$phenotype[1, ,1])


# sims <- calculate(p_resist,
#                   n_resistant,
#                   nsim = 1,
#                   values = list(p0 = 0.9))
# sims
# 
# 
# n_resistant <- numeric(time_series)  # Vecteur pour stocker le nombre de moustiques résistants


# determine the proportion of mosquitos resistant
proportion_resistant <- n_positive/n_tested
sims <- calculate(p_resist, 
                  proportion_resistant, 
                  nsim =1,
                  values = list(p0=0.9))
sims

#plotting
plot(sims$proportion_resistant, 
     type = "o", 
     col = "blue", 
     pch = 16)

points(sims$p_resist,
      type = "o", 
      col = "red",
      pch = c(16))


