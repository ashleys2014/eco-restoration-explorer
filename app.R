# ==============================================================================
# PHASE 3: Shiny App Skeleton (Enhanced UX Edition)
# Project: Ecosystem Health Explorer
# ==============================================================================

library(shiny)
library(tidyverse)

# 1. Load pre-processed data from Phase 2
regional_summary <- readRDS("data/regional_summary.rds")
daily_telemetry  <- readRDS("data/daily_telemetry.rds")

# ==============================================================================
# USER INTERFACE (UI)
# ==============================================================================

ui <- fluidPage(
  
  # App title
  titlePanel("Ecosystem Health Explorer 🌲"),
  
  # Subtitle
  p("Interactive tool for identifying ecological restoration priorities"),
  
  # Tab structure
  tabsetPanel(
    
    # TAB 1: Regional Health Dashboard
    tabPanel(
      "Regional Dashboard",
      h3("Overview of Regional Ecological Health"),
      p("Scan the health status of all monitoring regions."),
      tableOutput("regional_table")
    ),
    
    # TAB 2: Threshold Explorer
    tabPanel(
      "Threshold Explorer",
      h3("Custom Filtering by Environmental Thresholds"),
      sidebarLayout(
        sidebarPanel(
          p("Set thresholds to identify regions meeting your criteria:"),
          # Adjusted defaults to match real dataset ranges (~0.4 - 0.6)
          sliderInput("ndvi_threshold", "NDVI Index (Min):", min = 0, max = 1, value = 0.40, step = 0.05),
          sliderInput("biodiversity_threshold", "Biodiversity (Min):", min = 0, max = 1, value = 0.40, step = 0.05),
          sliderInput("degradation_threshold", "Land Degradation (Max):", min = 0, max = 1, value = 0.70, step = 0.05)
        ),
        mainPanel(
          p("Regions matching your thresholds:"),
          tableOutput("filtered_table")
        )
      )
    ),
    
    # TAB 3: Diagnostic Panel
    tabPanel(
      "Diagnostic Panel",
      h3("Regional Health Details"),
      p("Select a region to view detailed diagnostics."),
      selectInput("region_select", "Choose Region:", choices = unique(regional_summary$Region_ID)),
      verbatimTextOutput("diagnostic_output")
    ),
    
    # TAB 4: Temporal Comparison
    tabPanel(
      "Time Series Comparison",
      h3("Track Trends Over Time"),
      p("Compare two regions side-by-side (coming soon)."),
      fluidRow(
        column(6, selectInput("region1", "Region 1:", choices = unique(daily_telemetry$Region_ID))),
        column(6, selectInput("region2", "Region 2:", choices = unique(daily_telemetry$Region_ID)))
      ),
      plotOutput("timeseries_plot")
    )
  )
)

# ==============================================================================
# SERVER LOGIC
# ==============================================================================

server <- function(input, output, session) {
  
  # TAB 1: Display regional summary table
  output$regional_table <- renderTable({
    regional_summary %>%
      select(Region_ID, Land_Use_Category, Mean_Health_Score, Mean_NDVI, Mean_Biodiversity) %>%
      arrange(desc(Mean_Health_Score))
  })
  
  # TAB 2: Reactive filtering with Empty State Handling (UX Improvement)
  output$filtered_table <- renderTable({
    filtered_df <- regional_summary %>%
      filter(
        Mean_NDVI >= input$ndvi_threshold,
        Mean_Biodiversity >= input$biodiversity_threshold,
        Mean_Degradation <= input$degradation_threshold
      ) %>%
      select(Region_ID, Land_Use_Category, Mean_Health_Score, Mean_NDVI, Mean_Biodiversity) %>%
      arrange(desc(Mean_Health_Score))
    
    if (nrow(filtered_df) == 0) {
      return(data.frame(
        Status = "⚠️ No regions match your current filter criteria. Try lowering the thresholds on the left!"
      ))
    }
    
    return(filtered_df)
  })
  
  # TAB 3: Diagnostic output
  output$diagnostic_output <- renderText({
    selected_region <- input$region_select
    region_data <- regional_summary %>% filter(Region_ID == selected_region)
    
    if (nrow(region_data) > 0) {
      paste0(
        "Region: ", selected_region, "\n",
        "Land Use: ", region_data$Land_Use_Category[1], "\n",
        "Mean Health Score: ", round(region_data$Mean_Health_Score[1], 3), "\n",
        "NDVI Index: ", round(region_data$Mean_NDVI[1], 3), "\n",
        "Biodiversity: ", round(region_data$Mean_Biodiversity[1], 3)
      )
    } else {
      "No data available for this region."
    }
  })
  
  # TAB 4: Time series plot placeholder
  output$timeseries_plot <- renderPlot({
    plot(NULL, xlim=c(0,1), ylim=c(0,1), main = "Time series comparison (coming soon)")
  })
}

# ==============================================================================
# RUN APP
# ==============================================================================

shinyApp(ui, server)