#Converting tree position values to georeferenced spatial features
#Original: September 14, 2023 - Liam Irwin (liamakirwin@gmail.com)
#Adapted by: Hanno Southam (hannosoutham@gmail.com) 
#Last updated: 21 Aug 2024
#Last ran: 21 Aug 2024

rm(list=ls(all=TRUE))

library(sf)
library(dplyr)
library(tidyverse)
library(tmap)

#### PART 1: Define function to create XY coordinates from distance and azimuth 
#### reading from trimble point
#azimuth = azimuth from centre point in degrees
#distance = distance from center point in m
#xcenter/ycenter = X and Y coordinates of trimble reference point
#crs = EPSG code of Coordinate reference system you are using
polar_to_XY <- function(azimuth,
                        distance,
                        xcenter,
                        ycenter,
                        shape_file = TRUE,
                        crs) {
  
  if((max(azimuth) - min(azimuth) < 2*pi) == TRUE){
    print("WARNING: This function assumes azimuth is in degrees, please check")
  }
  angle = azimuth * pi/180
  #Convert to radians
  #angle = angle*pi/180
  angle = 2*pi - (angle - pi/2)
  x = xcenter + distance * cos(angle)
  y = ycenter + distance * sin(angle)
  
  #define output point locations
  tree_locations <- data.frame(X = x, Y = y)
  
  if(shape_file == T){# output a shape file of the tree locations
    print(paste("creating spatial points layer from tree locations. CRS is:", crs))
    
    tree_locations <- sf::st_as_sf(tree_locations, coords = c("X", 'Y'), crs = crs)
    
  }
  else{
    tree_locations
  }
  return(tree_locations)
}

#Replace coordinate system with whatever EPSG code you're using (NAD1983/BC Albers=3005; WGS84 = 4326). Check https://epsg.io/ for more info on what your code is
crs <- 3005

##############################################################
##############################################################
#### PART 2: Prepare Trimble Points
#Read in trimble gps points (Trimble Locations)
trimb <- read_csv('./data/cleaned/hdm_trimbpoints.csv')
summary(trimb)

#Make site_id and pt_type factors
trimb <- trimb %>% mutate(across(c(site_id, pt_type), ~ as.factor(.)))
trimb$pt_id <- as.numeric(trimb$pt_id) #make point id a numeric
levels(trimb$site_id)

#Add a column that identifies that these are all "raw" gps points (i.e. they
#haven't been generated based off their relationship to another point
#like the points we create in this script are)
trimb <- trimb %>% mutate(origin = "diff gps")

#Make the points a spatial object (simple features sf object from sf package). 
#CRS = WGS84
trimb <- st_as_sf(trimb, coords = c("Longitude", "Latitude"), crs=4326)
st_crs(trimb)$proj4string #check CRS

# Reproject to NAD1983/BC Albers because this CRS is a projected system 
# with units in m
# Liam's function below uses meters
?st_transform()
trimb <- st_transform(trimb, crs = 3005)
st_crs(trimb)$proj4string #check CRS

#Graph to look for outliers:
#Remove reference tree points because they make scale too small
trimb_grf <- trimb %>% filter(pt_type != "ref tree") %>% 
  mutate(pt_type = as.character(pt_type)) %>% 
  mutate(pt_type = as.factor(pt_type))
#Plot
tmap_mode("plot")
tm_shape(trimb_grf, is.master = TRUE) + tm_symbols(col="pt_type") + 
  tm_text("pt_id") + tm_facets(by="site_id")

#PLAN: 
#Use transect end points to define transect start points because they are more 
#because they are more consistent. Use stem mapping points for mature trees. 
#Exceptions
# (1) transect 101 at mk_1
# (2) transect 250 at ph_2
# Both of these transect ends seem weird
# (3) stem map plot 20 at mi_2. Could not relocate this plot so stem mapped
# from edge end point (ed.2.mi2)

#Convert working object back to a basic dataframe. 
#Extract the new UTM coordinates to their own columns. 
utm_coords <- data.frame((st_coordinates(trimb))) 
trimb <- trimb %>% 
  mutate(plot_x_utm = utm_coords$X, plot_y_utm = utm_coords$Y) %>% 
  st_drop_geometry()

#TASK 1: Define transect start points based on transect end points
#Read in transect data
transect <- read_csv('./data/cleaned/transect data_c.csv')
summary(transect)

#Extract transect start points and transect end points
ts <- trimb %>% filter(pt_type=="tran start")
te <- trimb %>% filter(pt_type=="tran end")

#Join transect end coordinates to transect start observations
ts <- left_join(ts, select(te, pt_id, plot_x_utm, plot_y_utm), 
                by = c("pt_id"="pt_id")) %>% 
  rename(end_X=plot_x_utm.y, end_Y=plot_y_utm.y)

