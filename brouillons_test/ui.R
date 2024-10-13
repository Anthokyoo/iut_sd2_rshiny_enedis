
library(shiny)
library(leaflet)
library(shinydashboard)

# Interface utilisateur
ui <- dashboardPage(
  dashboardHeader(
    title = tags$div(
      tags$img(src = "C:/Users/antho/Documents/73 Logement.png", height = '40px'),
      "Logement neuf"
    )
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Cartographie", tabName = "cartography", icon = icon("map")),
      menuItem("Informations Station", tabName = "station_info", icon = icon("info-circle")),
      menuItem("Information Global", tabName = "global_info", icon = icon("globe")),
      menuItem("Données", tabName = "data", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      # Cartography Tab
      tabItem(tabName = "cartography",
              actionButton("refresh", "Rafraîchir les données"),
              leafletOutput("Savoie_map", height = "600px")
      ),
      
      # Station Info Tab
      tabItem(tabName = "station_info",
              h2("Informations Station")
      ),
      
      # Global Info Tab
      tabItem(tabName = "global_info",
              h2("Information Global")
      ),
      
      # Data Tab
      tabItem(tabName = "data",
              h2("Données"),
              p("Display dataset or data tables here")
      )
    )
  )
)

# Server part
server <- function(input, output, session) {
  output$velov_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(lng = 5.9162, lat = 45.6884, popup = "Aix-Les-Bains Center") %>%
      setView(lng = 5.9162, lat = 45.6884, zoom = 12)
  })
  
  # Refresh button logic
  observeEvent(input$refresh, {
    showNotification("Les données ont été rafraîchies", type = "message")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
