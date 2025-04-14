#Code for cleaning extra regen height data
#Hanno Southam
#Date last updated: 21 Aug 2024
#Date last ran: 21 Aug 2024

rm(list=ls(all=TRUE))

#Load package
library(tidyverse)
library(here)

#Read in extra height data
ht_hdm_extra <- read_csv(here("./data/raw/regen_comp_extra_heights.csv"))
summary(ht_hdm_extra)

#Problem 1: a whole bunch of NA rows, remove these
ht_hdm_extra <- ht_hdm_extra %>% filter(!is.na(site_id))

#Problem 2: a number of trees are missing crown class
#All of these extra trees were codominant and dominants
#Assume these were codominants
ht_hdm_extra <- ht_hdm_extra %>% 
  mutate(crown_class = if_else(is.na(crown_class), "C", crown_class))

#Problem 3: dbh measurements are missing for the trees at ph_3 but there is
#no easy way to remedy that. 

#Problem 4: The protocol we used to measure height differed from the 
#provincial ground sampling procedures. We added height to accommodate the 
#apical droop of Hw. Prov procedures measure to apex of apical droop. 
#Correct by subtracting standard amount for each component/crown class.
#Because all of these trees are regen and codominant/dominants, some of these 
#rules don't have cases in this data. But included all rules because this 
#correction also happens in script for cleaning larger tree dataset. 
#Keeping it consistent. 
#Mature: if codominant/dominant = 1m; intermediate = 0.75, suppressed = 0.5m
#Regen: codominant = 0.5m; intermediate = 0.4m, suppressed = 0.3m
ht_hdm_extra <- ht_hdm_extra %>% 
  mutate(ht_corr = height_m - 0.5)


#Export this csv as a clean dataset
write_csv(ht_hdm_extra, "./data/cleaned/regen_extra_ht_c.csv")
