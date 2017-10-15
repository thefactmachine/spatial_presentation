# preliminaries
options(stringsAsFactors = FALSE)
rm(list = ls())

library(dplyr)
library(lubridate)
library(stringr)

# geoviz stuff
library(ggmap)
library(ggplot2)


# spatial stuff
library(sp)
library(rgdal)
library(rgeos)




# =======================================================================

# load in various shape files which create the following....

#  df_sa2_data                  ---   data frame of SA2 data.
#  sp_poly_df_act               ----  Canberra only SA3
#  sp_poly_df_AUST_SA2          ----  all Australia SA2
#  sp_poly_df_AUST_SA3          ----  all Australia SA3
#  sp_poly_df_NSW_SA2           ----  NSW and ACT SA2
#  sp_poly_df_qb_SA2            ----  Queenbeyan - SA2

source(file.path("r_code","a_loading_data.r", fsep = .Platform$file.sep))

# =======================================================================
# =======================================================================
# demonstrate some spatial verbs / functions ============================
# =======================================================================
source(file.path("r_code","b_spatial_verbs.r", fsep = .Platform$file.sep))


# =======================================================================
# =======================================================================
# demonstrate some spatial joins  =======================================
# =======================================================================
source(file.path("r_code","c_spatial_joins.r", fsep = .Platform$file.sep))



# =======================================================================
# =======================================================================
# demonstrate some choropleth maps ======================================
# =======================================================================
source(file.path("r_code","d_basic_visualisation.r", fsep = .Platform$file.sep))





