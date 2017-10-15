
# from hier https://www.data.act.gov.au/Education/Schools-in-the-ACT/9v9g-n5ht
df_schools <- read.csv("input_data/Schools_in_the_ACT.csv")

df_schools <- df_schools %>% filter(nchar(lok) != 0)
df_schools$pk <- 1:nrow(df_schools)


vct_lat <- stringr::str_extract(df_schools$lok, "-[0-9]{2}\\.[0-9]+") %>% as.numeric()
vct_long <- stringr::str_extract(df_schools$lok, " [0-9]{3}\\.[0-9]+") %>% as.numeric()

df_schools$lat <- vct_lat
df_schools$long <- vct_long
df_schools$lok <- NULL


df_schools %>% arrange(lat)

df_schools <- df_schools %>% filter(!pk %in% c(108, 55))

sp::coordinates(df_schools) <- ~long+lat

proj4string(df_schools) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")

# change name
sp_act_schools <- df_schools 
rm(df_schools)

if (length(dev.list()) > 0) {dev.off(dev.list()["RStudioGD"])}
plot(sp_act_schools)

