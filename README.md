# Logements en Savoie - Visualisation Interactive

Ce projet Shiny permet de visualiser les logements situés en Savoie, France. Les données proviennent de l'API publique de l'ADEME, et l'application affiche une carte interactive avec des informations sur les logements existants et neufs, ainsi qu'une analyse graphique.

## Fonctionnalités
- Cartographie interactive : Visualisation des logements sur une carte avec leurs coordonnées GPS.
- Filtrage par étiquette DPE : Coloration des logements en fonction de leur étiquette DPE (A à G).
- Données existants/neufs : Chargement des données des logements existants et neufs via l'API ADEME.
- Nuage de points : Visualisation de la répartition géographique des logements dans l'onglet "Données".
  
## Installation
### Prérequis
- R version 4.0 ou supérieure
- RStudio (optionnel, mais recommandé pour l'exécution de projets Shiny)
  
### Étapes
Cloner le repository GitHub sur votre machine locale :
    git clone https://github.com/iut_sd2_rshiny_enedis/logements-savoie.git  
Ouvrir le projet R dans RStudio (Projet_R_shinny.Rproj).

Installer les packages nécessaires avec la commande suivante dans R :
    install.packages(c('shiny', 'leaflet', 'shinydashboard', 'httr', 'jsonlite', 'ggplot2', 'data.table', 'shinyjs'))
Démarrer l'application Shiny :
    shiny::runApp()

## Utilisation
Une fois l'application lancée, cliquez sur "Charger les données" pour récupérer les informations sur les logements.
Explorez la carte interactive, et cliquez sur les points pour afficher des détails comme l'ID du logement, l'étiquette DPE, et la date de réception.
Accédez à l'onglet "Données" pour voir un nuage de points montrant la répartition des logements.
