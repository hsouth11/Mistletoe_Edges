# Regen and Mature Tree Data Cleaning
# Updated: 1 May 2024

# need to update stem_pa to be broom_pa (7 May 2024)

rm(list=ls(all=TRUE))

# Load packages
library(tidyverse)

# Read in data
regen <- read_csv("./data/raw/regen comp_master.csv")
mature <- read_csv('./data/raw/mature comp_master.csv')

# Learn a bit about data
dim(regen); dim(mature)
summary(regen)
summary(mature)

# Delete empty rows
regen <- regen%>% filter(!is.na(site_id))# Delete empty rows
mature <- mature %>% filter(!is.na(site_id))# Delete empty rows
dim(regen); dim(mature) #627 mature trees, 869 regen trees

# What are the variables? 
########### REGEN ##########
# tree_id: unique id; character
# flag_id: flag used to mark tree in fieldwork; character
# site_id: unique identifier of sites; factor
# transect_id: unique identifier of transects; integer
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
# broom_pos: position of brooms, 1 = lower live crown (lc), 2 = middle lc, 3 = upper lc, 4 = lower and middle lc, 5 = lower and upper lc, 6 = middle and upper lc, 7 = all lc, 8 = below lc, (-) not applicable
# broom_pa: presence or absence of stem infection, Y = present, N = absent, - = not applicable; factor
# crown_class: codominant (C), dominant (D), intermediate(I), suppressed (S), not applicable (-); factor
# dam_agent_1 and dam_agent_2: damage agents; characters (for now, not planning on doing anything with this data)
# path_ind_1 and path_ind_2: pathological indicators; characters (for now, not planning on doing anything with this data)
# crown condition: rating from 1 (good) to 6 (bad), see cheat sheet; factor
# notes: any notes about the tree

########### MATURE ##########
# Only variables that are different from REGEN dataset are includes
# plot_id: unique id of stem mapping plot, distinct numeric range from transect_id (variable in regen data); integer
# dist_m: distance from stem mapping point in meters; numeric
# az_deg: azimuth from the stem mapping point NOT DECLINATION CORRECTED, in degrees; numeric
# dec_deg: column for declination at the site, not filled in in raw data, degrees;
# outside_10: is the tree more than 10m (horizontal distance) from edge, Y, N, NA; factor
# assessed_by: who assessed the tree, only recorded at 1 site for a few trees, both (B), Hanno (HS), Noel (NH); factor

# CLEANING TO DO
# figure out how to treat - and NA values throughout --> 
### Right now, - = not applicable given another column, NA = no value
### For factors, convert to "-", for integers or numerics, leave NA
# sort out rules for hdm ratings
### if spp!=Hw or Ba, then dmrs = 0 and all other hdm variables are "-"
### if spp = Hw or Ba and hdm_na = N, then dmrs = 0 and all other hdm varaiables are "-"
### dmr = sum of dmrs, except when dmr = 0, hdm_pa = Y and b_lc = Y (i.e. the tree is only infected below live crown)

#Join the two datasets
regen <- regen %>% rename(plot_id = transect_id) 
#first rename transect_id with plot_id so two datasets align
trees <- full_join(regen, mature)

#Make a factor variable distinguishing the two
trees <- trees %>% 
  mutate(tree_type = case_when(str_detect(tree_id, "r") ~ "regen", 
                               str_detect(tree_id, "m") ~ "mature")) %>% 
  mutate(tree_type = factor(tree_type, levels = c("regen", "mature")))

#Make factor variables factors
trees <- trees %>% mutate(across(
  c(site_id, spp, status, hdm_pa, b_lc, 
    broom_pa, broom_pos, stem_pa, crown_class, crown_cond, outside_10, assessed_by), ~as.factor(.)))

#Make integer variables integers. Note: this turns "-" into NAs
trees <- trees %>% mutate(across(
  c(plot_id, dmr_l, dmr_m, dmr_u), ~as.integer(.)))

# Get a summary of the dataset. Check the levels and classes of variables against the list above.
str(trees)
summary(trees)

########## LOGICAL CHECKS ########## 
#Essential data: all trees should have tree_id, site_id, plot_id, spp, status, dbh, hdm_pa, and crown cond
na_summary <- trees %>% #from chatgpt
  summarise(across(c(tree_id, site_id, plot_id, spp, status, dbh, hdm_pa, crown_cond), ~ any(is.na(.))))
