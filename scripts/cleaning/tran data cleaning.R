# Cleaning mistletoe transect data
# Hanno Southam, 4 Mar 2024

# First step, adjust for transects slopes. Read in transect data: 
transect <- read_csv('./data/raw/transect data.csv')
transect <- transect %>% filter(!is.na(site_id))# Delete empty rows
summary(transect)

# Transects at site mi_2 were layed out with slope distance and so they are a little shorter than they were supposed to be. Their actual length (recorded after the fact) is the largest distance in tr_dist1 or tr_dist2. Correct tr_leng here:
transect <- transect %>% mutate(tr_leng =
                                  case_when(site_id == "mi_2" & !is.na(tr_sl2) ~ tr_dist2, 
                                            site_id == "mi_2" & is.na(tr_sl2) ~ tr_dist1,
                                            .default = tr_leng))

# mk_1, transect 102 fall line azimuths were recorded with a rangefinder. Correct the "fl_az_device" value for that transect. 
transect <- transect %>% mutate(fl_az_device = case_when(transect_id == 102 ~ "rangefinder", .default = fl_az_device))

# mk_3, transect 115 was extended to traverse a blowdown patch and ensure there was no infection on the other side. Slope applies to the whole transect so replace tr_dist1 with tr_leng. 
transect <- transect %>% mutate(tr_dist1 = case_when(transect_id == 115 ~ tr_leng, .default = tr_dist1))

# Export csv: 
write_csv(transect, './data/cleaned/transect data_c.csv')
