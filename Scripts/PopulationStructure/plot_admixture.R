library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)

metadata <- read.csv("/Users/zoemeziere/Documents/Maldives/Metadata/Metadata_SpeciesGroups.csv")
prefix <- "subset5_Maldives_all_filtered_LD"

qfiles <- list.files(pattern = paste0("^", prefix, "\\.[0-9]+\\.Q$"))
getK <- function(x) as.numeric(str_extract(x, "(?<=\\.)[0-9]+(?=\\.Q$)"))
fam <- read.table(paste0(prefix, ".fam"), header = FALSE)
samples <- fam$V2

# Function to read admixture Q files
readQ <- function(qfile) {
  Kval <- getK(qfile)
  qdat <- read.table(qfile, header = FALSE)
  colnames(qdat) <- paste0("Cluster_", 1:Kval)
  qdat$Sample <- samples
  qdat$K <- Kval
  qdat
}

admix_df <- bind_rows(lapply(qfiles, readQ))

# Convert to long format
admix_long <- admix_df %>%
  pivot_longer(
    cols = starts_with("Cluster_"),
    names_to = "Cluster",
    values_to = "Ancestry")

# Make K an ordered factor (2,3,4,...12)
admix_long$K <- factor(admix_long$K, levels = sort(unique(admix_long$K)))

# Horizontal facet plot
ggplot(admix_long, aes(x = Sample, y = Ancestry, fill = Cluster)) +
  geom_bar(stat = "identity", width = 1) +
  facet_grid(K ~ ., switch = "y") +      # horizontal facets
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 6),
    panel.spacing = unit(0.3, "lines"),
    strip.text.y.left = element_text(angle = 0),
    panel.grid.major = element_blank()) +
  labs(x = "Individuals", y = "Ancestry proportion") +
  scale_fill_brewer(palette = "Set3")

# Plot in order of species

# Remove everything from first "-" onward
samples_short <- sub("-.*$", "", samples)

# Add shortened names to admix dataframe
admix_df$Sample_short <- samples_short

# Convert to long format

admix_long <- admix_df %>%
  pivot_longer(
    cols = starts_with("Cluster_"),
    names_to = "Cluster",
    values_to = "Ancestry")

# Order individuals by SpeciesGroup

metadata_ordered <- metadata %>%
  arrange(SpeciesGroup)

ordered_samples <- metadata_ordered$Extraction_sample_name_vcf

# Apply ordering
admix_long$Sample_short <- factor(
  admix_long$Sample_short,
  levels = ordered_samples)

# Order K values

admix_long$K <- factor(
  admix_long$K,
  levels = sort(unique(admix_long$K)))

# Plot

ggplot(admix_long,
       aes(x = Sample_short, y = Ancestry, fill = Cluster)) +
  geom_bar(stat = "identity", width = 1) +
  facet_grid(K ~ ., switch = "y") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1,
                               vjust = 0.5, size = 6),
    panel.spacing = unit(0.3, "lines"),
    strip.text.y.left = element_text(angle = 0),
    panel.grid.major = element_blank()
  ) +
  labs(x = "Individuals", y = "Ancestry proportion") +
  scale_fill_brewer(palette = "Set3")
