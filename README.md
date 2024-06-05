# R_MSc

R project with all analyses for Hanno Souhtam's MSc: Hemlock dwarf mistletoe in group retention silviculture.

## FILE DIRECTORY 

### /data 

-   All project data. Raw data are data in the form hand entered from field datasheets. Cleaned data are data files after processing in ./scripts/cleaning; in some cases (e.g. site data), data didn't require cleaning and the starting file is in the /data/cleaned. Workflow data are intermediate files created in the data workflow. There are six datasets: (1) mature comp_master, (2) regen comp_master, (3) site_data, (4) transect_data, (5) residual reference tree data and (3) hdm_trimbpoints_2023.csv. (1) and (2) are the core tree data; they contain a single record for each tree mapped and measured at a site. (3) contains variables collected at the site level (e.g. the year the block was harvested). (4) contains data collected at the level of each individual transect (3 per site; e.g. slope). (5) contains tree data for putative residual trees and trees used to collect reference cores. (6) is a csv of differentially corrected (high accuracy) GPS points; tree locations are measured relative to these positions.

### /scripts 

#### ./cleaning 

-   Contains scripts for cleaning tree data (1 and 2 above) and transect data (4 above). The output of (tree data cleaning.R) are (trees.csv) and (trees.RDS) same data, different formats; regen and mature tree data are separate in raw data but combined in this file with a variable added to distinguish them.

#### ./convert_distaz_to_points.R 

-   Script that combines tree data and high accuracy gps points to determine the location of each tree. The output of this is a spatial features object (sf package in R; /data/workflow/trees_mapped.csv and /data/workflow/trees_mapped.geojson)

#### ./stem_mapped_figures.Rmd

-   Script used to create stem mapped figures.

**./site level analysis.RMD**

-   Analysis script. A work in progress.
