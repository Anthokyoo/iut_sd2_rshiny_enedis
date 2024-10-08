install.packages("shiny")
install.packages("httr")
library(shiny)
library(httr)

# Interface utilisateur
ui <- fluidPage(
  titlePanel("Affichage des Logements"),
 
  sidebarLayout(
    sidebarPanel(
      h4("Tableaux des Logements"),
      p("Ci-dessous se trouvent les données des logements existants et neufs pour le code postal 73."),
      hr()
    ),
    
    mainPanel(
      h3("Données des Logements Existants"),
      tableOutput("table_existants"),
      h3("Données des Logements Neufs"),
      tableOutput("table_neufs")
    )
  )
)

shinyApp(ui = ui, server = server)
