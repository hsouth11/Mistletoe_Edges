# Hemlock Dwarf Mistletoe Edge Spread

R project with all analyses for project: Edge spread of hemlock dwarf mistletoe and implications for the group retention silvicultural system.

## PROJECT DESCRIPTION

This research project measured infection patterns of the parasitic plant hemlock dwarf mistletoe (*Arceuthobium tsugense* subsp. *tsugense*; **HDM**), that infects the timber species western hemlock (*Tsuga heterophylla*), at edges separating a mature forest (the infection source) from a regnerating forest. The impetus for the project is to provide a foundation for comparative predictions of HDM infection in clearcut and group retention silvicultural systems. In the clearcut system, all trees in an area are harvested. In group retention, mature trees are retained in patches during harvesting to replicate patterns of mature forest structure that arise from the natural disturbance regime (gap disturbance) and balance timber and ecological objectives. In both systems HDM spreads from infected trees located at mature forest edges. These could be along the cutblock boundary (both clearcut and group retention) or retention patches (just group retention). Because infection originates at these edges, edge infection patterns can be scaled up to predict infection at the stand level with different levels of pre-harvest infection and retention levels/arrangements. Group retention cutblocks have higher edge:area ratios than equivalent clearcuts and therefore are expected to result in higher levels of HDM infection. The project is based in the coastal region of British Columbia, Canada where current guidelines reccomend against group retention in stands with HDM because of the anticipated timber impacts. Edge infection patterns and the stand level infection and timber impacts that underly these guidelines have never been measured. This is the gap the project starts to fill. The project objective is to characterize edge infection patterns; the predictive possiblities described above are left for future work. 

The survey design (Figure 1) and a set of stem maps (plots where trees are represented by actual points in space; Figure 2) are shown below to illustrate the basic format of the data. Each site (n = 11) consisted of a 55.0 m long portion of the edge of a clearcut harvested area. The harvested area must have been cut 20–45 years ago and is called the regenerating component. The adjacent mature forest is termed the mature component; it had to be >100 years-old and harbour severe HDM infection. Hemlock had to be a leading tree species in both components. The mature component was represented by a 10.0 x 55.0 m survey area. The regenerating component was represented by 5.0 m wide, variable length transects that extended perpendicular to edge. Transect length was determined by the infected regenerating tree farthest from the edge. Trees were stem mapped, measured and rated for HDM infection.

