# Pixel class probabilities scripts

These scripts are associated with the manuscript:

Convolutional neural network (CNN) based pixel probabilities for forested and urban land cover classification
Daniel T. Myers1* (ORCID 0000-0002-1932-5775), Diana Oviedo-Vargas1, Melinda Daniels1, Yog Aryal2

1 Stroud Water Research Center, 970 Spencer Road, Avondale, Pennsylvania 19311, USA
2 Department of Geography, Indiana University Bloomington, Student Building 120, 701 E. Kirkwood Avenue, Bloomington, IN 47405, USA
* Corresponding author (dmyers@stroudcenter.org)

They use the following dataset: Myers, Daniel; Oviedo-Vargas, Diana; Daniels, Melinda; Aryal, Yog (2023), “Pixel class probabilities investigations data”, Mendeley Data, V1, doi: 10.17632/zyds7t4pst.1

The Google Earth Engine Code Editor scripts can be run to generate growing and non-growing season Dynamic World images at https://developers.google.com/earth-engine/guides/playground. We also include the LULC images.

The scripts to reproduce LULC, hydrologic, and supplementary figures and analyses can be run in R (https://www.r-project.org/). Set the working directories to the data folders, then run the included .R scripts to reproduce our analyses and figures. You may need to install packages that the scripts mention. The scripts were run with R 4.2.0. Scripts should run in <1 minute.

Our data includes water quality measurements from the United States National Park Service, and remotely sensed landcover images from Dynamic World. Water quality data were downloaded from the Water Quality Portal at https://www.waterqualitydata.us/ using the Project ID search term “NCRNWQ01”.

Brown, C. F. et al. Dynamic World, Near real-time global 10 m land use land cover mapping. Scientific Data 2022 9:1 9, 1–17 (2022).

Norris, M., Pieper, J., Watts, T. & Cattani, A. National Capital Region Network Inventory and Monitoring Program Water Chemistry and Quantity Monitoring Protocol Version 2.0 Water chemistry, nutrient dynamics, and surface water dynamics vital signs. Natural Resource Report NPS/NCRN/NRR—2011/423 (2011).



References for other data sources and packages we used for model development and analyses are below:

III, K. G. R. et al. StreamStats, version 4. Fact Sheet (2017) doi:10.3133/FS20173046.

Jin, S. et al. Overall Methodology Design for the United States National Land Cover Database 2016 Products. Remote Sensing 2019, Vol. 11, Page 2971 11, 2971 (2019).

Lindsay, J. B. The Whitebox Geospatial Analysis Tools Project and Open-Access GIS. (2022).

United States Department of Agriculture. National Agriculture Imagery Program (NAIP) - Catalog. https://catalog.data.gov/dataset/national-agriculture-imagery-program-naip.

For more information contact:

Dan Myers, PhD
Postdoctoral Associate
Stroud Water Research Center
970 Spencer Road, Avondale, PA 19311
610-268-2153 ext. 1274
dmyers@stroudcenter.org
www.stroudcenter.org 