print(na_summary)
#crown_cond has one NA
#the rest look good from summary table
trees %>% filter(is.na(crown_cond)) #crown_cond NA is tree_id is r704, site mi_2, transect 124
#checked, not a data entry error, forgot to record

#Regen trees should also have: dist_x, dist_y and dbh>4
trees %>% filter(tree_type =="regen") %>% select(dist_x, dist_y, dbh) %>% summary()
trees %>% filter(tree_type =="regen" & dbh<4) 
trees %>% filter(tree_type =="regen" & dbh>30) 
#Some trees with dbh<4, tree_id = r213 and r538. Both data entry errors, should have been r213 dbh = 13.8, r538 dbh = 13.1. Fixed in raw data. dbh range looks reasonable otherwise (4-42.40). Checked a few large dbhs (r355, r362 and r229), not data entry errors. 
trees %>% filter(tree_type =="regen" & dist_y<0)
trees <- trees %>% mutate(dist_y = case_when(tree_id == "r525" ~ 1.9, .default = dist_y))
trees %>% filter(tree_id =="r525")
#dist_y and dist_x. No NAs. Range: dist x is bounded by (-2.5) - (2.5); dist_y should be >0 and max around 35m. Longest transect is 32.8m but this is horizontal dist, dist_y in slope dist. One tree <0, tree id r525. Checked datasheet, there is a (-) but must be an error. Make positive.

#Mature trees should also have: dist_m, az_deg, dbh>9 and outside_10
trees %>% filter(grepl('m', tree_id)) %>% select(dist_m, az_deg, dbh, outside_10) %>% summary()
trees %>% filter(grepl('m', tree_id) & dbh<9) 
trees %>% filter(grepl('m', tree_id) & dbh>100) 
#dist_m looks good. ranges make sense: 0<=dist_m<=15m.  no NAs (except in outside_10 which is OK)
#az_deg also looks good.ranges make sense: between 0<=az_deg<360
#outside_10 looks good. Some NAs but that okay. 
#One tree with dbh<9, tree_id = m385. Data entry error should be dbh = 14.0. Fixed in raw data. Checked a few large dbhs (m476, m472, m478, m30). m476 was a data entry error (should be r=17.9 (not 179)) others good. Fixed in raw data. m556, m582 and m585 from ph_2 make sense - big cedars on that site.   

#How many transects are there? Should be 30 (3 tranects/site * 10 sites)
trees %>% filter(tree_type=="regen") %>% pull(plot_id) %>% unique() %>% length()

########## Cleaning HDM variables ########## 
##### RULES
### Rule 1: if spp!=Hw or Ba, then dmrs = NAs and all other hdm variables are "-"
### Rule 2: if spp=Hw or Ba, it can can have hdm_pa = Y, N or U (unknown for unassessable trees, e.g. snags)
### Rule 3: if spp=Hw or Ba, it can have dmr by crown third= NA (dead trees, snags), 0, 1 or 2
###### Special cases: 
### Rule 4: if spp=Hw or Ba, status= LS, LL, LF or RD (i.e. its alive or recently dead) then hdm factor variables and dmrs are defined
### Rule 5: if spp=Hw or Ba, and status=SN or DS (i.e. its been dead for a while) then hdm_pa can be Y, N, U but dmrs = NA and all other hdm factors = "-" (i.e. dmr and hdm factors were not assessed for these trees)

# Note: there is some trees hiding in this rule:
# When spp = Hw or Ba, hdm_pa = Y and b_lc = Y and dmr = 0 (i.e. the tree is only infected below live crown), it will show up as dmr = 0, which isn't quite correct because it is infected just not in the live crown. Call this case IBLC. 
# When spp = Hw or Ba, status = DS or SN, dmr will = NA. This isn't quite representative because it could be infected. Call this: DI (dead, infected) if infected and DU (dead uninfected) if uninfected.
# To account for this for these cases, we will make another tree level dmr variable, that is a factor

