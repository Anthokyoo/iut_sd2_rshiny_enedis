#install.packages('shiny','leaflet','shinydashboard','httr','jsonlite')
library(shiny)
library(leaflet)
library(shinydashboard)
library(httr)
library(jsonlite)

# UI part
ui <- dashboardPage(
  dashboardHeader(
    title = tags$div(
      tags$img(src = "C:/Users/antho/Documents/73 Logement.png", height = '40px'),
      "Logements neufs"
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
  
  #setwd("C:/Users/ycharrade/Documents/iut_sd2_rshiny_enedis")
  adresse = read.csv(file = "adresses-73.csv", header = TRUE, sep = ";", dec = ".")
  
  code_postal = "73*"
  
  # Initialisation des paramètres de requête
  size <- 10000   # Taille des paquets
  df_existants <- data.frame()  # Dataframe pour stocker les résultats des logements existants
  df_neufs <- data.frame() # Dataframe pour stocker les résultats des logements neufs
  Date_existants = 2021 #filtrer a partir de la dae pour contourner le page*size
  Date_neufs = 2021
  base_url_existants <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"
  base_url_neufs <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-neufs/lines"
  repeat {
    # Paramètres de la requête
    params <- list(
      page = 1,
      size = size,
      select = "N°DPE,Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN),Identifiant__BAN",
      q = code_postal,
      q_fields = "Code_postal_(BAN)",
      qs = paste0("Date_réception_DPE:[",Date_existants,"-01-01 TO ",Date_existants,"-12-31]")
    )
    
    # Encodage des paramètres
    url_encoded <- modify_url(base_url_existants, query = params)
    
    # Effectuer la requête
    response <- GET(url_encoded)
    
    # Vérifier le statut de la réponse
    if (status_code(response) != 200) {
      stop("Erreur dans la requête : ", status_code(response))
    }
    
    # Convertir du json au char
    content = fromJSON(rawToChar(response$content), flatten = FALSE)
    
    # Récupérer les données pour la page actuelle
    data <- content$result
    
    # Ajouter les données récupérées à l'ensemble complet
    df_existants <- rbind(df_existants, data)
    
    Date_existants <- Date_existants + 1
    if (Date_existants == 2030){
      break
    }
    Sys.sleep(1)  # Pause de 1 seconde entre les requêtes
  }
  #df_existant à faire !!! ---> il est terminé
  
  repeat {
    # Paramètres de la requête
    params <- list(
      page = 1,
      size = size,
      select = "N°DPE,Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN),Identifiant__BAN",
      q = code_postal,
      q_fields = "Code_postal_(BAN)",
      qs = paste0("Date_réception_DPE:[",Date_neufs,"-01-01 TO ",Date_neufs,"-12-31]")
    ) 
    
    # Encodage des paramètres
    url_encoded <- modify_url(base_url_neufs, query = params)
    
    # Effectuer la requête
    response <- GET(url_encoded)
    
    # Vérifier le statut de la réponse
    if (status_code(response) != 200) {
      stop("Erreur dans la requête : ", status_code(response))
    }
    
    # On convertit le contenu brut (octets) en une chaîne de caractères (texte). Cela permet de transformer les données reçues de l'API, qui sont généralement au format JSON, en une chaîne lisible par R
    content = fromJSON(rawToChar(response$content), flatten = FALSE)
    
    # Récupérer les données pour la page actuelle
    data <- content$result
    
    # Ajouter les données récupérées à l'ensemble complet
    df_neufs <- rbind(df_neufs, data)
    
    #Incrémenter la date 
    Date_neufs <- Date_neufs+1
    
    if (Date_neufs == 2030){
      break
    }
    Sys.sleep(1)  # Pause de 1 seconde entre les requêtes
  }
  
  df_existants$type_logement = "Existant"
  df_neufs$type_logement = "Neufs"
  df_logement = rbind(df_existants,df_neufs)
  
  
  # Ajout des points des logements sur la carte
  output$Savoie_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      # Ajouter les marqueurs pour chaque logement
      addMarkers(
        lng = df_logement$lon,  # La colonne pour la longitude
        lat = df_logement$lat,  # La colonne pour la latitude
        popup = paste("Logement ID:", df_logement$`N°DPE`, "<br>",
                      "Etiquette DPE:", df_logement$Etiquette_DPE, "<br>",
                      "Date de réception DPE:", df_logement$Date_réception_DPE)
      ) %>%
      setView(lng = 5.9162, lat = 45.6884, zoom = 12)  # Centrer sur un point initial
  })
}

# Run the application
shinyApp(ui = ui, server = server)