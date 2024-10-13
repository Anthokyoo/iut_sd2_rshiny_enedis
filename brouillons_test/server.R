install.packages("ggplot2")
install.packages("httr")
install.packages("jsonlite")
library(ggplot2)
library(httr)
library(jsonlite)

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
      select = "N°DPE,Etiquette_DPE,Date_réception_DPE",
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
}
  #df_existant à faire !!! ---> il est terminé
  
  repeat {
  # Paramètres de la requête
  params <- list(
    page = 1,
    size = size,
    select = "N°DPE,Etiquette_DPE,Date_réception_DPE",
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
  }
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

shinyApp(ui = ui, server = server)