![image](https://github.com/user-attachments/assets/4c763611-a4ab-4379-a17f-90e35e9160a3)

*Figure 1. Overview of survey methods*


![trees_sl_defence](https://github.com/user-attachments/assets/b2e7c34f-7dd5-426c-a53b-a3fbe53ad245)
*Figure 2. Stem maps of three sites showing variation in infection patterns*

### Associated thesis

Southam, H. (2025). Edge spread of hemlock dwarf mistletoe and implications for the group retention silvicultural system [Text, The University of British Columbia]. http://hdl.handle.net/2429/91122

## FILE DIRECTORY

### /data 

-   Placeholder folder for data. To obtain the data download it here: xxxxxx. Then extract the zip folder inside of this data folder. The file structure and naming will align with what is shown below. 

#### /data/data_dictionary

data_dictionary.xlsx

- Excel workbook with dictionaries for each of the datasets used in analysis, except for the BC Government PSP dataset and the climate data from ClimateBC, which have their own dictionaries that are separate files. Only original variables are defined; variables derived in scripts are defined as they are generated.

psp_full_dictionary.xlsx

- Data dictionary for the BC Government Permanent Sample Plot (PSP) dataset (/data/cleaned/psp). See detailed description of the dataset itself under the dataset entry.

climate_bc_data_dictionary.pdf

- Data dictionary for the descriptive climate data for the research sites (/data/cleaned/hdm_sites_clim_data.csv). This file is a copy of the *Help* page from the ClimateBC webpage (https://climatebc.ca/Help2). See detailed description of the dataset itself under the dataset entry.

vri_full_data_dictionary.pdf

- This is an additional reference for the BC Government Vegetation Resource Inventory (VRI) dataset (/data/cleaned/vri_c.csv). A dictionary for this dataset is included in the project dictionary (/data/dat_dictionary/data_dictionary.xlsx) because the original VRI dataset has been modified slightly. The original data set was (1) subset to a set of variables that are relevant for this project, (2) ID variables have been added linking VRI polygons to specific research sites and (3) some variables have been corrected to account for differences between the time a research site was measured and the year VRI data is projected to. This file is the original dictionary for the VRI dataset and provides additional details to what is in the project dictionary. 

#### /data/raw

- Data in the form hand entered from field datasheets. These data will not be included in published dataset.

mature_comp_data.csv

- Individual tree measurements of trees in the mature component of edge spread field sites.

regen_comp_data.csv

- Individual tree measurements of trees in the regenerating component of edge spread field sites.

ref_tree_data.csv 

- Individual tree measurements reference trees at edge spread research sites. Reference trees are large dominant/codominant hemlock in the mature component that were cored to act as a reference for residual tree cores, if crossdating was necessary. Reference trees have associated differential GPS points in /data/cleaned/hdm_trimb_points.csv

regen_comp_extra_heights.csv

- Individual tree measurements for trees used to measure average height of codominanant/dominant hemlock at edge spread research sites, when not enough trees were present on a transect to meet our minimum requirement (three per transect).

transect_data.csv

- Data associated with transects that measure the regenerating component. Maps transect ids to each edge spread field site. Contains transect lengths and slope measurements for each site. 

vri_hdm_sites.csv

- Raw attribute information of vri polygons overlapping each edge spread field site. Data are projected to 1 Jan 2021. Each component at each site is represented by at least one (and sometimes two) vri polygons.

Forest Analysis and Inventory Branch. (2024). VRI - 2023—Forest Vegetation Composite Rank 1 Layer (R1) [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/2ebb35d8-c82f-4a17-9c96-612ac3532d55

#### /data/cleaned

- Cleaned data files that are analysis ready.

site_data.csv

- Site level data for edge spread field sites. Contains metadata (e.g. date harvested) and some analysis fields.

transect_data_c.csv

- Data associated with transects that measure the regenerating component. Maps transect ids to each edge spread field site. Contains transect lengths and slope measurements for each site. 

trees.csv

- Cleaned individual tree measurements from trees in both the regenerating and mature components of the edge spread field sites. This is the first version of the core analysis object for the project.
  
regen_extra_ht_c.csv 

- Individual tree measurements for trees used to measure average height of codominant/dominant hemlock at edge spread research sites, when not enough trees were present on a transect to meet our minimum requirement (three per transect).

resid_tree_data.csv 

- Individual tree measurements for potential residual trees at edge spread research sites. Potential residual trees are large, moderate-severely infected hemlock that could have been present pre-harvest. Residual trees were cored to assess whether they were present pre-harvest (but these cores have not been analyzed). Residual trees have associated differential GPS points in /data/cleaned/hdm_trimbpoints.csv. These trees are removed from analysis to focus on the tree cohort that originated post-harvest. 

hdm_trimb_points.csv

- Processed differential GPS points taken at each edge spread field site. Points include: transect start and end points (in regen component), stem mapping plot centres (in mature component), residual trees, reference trees, the edge line separating regen and mature components and a rough line delinating the outer infection boundary in the regen component. Trees at each site are stem mapped relative to the transect/stem mapping points.

hdm_sites_clim_data.csv

- Climate data for the edge spread research sites. From Climate BC v7.50 for the Normal 1991–2020 period. Reference: Wang et al. (2016). 

Climate BC website: https://climatebc.ca/ 

vri_c.csv

- Attribute information of vri polygons overlapping each edge spread field site filtered to relevant fields. Data are projected to 1 Jan 2021. Each component at each site is represented by at least one (and sometimes two) vri polygons.

Forest Analysis and Inventory Branch. (2024). VRI - 2023—Forest Vegetation Composite Rank 1 Layer (R1) [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/2ebb35d8-c82f-4a17-9c96-612ac3532d55

seed_disp_smith1966.csv

- Data from Table 1A from Smith (1966) used to build seed dispersal function in seed load proxy (see /scripts/05_seed_load.Rmd).

/data/cleaned/psp

- BC Government Permanent Sample Plot (PSP) data used to build equations relating hemlock tree height to height to live crown, which feeds into crown volume estimates (see: /scripts/04_crown_volume.Rmd). Accessed 24 Jul 2024. 

Forest Analysis and Inventory Branch. (2024). Forest Inventory Ground Plot Data and Interactive Map [Dataset]. British Columbia Data Catalogue. https://catalogue.data.gov.bc.ca/dataset/824e684b-4114-4a05-a490-aa56332b57f4

#### data/workflow

- Placeholder for folder that holds intermediate data objects created in analysis.

#### data/mof_footprints

- Placeholder folder that holds the shapefiles capturing each research site for the BC Government Experimental Project layer.

### /scripts

#### /scripts/cleaning and processing

-   Scripts for cleaning and processing raw data files (/data/raw).

tree_data_cleaning.Rmd

- Combines individual tree measurements from regenerating and mature components (/data/raw/regen_comp_data.csv and mature_comp_data.csv) and cleans them based on rules for each data field.

transect_data_cleaning.R

- Cleans up inconsistencies in transect data (data/raw/transect_data.csv) that arose from us working out the kinks in a field protocol.

extra_height_cleaning.R

- Cleans data for extra dominant/codominant hemlock trees measured to get estimates of average codominant/dominant hemlock height at each site (data/raw/regen_comp_extra_heights.csv).

vri_data_cleaning.Rmd

- Pulls out the relevant attributes from raw vri data (data/raw/vri_hdm_sites.csv), does some formatting, and where possible, corrects for differences between year a site was measured and the year it is projected in vri.

### /scripts

01_convert_dist_az_to_point.R

- Converts tree positions in raw data to georeferenced spatial features. In starting data, trees in the mature component are recorded as distance and azimuth from a stem mapping point. Trees in the regenerating component are recorded as x and y distance on a transect with a defined azimuth. Stem mapping points and transect start and end points had differential GPS points taken at them. The script maps tree locations from these GPS points using the distance and azimuth data. Input: ./data/cleaned/trees.csv. Output: ./data/workflow/trees_mapped.csv, which feeds into ./scripts/02_define_dmr.Rmd.

02_define_dmr.Rmd

- Defines tree-level dwarf mistletoe rating (DMR). Two versions of this variable are created: (1) traditional DMR: the sum of crown-third DMR ratings and (2) adapted DMR: a more general descriptor used to describe dwarf mistletoe infection in live and dead, susceptible trees. Input: ./data/workflow/trees_mapped.csv, from ./scripts/01_convert_dist_az_to_point.R. Output: ./data/workflow/trees_dmr.csv, which feeds into ./scripts/03_simulate_trees.Rmd.

03_simulate_trees.Rmd

- Simulates data to extend the regenerating component transects to a standard length of 50 m across sites. Regen transects were variable length to create felxibility in the measurement protocol and reduce field mneasurement time. Transect length was determined by the infected tree farthest from the edge or a minimum of 15 m. New trees are simulated based on measured data from a site and all simulated hemlock are healthy (because the transect length determined the outer infection limit). Input: ./data/workflow/trees_mapped.csv, from ./scripts/cleaning and processing/stem map.R. Output: ./data/workflow/trees_sim.csv, which feeds into ./scripts/04_crown_volume.Rmd.
 
04_crown_volume.Rmd

 - Gets simple crown volume estimates for each live hemlock crown class at each site. Heights are estimated by factoring measurements of dominant/codominant hemlock height by ratios with other crown classes, which were measured at one site (cr_3). Height to live crown is estimated based on a linear mixed effect model relating height to live crown to tree height, based on data from sites in the BC government permanent sample plot network that were similar to our field sites. Crown volume equations from Marshall et al. (2003) are used to generate final estimates. Input: ./data/workflow/trees_sim.csv and ./data/cleaned/psp. Output: ./data/workflow/trees_cv.csv, which feeds into ./scripts/05_seed_load.Rmd.

05_seed_load.Rmd

- This script estimates seed load—a proxy for the amount of HDM seed that is hitting a given target tree. There are three pieces in the script: (1) seed production is estimated by combining dwarf mistletoe rating (DMR) and crown volume estimates, (2) the proportion of a tree's seed production that reaches a given distance from the tree stem is estimated with a seed dispersal function and (3) pairs of source and target trees at each site are defined and interception between them is estimated. These three pieces are combined to estimate seed load. Data for the seed dispersal function are from Smith (1966), interception factors are based on Bloomberg et al. (1980) and numerous conceptual ideas take from Robinson et al. (2006). Inputs: ./data/workflow/trees_cv.csv and ./data/cleaned/pspseed_disp_smith1966.csv. Output: ./data/workflow/trees_sl.csv, which feeds into all the data analysis scripts.

06_exploratory_analysis.Rmd

- Exploratory data analysis comparing eleven edge spread research sites to eachother. Section 1 compares the different site climates using data from Climate BC (see https://climatebc.ca/mapVersion and see Wang et al. [2016]). A paper modelling HDM distributions at its northern limit (Barrett et al. 2012) is used as a framework for selecting and interpreting climate variables. There is a focus on precipitation because the Pacific Highway sites were the wettest and had relatively low rates of infection. Section 2 compares the size and composition of trees in the regen and mature components between sites. Section 3 compares HDM infection in the mature component between sites to get a  high-level understanding of whether the infection sources are similar between sites. Section 4 compares HDM infection in the regen component between sites. Summary tables and figures are created in each section for writing and downstream analyses. Inputs: ./data/workflow/trees_sl.csv, ./data/cleaned/hdm_sites_clim_data.csv and ./data/cleaned/vri_c.csv.

07_stem_maps.Rmd
- Generates stem maps, coloured by dwarf mistletoe rating, for each site. Inputs: ./data/workflow/trees_sl.csv and ./cleaned/hdm_trimb_points.csv. 

08_ordinal_regression.Rmd

- Fits ordinal models that predict the dwarf mislteotoe rating of live hemlock trees in the regenerating component from tree level variables (distance from the edge, DBH, crown class, seed load). Input: ./data/workflow/trees_sl.csv.

09_retention_geometry.R
- Generates geometries for "typical" clearcut and group retention cutblocks from a 16 ha area to provide an initial indication of how to zones of edge influence and associated HDM infection and timber impacts compare.

10_ep_footprints.Rmd
- Generates polygons capturing each research site to upload to the BC Government Experimental Project layer. Inputs: ./data/workflow/trees_sl.csv. Output: shapefiles in ./data/mof_footprints

### figures

- Placeholder for folder that holds figures created in various scripts.
  
### tables

- Placeholder for folder that holds tables created in various scripts.

## REFERENCES
Barrett, T. M., Latta, G., Hennon, P. E., Eskelson, B. N. I., & Temesgen, H. (2012). Host–parasite distributions under changing climate: Tsuga heterophylla and Arceuthobium tsugense in Alaska. Canadian Journal of Forest Research, 42(4), 642–656. https://doi.org/10.1139/x2012-016

Bloomberg, W. J., R. B. Smith, and A. Van Der Wereld. ‘A Model of Spread and Intensification of Dwarf Mistletoe Infection in Young Western Hemlock Stands’. Canadian Journal of Forest Research 10, no. 1 (1 March 1980): 42–52. https://doi.org/10.1139/X80-008.

Robinson, D. C. E., & Geils, B. W. (2006). Modelling dwarf mistletoe at three scales: Life history, ballistics and contagion. Ecological Modelling, 199(1), 23–38. https://doi.org/10.1016/J.ECOLMODEL.2006.06.007

Smith, R. B. (1966). Hemlock and Larch Dwarf Mistletoe Seed Dispersal. The Forestry Chronicle, 42(4), 395–401. https://doi.org/10.5558/tfc42395-4

Wang, T., Hamann, A., Spittlehouse, D., & Carroll, C. (2016). Locally downscaled and spatially customizable climate data for historical and future periods for North America. PloS One, 11(6). https://doi.org/10.1371/journal.pone.0156720
