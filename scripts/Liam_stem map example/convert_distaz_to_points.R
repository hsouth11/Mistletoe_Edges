# Converting tree positon values to georeferenced spatial features
# September 14, 2023 - Liam Irwin (liamakirwin@gmail.com)
# For Hanno

library(sf)
library(dplyr)
library(tidyverse)

# Read in plot coordinate dataframe (Trimble Locations)

plot_coords <- read_csv('./DistAz_to_Points/exdata/plot_coords.csv')

# Read in Stem Mapping Sheet with Distance/Az Measurements

stem_mapped_polar <- read_csv('./DistAz_to_Points/exdata/stem_mapped_polar.csv')

# Join relevant plot center coordinate with each tree

stem_mapped_polar <- inner_join(stem_mapped_polar, plot_coords, by = c("plotID" = "PlotID"))

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

# Replace coordinate system with whatever EPSG code you're using (ex WGS84 = 4326)
# Check https://epsg.io/ for more info on what your code is

crs <- 4326

# Replace the input column with whatever name you have (ex azimuth = tree_az)

stem_mapped_XY <- stem_mapped_polar %>%
  mutate(polar_to_XY(azimuth = Azimuth, distance = Distance,
                     xcenter = XPLOT, ycenter = YPLOT, crs = crs,
                     shape_file = TRUE))

# Convert dataframe into a spatial feature object

stem_mapped_pts <- st_as_sf(stem_mapped_XY)

# Write your spatial features as a shapefile (or change extension to whatever you prefer)

st_write(stem_mapped_pts, './DistAz_to_Points/exdata/tree_locations.shp')
