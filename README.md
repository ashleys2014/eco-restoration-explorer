# Ecosystem Health Explorer 🌲

Interactive Shiny app for ecological restoration prioritization.

---

## 📸 Preview
*(Screenshots coming soon during Phase 4 deployment!)*

---

## 📊 Project Overview

This project was developed as part of my Data Visualization portfolio. It models an interactive decision-support tool designed for environmental managers, restoration ecologists, and regional conservation boards to monitor habitat degradation and prioritize funding.

---

## ✨ Features

* **Regional Health Dashboard:** Interactive summary table ranking 15 monitoring regions by overall ecological status.
* **Threshold Explorer:** Reactive sidebar sliders filtering regions in real time based on custom environmental thresholds.
* **Diagnostic & Trend Comparison:** Side-by-side time-series visualizations tracking water quality, canopy cover, and soil metrics over time.

---

## ❓ Research Question

> *How can continuous environmental monitoring data be used to identify high-priority regions for ecological restoration?*

---

## 🛠 Tech Stack

* **Language:** R
* **Framework:** Shiny
* **Data Wrangling & Visualization:** tidyverse (`dplyr`, `ggplot2`), `lubridate`
* **Version Control & Hosting:** Git/GitHub, shinyapps.io

---

## 📂 Dataset

This project uses a synthesized environmental telemetry dataset containing **7,456 observations** collected across **15 monitoring regions**.

Key variables include:

- Groundwater Level
- Soil Moisture
- Rainfall
- NDVI Index
- Biodiversity Index
- Land Degradation Index
- Land Use Category
- Timestamp

---

## 🔬 Methodology

1. Cleaned and prepared hourly environmental monitoring data.
2. Parsed timestamps and aggregated to daily summaries.
3. Built interactive filtering tools to identify regions meeting user-defined thresholds.
4. Developed time-series visualizations for temporal comparison.

---

## 🌐 Live Demo

*Coming soon (will be deployed to shinyapps.io).*

---

## 💡 Key Insights

*Coming soon.*

---

## 📁 Project Structure

```text
eco-restoration-explorer/
├── data/              # Raw telemetry and cleaned .RData files
├── R/                 # Helper functions and data aggregation scripts
├── www/               # Custom CSS styles and assets
├── app.R              # Main R Shiny application file
├── README.md          # Project documentation
└── .gitignore         # Version control ignore list
```

---

## 🎯 Learning Objectives

This project was designed to demonstrate:

- Interactive application development with R Shiny
- Reactive programming concepts
- Time-series data visualization
- Environmental data analysis
- Git/GitHub version control
- User-centered dashboard design