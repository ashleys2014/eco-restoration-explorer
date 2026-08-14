library(shiny)
library(tidyverse)
library(DT)

# Load data
regional_summary <- readRDS("data/regional_summary.rds")
daily_telemetry  <- readRDS("data/daily_telemetry.rds")

# ==============================================================================
# UI
# ==============================================================================

ui <- fluidPage(
  
  titlePanel("Ecosystem Health Explorer 🌲"),
  p("Interactive tool for identifying ecological restoration priorities"),
  hr(),
  
  tabsetPanel(
    
    # ==========================================================================
    # TAB 1: Regional Dashboard
    # ==========================================================================
    
    tabPanel(
      "Regional Dashboard",
      br(),
      
      # KPI CARDS
      fluidRow(
        column(
          4,
          div(
            style = "background-color: #f8f9fa; border-left: 5px solid #8FAF9F; 
                     padding: 15px; border-radius: 4px; 
                     box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            h5(
              "Highest Health Score",
              style = "margin-top: 0; color: #555;"
            ),
            h3(
              uiOutput("top_region_kpi"),
              style = "margin: 5px 0; font-weight: bold; color: #8FAF9F;"
            )
          )
        ),
        
        column(
          4,
          div(
            style = "background-color: #f8f9fa; border-left: 5px solid #C97A63; 
                     padding: 15px; border-radius: 4px; 
                     box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            h5(
              "Lowest Health Score",
              style = "margin-top: 0; color: #555;"
            ),
            h3(
              uiOutput("lowest_region_kpi"),
              style = "margin: 5px 0; font-weight: bold; color: #C97A63;"
            )
          )
        ),
        
        column(
          4,
          div(
            style = "background-color: #f8f9fa; border-left: 5px solid #D9CBB4; 
                     padding: 15px; border-radius: 4px; 
                     box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            h5(
              "Average Dataset Health",
              style = "margin-top: 0; color: #555;"
            ),
            h3(
              uiOutput("avg_health_kpi"),
              style = "margin: 5px 0; font-weight: bold; color: #D9CBB4;"
            )
          )
        )
      ),
      
      br(),
      
      h4("Regional Health Overview"),
      
      p(
        "Relative performance tiers based on dataset health distribution."
      ),
      
      # Legend
      p(
        "Color Key: Critical (<0.49) | Moderate (0.49–0.52) | Healthy (>0.52)",
        style = "font-size: 12px; color: #666; margin-bottom: 4px;"
      ),
      
      # Threshold clarification
      p(
        "These ranges are interpretive dashboard categories designed to highlight 
        relative differences within this dataset. They are not ecological standards.",
        style = "font-size: 11px; color: #777; margin-top: -6px; margin-bottom: 10px;"
      ),
      
      DT::dataTableOutput("regional_table")
    ),
    
    
    # ==========================================================================
    # TAB 2: Threshold Explorer
    # ==========================================================================
    
    tabPanel(
      "Threshold Explorer",
      
      h3("Custom Filtering by Environmental Thresholds"),
      
      sidebarLayout(
        
        sidebarPanel(
          
          p(
            "Set thresholds to identify regions meeting your criteria:"
          ),
          
          sliderInput(
            "ndvi_threshold",
            "NDVI Index (Min):",
            min = 0,
            max = 1,
            value = 0.40,
            step = 0.05
          ),
          
          sliderInput(
            "biodiversity_threshold",
            "Biodiversity (Min):",
            min = 0,
            max = 1,
            value = 0.40,
            step = 0.05
          ),
          
          sliderInput(
            "degradation_threshold",
            "Land Degradation (Max):",
            min = 0,
            max = 1,
            value = 0.70,
            step = 0.05
          )
        ),
        
        mainPanel(
          
          p("Regions matching your thresholds:"),
          
          tableOutput("filtered_table")
        )
      )
    ),
    
    
    # ==========================================================================
    # TAB 3: Diagnostic Panel
    # ==========================================================================
    
    tabPanel(
      "Diagnostic Panel",
      
      h3("Regional Health Details"),
      
      p("Select a region to view detailed diagnostics."),
      
      selectInput(
        "region_select",
        "Choose Region:",
        choices = unique(regional_summary$Region_ID)
      ),
      
      verbatimTextOutput("diagnostic_output")
    ),
    
    
    # ==========================================================================
    # TAB 4: Temporal Comparison
    # ==========================================================================
    
    tabPanel(
      "Time Series Comparison",
      
      h3("Track Trends Over Time"),
      
      p("Compare two regions side-by-side (coming soon)."),
      
      fluidRow(
        
        column(
          6,
          selectInput(
            "region1",
            "Region 1:",
            choices = unique(daily_telemetry$Region_ID)
          )
        ),
        
        column(
          6,
          selectInput(
            "region2",
            "Region 2:",
            choices = unique(daily_telemetry$Region_ID)
          )
        )
      ),
      
      plotOutput("timeseries_plot")
    )
  )
)


