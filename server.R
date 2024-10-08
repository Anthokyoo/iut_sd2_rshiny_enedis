install.packages("ggplot2")
install.packages("httr")
install.packages("jsonlite")
library(ggplot2)
library(httr)
library(jsonlite)

server <- function(input, output) {

  #setwd("C:/Users/ycharrade/Documents/iut_sd2_rshiny_enedis")
  adresse = read.csv(file = "adresses-73.csv", header = TRUE, sep = ";", dec = ".")
  base_url <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"
  code_postal = "73*"
  
  # Initialisation des paramètres de requête
  size <- 10000   # Taille des paquets
  df_neufs <- data.frame()  # Dataframe pour stocker les résultats
  Date = 2021 #filtrer a partir de la dae pour contourner le page*size
  repeat {
    # Paramètres de la requête
    params <- list(
      page = 1,
      size = size,
      select = "N°DPE,Etiquette_DPE,Date_réception_DPE",
      q = code_postal,
      q_fields = "Code_postal_(BAN)",
      qs = paste0("Date_réception_DPE:[",Date,"-01-01 TO ",Date,"-12-31]")
    )
    
    # Encodage des paramètres
    url_encoded <- modify_url(base_url, query = params)
    print(url_encoded)
    
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
    print(content$total)
    # Ajouter les données récupérées à l'ensemble complet
    df_neufs <- rbind(df_neufs, data)
    
    
  df_existant <- data.frame()
  #df_existant à faire !!! ---> il est terminé
  base_url <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-neufs/lines"
  
  # Paramètres de la requête
  params <- list(
    page = 1,
    size = size,
    select = "N°DPE,Etiquette_DPE,Date_réception_DPE",
    q = code_postal,
    q_fields = "Code_postal_(BAN)",
    qs = paste0("Date_réception_DPE:[",Date,"-01-01 TO ",Date,"-12-31]")
  ) 
  
  # Encodage des paramètres
  url_encoded <- modify_url(base_url, query = params)
  print(url_encoded)
  
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
  # Afficher le nombre total de ligne dans la base de données
  print(content$total)
  # Ajouter les données récupérées à l'ensemble complet
  df_existants <- rbind(df_neufs, data)
  
  #Incrémenter la date 
  Date <- Date+1
  
  if (Date == 2025){
    break
  }
  
  # Pause après chaque 600 requêtes pour respecter les limitations de l'API
  if (Date %% 600 == 0) {
    Sys.sleep(60)  # Pause de 60 secondes
  }
  # Afficher les données récupérées
  df_existants <- content$result
  }
  # Afficher les données complètes récupérées des logements existants
  print(df_existants)
  # Afficher les données complètes récupérées des logements neufs
  print(df_neufs)
  # Rendre le tableau pour df_existants
  output$table_existants <- renderTable({
    df_existants
  })
  
  # Rendre le tableau pour df_neufs
  output$table_neufs <- renderTable({
    df_neufs
  })
}

