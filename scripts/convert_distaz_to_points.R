# Converting tree position values to georeferenced spatial features
# Original: September 14, 2023 - Liam Irwin (liamakirwin@gmail.com)
# For Hanno
# Updated: Mar 2024, by Hanno Southam (hannosoutham@gmail.com)

library(sf)
library(dplyr)
library(tidyverse)
library(tmap)

#### PART 1: Define function to create XY coordinates from distance and azimuth reading from trimble point
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

# Replace coordinate system with whatever EPSG code you're using (NAD1983/BC Albers=3005; WGS84 = 4326). Check https://epsg.io/ for more info on what your code is
crs <- 3005

##############################################################
##############################################################
#### PART 2: Prepare Trimble Points
# Read in trimble gps points (Trimble Locations)
trimb <- read_csv('./data/cleaned/hdm_trimbpoints_2023.csv')
summary(trimb)

# Make site_id and pt_type factors
trimb <- trimb %>% mutate(across(c(site_id, pt_type), ~ as.factor(.)))
trimb$pt_id <- as.numeric(trimb$pt_id) #make point id a numeric

# Make the points a spatial object (simple features sf object from sf package). CRS = WGS84
trimb <- st_as_sf(trimb, coords = c("long_num", "lat_num"), crs=4326)
st_crs(trimb)$proj4string #check CRS

# Reproject to NAD1983/BC Albers because this CRS is a projected system with units in m
# Liam's function below uses meters
?st_transform()
trimb <- st_transform(trimb, crs = 3005)
st_crs(trimb)$proj4string #check CRS

#Plot to look for outliers:
tmap_mode("plot")
tm_shape(trimb, is.master = TRUE) + tm_symbols(col="pt_type") + tm_text("pt_id") +
  tm_facets(by="site_id")
#Plan: 
# -use transect end points to define transect start points because they are more consistent
# -exception is middle transect at mk_1 (transect_id = 101)

# Convert working object back to a basic dataframe. Extract the new UTM coordinates to their own columns. 
utm_coords <- data.frame((st_coordinates(trimb))) #extract the coordinates from the geometry component of the trimb object
trimb <- trimb %>% mutate(plot_x_utm = utm_coords$X, plot_y_utm = utm_coords$Y) %>% st_drop_geometry()

# Define transect start points based on transect end points
# Read in transect data
transect <- read_csv('./data/cleaned/transect data_c.csv')
summary(transect)

# Extract transect start points and transect end points
ts <- trimb %>% filter(pt_type=="tran start")
te <- trimb %>% filter(pt_type=="tran end")

#Join transect end coordinates to transect start observations
ts <- left_join(ts, select(te, pt_id, plot_x_utm, plot_y_utm), by = c("pt_id"="pt_id")) %>% rename(end_X=plot_x_utm.y, end_Y=plot_y_utm.y)

# Transect data contains transect length (tr_leng) and azimuth (tr_az). Join these to the transect starts by the pt_id column. Then calculate angle 180 deg from tr_az because we want distance from end to start of transect.
ts <- left_join(ts, select(transect, tr_leng, tr_az, transect_id), by = c("pt_id"="transect_id"))
ts <- ts %>% mutate(tr_az_inv = (tr_az + 180)%%360)

# Use polar_to_XY to define new coordinates
ts <- ts %>%
  mutate(polar_to_XY(azimuth = tr_az_inv, distance = tr_leng,
                     xcenter = end_X, ycenter = end_Y, crs = crs,
                     shape_file = TRUE))
#Extract coordinates:
adj_ts_XY <- data.frame(st_coordinates(ts$geometry))

#Convert back to dataframe with coordinates as columns
ts <- ts %>% select(!plot_x_utm.x:geometry) %>%
  mutate(plot_x_utm = adj_ts_XY$X, plot_y_utm = adj_ts_XY$Y)
# Okay, these are final adjusted transect starts. 

# Combine this with stem mapping points to get final set of reference points to generate tree locations from. 
ts <- ts %>% filter(pt_id!=101) %>% #filter out point that seems misplaced by using transect ends
  mutate(pt_type = "r adj tran start")
ts_101 <- trimb %>% filter(pt_type=="tran start" & pt_id==101) %>% 
  mutate(pt_type="r adj tran start") #add ts for 101 from field data
trimb <- rbind(trimb, ts, ts_101)
#FINAL DATASET OF TRANSECT POINTS TO STEM MAP FROM

#Because of the pesky little transect (101) that wasn't created based of a transect end point, need to create another transect end point for it to make graphing later look good. 
#Create new transect end point from field collected 101
ts_101 <- left_join(ts_101, select(transect, transect_id, tr_az, tr_leng), 
                    by=c("pt_id" = "transect_id"))
te_101 <- ts_101 %>%
  mutate(polar_to_XY(azimuth = tr_az, distance = tr_leng,
                     xcenter = plot_x_utm, ycenter = plot_y_utm, crs = crs,
                     shape_file = TRUE))
adj_te_101_XY <- data.frame(st_coordinates(te_101$geometry))
te_101 <- trimb %>% filter(pt_type=="tran end" & pt_id==101) %>% mutate(plot_x_utm=adj_te_101_XY$X, plot_y_utm=adj_te_101_XY$Y)

trimb <- trimb %>% filter(!(pt_type=="tran end" & pt_id==101))
trimb <- rbind(trimb, te_101)
#FINAL TRIMB POINTS
#Export this:
write_csv(trimb, "./exports/trimb_processed.csv")

