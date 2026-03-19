setwd("~/Documents/Maldives/Analyses/SMCpp")

# Read SMC file
gen <- 4

SMC_M1 <- read.csv("smc_M1.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "M1")
SMC_M2 <- read.csv("smc_M2.csv") %>%mutate(x_years = x * gen) %>% mutate(species = "M2")

SMC_M1_Thaa<-read.csv("smc_M1_Thaa.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "Thaa")
SMC_M1_Laamu<-read.csv("smc_M1_Laamu.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "Laamu")
SMC_M1_Huva<-read.csv("smc_M1_Huva.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "Huvadhoo")
SMC_M1_all <- rbind(SMC_M1_Thaa, SMC_M1_Laamu, SMC_M1_Huva)

SMC_M2_Thaa<-read.csv("smc_M2_Thaa.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "Thaa")
SMC_M2_Laamu<-read.csv("smc_M2_Laamu.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "Laamu")
SMC_M2_Huva<-read.csv("smc_M2_Huva.csv") %>% mutate(x_years = x * gen) %>% mutate(species = "Huvadhoo")
SMC_M2_all <- rbind(SMC_M2_Laamu, SMC_M2_Huva)

plot_smc_m1<- ggplot(SMC_M1_all, aes(x = x_years, y = y, color = species)) +
  geom_line(data = subset(SMC_M1_all, plot_type == "path"), aes(group = interaction(label, plot_num), colour = label), linewidth = 1) +
  scale_x_log10(breaks=c(1e+2,1e+3,1e+4,1e+5,1e+6), 
                labels=c("100ya","1kya","10kya","100kya", "1mya"),
                limits=c(100,1.3e+6))+
  #scale_y_log10() +
  #scale_colour_manual(values = c("M1" = "lightsalmon", "M2" = "lightgoldenrod")) +
  scale_colour_manual(values = c("Thaa" = "darkolivegreen1", "Laamu" = "darkolivegreen3", "Huvadhoo"="darkolivegreen")) +
  labs(x="Years before present", y="Effective population size") +
  theme_bw(base_size = 12) 

plot_smc_m2<- ggplot(SMC_M2_all, aes(x = x_years, y = y, color = species)) +
  geom_line(data = subset(SMC_M2_all, plot_type == "path"), aes(group = interaction(label, plot_num), colour = label), linewidth = 1) +
  scale_x_log10(breaks=c(1e+2,1e+3,1e+4,1e+5,1e+6), 
                labels=c("100ya","1kya","10kya","100kya", "1mya"),
                limits=c(100,1.3e+6))+
  #scale_y_log10() +
  #scale_colour_manual(values = c("M1" = "lightsalmon", "M2" = "lightgoldenrod")) +
  scale_colour_manual(values = c("Thaa" = "darkolivegreen1", "Laamu" = "darkolivegreen3", "Huvadhoo"="darkolivegreen")) +
  labs(x="Years before present", y="Effective population size") +
  theme_bw(base_size = 12) 

plot_smc_m1 | plot_smc_m2