#Transect data contains transect length (tr_leng) and azimuth (tr_az). 
#Join these to the transect starts by the pt_id column. 
#Then calculate angle 180 deg from tr_az because we want distance from end 
#to start of transect.
ts <- left_join(ts, select(transect, tr_leng, tr_az, transect_id), 
                by = c("pt_id"="transect_id"))
ts <- ts %>% mutate(tr_az_inv = (tr_az + 180)%%360)

#Use polar_to_XY to define new coordinates
ts <- ts %>%
  mutate(polar_to_XY(azimuth = tr_az_inv, distance = tr_leng,
                     xcenter = end_X, ycenter = end_Y, crs = crs,
                     shape_file = TRUE))
#Extract coordinates:
adj_ts_XY <- data.frame(st_coordinates(ts$geometry))

#Convert back to dataframe with coordinates as columns
ts <- ts %>% select(!plot_x_utm.x:geometry) %>%
  mutate(plot_x_utm = adj_ts_XY$X, plot_y_utm = adj_ts_XY$Y)

#Identify that these points were created based off another point (transect ends)
#with origin column. 
ts <- ts %>% mutate(origin = "r adj")

#TASK 2: Address exceptions.
#Filter out two transects that seems misplaced by using transect ends
ts <- ts %>% filter(!pt_id %in% c(101, 250))
#Extract the measured gps points for these to use instead
ts_101_250 <- trimb %>% 
  filter(pt_type=="tran start" & (pt_id %in% c(101, 250))) 
#Bind them
ts <- rbind(ts, ts_101_250)

#Define two new columns: one that identifies whether these are points used
#in stem mapping. Another that defines whether they should be used in graphing. 
ts <- ts %>% mutate(stem_map = "Y", graph = "Y")
#This is the final set of transect start points we will use to generate 
#locations of regen trees. 

###########
#Because of the pesky little transect starts (101, 250) that weren't created 
#based off a transect end points,  we need to do the reverse of what we did 
#above and generate transect end points. If we don't, graphing later will
#look weird. Every transect will be perfectly perpendicular 
#except for these two. 
#Add transect azimuth and length to the transect start points for 101 and 250
ts_101_250 <- left_join(ts_101_250, select(transect, transect_id, tr_az, tr_leng), 
                    by=c("pt_id" = "transect_id"))

#Use function to generate new transect end points
te_101_250 <- ts_101_250 %>% 
  mutate(polar_to_XY(azimuth = tr_az, distance = tr_leng,
                     xcenter = plot_x_utm, ycenter = plot_y_utm, crs = crs,
                     shape_file = TRUE))
#Define pt_type, stem_map, graph  and origin variables. 
#These were generated based off another point, won't be used to stem map 
#but will be used to graph. 
te_101_250 <- te_101_250 %>% 
  mutate(pt_type = "tran end", origin = "r adj",stem_map = "N", graph = "Y")

#Extract coordinates:
adj_te_XY <- data.frame(st_coordinates(te_101_250$geometry))

#Convert back to dataframe with coordinates as columns
te_101_250 <- te_101_250 %>% select(!geometry) %>%
  mutate(plot_x_utm = adj_te_XY$X, plot_y_utm = adj_te_XY$Y)
############

#Now deal with stem map plot 20 at mi_2 that couldn't be relocated. 
#Filter it out of the trimb dataframe. 
trimb <- trimb %>% filter(pt_id != 20)

#Trees were remeasured from nearby edge end point (ed.2.mi2). Extract that
ed.2.mi2 <- trimb %>% filter(Comment == "ed.2.mi2")

#Redefine values to identify it as a stem mapping point. Essentially creating 
#a duplicate of the end point.
levels(trimb$pt_type)
ed.2.mi2 <- ed.2.mi2 %>% mutate(pt_id = 20,
                                pt_type = "stem map",
                                stem_map = "Y", 
                                graph = "Y")

####DONE with exceptions. 

#Now bind the three objects just generated (transect starts, transect ends
#from exception 1 and 2 and the stem mapping point replacing pt_id 20) with the 
#larger trimb abject. 

#First, add the "stem_map" and "graph" columns to the trimb dataframe. 
trimb <- trimb %>% 
  mutate(stem_map = if_else(pt_type == "stem map", "Y", "N"),
         graph = case_when(pt_type %in% c("edge", "infect perim",
                                          "landscape feat", "ref tree", 
                                          "residual",
                                          "stem map") ~ "Y",
                           pt_type == "tran start" ~ "N",
                           pt_type == "tran end" & 
                             pt_id %in% c(101, 250) ~ "N",
                           pt_type == "tran end" & 
                             !(pt_id %in% c(101, 250)) ~ "Y"))

