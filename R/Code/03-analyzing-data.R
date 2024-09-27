# Reproducible Research Fundamentals 
# 03. Data Analysis

# Load data 
#household level data
hh_data <- read_dta(file.path(data_path, "Final/TZA_CCT_analysis.dta"))

# secondary data 
secondary_data <- read_dta(file.path(data_path, "Final/TZA_amenity_analysis.dta"))

# Summary statistics ----

# Remove Stata-specific attributes from all variables


# Create summary statistics by district



# Balance table ----


# Regressions ----

# Model 1: Food consumption regressed on treatment


# Model 2: Add controls (crop_damage, drought_flood)

# Model 3: Add clustering by village


# Create regression table using stargazer


# Graphs: Area cultivated by treatment assignment across districts ----

# Bar graph by treatment for all districts
# Ensure treatment is a factor for proper labeling


# Create the bar plot

# Save graph as fig1.png


# Graphs: Distribution of non-food consumption by female-headed households ----

# Calculate mean non-food consumption for female and male-headed households

# Create the density plot

# Save graph as fig2.png

# Graphs: Secondary data ----

# tip: for ggplot it is better in long format use pivot_longer and then ggplot



# Create the facet-wrapped bar plot

# Save graph as fig3.png

