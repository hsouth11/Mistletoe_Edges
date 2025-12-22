#Intro to sf and stars package
#Followng Ch7. Spatial Data Science book
#https://r-spatial.org/book/07-Introsf.html 

#load packages
library(sf)
library(stars)
library(tidyverse)

#Read in sf object
(file <- system.file("gpkg/nc.gpkg", package = "sf"))
# [1] "/home/edzer/R/x86_64-pc-linux-gnu-library/4.3/sf/gpkg/nc.gpkg"
nc <- st_read(file)

#If a file (e.g. .gpkg has multiple layers) you can see the layers with. By default st_read takes the first layer unless you specify otherwise.
st_layers(file)

#Write sf object with
st_write() #Will give error if file already exists (will not overwrite). Can use append argument to add records to existing layer
write_sf() #dplyr version that will overwrite layers that already exist

#Read in stars object
tif <- system.file("tif/L7_ETMs.tif", package = "stars")
(r <- read_stars(tif))

#Inspect a raster
st_dimensions(r) #metadata
st_bbox(r) #spatial extent

#Write stars objects like this: 
write_stars()