#Bind it all together
trimb_comm_var <- intersect(names(trimb), names(te_101_250))
trimb <- trimb %>% select(all_of(trimb_comm_var))
te_101_250 <- te_101_250 %>% select(all_of(trimb_comm_var))
ed.2.mi2 <- ed.2.mi2 %>% select(all_of(trimb_comm_var))
ts <- ts %>% select(all_of(trimb_comm_var))

trimb <- rbind(trimb, ts, te_101_250, ed.2.mi2)
#FINAL TRIMB POINTS

#Export this:
write_csv(trimb, "./data/workflow/trimb_radjusted.csv")

#Create a subset to use to generate tree locations
trimb_sm <- trimb %>% filter(stem_map == "Y") %>% 
  select(pt_id, plot_x_utm, plot_y_utm)

#Plot to check some things. 
trimb_sf <- st_as_sf(trimb, coords = c("plot_x_utm", "plot_y_utm"), crs=3005)

#Plot 1: using graph points
#Check:
#should be only three transect starts and 3 transect ends
#trasects should be perpendicular
trimb_grf <- trimb_sf %>% filter(graph == "Y")
tmap_mode("plot")
tm_shape(trimb_grf, is.master = TRUE) + tm_symbols(col="pt_type") + 
  tm_text("pt_id") + tm_facets(by="site_id")

#Plot 2: r adjusted points
#Check:
#adjusted points should be all transect starts except 101 and 250 and transect 
#ends of 101 and 250
trimb_grf <- trimb_sf %>% filter(graph == "Y", pt_type != "ref tree")
tmap_mode("plot")
tm_shape(trimb_grf, is.master = TRUE) + tm_symbols(col="origin") + 
  tm_text("pt_id") + tm_facets(by="site_id")

#Plot 3: stem mapping points
#Check:
#stem mapping points should be transect starts, and stem mapping plots in
#mature component
trimb_grf <- trimb_sf %>% filter(stem_map == "Y")
tmap_mode("plot")
tm_shape(trimb_grf, is.master = TRUE) + tm_symbols(col="origin") + 
  tm_text("pt_id") + tm_facets(by="site_id")

#Looks good. 

##############################################################
##############################################################
###### PART 3: GENERATE TREE LOCATIONS
trees <- readRDS("./data/cleaned/trees.RDS")
# note: plot_id is a single variable here. It refer to transect_id for regen trees and stem mapping plot id for mature trees

#### MATURE COMPONENT
# Azimuth readings are magnetic and need to be declination corrected. Read in datasheet with declination correction by site. Then join it to stem mapping sheet.
site_data <- read_csv('./data/cleaned/site data.csv')
site_data <- site_data %>% select(site_id, Dec)

# Join declination corrections dataset by site
trees <- left_join(trees, site_data, by = c("site_id" = "site_id"))

# Delete dec_deg column (empty column and we just added Dec)
trees <- trees %>% select(!c(dec_deg))

# Add column for declination corrected azimuth.
trees <- trees %>% 
  mutate(corr_az_deg = (az_deg + Dec)%%360) %>% 
  mutate(across(corr_az_deg, round, 1))
  #modulo operator (%%) checks if 360 can go into the sum. If it can, it returns the difference.


#### REGEN COMPONENT
# Each tree in regen component has an x,y distance on a transect. Need to transform these to dist, az data. 
# First step, adjust for transects slopes. Read in transect data: 
transect <- read_csv('./data/cleaned/transect data_c.csv') #should also have been loaded above
summary(transect)

# Important variables in transect data are: tr_dist (specifies the transect section the slope applies to) and tr_sl (the slope for that transect section). Some transects had a uniform slope and so just one distance and slope. Others had a slope change and are measured in two segments (from 0 to tr_dist1, than from tr_dist1 to tr_dist2). Distances in the transect data are horizontal distances (measured with rangefinder). Slope is in degrees. 

# Create new variables with slopes in radians
transect <- transect %>% mutate(tr_sl1_rad = tr_sl1*(pi/180), tr_sl2_rad = tr_sl2*(pi/180))

# tr_dist1 is the inflection point for sites with multiple slopes. Define new variable that converts it to slope distance so it can be compared to distances in regen data.
transect <- transect %>% mutate(tr_dist1_sl = tr_dist1/cos(tr_sl1_rad))

# Join useful parts of transect data to regen data
trees <- left_join(trees, select(transect, tr_az, tr_leng, transect_id, tr_dist1, tr_sl1, tr_sl1_rad, tr_dist2, tr_sl1, tr_sl2_rad, tr_dist1_sl), by = c("plot_id" = "transect_id"))

