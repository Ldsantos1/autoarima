library(shiny)
library(data.table)
library(forecast)
library(utils)

# Define UI for data upload app ----
ui <- fluidPage(
  # App title ----
  titlePanel("Demand forecast using ARIMA model"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Select a file ----
      fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      # Horizontal line ----
      tags$hr(),
      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),
      # Input: Select values
      textInput("sku", "SKU", value = ""),
      # Input: Select separator ----
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = ","),
      # Input: Select quotes ----
      radioButtons("quote", "Quote",
                   choices = c(None = "",
                               "Double Quote" = '"',
                               "Single Quote" = "'"),
                   selected = '"'),
      # Horizontal line ----
      tags$hr(),
      # Input: Select number of rows to display ----
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               All = "all"),
                   selected = "head"),
      
      # Button: Export fitted values ----
      downloadLink("fitted", "Export Fitted Values")
    ),
    # Main panel for displaying outputs ----
    
    mainPanel(
      tabsetPanel(
        tabPanel("Table", tableOutput("contents")),
        tabPanel("Model", plotOutput("plot"),
                 verbatimTextOutput("model_summary")),
        tabPanel("Residuals", plotOutput("residuals"))
      )
    )
  )
)

# Define server logic to read selected file ----
server <- function(input, output, session) {
  data <- reactive({
    req(input$file1)
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    df <- read.csv(inFile$datapath, header = input$header)
    updateSelectInput(session, inputId = "col", choices = names(df))
    return(df)
  })
  
  output$contents <- renderTable({
    req(data())
    
    if (input$sku != "") {
      subset(data(), data()[, 1] == input$sku)
    } else {
      data.table(data())
    }
  })
  
  output$plot <- renderPlot({
    req(data())
    
    if (input$sku != "") {
      subset_sales <- subset(data(), data()[, 1] == input$sku)
      year_init <- min(as.numeric(substr(data()[,3], 1, 4)))
      month_init <- min(as.numeric(substr(data()[,3], 6, 7)))
      data.ts <- ts(subset_sales[, 2], frequency = 12, start = c(year_init, month_init))
      
      model <- auto.arima(data.ts)
      forecast <- forecast(model, level = 95)
      plot(forecast, type = "p", col = "red")
    }
  })
  
  output$model_summary <- renderPrint({
    req(data())
    
    if (input$sku != "") {
      subset_sales <- subset(data(), data()[, 1] == input$sku)
      year_init <- min(as.numeric(substr(data()[,3], 1, 4)))
      month_init <- min(as.numeric(substr(data()[,3], 6, 7)))
      data.ts <- ts(subset_sales[, 2], frequency = 12, start = c(year_init, month_init))
      model <- auto.arima(data.ts)
      forecast <- data.frame(forecast(model, level = 95))
      summary(forecast)
    }
  })
  
  
  output$residuals <- renderPlot({
    req(data())
    
    if (input$sku != "") {
      subset_sales <- subset(data(), data()[, 1] == input$sku)
      year_init <- min(as.numeric(substr(data()[,3], 1, 4)))
      month_init <- min(as.numeric(substr(data()[,3], 6, 7)))
      data.ts <- ts(subset_sales[, 2], frequency = 12, start = c(year_init, month_init))
      model <- auto.arima(data.ts)
      forecast <- data.frame(forecast(model, level = 95))
      checkresiduals(model)
    }
  })

  output$fitted <- downloadHandler(
    filename = function() {
      paste("fitted", ".csv", sep="")
    },
    content = function(file) {
      write.csv(data, file)
    }
  )
  
}
# Create Shiny app ----
shinyApp(ui, server)

