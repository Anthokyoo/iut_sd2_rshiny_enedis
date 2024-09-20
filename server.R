library(shiny)
library(ggplot2)

function(input, output) {

  setwd("C:/Users/umirandasenra/Documents/iut_sd2_rshiny_enedis")
  adresse = read.csv(file = "adresses-73.csv", header = TRUE, sep = ";", dec = ".")

  library(httr)
  library(jsonlite)

    base_url <- "https://data.ademe.fr/datasets/dpe-v2-logements-neufs/api-doc"
    code_postal = "73*"

    # Initialisation des paramètres de requête
    size <- 1000   # Taille des paquets (limite de 10 000 par page * size)
    page <- 1      # Pagination
    df_neufs <- data.frame()  # Dataframe pour stocker les résultats

    repeat {
    # Paramètres de la requête
    params <- list(
      page = page,
      size = size,
      select = "N°DPE,Etiquette_DPE,Date_réception_DPE",
      q = code_postal,
      q_fields = "Code_postal_(BAN)",
      qs = ""
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

    # Ajouter les données récupérées à l'ensemble complet
    df_neufs <- rbind(all_data, data)

    # Si la page contient moins de résultats que la taille demandée, on sort de la boucle
    if (nrow(data) < size) {
      break
    }

    # Incrémenter la page pour la prochaine requête
    page <- page + 1

    # Pause après chaque 600 requêtes pour respecter les limitations de l'API
    if (page %% 600 == 0) {
      Sys.sleep(60)  # Pause de 60 secondes
    }
    }
    # Afficher les données complètes récupérées
    print(df_neufs)

    
#df_existant à faire !!!
  base_url <- "https://data.ademe.fr/datasets/dpe-v2-logements-existants/api-doc"
  
  # Paramètres de la requête
  params <- list(
    page = 
    size = 
    select = "N°DPE,Etiquette_DPE,Date_réception_DPE",
    q = code_postal,
    q_fields = "Code_postal_(BAN)",
    qs = ""
  ) 
  
  # Encodage des paramètres
  url_encoded <- modify_url(base_url, query = params)
  print(url_encoded)
  
  # Effectuer la requête
  response <- GET(url_encoded)
  
  # Afficher le statut de la réponse
  print(status_code(response))
  
  # On convertit le contenu brut (octets) en une chaîne de caractères (texte). Cela permet de transformer les données reçues de l'API, qui sont généralement au format JSON, en une chaîne lisible par R
  content = fromJSON(rawToChar(response$content), flatten = FALSE)
  
  # Afficher le nombre total de ligne dans la base de données
  print(content$total)
  
  # Afficher les données récupérées
  df_existants <- content$result

}
