# Reproducible Research Fundamentals 
# 03. Data Analysis

# Libraries
# library(haven)
# library(dplyr)
# library(modelsummary)
# library(stargazer)
# library(ggplot2)
# library(tidyr)

# Load data 
#household level data
data_path <- "ADD-YOUR-PATH"
hh_data   <- read_dta(file.path(data_path, "Final/TZA_CCT_analysis.dta"))

# secondary data 
secondary_data <- read_dta(file.path(data_path, "Final/TZA_amenity_analysis.dta")) %>%
    mutate(district = as_factor(district))

# Summary statistics ----

# Create summary statistics by district and export to CSV
summary_table <- datasummary(
    ...... ~ ...... * (Mean + SD), 
    data = hh_data,
    title = "Summary Statistics by District",
    output = file.path("Outputs", "summary_table.csv")  # Change to CSV
)


# Balance table ----
balance_table <- datasummary_balance(
    ...... ~ ......,
    data = hh_data,
    stars = TRUE,
    title = "Balance by Treatment Status",
    note = "Includes HHS with observations for baseline and endline",
    output = file.path("Outputs", "balance_table.csv")  # Change to CSV
)

# Regressions ----

# Model 1: Food consumption regressed on treatment
model1 <- lm(......, data = hh_data)

# Model 2: Add controls (crop_damage, drought_flood)
model2 <- lm(......, data = hh_data)

# Model 3: Add FE by district
model3 <- lm(......, data = hh_data)

# Create regression table using stargazer
stargazer(
    ......,
    title = "Food Consumption Effects",
    keep = c("treatment", "crop_damage", "drought_flood"),
    covariate.labels = c("Treatment",
                         "Crop Damage",
                         "Drought/Flood"),
    dep.var.labels = c("Food Consumption (USD)"),
    dep.var.caption = "",
    add.lines = list(c("District Fixed Effects", "No", "No", "Yes")),
    header = FALSE,
    keep.stat = c("n", "adj.rsq"),
    notes = "Standard errors in parentheses",
    out = file.path("Outputs","regression_table.tex")
)

# Graphs: Area cultivated by treatment assignment across districts ----

# Bar graph by treatment for all districts
# Ensure treatment is a factor for proper labeling
hh_data_plot <- hh_data %>%
    mutate(treatment = factor(treatment, labels = c("Control", "Treatment")), 
           district = as_factor(district))

# Create the bar plot
# Create the bar plot
ggplot(hh_data_plot, aes(......) +
    geom_bar(......) +
    geom_text(......) +  # Add text labels
    facet_wrap(......) +  # Facet by district
    labs(title = "Area cultivated by treatment assignment across districts",
         x = NULL, y = "Average area cultivated (Acre)") +  # Remove x-axis title
    theme_minimal() +
    ...... # Add other customization if needed

ggsave(file.path("Outputs", "fig1.png"), width = 10, height = 6)


# Graphs: Distribution of non-food consumption by female-headed households ----

# Calculate mean non-food consumption for female and male-headed households
mean_female <- hh_data %>% 
    filter(female_head == 1) %>% 
    summarise(mean = mean(nonfood_cons_usd_w, na.rm = TRUE)) %>% 
    pull(mean)

mean_male <- hh_data %>% 
    filter(female_head == 0) %>% 
    summarise(mean = mean(nonfood_cons_usd_w, na.rm = TRUE)) %>% 
    pull(mean)

# Create the density plot
ggplot(hh_data, 
       aes(......)) +
    geom_density(......) +  # Density plot
    geom_vline(xintercept = ......, color = "purple", linetype = "dashed", size = 1) +  # Vertical line for female mean
    geom_vline(xintercept = ......, color = "grey", linetype = "dashed", size = 1) +  # Vertical line for male mean
    labs(title = "Distribution of Non-Food Consumption",
         x = "Non-food consumption value (USD)", 
         y = "Density",
         color = "Household Head:") +  # Custom labels
    theme_minimal() +
    ...... # Add other customization if needed

ggsave(file.path("Outputs", "fig2.png"), width = 10, height = 6)

# Graphs: Secondary data ----

long_data <- secondary_data %>%
    ungroup() %>% 
    select(-c(n_hospital, n_clinic)) %>% 
    pivot_longer(cols = c(n_school, n_medical), names_to = "amenity", values_to = "count") %>%
    mutate(amenity = recode(amenity, n_school = "Number of Schools", n_medical = "Number of Medical Facilities"),
           in_sample = if_else(district %in% c("Kibaha", "Chamwino", "Bagamoyo"), "In Sample", "Not in Sample"))

# Create the facet-wrapped bar plot
ggplot(long_data,
       aes(......)) +
    geom_bar(......) +
    coord_flip() +
    facet_wrap(......) +  # Create facets for schools and medical facilities
    labs(title = "Access to Amenities: By Districts",
         x = "District", y = NULL, fill = "Districts:") +
    scale_fill_brewer(palette="PuRd") +
    theme_minimal() +
    ...... # Add other customization if needed

ggsave(file.path("Outputs", "fig3.png"), width = 10, height = 6)