# ==============================================================================
# SERVER
# ==============================================================================

server <- function(input, output, session) {
  
  
  # ============================================================================
  # KPI CARDS
  # ============================================================================
  
  # Highest-scoring Region + Land Use combination
  output$top_region_kpi <- renderUI({
    
    top_row <- regional_summary %>%
      arrange(desc(Mean_Health_Score)) %>%
      slice(1)
    
    paste0(
      top_row$Region_ID,
      " (",
      top_row$Land_Use_Category,
      ")"
    )
  })
  
  
  # Lowest-scoring Region + Land Use combination
  output$lowest_region_kpi <- renderUI({
    
    bottom_row <- regional_summary %>%
      arrange(Mean_Health_Score) %>%
      slice(1)
    
    paste0(
      bottom_row$Region_ID,
      " (",
      bottom_row$Land_Use_Category,
      ")"
    )
  })
  
  
  # Average Health Score across the dataset
  output$avg_health_kpi <- renderUI({
    
    avg_score <- mean(
      regional_summary$Mean_Health_Score,
      na.rm = TRUE
    )
    
    round(avg_score, 3)
  })
  
  
  # ============================================================================
  # TAB 1: REGIONAL HEALTH TABLE
  # ============================================================================
  
  output$regional_table <- DT::renderDataTable({
    
    table_data <- regional_summary %>%
      select(
        Region_ID,
        Land_Use_Category,
        Mean_Health_Score,
        Mean_NDVI,
        Mean_Biodiversity,
        Mean_Degradation
      ) %>%
      arrange(desc(Mean_Health_Score))
    
    
    DT::datatable(
      
      table_data,
      
      options = list(
        pageLength = 15,
        searching = TRUE,
        dom = "tip"
      ),
      
      colnames = c(
        "Region",
        "Land Use",
        "Health Score",
        "NDVI",
        "Biodiversity",
        "Degradation"
      )
      
    ) %>%
      
      # Health Score conditional formatting
      DT::formatStyle(
        
        "Mean_Health_Score",
        
        backgroundColor = DT::styleInterval(
          
          c(0.49, 0.52),
          
          c(
            "#C97A63",  # Terracotta = Critical
            "#D9CBB4",  # Sand = Moderate
            "#8FAF9F"   # Sage = Healthy
          )
        )
      ) %>%
      
      # Round numerical values
      DT::formatRound(
        
        columns = c(
          "Mean_Health_Score",
          "Mean_NDVI",
          "Mean_Biodiversity",
          "Mean_Degradation"
        ),
        
        digits = 3
      )
  })
  
  
  # ============================================================================
  # TAB 2: THRESHOLD FILTERING
  # ============================================================================
  
  output$filtered_table <- renderTable({
    
    filtered_df <- regional_summary %>%
      
      filter(
        Mean_NDVI >= input$ndvi_threshold,
        Mean_Biodiversity >= input$biodiversity_threshold,
        Mean_Degradation <= input$degradation_threshold
      ) %>%
      
      select(
        Region_ID,
        Land_Use_Category,
        Mean_Health_Score,
        Mean_NDVI,
        Mean_Biodiversity,
        Mean_Degradation
      ) %>%
      
      arrange(desc(Mean_Health_Score))
    
    
    # Empty-state message
    if (nrow(filtered_df) == 0) {
      
      return(
        data.frame(
          Status = "⚠️ No regions match your current filter criteria. Try lowering the thresholds on the left!"
        )
      )
    }
    
    
    filtered_df
  })
  
  
  # ============================================================================
  # TAB 3: DIAGNOSTIC PANEL
  # ============================================================================
  
  output$diagnostic_output <- renderText({
    
    selected_region <- input$region_select
    
    region_data <- regional_summary %>%
      filter(Region_ID == selected_region)
    
    
    if (nrow(region_data) > 0) {
      
      paste0(
        "Region: ",
        selected_region,
        "\n",
        
        "Land Use: ",
        region_data$Land_Use_Category[1],
        "\n",
        
        "Mean Health Score: ",
        round(region_data$Mean_Health_Score[1], 3),
        "\n",
        
        "NDVI Index: ",
        round(region_data$Mean_NDVI[1], 3),
        "\n",
        
        "Biodiversity: ",
        round(region_data$Mean_Biodiversity[1], 3)
      )
      
    } else {
      
      "No data available for this region."
    }
  })
  
  
  # ============================================================================
  # TAB 4: TIME SERIES PLACEHOLDER
  # ============================================================================
  
  output$timeseries_plot <- renderPlot({
    
    plot(
      NULL,
      xlim = c(0, 1),
      ylim = c(0, 1),
      main = "Time series comparison (coming soon)"
    )
  })
}


# ==============================================================================
# RUN APP
# ==============================================================================

shinyApp(ui, server)