# ==============================================================================
# Phase 2: Data Exploration & Preparation
# Project: Ecosystem Health Explorer
# ==============================================================================

library(tidyverse)

# 1. Load Data -----------------------------------------------------------------
raw_data <- read_csv("data/Rural_Ecological_Dataset.csv")

# 2. Daily Aggregation ---------------------------------------------------------
daily_telemetry <- raw_data %>%
  mutate(Date = as.Date(Timestamp)) %>%
  group_by(Region_ID, Land_Use_Category, Date) %>%
  summarise(
    Soil_Moisture = mean(Soil_Moisture),
    Soil_Temperature = mean(Soil_Temperature),
    Soil_pH = mean(Soil_pH),
    Soil_Nitrogen = mean(Soil_Nitrogen),
    Soil_Phosphorus = mean(Soil_Phosphorus),
    Soil_Potassium = mean(Soil_Potassium),
    Air_Temperature = mean(Air_Temperature),
    Humidity = mean(Humidity),
    Rainfall = sum(Rainfall),
    Solar_Radiation = mean(Solar_Radiation),
    Groundwater_Level = mean(Groundwater_Level),
    Surface_Water_Availability = mean(Surface_Water_Availability),
    NDVI_Index = mean(NDVI_Index),
    Vegetation_Density = mean(Vegetation_Density),
    Biodiversity_Index = mean(Biodiversity_Index),
    Land_Degradation_Index = mean(Land_Degradation_Index),
    Crop_Yield_Potential = mean(Crop_Yield_Potential),
    Drought_Risk_Level = mean(Drought_Risk_Level),
    Soil_Erosion_Risk = mean(Soil_Erosion_Risk),
    Recommended_Irrigation = mean(Recommended_Irrigation),
    .groups = "drop"
  )

# 3. Calculate Composite Health Score ------------------------------------------
daily_telemetry <- daily_telemetry %>%
  mutate(
    Health_Score = (
      (NDVI_Index * 0.30) +
        (Biodiversity_Index * 0.25) +
        ((1 - Land_Degradation_Index) * 0.25) +
        ((1 - Soil_Erosion_Risk) * 0.20)
    )
  )

# 4. Create Regional Summary Table --------------------------------------------
regional_summary <- daily_telemetry %>%
  group_by(Region_ID, Land_Use_Category) %>%
  summarise(
    Mean_Health_Score = mean(Health_Score, na.rm = TRUE),
    Min_Health_Score = min(Health_Score, na.rm = TRUE),
    Max_Health_Score = max(Health_Score, na.rm = TRUE),
    Mean_NDVI = mean(NDVI_Index, na.rm = TRUE),
    Mean_Biodiversity = mean(Biodiversity_Index, na.rm = TRUE),
    Mean_Degradation = mean(Land_Degradation_Index, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(Mean_Health_Score))

# 5. Save Output Files ---------------------------------------------------------
saveRDS(raw_data, "data/raw_telemetry.rds")
saveRDS(daily_telemetry, "data/daily_telemetry.rds")
saveRDS(regional_summary, "data/regional_summary.rds")