# Transform the y distance in the regen data (in slope distance) to be horizontal distance. Complicated function but it says: 
# Case 1: tr_dist1 = tr_leng (i.e. there is only one slope), calculate the y horizontal distance using the first slope; 
# When tr_dist1 != tr_leng (i.e. there are two slopes) there are two cases, 
# Case 2: tr_dist1 != tr_leng and dist_y < tr_dist1_sl, calculate distance using the first slope
# Case 3: tr_dist1 != tr_leng and dist_y >= tr_dist1_sl, calculate the distance by adding the inflection point horizontal distance (tr_dist1) and remainder (dist_y - tr_dist1_sl) corrected with the second slope

#Test on three represenative trees. r1 = case 1, r291 = case 2, r299 = case 3
test <- trees %>% filter(tree_id %in% c("r1", "r291", "r299"))
test <- test %>% mutate(dist_y_h = 
           case_when(tr_dist1 == tr_leng ~ dist_y*cos(tr_sl1_rad), 
                     tr_dist1 != tr_leng & dist_y < tr_dist1_sl ~ dist_y*cos(tr_sl1_rad),
                     tr_dist1 != tr_leng & dist_y >= tr_dist1_sl ~ tr_dist1 + 
                       (dist_y - tr_dist1_sl)*cos(tr_sl2_rad), TRUE ~ NA_real_)) %>% 
  select(dist_y, dist_x, dist_y_h)

# That works. Perform the actual calculation
trees <- trees %>% mutate(
  dist_y_h =
    case_when(
      tr_dist1 == tr_leng ~ dist_y * cos(tr_sl1_rad),
      tr_dist1 != tr_leng &
        dist_y < tr_dist1_sl ~ dist_y * cos(tr_sl1_rad),
      tr_dist1 != tr_leng &
        dist_y >= tr_dist1_sl ~ tr_dist1 +
        (dist_y - tr_dist1_sl) * cos(tr_sl2_rad),
      TRUE ~ NA_real_))

# Now need to calculate distance from transect start point to each tree (x, y). This is a right triangle with sides: dist_x, dist_y_h.
# Make test dataset to make sure this isn't changing dist_m value for mature trees
test <- trees %>% filter(tree_id %in% c("r1", "m1")) %>% 
  select(tree_id, tree_type, dist_m, dist_x, dist_y_h)
test
test %>% mutate(dist_m = case_when(tree_type == "regen" ~ 
                                     (dist_x^2 + dist_y_h^2)^(0.5), .default = dist_m)) #good, that works 

trees <- trees %>% mutate(dist_m = case_when(tree_type == "regen" ~ 
                                               (dist_x^2 + dist_y_h^2)^(0.5), .default = dist_m))

# Now calculate the angle adjustment relative to the transect azimuth for point. theta = tan-1(dist_x/dist_y_h) (in radians).
trees <- trees %>% mutate(az_adj = atan(dist_x/dist_y_h)*(180/pi))

# Calcualte the azimuth of the tree from the transect start point in the corr_az_deg column
# Again, use test dataset to make sure this is only affecting regen trees
test <- trees %>% filter(tree_id %in% c("r1", "m1")) %>% 
  select(tree_id, tree_type, corr_az_deg, tr_az, az_adj)
test
test %>% mutate(corr_az_deg = case_when(tree_type == "regen" ~ 
                                          (tr_az + az_adj)%%360, .default = corr_az_deg)) #works

trees <- trees %>% mutate(corr_az_deg = case_when(tree_type == "regen" ~ (tr_az + az_adj)%%360, .default = corr_az_deg))

#Clean up data set by removing columns used for data processing
trees <- trees %>% select(!c(tr_dist1:tr_dist1_sl, az_adj))

#Join relevant plot center coordinate with each tree. Two key columns for 
#stem mapping: dist_m (distance from stem mapping point ) 
#and corr_az_deg (aziumuth from that point)
trees <- inner_join(trees, trimb_sm, 
                    by = c("plot_id" = "pt_id"))

# Run the function. Need to set azimuth, distance, xcenter, ycenter equal to variable names in stem mapped polar. 
stem_mapped_XY <- trees %>%
  mutate(polar_to_XY(azimuth = corr_az_deg, distance = dist_m,
                     xcenter = plot_x_utm, ycenter = plot_y_utm, crs = crs,
                     shape_file = TRUE))

class(stem_mapped_XY)
#Convert it to a spatial object:
stem_mapped_XY <- st_as_sf(stem_mapped_XY)

#Graph one site to make sure it looks good
mi_2 <- stem_mapped_XY %>% filter(site_id == "mi_2")
tmap_mode("plot")
tm_shape(mi_2, is.master = TRUE) + tm_symbols(col = "tree_type")

# Write your spatial features as a geojson file and a regular csv 
st_write(stem_mapped_XY, './data/workflow/trees_mapped.geojson', append = FALSE)
st_write(stem_mapped_XY, "./data/workflow/trees_mapped.csv", 
         layer_options = "GEOMETRY=AS_XY", append=FALSE)
?st_write

