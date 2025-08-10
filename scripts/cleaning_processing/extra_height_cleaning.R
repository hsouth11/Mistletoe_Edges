#Code for cleaning extra regen height data
#Hanno Southam
#Date last updated: 25 Apr 2025
#Date last ran: 25 Apr 2025

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

#Some formatting
#Drop units from height column name to be consistent with other columns
ht_hdm_extra <- ht_hdm_extra %>% 
  rename(height = height_m)

#Export this csv as a clean dataset
write_csv(ht_hdm_extra, "./data/cleaned/regen_extra_ht_c.csv")
