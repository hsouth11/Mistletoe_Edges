#Hypothetical group retention geometry
#Author: Hanno Southam
#Updated: 22 Dec 2025

####READ ME####
#This script generates hypothetical, "representative", group retention and 
#clearcut cutblocks for coastal BC to compare their zones of edge influence
#where HDM edge infection would be important. This generates a figures and some
#rough numbers for the discussion of my thesis/publication. 

####Prep####
#Unload loaded packages in R session
library(pacman)
p_loaded()
p_unload(p_loaded(), character.only = T)

#Load packages used in this script. Unloading then loading avoids potential
#package conflicts
library(sf)
library(tmap)
library(dplyr)

#Clear environment
rm(list=ls(all=TRUE))

####Step 1####
#Create a 16 ha cutblock (400m x 400m)
cb <- st_as_sf(st_sfc(st_polygon(list(rbind(
  c(0, 0), c(400, 0), c(400, 400), c(0, 400), c(0, 0)))), crs = 3005))
#Create a line object to buffer off
cb_line <- st_boundary(cb)

####Step 2#### 
#Define centre points for retention patch squares
rp_centers <- st_sfc(
  st_point(c(75, 75)),
  st_point(c(325, 75)),  
  st_point(c(200, 200)),  
  st_point(c(75, 325)),  
  st_point(c(325, 325))   
  , crs = 3005)

####Step 3#### 
#Create 100m x 100m retention patches at defined points
make_square <- function(pt, size = 100) {
  x <- st_coordinates(pt)[1]
  y <- st_coordinates(pt)[2]
  return(st_polygon(list(rbind(
    c(x - size / 2, y - size / 2),
    c(x + size / 2, y - size / 2),
    c(x + size / 2, y + size / 2),
    c(x - size / 2, y + size / 2),
    c(x - size / 2, y - size / 2)
  ))))
}
rp <- st_sfc(lapply(rp_centers, make_square), crs = 3005) %>%
  st_as_sf()

#Plot it to make sure it looks good
tmap_mode("plot") +
  tm_shape(cb) +
    tm_grid()+
    tm_borders(col = "blue") +
  tm_shape(rp_centers) +
    tm_symbols() +
  tm_shape(rp) +
    tm_borders(col = "green")

####Step 4####
#Create 15 and 35m buffers around retention patches

#Restrict to area within the cutblock and remove the retention patches 
#themselves
rp_35 <- st_buffer(rp, 35) %>% 
  st_intersection(cb)
rp_15 <- st_buffer(rp, 15) %>% 
  st_intersection(cb)

####Step 5####
#Create the same buffers around the block edge

#Remove the portion created that buffers outward from the block edge and any
#overlap with the retention patches
ed_35 <- st_buffer(cb_line, 35) %>% 
  st_intersection(cb) %>% 
  st_difference(st_combine(rp))
ed_15 <- st_buffer(cb_line, 15) %>% 
  st_intersection(cb) %>% 
  st_difference(st_combine(rp))

#Plot again to check
#15m buffers
tmap_mode("plot") +
  tm_shape(cb) +
    tm_borders(col = "black", lwd = 2) +
  tm_shape(rp) +
    tm_fill(col = "darkgreen", alpha = 0.3) +
  tm_shape(ed_15) +
    tm_borders(col = "blue", lty = "dashed")+
  tm_shape(rp_15) +
    tm_borders(col = "green", lty = "dashed") +
  tm_layout(frame = F)

#35m buffers
tmap_mode("plot") +
  tm_shape(cb) +
    tm_borders(col = "black", lwd = 2) +
  tm_shape(rp) +
    tm_fill(col = "darkgreen", alpha = 0.3) +
  tm_shape(ed_35) +
    tm_borders(col = "blue", lty = "dashed")+
  tm_shape(rp_35) +
    tm_borders(col = "green", lty = "dashed") +
  tm_layout(frame = F)

####Step 6####
#Remove overlapping areas

#Remove internal overlaps from retention patch buffers and the 
#retention patches themselves
rp_15 <- st_union(rp_15) %>% 
  st_difference(st_combine(rp))
rp_35 <- st_union(rp_35) %>% 
  st_difference(st_combine(rp))
  
#Identify areas that overlap with edge buffers. These are areas within the 
#buffer distance of both a retention patch and an edge. We'll create two
#objects, one that identifies these areas of dual overlap and one that removes
#these areas
#Identify areas of overlap
overlap_15 <- rp_15 %>% 
  st_intersection(ed_15)
overlap_35 <- rp_35 %>% 
  st_intersection(ed_35)

#Areas of difference
rp_15 <- rp_15 %>% 
  st_difference(ed_15)
rp_35 <- rp_35 %>% 
  st_difference(ed_35)

#Plot to make sure that worked
#15m buffers
tmap_mode("plot") +
  tm_shape(cb) +
    tm_borders(col = "black", lwd = 2) +
  tm_shape(rp) +
    tm_fill(col = "darkgreen", alpha = 0.3) +
  tm_shape(rp_15) +
    tm_borders(col = "green", lty = "dashed") +
  tm_shape(ed_15) +
    tm_borders(col = "blue", lty = "dashed") +
  tm_shape(overlap_15)+
    tm_fill(col = "grey", alpha = 0.3) + 
  tm_layout(frame = F)

#35m buffers
tmap_mode("plot") +
  tm_shape(cb) +
    tm_borders(col = "black", lwd = 2) +
  tm_shape(rp) +
    tm_fill(col = "darkgreen", alpha = 0.3) +
  tm_shape(rp_35) +
    tm_borders(col = "green", lty = "dashed") +
  tm_shape(ed_35) +
    tm_borders(col = "blue", lty = "dashed") +
  tm_shape(overlap_35)+
    tm_fill(col = "grey", alpha = 0.3) + 
  tm_layout(frame = F)

