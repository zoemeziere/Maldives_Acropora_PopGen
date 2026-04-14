library(ggspatial)
library(ggplot2)

# Functions
fit_gamma_pars = function(par, obs_quantiles, p_thresholds=c(0.025,0.5,0.975)) {
  p_quantiles = pgamma(obs_quantiles, shape = par[1], scale = par[2])
  statistic = max(abs(p_quantiles - p_thresholds))
  return(statistic)
} 
approx_gamma_pars<-function(par = NULL, obs_quantiles, p_thresholds=c(0.025,0.5,0.975)) {
  if (is.null(par)) {
    mean_obs <- mean(obs_quantiles)
    var_obs <- var(obs_quantiles)
    shape_init <- (mean_obs^2) / var_obs
    scale_init <- var_obs / mean_obs
    par <- c(shape_init, scale_init)
  }
  params<-optim(par, 
                fit_gamma_pars, 
                par,
                obs_quantiles,
                p_thresholds)$par
  return(params)
}
fit_lnorm_pars = function(par, obs_quantiles, p_thresholds=c(0.025,0.5,0.975)) {
  p_quantiles = plnorm(obs_quantiles, meanlog = par[1], sdlog = par[2])
  statistic = max(abs(p_quantiles - p_thresholds))
  return(statistic)
} 
approx_lnorm_pars<-function(par = c(mean(log(obs_quantiles)), sd(log(obs_quantiles))), obs_quantiles, p_thresholds=c(0.025,0.5,0.975)) {
  params<-optim(par, 
                fit_lnorm_pars, 
                par,
                obs_quantiles,
                p_thresholds)$par
  return(params)
}

# Effective population size data
Ne_estimates <- subset(read.csv("ne_m1_m2.csv", stringsAsFactors = FALSE), Population == "M2")
Ne<-Ne_estimates$Ne/0.83 
Ne_low<-Ne_estimates$Ne_low/0.83
Ne_high<-Ne_estimates$Ne_high/0.83
shape<-approx_gamma_pars(obs_quantiles=c(Ne_low, Ne, Ne_high))[1]
scale<-approx_gamma_pars(obs_quantiles=c(Ne_low, Ne, Ne_high))[2]
NE <-rgamma(1000, shape=shape, scale=scale)
hist(NE)

# Effective density  data
DE <- NE/Ne_estimates$Area
hist(DE)
quantile(DE, c(0.25, 0.5, 0.75))

# IBD regression slope data
#beta_quantiles <- c(2.8e-08, 5.28e-08, 10.7e-08) # M1
beta_quantiles <- c(1.2e-08 , 5.84e-08, 4.8e-08) # M2

n_sims <- 10000
beta_mean<-approx_lnorm_pars(obs_quantiles=beta_quantiles)[[1]]
beta_variance<-approx_lnorm_pars(obs_quantiles=beta_quantiles)[[2]]
beta<-rlnorm(n_sims, beta_mean, beta_variance)
hist(beta)
quantile(beta, c(0.25, 0.5, 0.75))

# Sigma and neighborhood size data
sigma<-sqrt(1/(4*DE*beta))
hist(sigma)
quantile(sigma, c(0.25, 0.5, 0.75))
Neighborhood<-1/beta
quantile(Neighborhood, c(0.25, 0.5, 0.75))

# Laplace kernel data
sigma_q <- quantile(sigma, probs=c(0.25, 0.5, 0.75))
distance <- seq(0, 100000, 10)

laplace_all <- sapply(sigma_q, function(s) {
  (1/(2*s)) * exp(-distance / s)
})

kernel_df <- data.frame(
  distance = distance,
  median = apply(laplace_all, 1, median),
  lower  = apply(laplace_all, 1, quantile, 0.025),
  upper  = apply(laplace_all, 1, quantile, 0.975))

probs <- c(0.5, 0.75, 0.95, 0.99)

radii_all <- sapply(probs, function(p) {
  -sigma_q * log(1 - p)
})
apply(radii_all, 2, quantile, c(0.25, 0.5, 0.75))
radii <- apply(radii_all, 2, median)

ggplot(kernel_df, aes(x = distance, y = median)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "lightgray", alpha = 0.7) +
  geom_line(color = "gray40") +
  geom_vline(xintercept = radii, linetype = "dashed", color = "darkorange", size = 1) +
  ylab("Dispersal probability density") +
  xlab("Dispersal distance (m)") +
  theme_bw()

# Plot map dispersal probability

library(sf)
library(ggplot2)
library(dplyr)

# point for reef
reef <- st_sfc(st_point(c(73.5, 1.75)), crs = 4326) |> st_sf(name="reef")

# radii in meters
#colors <- c("salmon", "lightsalmon", "#f4b480", "#f9d8b0")  # M1
colors <- c("goldenrod", "#f0c542", "lightgoldenrod", "#fff2b3")  # M2

# transform to projected CRS for meter buffering (e.g., UTM zone 42S ~ Maldives)
reef_proj <- st_transform(reef, 32742)  # EPSG:32742, UTM Zone 42S

# create circle polygons
circles <- lapply(seq_along(radii), function(i) {
  buf <- st_buffer(reef_proj, dist = radii[i])
  buf$prob <- paste0("circle_", i)
  buf$fill <- colors[i]
  buf
})
circles <- do.call(rbind, circles)

# back to lon/lat
circles <- st_transform(circles, 4326)

# plot
my_sf <- read_sf("/Users/zoemeziere/Documents/Maldives/Coordinates/Maldives-20251212092006/Reef-Extent/reefextent.geojson")

ggplot() + 
  geom_sf(data = circles, aes(fill = fill), color = NA, alpha = 0.5) +
  geom_sf(data = my_sf, color="grey30", fill = "grey60") +
  scale_fill_identity() +
  coord_sf(xlim = c(72.3, 74), ylim = c(0, 2.6)) +
  annotation_scale(location = "bl", width_hint = 0.5, text_cex = 1.1) +
  annotation_north_arrow(location = "bl", which_north = "true", pad_y = unit(1, "cm"),
                         style = north_arrow_fancy_orienteering(text_size = 12)) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        axis.text = element_text(size = 12),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "azure2", colour = NA))
