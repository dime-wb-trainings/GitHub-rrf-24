# Reproducible Research Fundamentals 
# 01. Data processing

### Libraries
# library(haven)
# library(dplyr)
# library(tidyr)
# library(stringr)
# library(labelled)

### Loading data ----

# Load the dataset
data_path <- "ADD-YOUR-PATH"
data      <- read_dta(file.path(data_path, "Raw/TZA_CCT_baseline.dta"))

### Remove duplicates based on hhid
data_dedup <- data %>%
    ......

### Household (HH) level data ----

#### Tidying data for HH level
data_tidy_hh <- data_dedup %>%
    ......

### Data cleaning for Household-member (HH-member) level
data_clean_hh <- data_tidy_hh %>%
    # Convert submissionday to date
    mutate(...... = as.Date(......, format = "%Y-%m-%d %H:%M:%S")) %>%
    # Convert duration to numeric (if it is not already)
    mutate(......) %>%
    # Convert ar_farm_unit to factor (categorical data)
    mutate(......) %>%
    # Replace values in the crop variable based on crop_other using regex for new crops
    mutate(crop = case_when(
        ......
    )) %>%
    # Recode negative numeric values (-88) as missing (NA)
    mutate(across(......)) %>%
    # Add variable labels
    set_variable_labels(
        ......
    )

# Save the household data
write_dta(data_clean_hh, file.path(data_path, "Intermediate/TZA_CCT_HH.dta"))

### Household member (HH-member) level data ----

#### Tidying data for HH-member level
data_tidy_mem <- data_dedup %>%
    select(......,
           starts_with(......)) %>%
    pivot_longer(cols = -c(vid, hhid, enid),  # Keep IDs static
                 names_to = ......,
                 names_pattern = "(.*)_(\\d+)")  # Capture the variable and the suffix

### Data cleaning for HH-member level
data_clean_mem <- data_tidy_mem %>%
    # Drop rows where gender is missing (NA)
    ...... %>%
    # Variable labels
    ......

# Save the tidy household-member data
write_dta(data_clean_mem, file.path(data_path, "Intermediate/TZA_CCT_HH_mem.dta"))

### Secondary data ----

# Load CSV data
secondary_data <- read.csv(file.path(data_path, "Raw/TZA_amenity.csv"))

# Tidying data
secondary_data <- secondary_data %>%
    pivot_wider(names_from = ......,
                values_from = ......,
                names_prefix = ......)

# Save the final tidy secondary data
write_dta(secondary_data, file.path(data_path, "Intermediate/TZA_amenity_tidy.dta"))
