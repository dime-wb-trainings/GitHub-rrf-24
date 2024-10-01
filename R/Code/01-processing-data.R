# Reproducible Research Fundamentals 
# 01. Data processing

### Libraries
 library(haven)
 library(dplyr)
 library(tidyr)
 library(stringr)
 library(labelled)

### Loading data ----

# Load the dataset
data_path <- "C:/Users/wb613031/Dropbox/WB/RRF2024/DataWork/DataWork/Data"
data      <- read_dta(file.path(data_path, "Raw/TZA_CCT_baseline.dta"))

### Remove duplicates based on hhid
data_dedup <- data %>%
    distinct(hhid, .keep_all = TRUE)

### Household (HH) level data ----

#------------------------------------------------
# observe data - usefull random things#

# n_distinct(data$enid) // cuantos son uniques
# unique(data$enid) // muestra los valores unicos
#------------------------------------------------

#### Tidying data for HH level
data_tidy_hh <- data_dedup %>%
    select(vid, hhid, enid, floor:n_elder , food_cons:submissionday)

### Data cleaning for Household-member (HH-member) level
data_clean_hh <- data_tidy_hh %>%
    # Convert submissionday to date
    mutate(submissionday = as.Date(submissionday, format = "%Y-%m-%d %H:%M:%S")) %>%
    # Convert duration to numeric (if it is not already)
    mutate(duration = as.numeric(duration)) %>%
    # Convert ar_farm_unit to factor (categorical data)
    mutate(ar_unit = as.factor(ar_farm_unit)) %>%
    mutate(ar_unit = na_if(ar_unit, "")) %>%
    # Clean crop_other variable (capitalize first letter)
    mutate(crop_other = str_to_title(crop_other)) %>%
    # Replace values in the crop variable based on crop_other using regex for new crops
    mutate(crop = case_when(
      str_detect(crop_other , "Coconut") ~ 40 , # substitute 40
      str_detect(crop_other , "Sesame") ~ 41 , # substitute 41 
      TRUE ~ crop
    )) %>%
    # Recode negative numeric values (-88) as missing (NA)
    mutate(across(where(is.numeric), ~ replace(.,. == -88 , NA))) %>%
    # Add variable labels
    set_variable_labels(
        duration = "Duration of the interview (min)" , 
        submissiondate = "Submission Date" , 
        
    )

# Save the household data
write_dta(data_clean_hh, file.path(data_path, "Intermediate/TZA_CCT_HH.dta"))

### Household member (HH-member) level data ----

#### Tidying data for HH-member level
data_tidy_mem <- data_clean %>%
    select(vid, hhid, enid, starts_with("gender"), starts_with("age") ,
           starts_with("day_sick") , starts_with("read") , starts_with("treat_cost") ,
           starts_with("clinic_visit") , starts_with("treat_fin") , starts_with("ill_impact") ,
           starts_with("days_impact") ) %>%
    pivot_longer(cols = -c(vid, hhid, enid),  # Keep IDs static
                 names_to = c(",value" , "member"),
                 names_pattern = "(.*)_(\\d+)")  # Capture the variable and the suffix 
                # lo primero que encuentre sera value y lo segundo sera member

### Data cleaning for HH-member level
data_clean_mem <- data_tidy_mem %>%
    # Drop rows where gender is missing (NA)
    filter(!is.na(gender)) %>%
    set_variable_labels(
      member = "HH member ID" , 
      age = "Age" , 
      clinic_visit = "In the past 23 mnts, how many times has the member attended the clinic" , 
      days_sick = "# of days in the last 4 weeks",
      treat_cost = "How much did the treatment cost?" , 
      days_impact = "# of dats member was unable to work due to illness"
    )

# Save the tidy household-member data
write_dta(data_clean_mem, file.path(data_path, "Intermediate/TZA_CCT_HH_mem.dta"))

### Secondary data ----

# Load CSV data
secondary_data <- read.csv(file.path(data_path, "Raw/TZA_amenity.csv"))

# Tidying data
secondary_data <- secondary_data %>%
    pivot_wider(names_from = amenity,
                values_from = n ,
                names_prefix = "n_")

# Save the final tidy secondary data
write_dta(secondary_data, file.path(data_path, "Intermediate/TZA_amenity_tidy.dta"))
