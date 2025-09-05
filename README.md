# Hemlock Dwarf Mistletoe Edge Spread

R project with all analyses for project: Edge spread of hemlock dwarf mistletoe and implications for the group retention silvicultural system.

## PROJECT DESCRIPTION

This research project measured infection patterns of the parasitic plant hemlock dwarf mistletoe (*Arceuthobium tsugense* subsp. *tsugense*; **HDM**), that infects the timber species western hemlock (*Tsuga heterophylla*), at edges separating a mature forest (the infection source) from a regnerating forest. The impetus for the project is to provide a foundation for comparative predictions of HDM infection in clearcut and group retention silvicultural systems. In the clearcut system, all trees in an area are harvested. In group retention, mature trees are retained in patches during harvesting to replicate patterns of mature forest structure that arise from the natural disturbance regime (gap disturbance) and balance timber and ecological objectives. In both systems HDM spreads from infected trees located at mature forest edges. These could be along the cutblock boundary (both clearcut and group retention) or retention patches (just group retention). Because infection originates at these edges, edge infection patterns can be scaled up to predict infection at the stand level with different levels of pre-harvest infection and retention levels/arrangements. Group retention cutblocks have higher edge:area ratios than equivalent clearcuts and therefore are expected to result in higher levels of HDM infection. The project is based in the coastal region of British Columbia, Canada where current guidelines reccomend against group retention in stands with HDM because of the anticipated timber impacts. Edge infection patterns and the stand level infection and timber impacts that underly these guidelines have never been measured. This is the gap the project starts to fill. The project objective is to characterize edge infection patterns; the predictive possiblities described above are left for future work. 

The survey design and a set of stem maps (plots where trees are represented by actual points in space) are shown below to illustrate the basic format of the data. Each site consisted of a 55.0 m long portion of the edge of a clearcut harvested area. The harvested area must have been cut 20–45 years ago and is called the regenerating component. The adjacent mature forest is termed the mature component; it had to be >100 years-old and harbour severe HDM infection. Hemlock had to be a leading tree species in both components. The mature component was represented by a 10.0 x 55.0 m survey area. The regenerating component was represented by 5.0 m wide, variable length transects that extended perpendicular to edge. Transect length was determined by the infected regenerating tree farthest from the edge. Trees were stem mapped, measured and rated for HDM infection.

