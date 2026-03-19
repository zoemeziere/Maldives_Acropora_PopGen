library(sf)
library(ggplot2)
library(ggspatial)
library(dplyr)
library(tidyr)
library(scatterpie)

# Coral Allen Atlas
my_sf <- read_sf("/Users/zoemeziere/Documents/Maldives/Coordinates/Maldives-20251212092006/Reef-Extent/reefextent.geojson")

metadata <- read.csv("/Users/zoemeziere/Documents/Maldives/Metadata/Metadata_SpeciesGroups.csv")

# Summarise samples per site
site_species <- metadata %>%
  group_by(SamplingSite) %>%
  count(SpeciesGroup) %>%
  pivot_wider(names_from = SpeciesGroup, values_from = n, values_fill = 0) %>%
  left_join(
    metadata %>% 
      select(SamplingSite, LONG_WP, LAT_WP) %>% 
      distinct(),
    by = "SamplingSite"
  ) %>%
  mutate(Total = Ahya_M1 + Ahya_M2)

# Scale pie chart radii
scale_factor <- 0.018

site_species <- site_species %>%
  mutate(
    r_scaled = sqrt(Total) * scale_factor,
    X_pie = LONG_WP,
    Y_pie = LAT_WP
  )

# Create data-driven legend sizes
legend_sizes <- pretty(range(site_species$Total), n = 3)

# Plot
ggplot() +
  
  # Reef polygons
  geom_sf(data = my_sf, color = "grey30", fill = "grey60") +
  
  # Pie charts
  geom_scatterpie(
    aes(x = X_pie, y = Y_pie, r = r_scaled),
    data = site_species,
    cols = c("Ahya_M1", "Ahya_M2")
  ) +
  
  # Pie colours
  scale_fill_manual(
    values = c("Ahya_M1" = "lightsalmon",
               "Ahya_M2" = "lightgoldenrod"),
    name = "Species group"
  ) +
  
  # Bubble size legend
  geom_scatterpie_legend(
    sqrt(legend_sizes) * scale_factor,
    x = 73.6,   # adjust if needed
    y = 0.35,   # adjust if needed
    n = length(legend_sizes),
    labeller = function(x) round((x / scale_factor)^2)
  ) +
  
  # Map extent
  coord_sf(xlim = c(72.5, 73.8), ylim = c(0, 2.55)) +
  
  # Map annotations
  annotation_scale(location = "bl", width_hint = 0.4, text_cex = 1) +
  annotation_north_arrow(
    location = "bl",
    which_north = "true",
    pad_y = unit(1, "cm"),
    style = north_arrow_fancy_orienteering(text_size = 12)
  ) +
  
  # Theme
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "azure2", colour = NA),
    axis.text = element_text(size = 12)
  )
