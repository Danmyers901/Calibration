# Seasonal landcover variation and environmental modeling scripts

These scripts are from the Myers et al. study with seasonal landcover variation and environmental modeling.

They use the following dataset:

Myers, Daniel; Jones, David; Oviedo-Vargas, Diana; Schmit, John Paul; Ficklin, Darren; Zhang, Xuesong (2022), “Seasonal landcover variation and environmental modeling data”, Mendeley Data, V3, doi: 10.17632/bbb9xbpv22.3


The Google Earth Engine Code Editor scripts can be run to generate growing and non-growing season Dynamic World images at https://developers.google.com/earth-engine/guides/playground. We also include the LULC images.

The scripts to reproduce LULC, hydrologic, and supplementary figures and analyses can be run in R (https://www.r-project.org/). Set the working directories to the data folders, then run the included .R scripts to reproduce our analyses and figures. You may need to install packages that the scripts mention. The scripts were run with R 4.2.0. Scripts should run in <1 minute.

Our data includes water quality measurements from the United States National Park Service, and remotely sensed landcover images from Dynamic World, for 37 current (+18 inactive) monitoring sites near Washington, D.C., USA. Water quality data were downloaded from the Water Quality Portal at https://www.waterqualitydata.us/ using the Project ID search term “NCRNWQ01”.

Brown, C. F. et al. Dynamic World, Near real-time global 10 m land use land cover mapping. Scientific Data 2022 9:1 9, 1–17 (2022).

Norris, M., Pieper, J., Watts, T. & Cattani, A. National Capital Region Network Inventory and Monitoring Program Water Chemistry and Quantity Monitoring Protocol Version 2.0 Water chemistry, nutrient dynamics, and surface water dynamics vital signs. Natural Resource Report NPS/NCRN/NRR—2011/423 (2011).


The hydrologic model we used was the Soil and Water Assessment Tool (SWAT) with AMALGAM calibration.

Arnold, J. G., Srinivasan, R., Muttiah, R. S. & Williams, J. R. Large Area Hydrologic Modeling and Assessment Part I : Model Development. J Am Water Resour Assoc 34, 73–89 (1998).

Vrugt, J. A. & Robinson, B. A. Improved evolutionary optimization from genetically adaptive multimethod search. Proceedings of the National Academy of Sciences (2007) doi:10.1073/pnas.0610471104.

Myers, D. T. et al. Choosing an arbitrary calibration period for hydrologic models: How much does it influence water balance simulations? Hydrol Process 35, e14045 (2021).


References for other data sources and packages we used for model development and analyses are below:

Abbaspour, K. C., Vaghefi, S. A., Yang, H. & Srinivasan, R. Global soil, landuse, evapotranspiration, historical and future weather databases for SWAT Applications. Scientific Data 2019 6:1 6, 1–11 (2019).

European Space Agency (ESA). Sentinel-2 MSI User Guide. Sentinel-2 MSI (2020).

III, K. G. R. et al. StreamStats, version 4. Fact Sheet (2017) doi:10.3133/FS20173046.

Jin, S. et al. Overall Methodology Design for the United States National Land Cover Database 2016 Products. Remote Sensing 2019, Vol. 11, Page 2971 11, 2971 (2019).

Lindsay, J. B. The Whitebox Geospatial Analysis Tools Project and Open-Access GIS. (2022).

Leeper, R. D., Rennie, J. & Palecki, M. A. Observational Perspectives from U.S. Climate Reference Network (USCRN) and Cooperative Observer Program (COOP) Network: Temperature and Precipitation Comparison. J Atmos Ocean Technol 32, 703–721 (2015).

Lehner, B., Verdin, K. & Jarvis, A. HydroSHEDS Technical Documentation. World Wildlife Fund, Washington, DC (2006).

Pianosi, F. & Wagener, T. A simple and efficient method for global sensitivity analysis based oncumulative distribution functions. Environmental Modelling and Software 67, 1–11 (2015).

Pianosi, F., Sarrazin, F. & Wagener, T. A Matlab toolbox for Global Sensitivity Analysis. Environmental Modelling and Software 70, 80–85 (2015).

Sugarbaker, L. J. et al. USGS Circular 1399: The 3D Elevation Program Initiative— A Call for Action. https://pubs.usgs.gov/circ/1399/ (2014).

United States Department of Agriculture. National Agriculture Imagery Program (NAIP) - Catalog. https://catalog.data.gov/dataset/national-agriculture-imagery-program-naip.

USGS. National Water Information System data available on the World Wide Web (USGS Water Data for the Nation). United States Geological Survey waterdata.usgs.gov (2022).

Zadeh, F. K. et al. Comparison of variance-based and moment-independent global sensitivity analysis approaches by application to the SWAT model. Environmental Modelling and Software 91, 210–222 (2017).


For more information contact:

Dan Myers, PhD
Postdoctoral Associate
Stroud Water Research Center
970 Spencer Road, Avondale, PA 19311
610-268-2153 ext. 1274
dmyers@stroudcenter.org
www.stroudcenter.org 
