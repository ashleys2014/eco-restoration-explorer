library(shiny)
library(tidyverse)
library(DT)

# Load data
regional_summary <- readRDS("data/regional_summary.rds")
daily_telemetry  <- readRDS("data/daily_telemetry.rds")

# Total rows for dynamic denominator
total_combinations <- nrow(regional_summary)

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
      p("Relative performance tiers based on dataset health distribution."),
      
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
      br(),
      
      sidebarLayout(
        
        sidebarPanel(
          width = 4,
          
          h4("Filter Environmental Criteria 🎯"),
          p("Adjust slider thresholds to isolate target monitoring regions:"),
          hr(style = "margin-top: 10px; margin-bottom: 15px;"),
          
          sliderInput(
            "ndvi_threshold",
            "Minimum NDVI Index (Vegetation Density):",
            min = 0,
            max = 1,
            value = 0.40,
            step = 0.05
          ),
          
          sliderInput(
            "biodiversity_threshold",
            "Minimum Biodiversity Score:",
            min = 0,
            max = 1,
            value = 0.40,
            step = 0.05
          ),
          
          sliderInput(
            "degradation_threshold",
            "Maximum Land Degradation:",
            min = 0,
            max = 1,
            value = 0.70,
            step = 0.05
          ),
          
          hr(),
          
          p(
            style = "font-size: 12px; color: #666; font-style: italic;",
            "💡 Tip: Lower degradation thresholds to focus on high-integrity conservation areas, or relax criteria to identify candidate restoration zones."
          )
        ),
        
        mainPanel(
          width = 8,
          
          div(
            style = "background-color: #f8f9fa; border-left: 5px solid #2C526A; padding: 12px 18px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 20px;",
            h4(uiOutput("filtered_counter"), style = "margin: 0; font-weight: bold; color: #2C526A;")
          ),
          
          h4("Matching Monitoring Regions"),
          p("Filtered results ordered by Health Score:"),
          
          DT::dataTableOutput("filtered_table_dt")
        )
      )
    ),
    
    
    # ==========================================================================
    # TAB 3: Time Series Comparison (Temporal Investigation)
    # ==========================================================================
    
    tabPanel(
      "Time Series Comparison",
      br(),
      
      sidebarLayout(
        sidebarPanel(
          width = 3,
          h4("Comparison Controls 📈"),
          p("Select two regions to evaluate leading-lagging indicator trajectories over time."),
          hr(),
          
          selectInput(
            "region1",
            "Select Primary Region:",
            choices = unique(daily_telemetry$Region_ID),
            selected = "R13"
          ),
          
          selectInput(
            "region2",
            "Select Comparison Region:",
            choices = unique(daily_telemetry$Region_ID),
            selected = "R01"
          ),
          
          hr(),
          
          selectInput(
            "time_metric",
            "Select Environmental Metric:",
            choices = c(
              "NDVI Index (Vegetation)" = "NDVI_Index",
              "Groundwater Level"       = "Groundwater_Level",
              "Soil Moisture"           = "Soil_Moisture",
              "Land Degradation"        = "Land_Degradation_Index"
            ),
            selected = "NDVI_Index"
          ),
          p(
            style = "font-size: 11px; color: #666; margin-top: -5px;",
            "Select a metric to compare daily telemetry patterns across regions."
          ),
          
          hr(),
          
          radioButtons(
            "trend_display",
            "Trend Display Mode:",
            choices = c(
              "Smoother Trend (LOESS)" = "smooth",
              "Raw Daily Telemetry"   = "raw"
            ),
            selected = "smooth"
          ),
          
          hr(),
          div(
            style = "background-color: #f1f3f5; padding: 10px; border-radius: 4px;",
            p(
              style = "font-size: 12px; color: #333; margin: 0; font-style: italic;",
              "💡 Research Question: Does a drop in groundwater precede drops in NDVI vegetation across different land-use zones?"
            )
          )
        ),
        
        mainPanel(
          width = 9,
          h4("Temporal Trajectory Analysis"),
          p("Comparing daily telemetry patterns across selected regions over time:"),
          br(),
          
          plotOutput("timeseries_plot", height = "420px"),
          
          br(),
          div(
            style = "background-color: #f8f9fa; padding: 12px 15px; border-radius: 4px; border: 1px solid #e9ecef;",
            h5("📊 Regional Land-Use Context & Insights", style = "margin-top: 0; font-weight: bold; color: #444;"),
            uiOutput("timeseries_summary_text")
          )
        )
      )
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
  
  output$top_region_kpi <- renderUI({
    top_row <- regional_summary %>%
      arrange(desc(Mean_Health_Score)) %>%
      slice(1)
    
    paste0(top_row$Region_ID, " (", top_row$Land_Use_Category, ")")
  })
  
  output$lowest_region_kpi <- renderUI({
    bottom_row <- regional_summary %>%
      arrange(Mean_Health_Score) %>%
      slice(1)
    
    paste0(bottom_row$Region_ID, " (", bottom_row$Land_Use_Category, ")")
  })
  
  output$avg_health_kpi <- renderUI({
    avg_score <- mean(regional_summary$Mean_Health_Score, na.rm = TRUE)
    round(avg_score, 3)
  })
  
  
  # ============================================================================
  # TAB 1: REGIONAL HEALTH TABLE
  # ============================================================================
  
  output$regional_table <- DT::renderDataTable({
    table_data <- regional_summary %>%
      select(Region_ID, Land_Use_Category, Mean_Health_Score, Mean_NDVI, Mean_Biodiversity, Mean_Degradation) %>%
      arrange(desc(Mean_Health_Score))
    
    DT::datatable(
      table_data,
      options = list(pageLength = 15, searching = TRUE, dom = "tip"),
      colnames = c("Region", "Land Use", "Health Score", "NDVI", "Biodiversity", "Degradation")
    ) %>%
      DT::formatStyle(
        "Mean_Health_Score",
        backgroundColor = DT::styleInterval(
          c(0.49, 0.52),
          c("#C97A63", "#D9CBB4", "#8FAF9F")
        )
      ) %>%
      DT::formatRound(
        columns = c("Mean_Health_Score", "Mean_NDVI", "Mean_Biodiversity", "Mean_Degradation"),
        digits = 3
      )
  })
  
  
  # ============================================================================
  # TAB 2: THRESHOLD FILTERING
  # ============================================================================
  
  filtered_data <- reactive({
    regional_summary %>%
      filter(
        Mean_NDVI >= input$ndvi_threshold,
        Mean_Biodiversity >= input$biodiversity_threshold,
        Mean_Degradation <= input$degradation_threshold
      ) %>%
      select(Region_ID, Land_Use_Category, Mean_Health_Score, Mean_NDVI, Mean_Biodiversity, Mean_Degradation) %>%
      arrange(desc(Mean_Health_Score))
  })
  
  output$filtered_counter <- renderUI({
    count <- nrow(filtered_data())
    if (count == 0) {
      return(span("⚠️ 0 regions match your criteria", style = "color: #C97A63;"))
    } else {
      return(paste0("🔍 ", count, " of ", total_combinations, " region/land-use zones match your criteria"))
    }
  })
  
  output$filtered_table_dt <- DT::renderDataTable({
    df <- filtered_data()
    
    DT::datatable(
      df,
      options = list(pageLength = 10, searching = FALSE, dom = "tip"),
      colnames = c("Region", "Land Use", "Health Score", "NDVI", "Biodiversity", "Degradation")
    ) %>%
      DT::formatStyle(
        "Mean_Health_Score",
        backgroundColor = DT::styleInterval(
          c(0.49, 0.52),
          c("#C97A63", "#D9CBB4", "#8FAF9F")
        )
      ) %>%
      DT::formatRound(
        columns = c("Mean_Health_Score", "Mean_NDVI", "Mean_Biodiversity", "Mean_Degradation"),
        digits = 3
      )
  })
  
  
  # ============================================================================
  # TAB 3: TIME SERIES COMPARISON (Server)
  # ============================================================================
  
  ts_data <- reactive({
    req(input$region1, input$region2, input$time_metric)
    
    df <- daily_telemetry %>%
      filter(Region_ID %in% c(input$region1, input$region2))
    
    validate(
      need(nrow(df) > 0, "No telemetry data found for the selected region combination.")
    )
    
    df %>%
      mutate(plot_date = as.Date(Date)) %>%
      filter(!is.na(plot_date), !is.na(.data[[input$time_metric]]))
  })
  
  output$timeseries_plot <- renderPlot({
    df <- ts_data()
    metric <- input$time_metric
    
    metric_title <- switch(metric,
                           "NDVI_Index"             = "NDVI Index (Vegetation Vitality)",
                           "Groundwater_Level"      = "Groundwater Level",
                           "Soil_Moisture"          = "Soil Moisture Content",
                           "Land_Degradation_Index" = "Land Degradation Index",
                           metric
    )
    
    color_palette <- c("#2C526A", "#C97A63")
    
    p <- ggplot(df, aes(x = plot_date, y = .data[[metric]], color = Region_ID, group = Region_ID))
    
    if (input$trend_display == "smooth") {
      p <- p +
        geom_line(alpha = 0.25, linewidth = 0.5) +
        geom_smooth(method = "loess", span = 0.25, se = FALSE, linewidth = 1.4)
    } else {
      p <- p + geom_line(linewidth = 1.0, alpha = 0.85)
    }
    
    p +
      scale_color_manual(values = color_palette) +
      theme_minimal(base_size = 14) +
      labs(
        title = paste("Daily Trajectory Comparison:", metric_title),
        subtitle = ifelse(
          input$trend_display == "smooth",
          paste("LOESS Trend comparison between", input$region1, "and", input$region2),
          paste("Raw daily data comparison between", input$region1, "and", input$region2)
        ),
        x = "Date",
        y = metric_title,
        color = "Region ID"
      ) +
      theme(
        plot.title = element_text(face = "bold", size = 16, color = "#222"),
        plot.subtitle = element_text(color = "#666", size = 12),
        legend.position = "top",
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#f0f0f0")
      )
  })
  
  output$timeseries_summary_text <- renderUI({
    req(input$region1, input$region2)
    
    get_uses <- function(reg_id) {
      uses <- regional_summary %>% 
        filter(Region_ID == reg_id) %>% 
        pull(Land_Use_Category) %>% 
        unique()
      
      if (length(uses) == 0) return("Unclassified")
      if (length(uses) > 3) {
        return(paste0(paste(uses[1:3], collapse = ", "), " (+", length(uses) - 3, " more land-use sub-zones)"))
      }
      return(paste(uses, collapse = ", "))
    }
    
    r1_use <- get_uses(input$region1)
    r2_use <- get_uses(input$region2)
    
    HTML(paste0(
      "<b>Primary Region (", input$region1, "):</b> Land-Use Composition — <i>", r1_use, "</i><br/>",
      "<b>Comparison Region (", input$region2, "):</b> Land-Use Composition — <i>", r2_use, "</i><br/>",
      "<span style='color: #555; font-size: 13px;'>Toggle 'Smoother Trend' to evaluate multi-month seasonal convergence, lag indicators, and ecological stress trajectories clearly.</span>"
    ))
  })
  
}

# ==============================================================================
# RUN APP
# ==============================================================================

shinyApp(ui, server)