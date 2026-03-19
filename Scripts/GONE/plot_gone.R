library(ggplot2)
library(readr)
library(tidyverse)
library(patchwork)
setwd("~/Documents/Maldives/Analyses/GONE")

# Read replicate files 
ne_files <- list.files(pattern = "gone_rep.*\\.vcf_GONE2_Ne$")

ne <- map_dfr(ne_files, function(f) {read_tsv(f, show_col_types = FALSE) %>%
    mutate(replicate = f)})

# Read ne data for each taxon
ne_m1 <- readRDS("ne_m1.rds") %>% mutate(Species = "M1", Years_ago = Generation * 4)
ne_m2 <- readRDS("ne_m2.rds") %>% mutate(Species = "M2", Years_ago = Generation * 4)
ne_all <- bind_rows(ne_m1, ne_m2)

# Read sea level data
present_year <- 2023
seaLevel <- read.csv("ma_raw.csv") %>% 
  transmute(Years_ago = present_year - AgeCoreCE, RSL_m= ElevationHLC, age_err=AgeError / 2) 

# Summuarise across replicates
ne_ci <- ne_all %>%
  group_by(Species, Generation) %>%
  summarise(
    Ne_median = median(Ne_diploids, na.rm = TRUE),
    Ne_low    = quantile(Ne_diploids, 0.05, na.rm = TRUE),
    Ne_high   = quantile(Ne_diploids, 0.95, na.rm = TRUE),
    .groups = "drop") %>%
  mutate(Years_ago = Generation * 4)

# Same time span
xlims <- range(ne_ci$Years_ago, na.rm = TRUE)
seaLevel <- seaLevel %>% filter(Years_ago >= min(xlims), Years_ago <= max(xlims))
shared_x <- scale_x_continuous(limits = xlims, expand = c(0, 0))

# Plot both species together
ggplot(ne_ci, aes(x = Years_ago, colour = Species, fill = Species)) +
  geom_ribbon(aes(ymin = Ne_low, ymax = Ne_high), alpha = 0.25, colour = NA) +
  geom_line(aes(y = Ne_median), linewidth = 1) +
  scale_y_log10() +
  xlim(shared_x$limits) +
  labs(x = "Years before present", y = "Effective population size (Ne)") +
  theme_bw(base_size = 14) +
  scale_colour_manual(values = c("M1" = "lightsalmon", "M2" = "lightgoldenrod")) +
  scale_fill_manual(values = c("M1" = "lightsalmon", "M2" = "lightgoldenrod"))

# BY ATOLLS
ne_m1_laa<-read_tsv("Maldives_M1_LAAMU.vcf_GONE2_Ne") %>% mutate(Atoll = "Laamu", Years_ago = Generation * 4)
ne_m1_tha<-read_tsv("Maldives_M1_THAA.vcf_GONE2_Ne") %>% mutate(Atoll = "Thaa", Years_ago = Generation * 4)
ne_m1_huv<-read_tsv("Maldives_M1_HUVADHOO.vcf_GONE2_Ne") %>% mutate(Atoll = "Huvadhoo", Years_ago = Generation * 4)

ne_m2_laa<-read_tsv("Maldives_M2_LAAMU.vcf_GONE2_Ne") %>% mutate(Atoll = "Laamu", Years_ago = Generation * 4)
ne_m2_tha<-read_tsv("Maldives_M2_THAA.vcf_GONE2_Ne") %>% mutate(Atoll = "Thaa", Years_ago = Generation * 4)
ne_m2_huv<-read_tsv("Maldives_M2_HUVADHOO.vcf_GONE2_Ne") %>% mutate(Atoll = "Huvadhoo", Years_ago = Generation * 4)

ne_m1_all<- bind_rows(ne_m1_laa, ne_m1_tha, ne_m1_huv)
ne_m2_all<- bind_rows(ne_m2_laa, ne_m2_tha, ne_m2_huv)

ymin <- min(c(ne_m1_all$Ne_diploids, ne_m2_all$Ne_diploids), na.rm = TRUE)
ymax <- max(c(ne_m1_all$Ne_diploids, ne_m2_all$Ne_diploids), na.rm = TRUE)

gone_m1 <- ggplot(ne_m1_all, aes(x = Years_ago, colour = Atoll)) +
  geom_line(aes(y = Ne_diploids), linewidth = 1) +
  labs(x = "Years before present", y = "Effective population size (Ne)") +
  theme_bw(base_size = 14) +
  scale_colour_manual(values = c("Thaa" = "darkolivegreen1", 
                                 "Laamu" = "darkolivegreen3", 
                                 "Huvadhoo"="darkolivegreen")) +
  coord_cartesian(ylim = c(ymin, ymax)) 

gone_m2 <- ggplot(ne_m2_all, aes(x = Years_ago, colour = Atoll)) +
  geom_line(aes(y = Ne_diploids), linewidth = 1) +
  labs(x = "Years before present", y = "Effective population size (Ne)") +
  theme_bw(base_size = 14) +
  scale_colour_manual(values = c("Thaa" = "darkolivegreen1", 
                                 "Laamu" = "darkolivegreen3", 
                                 "Huvadhoo"="darkolivegreen")) +
  coord_cartesian(ylim = c(ymin, ymax))  

gone_m1 | gone_m2
