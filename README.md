# Hemlock Dwarf Mistletoe Edge Spread

R project with all analyses for project: Edge spread of hemlock dwarf mistletoe and implications for the group retention silvicultural system. 

## FILE DIRECTORY

### /data 

-   All project data.

/data/raw

-  Data in the form hand entered from field datasheets.

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

stem map.R

- Converts tree positions in raw data to georeferenced spatial features. In raw data, mature tree locations are recorded as distance and azimuth from a stem mapping point. Regenerating tree data are recorded as x and y distance on a transect with a defined azimuth. Stem mapping points and transect start and end points had differential GPS points taken at them. The script uses the data to map tree locations from these post-processed GPS points. 

tran data cleaning.R

- Cleans up inconsistencies in transect data (data/raw/transect data.csv) that arose from us working out the kinks in a field protocol.

extra height cleaning.R

- Cleans data for extra dominant/codominant hemlock trees (data/raw/regen extra heights.csv).

vri data cleaning.Rmd

- Pulls out the relevant attributes from raw vri data (data/raw/vri_hdm_sites.csv) that contains 193 attributes and does some formatting.

/scripts

simulate trees.Rmd

- Simulates data to extend the regenerating component transects to a standard length of 50 m across sites. Regen transects were variable length to create felxibility in the measurement protocol and reduce field mneasurement time. Transect length was determined by the infected tree farthest from the edge or a minimum of 15 m. New trees are simulated based on measured data from a site and all simulated hemlock are healthy (because the transect length determined the outer infection limit). This script starts with the output (data/workflow/trees_mapped.csv) from the stem mapping script (scripts/cleaning and processing/stem map.R). A new data file is created (data/workflow/trees_sim.csv) that feeds into the script to estimate crown volume (scripts/crown volume.Rmd).

 crown volume.Rmd

 - Gets simple crown volume estimates for each live hemlock crown class at each site. Heights are estimated by factoring measurements of dominant/codominant hemlock height by ratios with other crown classes, which were measured at one site (cr_3). Height to live crown is estimated based on a linear mixed effect model relating height to live crown to tree height, based on data from sites in the BC government permanent sample plot network that were similar to our field sites (/data/raw/psp). Crown volume equation from Marshall et al. (2003) are used to generate final estimates. This script starts with the output (data/workflow/trees_sim.csv) from the script simulating data on regenerting component transects (scripts/simulate trees.Rmd). A new data file is created (data/workflow/trees_cv.csv) that feeds into the script that estimates the seed load proxy (scripts/seed load.Rmd).
Marshall, David D, Gregory P Johnson, and David W Hann. ‘Crown Profile Equations for Stand-Grown Western Hemlock Trees in Northwestern Oregon’. Canadian Journal of Forest Research 33, no. 11 (1 November 2003): 2059–66. https://doi.org/10.1139/x03-126.

seed load.Rmd

- This script estimates seed load—a proxy for the amount of HDM seed that is hitting a given target tree. There are three pieces in the script: (1) seed production is estimated by combining dwarf mistletoe rating (DMR) and crown volume estimates, (2) the proportion of a tree's seed production that reaches a given distance from the tree stem is estimated with a seed dispersal function and (3) pairs of source and target trees at each site are defined and interception between them is estimated. These three pieces are combined to estimate seed load. This script starts with the output (data/workflow/trees_cv.csv) from the script estimating crown volume for live hemlock (scripts/crown volume.Rmd). A new data file is created (data/workflow/trees_sl.csv) that is used all the data analysis scripts.


site level analysis.Rmd

- Exploratory data analysis comparing eleven edge spread research sites to eachother. Section 1 compares the different site climates using data from Climate BC (see https://climatebc.ca/mapVersion and see Wang et al. [2016]). A paper modelling HDM distributions at its northern limit (Barrett et al. 2012) is used as a framework for selecting and interpreting climate variables. There is a focus on precipitation because the Pacific Highway sites were the wettest and had relatively low rates of infection. Section 2 compares the size and composition of trees in the regen and mature components between sites. Section 3 compares HDM infection in the mature component between sites to get a  high-level understanding if the infection sources are similar between sites. Section 4 compares HDM infection in the regen component between sites. Summary tables and figures are created in each section for writing and downstream analyses. The primary starting object for the script (data/workflow/trees_sl.csv) is the output of the script estimating seed load (scripts/seed load.Rmd). 
Wang, T., Hamann, A., Spittlehouse, D., & Carroll, C. (2016). Locally downscaled and spatially customizable climate data for historical and future periods for North America. PloS One, 11(6). https://doi.org/10.1371/journal.pone.0156720
Barrett, T. M., Latta, G., Hennon, P. E., Eskelson, B. N. I., & Temesgen, H. (2012). Host–parasite distributions under changing climate: Tsuga heterophylla and Arceuthobium tsugense in Alaska. Canadian Journal of Forest Research, 42(4), 642–656. https://doi.org/10.1139/x2012-016

stem_maps.Rmd
- Generates stem maps, coloured by dwarf mistletoe rating, for each site. The output of the script estimating seed load (script: scripts/seed load.Rmd, output: data/workflow/trees_sl.csv) and the post-processed, differentially corrected GPS points (workflow/trimb_radjusted.csv), which were cleaned in the stem mapping script (/scripts/cleaning and processing/stem map.R), are the starting objects.

modelling.Rmd

- Fits ordinal models that predict the dwarf mislteotoe rating of live hemlock trees in the regenerating component from tree level variables (distance from the edge, DBH, crown class, seed load). The primary starting object for the script (data/workflow/trees_sl.csv) is the output of the script estimating seed load (scripts/seed load.Rmd).

retention_geometry.R
- Generates geometries for "typical" clearcut and group retention cutblocks from a 16 ha area to provide an initial indication of how to zones of edge influence and associated HDM infection and timber impacts compare.

footprints.Rmd
- Generates polygons capturing each research site to upload to the BC Government Experimental Project layer. 

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
