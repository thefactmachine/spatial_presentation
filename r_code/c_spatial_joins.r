

# ========================================================
# =====Intersecting Polygons =============================
# ========================================================

# previously data / geometries loaded from disk....
# see a_loading_data.r

# logical vector of all the SA2 polygons within NSW
# length(vct_contained_in_CBR) == nrow(sp_poly_df_NSW_SA2)
vct_contained_in_CBR <- rgeos::gContains(sp_poly_df_CBR_dissolve, 
                            sp_poly_df_NSW_SA2, byid=TRUE) %>% .[, 1] 

# 3) Subset using a logical vector
sp_poly_df_CBR_SA2 <- sp_poly_df_NSW_SA2[vct_contained_in_CBR,]

# 4) Plot
if (length(dev.list()) > 0) dev.off(dev.list()["RStudioGD"])
plot(sp_poly_df_CBR_SA2, lty = 1, lwd = 1, border = 'black',  col = '#c2daf0')


# ========================================================
# ===== Points with polygons =============================
# ========================================================

source(file.path("r_code","process_schools_data.r", fsep = .Platform$file.sep))

# Reproject the sucker to WGS 84
sp_poly_df_act_wgs84  <- 
  sp::spTransform(sp_poly_df_act, 
                  CRS = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))

# get a data.frame of which school is in which polygon
df_within <- sp::over(sp_act_schools, sp_poly_df_act_wgs84)

# n.a === > FALSE
vct_within <- ifelse(is.na(df_within$pk), FALSE, TRUE)

#  get rid of points data (i.e. schools which are not in the 8 ACT polygons)
sp_act_schools <- sp_act_schools[vct_within, ]


# Plot things.....
if (length(dev.list()) > 0) {dev.off(dev.list()["RStudioGD"])}
plot(sp_poly_df_act_wgs84)
plot(sp_act_schools, pch = 16, cex = 0.7,  col = rgb(0,0,1, alpha = 0.8) ,  add = TRUE)


# make a short tabular report.....
df_count <- sp::over(sp_act_schools, sp_poly_df_act_wgs84)

df_summary <- df_count %>% dplyr::group_by(name) %>% 
  summarise(count = n()) %>% arrange(desc(count)) %>% as.data.frame()

df_summary

# ========================================================
# ===== Geometry with Data== =============================
# ========================================================

# previously data / geometries loaded from disk....
# see a_loading_data.r

# subset by Canberra polygons 2205 ==> 111 rows
df_sa2_data <- df_sa2_data %>% filter(as.character(.$region_id) %in% 
                                        sp_poly_df_CBR_SA2@data$SA2_MAIN) 

# prep work for creating the quantiles
int_num_quantiles = 5
vct_probs <- seq(from = 0, to = 1, length.out = int_num_quantiles + 1)
vct_labels <- paste0('q', 1:int_num_quantiles)

# 1) calculate the cut off points 
q <- quantile(df_sa2_data$pc, probs = vct_probs,na.rm = TRUE)

# 2) now apply the cut points to the data (result is ordered factor)
df_sa2_data$p_quant <- cut(df_sa2_data$pc, q, 
                           include.lowest = TRUE, labels = vct_labels)

# change the data to character for faciliate the join:
df_sa2_data$region_id  <- df_sa2_data$region_id %>% as.character()

# join the stuff back to our spatial polygon -- select only key fields
sp_poly_df_CBR_SA2@data <- sp_poly_df_CBR_SA2@data %>% 
  dplyr::inner_join(df_sa2_data, by = c("SA2_MAIN" = "region_id")) %>%
  select(SA2_MAIN, SA2_NAME, AREA_SQKM, tp_2006, tp_2011, pc, p_quant)

# list the first few rows....
sp_poly_df_CBR_SA2@data %>% head()