### Rule 1: if spp!=Hw or Ba, then dmrs = NA and all other hdm variables are "-"
trees %>% filter(!spp %in% c("Hw", "Ba")) %>% select(spp, hdm_pa) %>% group_by(spp) %>% count(hdm_pa)
# Ba is a recorded rare host and at ph_2 it had significant brooming and infection, so we will treat it as a host invovled in transmission
# Fd is the only other species where we observed HDM infection, but we were unsure about it, infection was truly rare and we didn't see brooming. Can note that in our discussion but will assume it doesn't contribute to transmission and treat it as a non-host. 

#Set factors = "-"
trees <- trees %>% mutate(across(c(hdm_pa, b_lc, broom_pa, broom_pos, stem_pa), ~ 
                                   case_when(!spp %in% c("Hw", "Ba") ~ "-", TRUE ~ .))) %>% 
  mutate(across(c(hdm_pa, b_lc, broom_pa, broom_pos, stem_pa), ~as.factor(.)))
trees %>% filter(!spp %in% c("Hw", "Ba")) %>% select(spp, hdm_pa) %>% group_by(spp) %>% count(hdm_pa) # Check, looks good. 

#Set dmrs = NA
trees <- trees %>% mutate(across(dmr_l:dmr_u, ~ case_when((!spp %in% c("Hw", "Ba")) ~ NA, TRUE ~ .)))
trees %>% filter(!spp %in% c("Hw", "Ba")) %>% 
  select(dmr_l:dmr_u) %>% summary() # Check, looks good


### Rule 2: if spp=Hw or Ba, it can can have hdm_pa = Y, N or U (unknown for unassessable trees, e.g. snags)
# What are the levels of hdm_pa in Hw trees? 
trees %>% filter(spp %in% c("Hw", "Ba")) %>% select(hdm_pa) %>% summary() #Y, N and -. 
# Want it to be Y, N and U. Only nine trees with "-"

#Lets look at those. 8 are snags and the other DS, so - indicates unassessable. Lets redefine them to U
trees %>% filter((spp %in% c("Hw", "Ba")) & hdm_pa=="-")
trees <- trees %>% mutate(hdm_pa = case_when((spp %in% c("Hw", "Ba") & hdm_pa=="-") ~ "U", 
                                             .default = hdm_pa)) %>% mutate(hdm_pa = factor(hdm_pa))
trees %>% filter(spp %in% c("Hw", "Ba")) %>% select(hdm_pa) %>% summary() #check, looks good


### Rules 3-5
# Case 1: status = LS, LL, LF, RD (live and recently dead trees)
trees %>% filter(spp %in% c("Hw", "Ba") & status %in% c("LS", "LL", "LF", "RD")) %>% 
  group_by(spp, status) %>% summarise(hdm_pa = table(hdm_pa))  %>% print(n=24)
# gives you a table summarizing # of trees in each hdm_pa level by status. Unfortunately, it doesn't explicitly list the level of the hdm_pa in the table so list that explictly to help read the table. 
levels(trees$hdm_pa)
# For Hw: infected and uninfected trees in all four status categories
# For Ba: only LS and LL classes represented. LL has one healthy tree and LS has healthy and infected.

# Set hdm factor variables equal to "-' and dmr = 0, where spp=Hw or Ba, hdm_pa=N and status = LS, LL, LF, RD
trees <- trees %>% mutate(across(c(b_lc, broom_pa, broom_pos, stem_pa), ~ 
                                   case_when((spp %in% c("Hw", "Ba") & hdm_pa=="N" & 
                                              status %in% c("LS", "LL", "LF", "RD")) ~ "-", TRUE ~ .))) %>% 
                  mutate(across(c(b_lc, broom_pa, broom_pos, stem_pa), ~as.factor(.)))

trees %>% filter(spp %in% c("Hw", "Ba") & hdm_pa=="N" & status %in% c("LS", "LL", "LF", "RD")) %>% 
  select(b_lc, broom_pa, broom_pos, stem_pa) %>% summary()
#Check, looks good

#Set dmrs = 0 if spp=Hw or Ba and hdm_pa=N
trees <- trees %>% mutate(across(dmr_l:dmr_u, ~ case_when((spp %in% c("Hw", "Ba") & hdm_pa=="N"
                                                           & status %in% c("LS", "LL", "LF", "RD")) ~ 0, TRUE ~ .)))

trees %>% filter(spp %in% c("Hw", "Ba") & hdm_pa=="N" & status %in% c("LS", "LL", "LF", "RD")) %>% 
  select(dmr_l:dmr_u) %>% summary() # looks good

