library(data.table)

fn_calc_distance <- function(lcl_df) {
  # fn calculates distance from ordered x, y
  # convert to 2 column matrix
  mat_xy <- lcl_df[, c("x", "y")] %>% data.matrix()
  # calculate a matrix of distances....
  mat_distance <- sp::spDists(mat_xy, longlat = TRUE)
  # matrix is square.  We need the length of a side
  mat_length = mat_distance %>% nrow()
  # set up vectors of rows
  vct_row <- 1:(mat_length - 1); vct_col <- 2:mat_length
  # this piece of poetry extracts a vector of distances: n, n+1
  vct_dist <- mapply(function(r, c) mat_distance[r, c], vct_row, vct_col)
  # add back to the data frame...with blank for initial value
  lcl_df$dist <- c(NA, vct_dist)
  print("just did an iteration")
  # send back to caller
  return(lcl_df)
}


# ===== load in the data ==================

# get tracks data -- 54168 obs
sp_pts_esa <- rgdal::readOGR(dsn = "input_data/ESA_201608 _201609", 
                             layer = "esa")
# Reproject the sucker to WGS 84
sp_pts_esa_wgs84  <- 
  sp::spTransform(sp_pts_esa, 
                  CRS = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))

# add a primary key
sp_pts_esa_wgs84@data$pk <- 1:nrow(sp_pts_esa_wgs84@data)

# ==== data prep ==============
# detach the data frame
df_data <- sp_pts_esa_wgs84@data

# filter to include only fire -- 48163
df_data <- df_data[df_data$servicecod == "FaRS" & 
                     is.na(df_data$servicecod) == FALSE ,]

# convert time_from and time_to to POSIXct variables
df_data$time_to <- as.POSIXct(df_data$time_to, format = "%Y%m%d%H%M%S")
df_data$time_from <- as.POSIXct(df_data$time_from, format = "%Y%m%d%H%M%S")

# drop output_fi
df_data$output_fil <- NULL
df_data$servicecod <- NULL


# change column order...
df_data <- df_data %>% 
  select(pk, callsign, vehicle_ty, x, y, time_to, time_from) %>% 
  arrange(callsign, time_from )


# add time differential column
df_data$diff_time <- difftime(df_data$time_to, df_data$time_from, units = "secs")

# ===== data processing  =========================

# define a function to split the data frame into groups
fn_split <- function(lcl_df, col_name) lcl_df %>% split(., .[,col_name])

# split the data.frame according to callsign   
lst_groups <- df_data %>% fn_split('callsign')

# now we have a list of data frames process each separately
lst_groups_new <- lapply(lst_groups, function(x) fn_calc_distance(x))

# put humpty dumpty together again
df_data_assem <- data.table::rbindlist(lst_groups_new)

# filter things in where the distance travelled was 0
df_data_filt <- df_data_assem %>% filter(dist == 0)

# now filter were there are distinct lats and longs
df_data_filt <- df_data_filt %>% distinct(x, y, .keep_all = TRUE)


vct_valid = sp_pts_esa_wgs84@data$pk %in% df_data_filt$pk
df_valid = data.frame(pk = sp_pts_esa_wgs84@data$pk, lgl_valid = vct_valid)

sp_pts_esa_wgs84@data <- sp_pts_esa_wgs84@data %>% 
  inner_join(df_valid, by = c("pk" = "pk"))


sp_pts_esa_wgs84_clean <- sp_pts_esa_wgs84[sp_pts_esa_wgs84@data$lgl_valid == TRUE, ]