![image](https://github.com/user-attachments/assets/4c763611-a4ab-4379-a17f-90e35e9160a3)

*Overview of survey methods*


![trees_sl_defence](https://github.com/user-attachments/assets/b2e7c34f-7dd5-426c-a53b-a3fbe53ad245)
*Stem maps of three sites showing variation in infection patterns*

## FILE DIRECTORY

### /data 

-   All project data.

#### /data/data_dictionary

data_dictionary.xlsx

- Excel workbook with dictionaries for each of the datasets used in analysis, except for the BC Government PSP dataset, which has its own dictionary. Only original variables are defined; variables derived in scripts are defined as they are generated.

psp_full_dictionary.xlsx

- Data dictionary for the BC Government Permanent Sample Plot (PSP) dataset (/data/cleaned/psp). See detailed description of the dataset itself under the dataset entry.

vri_full_data_dictionary.pdf

- This is an additional reference for the BC Government Vegetation Resource Inventory (VRI) dataset (/data/cleaned/vri_c.csv). A dictionary for this dataset is included in the project dictionary (/data/dat_dictionary/data_dictionary.xlsx) because the original VRI dataset has been subset to a set of variables that are relevant for this project, ID variables have been added linking VRI polygons to specific research sites and some variables have been corrected to account for differences between the time a research site was measured and the year VRI data is projected to. This file is the original dictionary for the VRI dataset and provides additional details to what is in the project dictionary. 

#### /data/raw

-  Data in the form hand entered from field datasheets.

regen_comp_data.csv

- Individual tree measurements of trees in the regenerating component of edge spread field sites.

mature_comp_data.csv

- Individual tree measurements of trees in the mature component of edge spread field sites.

transect_data.csv

- Maps transect ids to each edge spread field site. Contains slope measurements for the site.

vri_hdm_sites.csv

- Attribute information of vri polygons overlapping each edge spread field site. Data are projected to 1 Jan 2021. Each component at each site is represented by at least one (and sometimes two) vri polygons.

Forest Analysis and Inventory Branch. (2024). VRI - 2023—Forest Vegetation Composite Rank 1 Layer (R1) [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/2ebb35d8-c82f-4a17-9c96-612ac3532d55

hdm_sites_clim_data.csv

- Climate data for the edge spread research sites. From Climate BC v7.50 for the Normal 1991–2020 period.

Climate BC website: https://climatebc.ca/ 

Wang, T., Hamann, A., Spittlehouse, D., & Carroll, C. (2016). Locally downscaled and spatially customizable climate data for historical and future periods for North America. PloS One, 11(6). https://doi.org/10.1371/journal.pone.0156720

regen_comp_extra_heights.csv

- Individual tree measurements for trees used to measure hemlock top height at edge spread research sites, when not enough trees were present on a transect to meet our minimum requirement (three dominant/codominant hemlock per transect).

resid_ref_tree_data.csv 

- Individual tree measurements for potential residual trees and reference trees at edge spread research sites. Potential residual trees are large, moderate-severely infected hemlock that could have been present pre-harvest. Residual trees were cored to assess whether they were present pre-harvest (but these cores have not been analyzed). Reference trees are large dominant/codominant hemlock in the mature component that were cored to act as a reference for residual tree cores, if crossdating was necessary. Both residual and reference trees have differential GPS points in /data/cleaned/hdm_trimbpoints.csv

seed_disp_smith1966.csv

- Data from Table 1A from Smith (1966) used to build seed dispersal function in seed load proxy (/scripts/seed load.Rmd).

Smith, R. B. (1966). Hemlock and Larch Dwarf Mistletoe Seed Dispersal. The Forestry Chronicle, 42(4), 395–401. https://doi.org/10.5558/tfc42395-4

/data/raw/psp

- BC Government Permanent Sample Plot (PSP) data used to build equations hemlock tree height to height to live crown, which feeds into crown volume estimates (/scripts/crown volume.Rmd). Accessed 24 Jul 2024. 

Forest Analysis and Inventory Branch. (2024). Forest Inventory Ground Plot Data and Interactive Map [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/824e684b-4114-4a05-a490-aa56332b57f4

#### /data/cleaned

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

#### data/workflow

- Intermediate data objects created in various scripts.

trees_mapped.csv

- Individual tree measurements with spatial point locations for each tree. Generated from data/cleaned/trees.csv object in the stem mapping script (/scripts/cleaning and processing/convert_dist_az_to_point.R).

trees_sim.csv 

- Individual tree measurements with spatial point locations and additional simulated trees in regenerating component. Generated from data/cleaned/trees_mapped.csv in the script that simulates regenerating component trees from the transect end to 50 m from the edge (scripts/simulate_trees.Rmd).

trees_cv.csv 

- Individual tree measurements with spatial point locations, additional simulated trees in regenerating component and crown volume estimates for live hemlock trees. Generated from data/cleaned/trees_sim.csv in the script that estimates crown volume for live hemlock trees (scripts/crown_volume.Rmd).

trees_sl.csv

- Individual tree measurements with spatial point locations, additional simulated trees in regenerating component, crown volume estimates for live hemlock trees and estimates of seed production and seed load proxies. Generated from data/cleaned/trees_cv.csv in the script that estimates the seed load and seed prodcution proxies (scripts/seed_load.Rmd).

crown_vol.csv

- Crown volume estimates for each live hemlock crown class in each component (regenerating or mature) at each site. Also includes tree measurements or estimates that feed into crown volume equations. Generated in the scripts/crown_volume.Rmd script.

top_ht_long.csv and top_ht_wide.csv

- Height estimates of live dominant/codominant hemlock in each component at each site (i.e. top height). Two estimates are included for each site-component: one from a sample of field measurements and one from the vri data (/data/raw/vri_hdm_sites.csv). Long versions has these different estimates spread across columns or gathered into fewer columns.

psp_tree_cwh.csv

- Subset of BC Government Permanent Sample Plot data (/data/raw/psp) filtered to sites within the Coastal Western Hemlock biogeoclimactic zone and near field sites.

site_metrics.csv

- Composite dataframe with site level variables summarising size distribution, composition and misteltoe infection in each component. Called in the modelling script. Probably delete?

trimb_r_adjusted.csv 

- Spatial points marking features (edge line, stem mapping plots, transect start and ends, other miscallaneous) at each edge spread field site. Generated from /data/raw/hdm_trimbpoints.csv in script that selects which points to use for stem mapping, then maps tree locations (/scripts/cleaning_processing/convert_dist_az_to_point.R). 

#### data/mof_footprints

- Polygons capturing each research site for the BC Government Experimental Project layer. Generated in /scripts/footprints.Rmd script.

### /scripts

#### /scripts/cleaning and processing

-   Scripts for cleaning and processing raw data files (/data/raw).

tree_data_cleaning.R

- Combines individual tree measurements from regenerating and mature components (/data/raw/regen comp_master.csv and mature comp_master.csv) and cleans them based on rules for each data field. Rules for how dwarf misltetoe rating (DMR) is defined for each tree are in this script.

stem map.R

- Converts tree positions in raw data to georeferenced spatial features. In raw data, mature tree locations are recorded as distance and azimuth from a stem mapping point. Regenerating tree data are recorded as x and y distance on a transect with a defined azimuth. Stem mapping points and transect start and end points had differential GPS points taken at them. The script uses the data to map tree locations from these post-processed GPS points. 

tran data cleaning.R

- Cleans up inconsistencies in transect data (data/raw/transect data.csv) that arose from us working out the kinks in a field protocol.

extra height cleaning.R

- Cleans data for extra dominant/codominant hemlock trees (data/raw/regen extra heights.csv).

vri data cleaning.Rmd

- Pulls out the relevant attributes from raw vri data (data/raw/vri_hdm_sites.csv) that contains 193 attributes and does some formatting.

### /scripts

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

### figures

- Figures exported in various scripts. Empty in Git repository but generated figures will be placed here.

### tables

- Tables exported in various scripts. Empty in Git repository but generated tables will be placed here.