# Case 2: spp=Hw or Ba and status=SN or DS (i.e. its been dead for a while)
trees %>% filter(spp %in% c("Hw", "Ba") & status %in% c("DS", "SN")) %>% 
  group_by(spp, status) %>% summarise(hdm_pa = table(hdm_pa))
# gives you a table summarizing # of trees in each hdm_pa level by status. Unfortunately, it doesn't explicitly list the level of the hdm_pa in the table so list that explictly to help read the table. 
levels(trees$hdm_pa)
# DS and SN contain infected, uninfected unassessable trees, thats good

trees %>% filter(spp %in% c("Hw", "Ba") & status %in% c("DS", "SN")) %>% 
  select(hdm_pa, b_lc, broom_pa, broom_pos, stem_pa) %>% summary()
# Shows that there are a few trees where we recorded hdm data even though they were DS or SN. This wasn't in the collection protocol, so okay to lose this data and reassign values.  

# Set hdm factor variables equal to "-' and dmr = NA, where spp=Hw and status = DS or SN
trees <- trees %>% mutate(across(c(b_lc, broom_pa, broom_pos, stem_pa), ~ 
                                   case_when((spp %in% c("Hw", "Ba") & status %in% c("DS", "SN")) ~ "-", TRUE ~ .))) %>% 
                   mutate(across(c(b_lc, broom_pa, broom_pos, stem_pa), ~as.factor(.)))
trees %>% filter(spp %in% c("Hw", "Ba") & status %in% c("DS", "SN")) %>% 
  select(hdm_pa, b_lc, broom_pa, broom_pos, stem_pa) %>% summary() #Check, looks good. 

#Set dmrs = NA
trees <- trees %>% mutate(across(dmr_l:dmr_u, ~ case_when((spp %in% c("Hw", "Ba") & 
                                                             status %in% c("DS", "SN")) ~ NA, TRUE ~ .)))

trees %>% filter(spp %in% c("Hw", "Ba") & status %in% c("DS", "SN")) %>% 
  select(dmr_l:dmr_u) %>% summary() #check, looks good, all NA

########## Calculate Tree Level DMR ########## 
# Going to calculate two of these. 
# dmr = an integer that will only capture the tree level dmr for trees where dmr by crown third (dmr_l, dmr_m, dmr_u) is defined (i.e. live and recently dead trees)
# dmr_f = a factor that captures special cases including: 
# When spp !=Hw, dmr=NA and we'd rather it be - to indicate it isn't applicable
# When spp = Hw, hdm_pa = Y and b_lc = Y and dmr = 0 (i.e. the tree is only infected below live crown), it will show up as dmr = 0, which isn't quite correct because it is infected just not in the live crown. Call this case IBLC. 
# When spp = Hw, status = DS or SN, dmr will = NA. This isn't quite representative because it could be infected or uninfected. Call this: DI (dead, infected) if infected and DU (dead uninfected) if uninfected.

# Calculate integer dmr
trees <- trees %>% mutate(dmr=dmr_l+dmr_m+dmr_u)

#Calculate new factor version of tree level dmr
trees <- trees %>% 
  mutate(dmr_f = case_when(!spp %in% c("Hw", "Ba") ~ "-", # not Hw, give "-"
                           (spp %in% c("Hw", "Ba") & hdm_pa=="Y" & b_lc=="Y" & dmr==0) ~ "IBLC", 
                           # live or recently dead, infected b lc
                           (spp %in% c("Hw", "Ba") & status %in% c("DS", "SN") & hdm_pa=="Y") ~ "DI", 
                           # dead a while, infected
                           (spp %in% c("Hw", "Ba") & status %in% c("DS", "SN") & hdm_pa %in% c("N", "U")) ~ "DU", 
                           # dead a while uninfected
                           TRUE ~ as.character(dmr))) %>% # all other cases, same as dmr
  mutate(dmr_f = factor(dmr_f, levels = c("-", "DU", "0", "DI", "IBLC", "1", "2", "3", "4", "5", "6")))

trees %>% select(dmr_f) %>% table(useNA = "ifany") #Looks good!

########## Export data ##########
# As an R object
saveRDS(trees, "./data/cleaned/trees.RDS")

# As a CSV
write_csv(trees, "./data/cleaned/trees.csv")

