# =================================================================
# Importing basic Canberra geometry at SA3 level ==================
# =================================================================

# 1) LOAD in shapefile from disk
sp_poly_df_AUST_SA3 <- rgdal::readOGR(dsn = "input_data/2011_SA3_shape", 
                                      layer = "SA3_2011_AUST")
# 2 SET CRS
# Set the projection system explicitly.. this the sames as in the *.prj file
proj4string(sp_poly_df_AUST_SA3) <-  sp::CRS("+init=epsg:4283")

# 3) FILTER --filter Act only ( State Code == 8) and exlude the Cotter region (i.e. 80102)

# 3.1) make a logical vector reflecting the filter condition
vct_act_only <- sp_poly_df_AUST_SA3@data$STATE_CODE == "8" & 
  sp_poly_df_AUST_SA3@data$SA3_CODE != "80102"

# ===
# 3.2 apply the filter
sp_poly_df_act <- sp_poly_df_AUST_SA3[vct_act_only, ]


# 4 DISPLAY
# this erases any previous  plots
if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
plot(sp_poly_df_act)


# =================================================================
#  Properties of sp_poly_df_AUST_SA3 ==============================
# =================================================================

# number of rows
nrow(sp_poly_df_act)

# find out the class
sp_poly_df_act %>% class()

# what properties does the object have..?
slotNames(sp_poly_df_act)

# display the class of the data property
sp_poly_df_act@data %>% class()

# display the class of the polygons property
sp_poly_df_act@polygons %>% class()

# display the length of the polygons list
sp_poly_df_act@polygons %>% length()

# what is the object size
object.size(sp_poly_df_act)

# =================================================================
#  Import Queenbeyan (NB SA2 level) ===============================
# =================================================================
# 1) load from disk
sp_poly_df_qb_SA2 <- rgdal::readOGR(dsn = "input_data/queenbeyan_sa2", 
                                    layer = "qb_sa2")
# 2) set coordinate system
proj4string(sp_poly_df_qb_SA2) <- CRS("+init=epsg:4283")

# 3) plot **TWO** distinct polygons
# 3.1) this erases any previous  plots
if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
# 3.2 ) plot Canberra SA3 (polygon 1)
plot(sp_poly_df_act, border = '#0365C0')

if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
# 3.3 ) Now add the Queenbeyan SA2 piece (polygon 2)
plot(sp_poly_df_qb_SA2 ,  border = '#0365C0')

# =================================================================
#  Load in NSW and ACT SA2 Data ===================================
# =================================================================




sp_poly_df_NSW_SA2 <- rgdal::readOGR(dsn = "processed_data", 
                                      layer = "sp_poly_df_NSW_SA2")


# 2) set coordinate system
proj4string(sp_poly_df_NSW_SA2) <- CRS("+init=epsg:4283")

# =================================================================
# Load in CSV file -- cut down columns and create percentages...
# =================================================================

# read in csv file TimeSeries at SA2 level
df_sa2_data <- read.csv("input_data/csv_data/2011Census_T01_AUST_SA2_long.csv")

# define vector of relevant names
vct_col_names <- c("region_id", "Total_persons_2006_Census_Persons", 
                   "Total_persons_2011_Census_Persons")

# select in the names we are interested in
df_sa2_data <- df_sa2_data %>% dplyr::select(vct_col_names %>% one_of())

# rename columns to something smaller
df_sa2_data <- df_sa2_data %>% rename(
  tp_2006 = Total_persons_2006_Census_Persons, 
  tp_2011 = Total_persons_2011_Census_Persons)

# add a % change column
df_sa2_data$pc <- (df_sa2_data$tp_2011 - df_sa2_data$tp_2006)  / 
  df_sa2_data$tp_2011
# format 
df_sa2_data$pc <- (df_sa2_data$pc * 100) %>% round(2)