####Step 7#### 
#Calculate areas in hectares

#Harvested area, should be 11 but just to check
a_cb <- cb %>% st_difference(st_combine(rp)) %>% 
  st_area()/10000
a_cb

#Retention patches, should be 5ha but just to check
a_rp <- st_area(st_combine(rp))/10000
a_rp

#Area within each buffer
a_35 <- st_union(ed_35, rp_35) %>% st_area()/10000
a_35
a_15<- st_union(ed_15, rp_15) %>% st_area()/10000
a_15

#What % of harvested area is within a tree length in this case? 
a_35/a_cb*100

#What % of harvested area is within 20m?
a_15/a_cb*100

#How much of this is additional to what is in the cutblock without retention?
ed_15_clearcut <- st_buffer(cb_line, 15) %>% 
  st_intersection(cb)
a_ed_15_clearcut <- st_area(ed_15_clearcut)/10000
#Compare these two numbers
a_ed_15_clearcut
a_15 #Approximately doubles it
a_15 - a_ed_15_clearcut

#How much is within the area affected by two edges? 
#This isn't quite accurate right now because it doesn't incporporate area 
#within 15m of two retention patches. But from the plots, these are minimal,
#so its a good approximation
a_overlap <- st_area(overlap_15)/10000
a_overlap

#Assuming 30% of mature edge infected, how much of harevested area affected?
#These are "independent" probabilities, but have to account for overlapping
#areas by including them twice
a_inf <- ((st_area(rp_15)*0.3) + 
  (st_area(ed_15)*0.3) + (st_area(overlap_15)*0.3))/10000
a_inf

#If just a clearcut
a_inf_clearcut <- a_ed_15_clearcut*0.3
a_inf_clearcut

#Difference
a_inf - a_inf_clearcut
(a_inf - a_inf_clearcut)/a_inf_clearcut*100

#Percent of total harvested area
a_inf/a_cb*100
a_inf_clearcut/16*100

####Step 8####
#Create one final plot for thesis
#Generate a polygon of just area >35 m
ha_35 <- cb %>% 
  st_difference(st_combine(rp)) %>% 
  st_difference(rp_35) %>% 
  st_difference(ed_35)

#Generate another polygon, 10m wide that can serve as the mature forest edge 
#around the cutblock
#Step 1: Create a 16 ha cutblock (400m x 400m)
edge <- st_as_sf(st_sfc(st_polygon(list(rbind(
  c(-50, -50), c(450, -50), c(450, 450), c(-50, 450), c(-50, -50)))), 
  crs = 3005)) %>% st_difference(cb)

# Ensure all objects are sf
edge <- st_as_sf(edge)
ha_35 <- st_as_sf(ha_35)
rp <- st_as_sf(rp)
rp_35 <- st_as_sf(rp_35)
ed_35 <- st_as_sf(ed_35)
rp_15 <- st_as_sf(rp_15)
ed_15 <- st_as_sf(ed_15)

#Combine all polygons into one sf object with a category attribute
group_reten <- bind_rows(
  edge %>% mutate(category = "Mature forest"),
  ha_35 %>% mutate(category = "> 35 m"),
  rp %>% mutate(category = "Mature forest"),
  rp_35 %>% mutate(category = "≤ 35 m"),
  ed_35 %>% mutate(category = "≤ 35 m"),
  rp_15 %>% mutate(category = "≤ 15 m"),
  ed_15 %>% mutate(category = "≤ 15 m")) %>% 
  mutate(category = factor(category, levels = c("Mature forest", "> 35 m",
                                                "≤ 35 m", "≤ 15 m")),
         system = "Group retention")

#Create a clearcut to plot
ed_15_clearcut <- st_buffer(cb_line, 15) %>% 
  st_intersection(cb)
ed_35_clearcut <- st_buffer(cb_line, 35) %>% 
  st_intersection(cb)
ha_35_clearcut <- cb %>% 
  st_difference(ed_35_clearcut)

clearcut <- bind_rows(
  edge %>% mutate(category = "Mature forest"),
  ha_35_clearcut %>% mutate(category = "> 35 m"),
  ed_35_clearcut %>% mutate(category = "≤ 35 m"),
  ed_15_clearcut %>% mutate(category = "≤ 15 m")) %>% 
  mutate(category = factor(category, levels = c("Mature forest", "> 35 m",
                                                "≤ 35 m", "≤ 15 m")),
         system = "Clearcut")

x <- bind_rows(clearcut,
               group_reten)

# Define colors for each category
fill_colors <- c("#a6611a80", "#dfc27d60", "#80cdc120", "#01857140") 
 
# Plot using category-based coloring
p <- tmap_mode("plot") +
  tm_shape(x) +
  tm_facets(by = "system", free.scales = TRUE, 
            free.coords = FALSE, ncol = 2,
            ) +
    tm_fill(col = "category", 
            palette = fill_colors,
            title = "Area",
            legend.is.portrait = F) +
  tm_shape(cb) +
    tm_grid(n.x = 3,
            n.y = 3,
            labels.size = 1.1,
            lines = T) +
    tm_borders(col = "black", lwd = 2) +
  tm_layout(frame = FALSE, 
            panel.label.size = 1.1,
            legend.outside = TRUE,
            legend.outside.position = "bottom",
            fontfamily = "Times New Roman",
            legend.title.size = 1.2,
            legend.title.fontface = "bold",
            legend.text.size = 1)
p

#Save the plot
# tmap_save(p, filename = "./figures/retention_geometry.svg",
#           width = 6.5, height = 5, units = "in", dpi = 600)