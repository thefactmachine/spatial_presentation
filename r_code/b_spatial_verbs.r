# =================================================================
#  UNION Canberra AND Queenbeyan ==================================
# =================================================================

# 1) set common names
vct_names <- c("pk", "name", "state_cd", "state", "area")
names(sp_poly_df_act@data) <- vct_names
names(sp_poly_df_qb_SA2@data) <- vct_names

# 2) Union the two together --- how easy
sp_poly_cbr_qb <- base::rbind(sp_poly_df_act, sp_poly_df_qb_SA2)

# 3) Display things.
if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
# Plot ref: http://www.statmethods.net/advgraphs/parameters.html
plot(sp_poly_cbr_qb, lty = 1,  border = '#0365C0')


# =================================================================
#  DISSOLVING polygons ============================================
# =================================================================

# 1) Prepare -- create an attribute, same for all rows
sp_poly_cbr_qb@data$cbr_qb <- TRUE

# 2) Dissolve
sp_poly_df_CBR_dissolve <- rgeos::gUnaryUnion(sp_poly_cbr_qb, 
                                              id = sp_poly_cbr_qb@data$cbr_qb)

# 3) Display things.
if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
# Plot ref: http://www.statmethods.net/advgraphs/parameters.html
plot(sp_poly_df_CBR_dissolve,  border = '#0365C0')


# =================================================================
#  BUFFERING polygons =============================================
# =================================================================

# find out what projection system to use..
# http://spatialservices.finance.nsw.gov.au/surveying/geodesy/projections
# http://prj2epsg.org/epsg/3308

# GCS needs to be converted to Projected Coordinate System (PGS)
sp_dissolve_proj <- sp::spTransform(sp_poly_df_CBR_dissolve, 
                                    CRS = CRS("+init=epsg:3308"))

# perform the buffering operation (3km)
sp_dissolve_proj_buff <- rgeos::gBuffer(sp_dissolve_proj, width = 3000)


if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
# plot the larger object first
plot(sp_dissolve_proj_buff, lwd = 2,  border = '#EC3639')
plot(sp_dissolve_proj,  lwd = 2, border = '#00B2F5', col = "white", add = TRUE)


# =================================================================
#  DIFFERENCE  ====================================================
# =================================================================

# extract the buffer using the difference function
sp_buffer <- rgeos::gDifference(sp_dissolve_proj_buff, sp_dissolve_proj)

# plot the result
if (length(dev.list()) > 0) {dev.off(dev.list()["RStudioGD"])}
plot(sp_buffer, col = "#0365c0", border = 'white')




# ====================================================================
# =====Centroids =====================================================
# ====================================================================

sp_points_df_CBR_cent <- 
  sp::SpatialPointsDataFrame(
    coords = rgeos::gCentroid(sp_poly_cbr_qb, byid = TRUE),  
    data = sp_poly_cbr_qb@data, 
    proj4string = sp_poly_cbr_qb@proj4string)

if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
plot(sp_poly_cbr_qb, border = 'black')
plot(sp_points_df_CBR_cent, pch = 16, cex = 1.1,  col = 'red', add = TRUE)


# ====================================================================
# ====================================================================
# ===== Extent  ======================================================
# ====================================================================

# just the bbox ====
# this one's a projection so the units are in metres / kms...
sp_dissolve_proj@bbox

# this one's a GCS so units are degrees.
sp_poly_cbr_qb@bbox




















