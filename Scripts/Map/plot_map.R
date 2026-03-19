library(rnaturalearth)
library(sf)
library(ggplot2)
library(ggspatial)
library(rjson)

# World
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
maldives_box <- st_as_sfc(
  st_bbox(c(xmin = 72, xmax = 74, ymin = -2, ymax = 8), crs = 4326))

# Plot world map
ggplot() +
  geom_sf(data = world, fill = "burlywood", color = "burlywood") +
  geom_sf(data = maldives_box, color = "maroon", fill = NA, size = 0.5) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        axis.text = element_text(size = 12),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "azure2", colour = NA)) +
  coord_sf(
    xlim = c(30, 120),
    ylim = c(-30, 25)) 

# Coral Allen Atlas
my_sf <- read_sf("/Users/zoemeziere/Documents/Maldives/Coordinates/Maldives-20251212092006/Reef-Extent/reefextent.geojson")

# Coordinates sample sites
coordinates<-read.csv("/Users/zoemeziere/Documents/Maldives/Coordinates/maldives_gps.csv")
sites_sp = st_as_sf(coordinates, coords = c("X", "Y"))
st_crs(sites_sp) <- 4326
sites_sp <- st_transform(sites_sp, crs = st_crs(my_sf))

# Plot map Maldives
ggplot() + 
  geom_sf(data= my_sf, color="grey30", fill = "grey60") +
  coord_sf(xlim = c(72, 74.5), ylim = c(-1.5, 7.5)) +
  annotation_scale(location = "bl", width_hint = 0.5, text_cex = 1.1) +
  annotation_north_arrow(location = "bl", which_north = "true", pad_y = unit(1, "cm"),
                         style = north_arrow_fancy_orienteering(text_size = 12)) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        axis.text = element_text(size = 12),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "azure2", colour = NA))

# Plot map sampling sites
ggplot() + 
  geom_sf(data= my_sf, color="grey30", fill = "grey60") +
  geom_sf(data= sites_sp, shape = 21, fill = "coral2",colour = "black", size = 3) +
  coord_sf(xlim = c(72.3, 74), ylim = c(0, 2.6)) +
  annotation_scale(location = "bl", width_hint = 0.5, text_cex = 1.1) +
  annotation_north_arrow(location = "bl", which_north = "true", pad_y = unit(1, "cm"),
                         style = north_arrow_fancy_orienteering(text_size = 12)) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        axis.text = element_text(size = 12),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "azure2", colour = NA))
