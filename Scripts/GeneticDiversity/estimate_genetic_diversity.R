library(adegenet)    # for genlight handling
library(hierfstat)   # for He, FIS, Ar
library(dplyr)
library(sp)
library(sf)
library(gstat)
library(raster)
library(ggplot2)
library(dartR)
library(data.table)

setwd("~/Documents/Maldives/Analyses/Diversity")

# 1. pi using pixy

pi<-read.table("M1_pixy_pi.txt", header = TRUE) %>% filter(no_sites > 0)

genlight <- readRDS("../IBD/M1_gl.rds")
metadata <- read.csv("../IBD/Maldives_M1_metadata.csv", stringsAsFactors = FALSE)
pop(genlight) <- metadata$ATOLL 

pi_genomewide <- pi %>%
  group_by(pop) %>%
  summarise(
    total_diffs = sum(count_diffs, na.rm = TRUE),
    total_comparisons = sum(count_comparisons, na.rm = TRUE),
    genomewide_pi = total_diffs / total_comparisons)

# 2. Heterozygosity vcftools

m1_het <- fread("Maldives_M1_filtered.recode.het")
m1_het$sample_short <- sub("-.*$", "", m1_het$INDV)

metadata<- read.csv("../IBD/Maldives_M1_metadata.csv")
metadata$sample_short <- metadata$Extraction_sample_name_vcf
m1_het_meta <- m1_het %>% left_join(metadata, by = "sample_short")
m1_het_meta <- m1_het_meta %>% mutate(He_obs = 1 - (`O(HOM)`/N_SITES))  
m1_het_meta <- m1_het_meta %>% mutate(He_exp = 1 - (`E(HOM)`/N_SITES))

summary <- m1_het_meta %>%
  group_by(ATOLL) %>%
  summarise(
    n = n(),
    mean_He = mean(He_exp, na.rm = TRUE),
    sd_He = sd(He_exp, na.rm = TRUE),
    se_He = sd_He / sqrt(n),
    He_lower = mean_He - qt(0.975, df = n - 1) * se_He,
    He_upper = mean_He + qt(0.975, df = n - 1) * se_He,
    mean_Fis = mean(F, na.rm = TRUE),
    sd_Fis = sd(F, na.rm = TRUE),
    se_Fis = sd_Fis / sqrt(n),
    Fis_lower = mean_Fis - qt(0.975, df = n - 1) * se_Fis,
    Fis_upper = mean_Fis + qt(0.975, df = n - 1) * se_Fis)

# 3. Allelic richness using ADZE

genlight <- readRDS("../IBD/M1_gl.rds")
metadata<- read.csv("../IBD/Maldives_M1_metadata.csv")
pop(genlight) <- metadata$ATOLL

gl2structure(genlight, outfile = "Acropora_M1.stru", 
             outpath="/Users/zoemeziere/Documents/Maldives/Analyses/Diversity/ADZE", 
             addcolumns=pop(genlight))

# 4. Spatial extrapolation

# Convert metrics to SpatialPointsDataFrame
coords <- metrics_df[,c("LONG_WP","LAT_WP")]
sp_metrics <- SpatialPointsDataFrame(coords, metrics_df, proj4string = CRS("+proj=longlat +datum=WGS84"))

# Transform reef polygons and points to same CRS
reefs_sf <- st_read("reefextent.geojson")
reefs_sf <- st_transform(reefs_sf, crs = st_crs(sp_metrics))
reefs_sf <- st_make_valid(reefs_sf)
reefs_union <- st_union(reefs_sf)

# Create grid of points over reef bounding box
reef_bbox <- st_bbox(reefs_sf)
grid <- expand.grid(
  Lon = seq(reef_bbox["xmin"], reef_bbox["xmax"], length.out = 200),
  Lat = seq(reef_bbox["ymin"], reef_bbox["ymax"], length.out = 200))

grid_sf <- st_as_sf(grid, coords = c("Lon","Lat"), crs = st_crs(reefs_sf))
within_index <- lengths(st_within(grid_sf, reefs_union)) > 0
grid_reef <- grid_sf[within_index, ]
grid_sp <- as(grid_reef, "Spatial")

# Fit variogram and perform kriging for each metric
metrics_to_krige <- c("He","FIS","Ar")
krig_list <- list()

for(m in metrics_to_krige){
  
  # Remove sites with NA for this metric
  sp_sub <- sp_metrics[!is.na(sp_metrics[[m]]), ]
  
  # Empirical variogram
  vgm_emp <- variogram(as.formula(paste(m,"~1")), sp_sub)
  vgm_fit <- fit.variogram(vgm_emp, model=vgm("Sph"))
  
  # Ordinary kriging
  krig_res <- krige(as.formula(paste(m,"~1")), sp_sub, grid_sp, model = vgm_fit)
  
  # Save results
  krig_list[[m]] <- krig_res
}

krig_to_df <- function(krig){
  df <- as.data.frame(krig)
  df <- df[,c("coords.x1","coords.x2","var1.pred")]
  names(df) <- c("Lon","Lat","value")
  return(df)
}

for(m in metrics_to_krige){
  df_plot <- krig_to_df(krig_list[[m]])
  
  p <- ggplot() +
    geom_sf(data = reefs_sf, fill = "lightblue", color = "black") +
    geom_tile(data = df_plot, aes(x=Lon, y=Lat, fill=value), alpha=0.8) +
    geom_point(data = metrics_df, aes(x=LONG_WP, y=LAT_WP), color="red", size=2) +
    scale_fill_viridis_c(option = "plasma") +
    coord_sf(xlim = c(reef_bbox["xmin"], reef_bbox["xmax"]),
             ylim = c(reef_bbox["ymin"], reef_bbox["ymax"])) +
    labs(fill = m,
         title = paste("Spatial distribution of", m, "for species X")) +
    theme_bw() +
    theme(panel.grid = element_line(color="grey80"))
  print(p)
}
