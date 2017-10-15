# =================================================================
#  Import Australia SA2 level and filter to NSW and ACT Only========
# =================================================================

# A) load in SA2
sp_poly_df_AUST_SA2 <- rgdal::readOGR(dsn = "input_data/2011_SA2_shape", 
                                      layer = "SA2_2011_AUST")
# B) SET CRS
# Set the projection system explicitly.. this the sames as in the *.prj file
proj4string(sp_poly_df_AUST_SA2) <- CRS("+init=epsg:4283")

# ===================================================================
# C) Blocking ...cut the sucker down to ACT or NSW 
sp_poly_df_NSW_SA2 <- sp_poly_df_AUST_SA2[
  sp_poly_df_AUST_SA2@data$STATE_CODE == "1" | 
    sp_poly_df_AUST_SA2@data$STATE_CODE == "8", ]

writeOGR(obj = sp_poly_df_NSW_SA2, dsn = "processed_data", 
         layer = "sp_poly_df_NSW_SA2", driver="ESRI Shapefile") 
