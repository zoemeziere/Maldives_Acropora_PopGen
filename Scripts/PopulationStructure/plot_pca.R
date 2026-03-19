library(tidyverse)
library(dartR)
library(data.table)

setwd("~/Documents/Maldives/Analyses/PCA")

prefix <- "Maldives_M1_filtered_LD"
prefix_sum <- "Maldives_M1_filtered"

pca <- fread(paste0(prefix, ".eigenvec"))
eigenval <- fread(paste0(prefix, ".eigenval"))
metadata <- read.csv("/Users/zoemeziere/Documents/Maldives/Metadata/Metadata_SpeciesGroups.csv")

ind_miss<- fread(paste0(prefix_sum, ".imiss"))
ind_het<- fread(paste0(prefix_sum, ".het"))

pca <- pca[,-1]
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)
ggplot(pve, aes(PC, V1)) + geom_bar(stat = "identity") +
  ylab("Percentage variance explained") + theme_light()

pca$sample_short <- sub("-.*$", "", pca$ind)
metadata$sample_short <- metadata$Extraction_sample_name_vcf

ind_miss$sample_short <- sub("-.*$", "", ind_miss$INDV)
ind_het$sample_short <- sub("-.*$", "", ind_het$INDV)

pca_meta <- pca %>% 
  left_join(metadata, by = "sample_short") %>% 
  left_join(ind_miss, by = "sample_short") %>% 
  left_join(ind_het, by = "sample_short")

pca_meta$Ho <- 1 - (pca_meta$`O(HOM)` / pca_meta$N_SITES)

# Plot PCA

species_cols <- c(
  "Amil" = "mediumorchid",
  "Aken" = "maroon",
  "Ahya_group1" = "cyan3",
  "Ahya_group2" = "cadetblue",
  "Ahya_group3" = "steelblue1",
  "Ahya_group4" = "steelblue3",
  "Ahya_M1" = "lightsalmon",
  "Ahya_M2" = "lightgoldenrod")

atoll_cols <- c(
  "THAA" = "darkolivegreen1",
  "LAAMU" = "darkolivegreen3",
  "HUVADHOO" = "darkolivegreen")

ggplot(pca_meta, aes(PC1, PC2, fill=pca_meta$F)) + 
  #scale_fill_manual(values = atoll_cols) +
  geom_point(shape=21, size=6) +
  coord_equal() + theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10)) +
  xlab(paste0("PC1 (", signif(pve$V1[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$V1[2], 3), "%)")) +
  theme(axis.text = element_text(size = 14)) +
  scale_x_continuous(expand = expansion(mult = 0.6))

# Assign groups
pca_meta$SpeciesGroup <- pca_meta$SPECIES
pca_meta$SpeciesGroup[pca_meta$PC2 < 0 & pca_meta$PC1 < 0]  <- "Ahya_M1"
pca_meta$SpeciesGroup[pca_meta$PC2 < 0 & pca_meta$PC1 >= 0] <- "Ahya_M2"

M1_samples <- pca_meta$ind[pca_meta$SpeciesGroup=="Ahya_M1"]
write.table(M1_samples, 
            file = "M1_samples.txt", 
            quote = FALSE, 
            row.names = FALSE, 
            col.names = FALSE)

M2_samples <- pca_meta$ind[pca_meta$SpeciesGroup=="Ahya_M2"]
write.table(M2_samples, 
            file = "M2_samples.txt", 
            quote = FALSE, 
            row.names = FALSE, 
            col.names = FALSE)

# Figuring out odd substructure
set.seed(42)
kmeans_res <- kmeans(pca_meta[, c("PC1","PC2")], centers=2)
pca_meta$sex_guess <- factor(kmeans_res$cluster, labels=c("Group1","Group2"))

ggplot(pca_meta, aes(PC1, PC2, color=sex_guess)) +
  geom_point(size=4) + theme_bw() +
  labs(x=paste0("PC1 (", signif(pve$V1[1],3), "%)"),
       y=paste0("PC2 (", signif(pve$V1[2],3), "%)"))
