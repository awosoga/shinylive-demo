## with shinyauthr

library(shiny)
library(bslib)
library(shinyauthr)

# Define user credentials
user_base <- data.frame(
  user = c("test"), 
  password = c("test"), # plaintext for simplicity; use hashed passwords in production
  stringsAsFactors = FALSE
)

# Define UI for app
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "united"),
  shinyauthr::loginUI("login"),
  uiOutput("app_ui") # Placeholder for main app UI, shown after login
)

# Define server logic
server <- function(input, output, session) {
  # Initialize login module
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactiveVal(FALSE)
  )
  
  # Show the main app UI only after successful login
  output$app_ui <- renderUI({
    req(credentials()$user_auth) # Require user to be authenticated
    
    # Main app UI
    page_sidebar(
      title = "Authenticated Shiny App!",
      sidebar = sidebar(
        sliderInput(
          inputId = "bins",
          label = "Number of bins:",
          min = 1,
          max = 50,
          value = 30
        )
      ),
      plotOutput(outputId = "distPlot")
    )
  })
  
  # Server logic for the main app
  output$distPlot <- renderPlot({
    req(credentials()$user_auth) # Require user to be authenticated
    
    x <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")
  })
}

shinyApp(ui = ui, server = server)
