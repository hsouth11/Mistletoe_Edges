# Regen and Mature Tree Data Cleaning
# Updated: 27 Mar 2024

# Load packages
library(dplyr)

# Read in data
regen <- read_csv("./data/regen comp_master_21Feb2024.csv")
mature <- read_csv('./data/mature comp_master_21Feb2024.csv')

# Learn a bit about data
dim(regen); dim(mature)
summary(regen)
summary(mature)

# Delete empty rows
regen <- regen%>% filter(!is.na(site_id))# Delete empty rows
mature <- mature %>% filter(!is.na(site_id))# Delete empty rows
dim(regen); dim(mature) #546 mature trees, 735 regen trees

# What are the variables? 
########### REGEN ##########
# tree_id_new: unique id; character
# tree_id_old: flag used to mark tree in fieldwork; character
# site_id: factor
# transect_id: unique identifier of transects; 
# spp: species; factor
# dist_x: x coordinate of tree on transect (left = neg, right = pos)
# dist_y: y coordinate of tree on transect in slope distance
# status: live standing (LS), live leaning (LL), live fallen (LF), dead standing (DS), snag (SN); factor
# dbh: diameter at 1.3m in cm; numeric
# height: height in m; numeric
# hdm_pa: presence or absence of HDM, Y = present, N = absent, - = not applicable (e.g. not a Hw or tree so decomposed its hard to assess); factor
# b_lc: presence or absence of HDM below live crown, Y = present, N = absent, - = not applicable; factor
# dmr_l, dmr_m, dmr_u: dwarm mistletoe rating for lower, middle and upper LIVE crown respectively, 0 = none, 1 = <50% primary branches infected, 2 = >50% branches infected
# broom_pa: presence or absence of brooms, Y = present, N = absent, - = not applicable; factor
# broom_pos: position of brooms, blc = below live crown, 1 = lower live crown (lc), 2 = middle lc, 3 = upper lc, 4 = lower and middle lc, 5 = lower and upper lc, 6 = middle and upper lc, 7 = all lc, 8 = below lc 
# broom_stem: presence or absence of stem infection, Y = present, N = absent, - = not applicable; factor
# crown_class: codominant (C), dominant (D), intermediate(I), suppressed (S), not applicable (-); factor
# dam_agent_1 and dam_agent_2: damage agents; characters (for now, not planning on doing anything with this data)
# path_ind_1 and path_ind_2: pathological indicators; characters (for now, not planning on doing anything with this data)
# crown condition: rating from 1 (good) to 6 (bad), see cheat sheet; factor
# notes: any notes about the tree

# CLEANING TO DO
# Convert broom_pos to a factor, and deal with (-)


#Make factor variables factors
regen <- regen %>% mutate(across(
  c(site_id, spp, status, hdm_pa, b_lc, 
    broom_pa, broom_stem, crown_class, crown_cond), ~as.factor(.)))

levels(regen$crown_class)

#Make integer variables integers
regen <- regen %>% mutate(across(c(dmr_l, dmr_m, dmr_u), ~as.integer(.)))



