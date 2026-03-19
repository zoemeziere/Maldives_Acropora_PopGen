library(dartR)
library(vcfR)
library(vegan)
library(genepop)
library(sp)
library(sf)

setwd("~/Documents/Maldives/Analyses/IBD")

#### Population level ####

# Ahya M1
pop_data <- read.csv("Maldives_M1_metadata.csv", stringsAsFactors = FALSE)
vcf_file <- "Maldives_M1_filtered_LD.vcf"

# Ahya M2
pop_data <- read.csv("Maldives_M2_metadata.csv", stringsAsFactors = FALSE)
vcf_file <- "Maldives_M2_filtered_LD.vcf"

vcf <- read.vcfR(vcf_file)
gl <- vcfR2genlight(vcf)
clean_ids <- sub("-.*", "", indNames(gl))
indNames(gl) <- clean_ids

matched_idx <- match(indNames(gl), pop_data$Extraction_sample_name_vcf)
if(any(is.na(matched_idx))) {
  stop("Some individuals in the VCF do not match metadata: ", 
       paste(indNames(gl)[is.na(matched_idx)], collapse=", "))
}
pop(gl) <- pop_data$WP[matched_idx]

pop_coords <- unique(pop_data[, c("WP", "LONG_WP", "LAT_WP")])
coords <- pop_coords[match(pop(gl), pop_coords$WP), c("LONG_WP", "LAT_WP")]
gl@other$latlon <- as.matrix(coords)
colnames(gl@other$latlon) <- c("lon", "lat")

saveRDS(gl, "M2_gl.rds")
  
ibd_res <- gl.ibd(
  x             = gl,
  distance      = "Fst",
  coordinates   = "latlon",
  Dgen_trans    = "Dgen/(1-Dgen)",
  Dgeo_trans    = "log(Dgeo)",
  permutations  = 999,
  plot.out      = TRUE)

#### Individual level ####
pop_data <- read.csv("Maldives_M1_metadata.csv", stringsAsFactors = FALSE)
genlight_mercator <- readRDS("M1_gl.rds")

# Reorder samples
idx <- match(indNames(genlight_mercator), pop_data$Extraction_sample_name_vcf)
pop_data <- pop_data[idx, ]

# Assign ind names
indNames(genlight_mercator) <- make.unique(pop_data$Extraction_sample_name_vcf)

# Attach coordinates and project to mercator
coords_ll <- pop_data[, c("LONG_WP", "LAT_WP")]
coords_sf <- st_as_sf(pop_data, coords = c("LONG_WP", "LAT_WP"), crs = 4326)
coords_merc <- st_transform(coords_sf, crs = 3395)
coords_mat  <- st_coordinates(coords_merc)

# Jittter coordinates
site_id <- pop_data$SamplingSite
set.seed(123)
coords_unique <- coords_mat
for (s in unique(site_id)) {
  idx <- which(site_id == s)  # individuals at this site
  if (length(idx) > 1) {
    # Add tiny jitter: N(0, 1) meters
    coords_unique[idx, ] <- coords_mat[idx, ] +
      matrix(rnorm(length(idx) * 2, mean = 0, sd = 1), ncol = 2)
  }
}
genlight_mercator@other$xy <- coords_unique

# Create coordinate-based names and pops
coord_names <- apply(coords_unique, 1, function(x) paste0(x[1], "_", x[2]))
indNames(genlight_mercator) <- coord_names
pop(genlight_mercator) <- indNames(genlight_mercator)

# Convert to genepop format
genepop_obj <- gl2genepop(genlight_mercator)
write.table(genepop_obj, file = "M1_genepop.txt", quote = FALSE, row.names = FALSE,col.names = FALSE)

# Run genepop
M2_genepop_run <- ibd(inputFile= "M1_genepop.txt", outputFile = "M1_genepop_out.txt", statistic='a', dataType='Diploid', settingsFile = '', geographicScale='2D', verbose = interactive())

# Plot
IBD_results <- read.table("M1_genepop3.txt.GRA")
IBD_results <- read.table("M2_genepop3.txt.GRA")

ggplot() + 
  geom_point(data=IBD_results, aes(x = V1, y = V2), size=2, shape=16, alpha=0.5) + 
  geom_smooth(data=IBD_results, aes(x = V1, y = V2), method = lm, colour="darkred", size=1) + 
  ylab("Genetic distance (Rousset's a)") +
  xlab("log-transformed geographic distance (m)") +
  theme_bw()
