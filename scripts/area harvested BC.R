#Summary of area harvested in BC
#Original data: Canadian Council of Forest Ministers. (2023). Forest area harvested on private and Crown lands in Canada [dataset]. National Forestry Database. http://nfdp.ccfm.org/en/data/harvest.php
### NEED TO CHECK THIS IS JUST FOR PUBLIC LAND IN BC

library("tidyverse")
har <- read_csv("/Users/hannosoutham/OneDrive - UBC (1)/Msc/Grants and Awards/Wall Scholarship/area harvested.csv")

summary(har)
