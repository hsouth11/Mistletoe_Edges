# R_MSc

R project with all analyses for project: Edge spread of hemlock dwarf mistletoe and implications for the group retention silvicultural system
:) :) :)

## FILE DIRECTORY

### /data 

-   All project data.

/data/raw

-  Data in the form hand entered from field datasheets

regen comp_master.csv

- Individual tree measurements of trees in the regenerating component of edge spread field sites.

mature comp_master.csv

- Individual tree measurements of trees in the mature component of edge spread field sites.

transect data.csv

- Maps transect ids to each edge spread field site. Contains slope measurements for the site.

vri_hdm_sites.csv

- Attribute information of vri polygons overlapping each edge spread field site. Data are projected to 1 Jan 2021. Each component at each site is represented by at least one (and sometimes two) vri polygons.
Forest Analysis and Inventory Branch. (2024). VRI - 2023—Forest Vegetation Composite Rank 1 Layer (R1) [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/2ebb35d8-c82f-4a17-9c96-612ac3532d55

hdm_climdata.csv

- Climate data for the edge spread research sites. From Climate BC v7.50 for the Normal 1991–2020 period.
Climate BC website: https://climatebc.ca/ 
Wang, T., Hamann, A., Spittlehouse, D., & Carroll, C. (2016). Locally downscaled and spatially customizable climate data for historical and future periods for North America. PloS One, 11(6). https://doi.org/10.1371/journal.pone.0156720

regen extra heights.csv

- Individual tree measurements for trees used to measure hemlock top height at edge spread research sites, when not enough trees were present on a transect to meet our minimum requirement (three dominant/codominant hemlock per transect).

residual reference tree data.csv 

- Individual tree measurements for potential residual trees and reference trees at edge spread research sites. Potential residual trees are large, moderate-severely infected hemlock that could have been present pre-harvest. Residual trees were cored to assess whether they were present pre-harvest (but these cores have not been analyzed). Reference trees are large dominant/codominant hemlock in the mature component that were cored to act as a reference for residual tree cores, if crossdating was necessary. Both residual and reference trees have differential GPS points in /data/cleaned/hdm_trimbpoints.csv

seed dispersal_smith1966.csv

- Data from Table 1A from Smith (1966) used to build seed dispersal function in seed load proxy (/scripts/seed load.Rmd).
Smith, R. B. (1966). Hemlock and Larch Dwarf Mistletoe Seed Dispersal. The Forestry Chronicle, 42(4), 395–401. https://doi.org/10.5558/tfc42395-4

/data/raw/psp

- BC Government Permanent Sample Plot (PSP) data used to build equations hemlock tree height to height to live crown, which feeds into crown volume estimates in seed load proxy (/scripts/seed load.Rmd). Accessed 24 Jul 2024. Contains a data dictionary in folder—see that for further details. 
Forest Analysis and Inventory Branch. (2024). Forest Inventory Ground Plot Data and Interactive Map [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/824e684b-4114-4a05-a490-aa56332b57f4

/data/cleaned
- Cleaned data are data files that are analysis ready or are generated from raw data in (/scripts/cleaning).

site data.csv

- Site level data for edge spread field sites. Contains metadata (e.g. date harvested) and some analysis fields.

trees.csv

- Cleaned individual tree measurements from trees in both the regenerating and mature components of the edge spread field sites. This is the first version of the core analysis object for the project. Generated from (/data/raw/regen comp_master.csv and mature comp_master.csv) in the (/scripts/cleaning and processing/tree data cleaning.Rmd) script.

transect data_c.csv

- Cleaned version of data that maps transect ids to each edge spread field site and contains slope measurements. Generated from (/data/raw/transect data.csv) in the (/scripts/cleaning and processing/tran data cleaning.Rmd) script.

vri_c.csv

- Attribute information of vri polygons overlapping each edge spread field site filtered to relevant fields. Generated from (/data/raw/vri_hdm_sites.csv) in the (/scripts/cleaning and processing/vri data cleaning.Rmd) script.

hdm_trimbpoints.csv

- Processed differential GPS points taken at each edge spread field site. Trees at each site are stem mapped relative to these points.

regen_extra_ht_c.csv 

- Cleaned version individual measurements for trees used to measure hemlock top height at edge spread research sites, when not enough trees were present on a transect to meet our minimum requirement (three dominant/codominant hemlock per transect). Generated from (/data/raw/regen extra heights.csv) in the (/scripts/cleaning and processing/extra height cleaning.Rmd) script. 

/data/workflow

- Data files created in the various scripts in this project. These are intermediate (and eventually a final objects) that are derived from the data in (/data/raw and /data/cleaned)

### /scripts

/scripts/cleaning and processing

-   Scripts for cleaning and processing raw data files (/data/raw).

tree data cleaning.R

- Combines individual tree measurements from regenerating and mature components (/data/raw/regen comp_master.csv and mature comp_master.csv) and cleans them based on rules for each data field. Rules for how dwarf misltetoe rating (DMR) is defined for each tree are in this script.



#### ./convert_distaz_to_points.R

-   Script that combines tree data and high accuracy gps points to determine the location of each tree. The output of this is a spatial features object (sf package in R; /data/workflow/trees_mapped.csv and /data/workflow/trees_mapped.geojson)

#### ./stem_mapped_figures.Rmd

-   Script used to create stem mapped figures.

**./site level analysis.RMD**

-   Script comparing site level variables.
    -   Section 1 compares the different site climates, using data from Climate BC (<https://climatebc.ca/mapVersion>) and Barrett et al. (2012) as a framework for selecting and interpreting variables.
    -   Section 2 compares the size and composition of trees in the regen and mature components between sites.
    -   Section 3 compares HDM infection in the mature component between sites to get a high-level understanding if the infection sources are similar between sites.
    -   Section 4 compares HDM infection in the regen component between sites to get a first impression of the spread that has occurred and what variables might be important in predicting it.

Barrett, T. M., Latta, G., Hennon, P. E., Eskelson, B. N. I., & Temesgen, H. (2012). Host--parasite distributions under changing climate: Tsuga heterophylla and Arceuthobium tsugense in Alaska. *Canadian Journal of Forest Research*, *42*(4), 642--656. <https://doi.org/10.1139/x2012-016>
