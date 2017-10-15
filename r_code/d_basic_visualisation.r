# ====================================================================
# ====================================================================
#  Create the Choropleth =============================================
# ====================================================================
# ====================================================================



# ====================================================================
# ==== Tweek factor to include no data (ie. Q6) and the lake (qlake)
# ====================================================================
# Reproject the sucker to WGS 84
sp_poly_df_CBR_SA2  <- 
  sp::spTransform(sp_poly_df_CBR_SA2, 
                  CRS = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))


# convert from factor to character
sp_poly_df_CBR_SA2@data$p_quant <- as.character(sp_poly_df_CBR_SA2@data$p_quant)

# add in a no data quantile
sp_poly_df_CBR_SA2@data[is.na(sp_poly_df_CBR_SA2@data$pc), "p_quant"] <- "q6"

# create a lake quantile
sp_poly_df_CBR_SA2@data[sp_poly_df_CBR_SA2@data$SA2_MAIN ==  801061066, 
                        "p_quant"] <- "qlake" 

# now convert the character into an ordered factor...
sp_poly_df_CBR_SA2@data$p_quant <- factor(sp_poly_df_CBR_SA2@data$p_quant, 
      levels = c("q1", "q2", "q3", "q4", "q5", "q6", "qlake"), ordered = TRUE)

# ====================================================================
# === Prep the data ==================================================
# ====================================================================


# fortify converts into a data frame with one row for each pair of coodinates.
df_cbr_sa2_f <- ggplot2::fortify(model = sp_poly_df_CBR_SA2, region = "SA2_MAIN")

# need to join our data back to this fortify data frame.......
df_cbr_sa2_data <- df_cbr_sa2_f %>% 
  dplyr::inner_join(sp_poly_df_CBR_SA2@data, by = c("id" = "SA2_MAIN"))

vct_colors <- c("#ccece6","#99d8c9","#66c2a4","#2ca25f",
                "#006d2c", "#969696", "#9ecae1")


# ====================================================================
# === GGplot =========================================================
# ====================================================================


p <- ggplot(df_cbr_sa2_data, aes(x = long, y = lat, group = group, fill = p_quant))
p <- p + geom_polygon()
p <- p + coord_equal()
p <- p + scale_fill_manual(values = vct_colors )


p <- p + theme(axis.text.x = element_blank(), 
               axis.text.y = element_blank(),
               axis.ticks = element_blank(),
               axis.title.x = element_blank(),
               axis.title.y = element_blank())

p <- p + theme(panel.grid.minor.y = element_blank())
p <- p + theme(panel.grid.minor.x = element_blank())
p <- p + theme(panel.grid.major.x = element_blank())
p <- p + theme(panel.border = element_blank())
p <- p + theme(panel.background = element_blank())

p <- p + geom_path(data = df_cbr_sa2_data,  
                   aes(x = long, y = lat, group = group),
                   colour="black", size = 0.1, alpha = 1.0)

p <- p + theme(legend.position="none")

p

# ====================================================================
# === GGMap (toner) ==================================================
# ====================================================================



bb <- sp::bbox(sp_poly_df_CBR_SA2)

# fiddle with bounding box....must be a nicer way to do this
bb[1, ] <- (bb[1, ] - mean(bb[1, ])) * 1.20 + mean(bb[1, ])
bb[2, ] <- (bb[2, ] - mean(bb[2, ])) * 1.20 + mean(bb[2, ])

map_cbr <- ggmap(get_map(location = bb, source = "stamen", 
                         maptype = "toner", crop = T, zoom = 12))


if (length(dev.list()) > 0) {dev.off(dev.list()["RStudioGD"])}

p2 <- map_cbr
p2 <- p2 + geom_polygon(data = df_cbr_sa2_data,  
                        aes(x = long, y = lat, group = group,  fill = p_quant),
                        alpha = 0.9)
p2 <- p2 + coord_equal()
p2 <- p2 + scale_fill_manual(values = vct_colors )
p2 <- p2 + theme(axis.text.x = element_blank())
p2 <- p2 + theme(axis.text.y = element_blank())
p2 <- p2 + theme(axis.ticks = element_blank())
p2 <- p2 + theme(axis.title.x = element_blank())
p2 <- p2 + theme(axis.title.y = element_blank())
p2 <- p2 + theme(panel.grid.minor.y = element_blank())
p2 <- p2 + theme(panel.grid.minor.x = element_blank())
p2 <- p2 + theme(panel.grid.major.x = element_blank())
p2 <- p2 + theme(panel.border = element_blank())
p2 <- p2 + theme(panel.background = element_blank())
p2 <- p2 + geom_path(data = df_cbr_sa2_data,  aes(x = long, y = lat, group = group),
                     colour="black", size = 0.1, alpha = 1.0)
p2 <- p2 + theme(legend.position = "none")
p2


# ====================================================================
# === GGMap (google) =================================================
# ====================================================================

# https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf
# http://stat405.had.co.nz/ggmap.pdf

bb <- sp::bbox(sp_poly_df_CBR_SA2)
#bb[1, ] <- (bb[1, ] - mean(bb[1, ])) * 1.05 + mean(bb[1, ])
#bb[2, ] <- (bb[2, ] - mean(bb[2, ])) * 1.05 + mean(bb[2, ])

map_cbr <- ggmap(
  get_map(location = c(lon = mean(bb[1,]), 
                       lat = mean(bb[2,])), 
          source = "google", 
          maptype = "satellite", crop = T, zoom = 10
  )
)

if (length(dev.list()) > 0) {dev.off(dev.list()["RStudioGD"])}

p2 <- map_cbr
p2 <- p2 + geom_polygon(data = df_cbr_sa2_data,  
                        aes(x = long, y = lat, group = group,  fill = p_quant),
                        alpha = 0.8)
p2 <- p2 + coord_equal()
p2 <- p2 + scale_fill_manual(values = vct_colors )
p2 <- p2 + theme(axis.text.x = element_blank())
p2 <- p2 + theme(axis.text.y = element_blank())
p2 <- p2 + theme(axis.ticks = element_blank())
p2 <- p2 + theme(axis.title.x = element_blank())
p2 <- p2 + theme(axis.title.y = element_blank())
p2 <- p2 + theme(panel.grid.minor.y = element_blank())
p2 <- p2 + theme(panel.grid.minor.x = element_blank())
p2 <- p2 + theme(panel.grid.major.x = element_blank())
p2 <- p2 + theme(panel.border = element_blank())
p2 <- p2 + theme(panel.background = element_blank())
p2 <- p2 + geom_path(data = df_cbr_sa2_data,  aes(x = long, y = lat, group = group),
                     colour="black", size = 0.1, alpha = 1.0)
p2 <- p2 + theme(legend.position = "none")

p2








