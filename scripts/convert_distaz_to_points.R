# Converting tree positon values to georeferenced spatial features
# Original: September 14, 2023 - Liam Irwin (liamakirwin@gmail.com)
# For Hanno
# Updated: Feb 2024, by Hanno Southam (hannosoutham@gmail.com)

library(sf)
library(sp)
library(dplyr)
library(tidyverse)

# Read in plot coordinate dataframe (Trimble Locations)
plot_coords <- read_csv('./data/hdm_trimbpoints_2023.csv')
summary(plot_coords)

# Make the points a spatial dataframe. CRS = WGS84
?st_as_sf()
plot_coords_sf <- st_as_sf(plot_coords, coords = c("long_num", "lat_num"), crs=4326)
st_crs(plot_coords_sf)$proj4string #check CRS

# Reproject to NAD1983/BC Albers because this CRS is a projected system with units in m
# Liam's function below uses meters
?st_transform()
plot_coords_sf <- st_transform(plot_coords_sf, crs = 3005)
st_crs(plot_coords_sf)$proj4string #check CRS

#Then add these UTM coordinates back to the original dataframe
utm_coords <- data.frame((st_coordinates(plot_coords_sf))) #extract the coordinates from the geometry component of the plot_coords_sf object
plot_coords <- plot_coords %>% mutate(plot_x_utm = utm_coords$X, plot_y_utm = utm_coords$Y)

# Filter so they only include mature component stem mapping plots and transect start points.  
plot_coords$pt_type <- as.factor(plot_coords$pt_type) #make point type a factor
levels(plot_coords$pt_type) #check the values
plot_coords <- plot_coords %>% filter(pt_type=="stem map" |pt_type=="tran start") #filter to just mature stem mapping plots
plot_coords$pt_id <- as.numeric(plot_coords$pt_id) #make point id a numeric

#Remove all columns except for the point id and the coordinates
plot_coords <- plot_coords %>%
  select(pt_id, plot_x_utm, plot_y_utm)

# Read in mature component data with Distance/Az Measurements
mature <- read_csv('./data/mature comp_master.csv')
mature <- mature %>% filter(!is.na(tree_id_new))# Delete empty rows

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
transect <- read_csv('./data/cleaned/transect data_c.csv')
summary(transect)

# Important variables in transect data are: tr_dist (specifies the transect section the slope applies to) and tr_sl (the slope for that transect section). Some transects had a uniform slope and so just one distance and slope. Others had a slope change and are measured in two segments (from 0 to tr_dist1, than from tr_dist1 to tr_dist2). Distance is horizontal distance (measured with rangefinder). Slope is in degrees. 

# Create new variables with slopes in radians
transect <- transect %>% mutate(tr_sl1_rad = tr_sl1*(pi/180), tr_sl2_rad = tr_sl2*(pi/180))

# tr_dist1 is the inflection point for sites with multiple slopes. Define new variable that converts it to slope distance so it can be compared to distances in regen data.
transect <- transect %>% mutate(tr_dist1_sl = tr_dist1/cos(tr_sl1_rad))

# Join useful parts of transect data to regen data
regen <- inner_join(regen, select(transect, tr_az, tr_leng, transect_id, tr_dist1, tr_sl1, tr_sl1_rad, tr_dist2, tr_sl1, tr_sl2_rad, tr_dist1_sl), by = "transect_id")

# Transform the y distance in the regen data to be horizontal distance. Complicated function but it says: 
# Case 1: tr_dist1 = tr_leng (i.e. there is only one slope), calculate the y distance using the first slope; 
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

# Now calculate the angle adjustment relative to the transect azimuth for point. tan(theta) = dist_x/dist_y_h (in radians).
regen <- regen %>% mutate(az_adj = atan(dist_x/dist_y_h)*(180/pi))

# Define new variable: az_deg, the azimuth of the tree from the transect start point
regen <- regen %>% mutate(corr_az_deg = tr_az - az_adj)

# Join mature tree and regen tree data. 
# Change transect_id=plot_id - just need an id column to match stem mapping points. Before joining, filter data to remove columns from data processing. 
regen <- regen %>% rename(plot_id = transect_id) %>% select(!c(tr_az:dist_y_h, az_adj))
# Change
trees <- full_join(mature, regen)

# Join relevant plot center coordinate with each tree. Two key columns for stem mapping: dist_m (distance from stem mapping point (stem map or tran start)) and corr_az_deg (aziumuth from that point)
trees <- inner_join(trees, plot_coords, by = c("plot_id" = "pt_id"))

# Function to convert distance/azimuth to XY coordinates
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


# Replace coordinate system with whatever EPSG code you're using (NAD1983/BC Albers; WGS84 = 4326). Check https://epsg.io/ for more info on what your code is
crs <- 3005

# Run the function. Need to set azimuth, distance, xcenter, ycenter equal to variable names in stem mapped polar. 
stem_mapped_XY <- trees %>%
  mutate(polar_to_XY(azimuth = corr_az_deg, distance = dist_m,
                     xcenter = plot_x_utm, ycenter = plot_y_utm, crs = crs,
                     shape_file = TRUE))

stem_mapped_XY <- st_as_sf(stem_mapped_XY)

stem_mapped_XY <- mutate(dmr_u=case_when(dmr_u=- ~ 0, .default = dmr_u))
stem_mapped_XY <- stem_mapped_XY %>% mutate(c(dmr_l, dmr_m, dmr_u), as.numeric)

mi_1 <- stem_mapped_XY %>% filter(site_id=="mi_1")
ggplot(mi_1, aes(color=hdm_pa)) + geom_sf() + scale_color_manual(values = c("blue", "green", "red"))

# Write your spatial features as a shapefile (or change extension to whatever you prefer)
st_write(stem_mapped_XY, './exports/mature_comp_2023.shp')

#looking at outliers that pop up in GIS
stem_mapped_XY %>% filter(tree_id_new=="m379") %>% select(dist_m)
