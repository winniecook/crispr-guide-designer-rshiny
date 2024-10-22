
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(Biostrings)
library(tidyverse)
library(shinyjs)
library(shinycssloaders)

# Source helper functions
source("helpers.R")

# UI Definition
ui <- dashboardPage(
  dashboardHeader(title = "CRISPR gRNA Designer Pro"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Design gRNAs", tabName = "design", icon = icon("dna")),
      menuItem("Analysis", tabName = "analysis", icon = icon("chart-line")),
      menuItem("Documentation", tabName = "docs", icon = icon("book"))
    )
  ),
  
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #f9f9f9; }
        .box { border-top: 3px solid #00a65a; }
      "))
    ),
    
    tabItems(
      # Design Tab
      tabItem(tabName = "design",
        fluidRow(
          box(
            width = 4,
            title = "Input Parameters",
            status = "success",
            solidHeader = TRUE,
            
            textAreaInput("gene_sequence", 
                         "Enter Gene Sequence", 
                         rows = 6,
                         placeholder = "Paste DNA sequence here..."),
            
            selectInput("crispr_system",
                       "CRISPR System",
                       choices = c("Cas9" = "cas9",
                                 "Cas12a" = "cas12a",
                                 "Cas13" = "cas13")),
            
            numericInput("max_mismatches",
                        "Maximum Mismatches",
                        value = 3,
                        min = 0,
                        max = 10),
            
            textInput("pam_sequence",
                     "PAM Sequence",
                     value = "NGG"),
            
            sliderInput("min_efficiency",
                       "Minimum Efficiency Score",
                       min = 0,
                       max = 100,
                       value = 50),
            
            actionButton("submit", 
                        "Design gRNAs",
                        class = "btn-success btn-block")
          ),
          
          box(
            width = 8,
            title = "Results",
            status = "success",
            solidHeader = TRUE,
            
            tabsetPanel(
              tabPanel("Data Table", 
                DTOutput("grna_table") %>% withSpinner()),
              tabPanel("Visualization",
                plotlyOutput("efficiency_plot") %>% withSpinner())
            )
          )
        )
      ),
      
      # Analysis Tab
      tabItem(tabName = "analysis",
        fluidRow(
          box(
            width = 12,
            title = "Off-target Analysis",
            status = "success",
            solidHeader = TRUE,
            
            plotlyOutput("offtarget_heatmap") %>% withSpinner(),
            plotlyOutput("specificity_plot") %>% withSpinner()
          )
        )
      ),
      
      # Documentation Tab
      tabItem(tabName = "docs",
        fluidRow(
          box(
            width = 12,
            title = "Documentation",
            status = "success",
            solidHeader = TRUE,
            
            includeMarkdown("docs.md")
          )
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Reactive value to store gRNA results
  grna_results <- reactiveVal(NULL)
  
  # Generate gRNAs when submit button is clicked
  observeEvent(input$submit, {
    req(input$gene_sequence)
    
    # Validate input sequence
    tryCatch({
      seq <- DNAString(input$gene_sequence)
    }, error = function(e) {
      showNotification("Invalid DNA sequence", type = "error")
      return(NULL)
    })
    
    # Generate gRNAs
    results <- design_grnas(
      sequence = input$gene_sequence,
      crispr_system = input$crispr_system,
      max_mismatches = input$max_mismatches,
      pam_sequence = input$pam_sequence,
      min_efficiency = input$min_efficiency
    )
    
    grna_results(results)
  })
  
  # Render results table
  output$grna_table <- renderDT({
    req(grna_results())
    
    datatable(
      grna_results(),
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      rownames = FALSE
    ) %>%
      formatStyle(
        'efficiency',
        background = styleColorBar(c(0,100), '#00a65a'),
        backgroundSize = '98% 88%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      )
  })
  
  # Render efficiency plot
  output$efficiency_plot <- renderPlotly({
    req(grna_results())
    
    plot_ly(grna_results(), x = ~sequence, y = ~efficiency, type = "bar",
            marker = list(color = '#00a65a')) %>%
      layout(
        title = "gRNA Efficiency Scores",
        xaxis = list(title = "gRNA Sequence"),
        yaxis = list(title = "Efficiency Score")
      )
  })
  
  # Render off-target heatmap
  output$offtarget_heatmap <- renderPlotly({
    req(grna_results())
    
    plot_offtarget_heatmap(grna_results())
  })
  
  # Render specificity plot
  output$specificity_plot <- renderPlotly({
    req(grna_results())
    
    plot_ly(grna_results(), x = ~specificity, y = ~efficiency, 
            type = "scatter", mode = "markers",
            text = ~sequence,
            marker = list(
              size = 10,
              color = '#00a65a',
              line = list(color = 'rgba(0, 166, 90, .8)', width = 2)
            )) %>%
      layout(
        title = "Efficiency vs Specificity",
        xaxis = list(title = "Specificity Score"),
        yaxis = list(title = "Efficiency Score")
      )
  })
}

# Run the app
shinyApp(ui = ui, server = server)