##############################################################
##############################################################
#### PART 3: GENERATE TREE LOCATIONS
# Read in mature component data with Distance/Az Measurements
mature <- read_csv('./data/mature comp_master.csv')
mature <- mature %>% filter(!is.na(plot_id))# Delete empty rows

# Azimuth readings are magnetic and need to be declination corrected. Read in datasheet with declination correction by site. Then join it to stem mapping sheet.
site_centre_data <- read_csv('./data/site_centrepoints_tab.csv')
site_centre_data <- site_centre_data %>% select(site_id, Dec)
mature <- inner_join(mature, site_centre_data, by = c("site_id" = "site_id"))

# Delete dec_deg column (empty column and we just added Dec)
mature <- mature %>% select(!c(dec_deg))

# Add column for declination corrected azimuth.
mature <- mature %>% 
  mutate(corr_az_deg = (az_deg + Dec)%%360) %>% 
  mutate(across(corr_az_deg, round, 1))
  #modulo operator (%%) checks if 360 can go into the sum. If it can, it returns the difference.

# Read in regen component, transect data
regen <- read_csv('./data/regen comp_master.csv')
regen <- regen %>% filter(!is.na(site_id))# Delete empty rows

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
regen <- inner_join(regen, select(transect, tr_az, tr_leng, transect_id, tr_dist1, tr_sl1, tr_sl1_rad, tr_dist2, tr_sl1, tr_sl2_rad, tr_dist1_sl), by = "transect_id")

# Transform the y distance in the regen data (in slope distance) to be horizontal distance. Complicated function but it says: 
# Case 1: tr_dist1 = tr_leng (i.e. there is only one slope), calculate the y horizontal distance using the first slope; 
# When tr_dist1 != tr_leng (i.e. there are two slopes) there are two cases, 
# Case 2: tr_dist1 != tr_leng and dist_y < tr_dist1_sl, calculate distance using the first slope
# Case 3: tr_dist1 != tr_leng and dist_y >= tr_dist1_sl, calculate the distance by adding the inflection point horizontal distance (tr_dist1) and remainder (dist_y - tr_dist1_sl) corrected with the second slope

#Test on three represenative trees. r1 = case 1, r291 = case 2, r299 = case 3
test <- regen %>% filter(tree_id_new %in% c("r1", "r291", "r299"))
test <- test %>% mutate(dist_y_h = 
           case_when(tr_dist1 == tr_leng ~ dist_y*cos(tr_sl1_rad), 
                     tr_dist1 != tr_leng & dist_y < tr_dist1_sl ~ dist_y*cos(tr_sl1_rad),
                     tr_dist1 != tr_leng & dist_y >= tr_dist1_sl ~ tr_dist1 + 
                       (dist_y - tr_dist1_sl)*cos(tr_sl2_rad), TRUE ~ NA_real_)) %>% 
  select(dist_y, dist_x, dist_y_h)

# That works. Perform the actual calculation
regen <- regen %>% mutate(
  dist_y_h =
    case_when(
      tr_dist1 == tr_leng ~ dist_y * cos(tr_sl1_rad),
      tr_dist1 != tr_leng &
        dist_y < tr_dist1_sl ~ dist_y * cos(tr_sl1_rad),
      tr_dist1 != tr_leng &
        dist_y >= tr_dist1_sl ~ tr_dist1 +
        (dist_y - tr_dist1_sl) * cos(tr_sl2_rad),
      TRUE ~ NA_real_))

# Now need to calculate distance from transect start point to each tree (x, y). This is a right triangle with sides: dist_x, dist_y_h and the new variable: dist_m
regen <- regen %>% mutate(dist_m = (dist_x^2 + dist_y_h^2)^(0.5))

# Now calculate the angle adjustment relative to the transect azimuth for point. theta = tan-1(dist_x/dist_y_h) (in radians).
regen <- regen %>% mutate(az_adj = atan(dist_x/dist_y_h)*(180/pi))

# Define new variable: corr_az_deg, the azimuth of the tree from the transect start point
regen <- regen %>% mutate(corr_az_deg = tr_az + az_adj)

# Join mature tree and regen tree data. 
# Change transect_id=plot_id - just need an id column to match stem mapping points. Before joining, filter data to remove columns from data processing. 
regen <- regen %>% rename(plot_id = transect_id) %>% select(!c(tr_dist1:dist_y_h, az_adj))
trees <- full_join(mature, regen)

# Join relevant plot center coordinate with each tree. Two key columns for stem mapping: dist_m (distance from stem mapping point (stem map or tran start)) and corr_az_deg (aziumuth from that point)
stem_map <- trimb %>% filter(pt_type %in% c("stem map", "r adj tran start"))
trees <- inner_join(trees, select(stem_map, pt_id, plot_x_utm, plot_y_utm), by = c("plot_id" = "pt_id"))

# Run the function. Need to set azimuth, distance, xcenter, ycenter equal to variable names in stem mapped polar. 
stem_mapped_XY <- trees %>%
  mutate(polar_to_XY(azimuth = corr_az_deg, distance = dist_m,
                     xcenter = plot_x_utm, ycenter = plot_y_utm, crs = crs,
                     shape_file = TRUE))

class(stem_mapped_XY)
#Convert it to a spatial object:
stem_mapped_XY <- st_as_sf(stem_mapped_XY)

# Write your spatial features as a geojson file (or change extension to whatever you prefer)
st_write(stem_mapped_XY, './exports/trees.geojson', append = FALSE)
