# Logements en Savoie - Visualisation Interactive

Ce projet Shiny permet de visualiser les logements situés en Savoie, France. Les données proviennent de l'API publique de l'ADEME, et l'application affiche une carte interactive avec des informations sur les logements existants et neufs, ainsi qu'une analyse graphique.

## Fonctionnalités
### 1. Cartographie interactive
Affichage des logements sur une carte interactive utilisant leaflet, avec possibilité de zoom et navigation. Les points représentent les logements, et chaque point peut être cliqué pour révéler des informations détaillées telles que :
- L'ID du logement
- L'étiquette DPE (A à G)
- La date de réception du logement
- Le coût du chauffage et la consommation énergétique

### 2. Filtrage par étiquette DPE
Les logements sont colorés selon leur étiquette de performance énergétique (DPE), allant de A (meilleure performance) à G (plus énergivore), facilitant l'identification visuelle des performances énergétiques sur la carte.

### 3. Données existants/neufs
L'application permet de charger et visualiser les données des logements existants et neufs en Savoie via l'API ADEME. Les utilisateurs peuvent comparer les performances énergétiques des nouveaux logements par rapport à ceux plus anciens.

### 4. Visualisation des données
Un nuage de points est disponible dans l'onglet "Données", affichant la répartition des logements par diverses caractéristiques, telles que :
- Année de construction
- Type de bâtiment (maison, appartement, immeuble, etc.)
- Surface habitable
- Conso énergétique (5 usages énergétiques majeurs)

### 5. Graphiques d'analyse
Des graphes interactifs sont inclus, permettant une analyse approfondie des caractéristiques des logements, telles que :
- Histogrammes de consommation énergétique
- Boîtes à moustaches pour analyser les écarts de consommation entre les types de bâtiments
- Modèle de régression linéaire pour estimer la relation entre l'année de construction et le DPE des logements.

### 6. Thème sombre/clair
L'application inclut un mode sombre/clair que l'utilisateur peut activer pour ajuster l'interface à ses préférences visuelles, via le package shinyjs.

### 7. Système de pop-ups
Sur la carte, chaque point dispose d'un popup qui affiche un résumé des informations clés du logement. Ce système rend la navigation et l'interaction plus fluides.

### 8. Documentation et informations
Un onglet Informations est inclus, où une documentation est fournie sur :
- Le fonctionnement général de l'application
- Une explication des étiquettes DPE
- L'importance de la rénovation énergétique des logements en France.

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
- Une fois l'application lancée, cliquez sur le bouton "Charger les données" pour récupérer les informations sur les logements via l'API.
- Explorez la carte interactive, cliquez sur les points pour afficher des informations détaillées sur les logements.
- Accédez à l'onglet "Données" pour visualiser le nuage de points qui montre la répartition des logements selon plusieurs critères.
- Utilisez les graphes interactifs pour approfondir votre analyse des logements et des données énergétiques.
