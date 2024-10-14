# Ajouter un miroir CRAN pour éviter l'erreur sur shinyapps.io
options(repos = c(CRAN = "https://cran.rstudio.com/"))

install.packages(c('shiny', 'leaflet', 'shinydashboard', 'httr', 'jsonlite', 'ggplot2','leaflet.extras','shinyjs','rsconnect'))
library(shiny)
library(leaflet)
library(shinydashboard)
library(httr)
library(jsonlite)
library(ggplot2)
library(leaflet.extras)
library(shinyjs)
library(rsconnect)

# Lecture du fichier CSV local
adresse <- read.csv(file = "adresses-73.csv", header = TRUE, sep = ";", dec = ".")

# Variables et URLs API
code_postal <- "73*"
size <- 10000
df_existants <- data.frame()
df_neufs <- data.frame()
Date_existants <- 2021
Date_neufs <- 2021
base_url_existants <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"
base_url_neufs <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-neufs/lines"

# Récupération des données depuis l'API
# Pour logements existants
repeat {
  params <- list(
    page = 1,
    size = size,
    select = "N°DPE,Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN),Identifiant__BAN,Conso_5_usages_é_finale,Surface_habitable_logement,Coût_chauffage",
    q = code_postal,
    q_fields = "Code_postal_(BAN)",
    qs = paste0("Date_réception_DPE:[", Date_existants, "-01-01 TO ", Date_existants, "-12-31]")
  )
  
  url_encoded <- modify_url(base_url_existants, query = params)
  response <- GET(url_encoded, timeout(60))
  
  if (status_code(response) != 200) {
    stop("Erreur dans la requête : ", status_code(response))
  }
  
  content <- fromJSON(rawToChar(response$content), flatten = FALSE)
  data <- content$result
  df_existants <- rbind(df_existants, data)
  
  Date_existants <- Date_existants + 1
  if (Date_existants == 2030) {
    break
  }
  Sys.sleep(2)
}

# Pour logements neufs
repeat {
  params <- list(
    page = 1,
    size = size,
    select = "N°DPE,Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN),Identifiant__BAN,Conso_5_usages_é_finale,Surface_habitable_logement,Coût_chauffage",
    q = code_postal,
    q_fields = "Code_postal_(BAN)",
    qs = paste0("Date_réception_DPE:[", Date_neufs, "-01-01 TO ", Date_neufs, "-12-31]")
  )
  
  url_encoded <- modify_url(base_url_neufs, query = params)
  response <- GET(url_encoded, timeout(60))
  
  if (status_code(response) != 200) {
    stop("Erreur dans la requête : ", status_code(response))
  }
  
  content <- fromJSON(rawToChar(response$content), flatten = FALSE)
  data <- content$result
  df_neufs <- rbind(df_neufs, data)
  
  Date_neufs <- Date_neufs + 1
  if (Date_neufs == 2030) {
    break
  }
  Sys.sleep(2)
}

df_existants$type_logement <- "Existant"
df_neufs$type_logement <- "Neufs"
df_logement <- rbind(df_existants, df_neufs)
df_logement <- df_logement[!is.na(df_logement$'Coordonnée_cartographique_X_(BAN)') &
                             !is.na(df_logement$'Coordonnée_cartographique_Y_(BAN)'), ]

# Transformation des coordonnées en numérique pour les deux dataframes
df_logement$'Coordonnée_cartographique_X_(BAN)' <- as.numeric(df_logement$'Coordonnée_cartographique_X_(BAN)')
df_logement$'Coordonnée_cartographique_Y_(BAN)' <- as.numeric(df_logement$'Coordonnée_cartographique_Y_(BAN)')

adresse$x <- as.numeric(adresse$x)  
adresse$y <- as.numeric(adresse$y)  

# Jointure entre df_logement et adresse sur les colonnes de coordonnées
df_principale <- merge(df_logement, adresse, 
                       by.x = c("Coordonnée_cartographique_X_(BAN)", "Coordonnée_cartographique_Y_(BAN)"), 
                       by.y = c("x", "y"), 
                       all.x = TRUE)

# Création du modèle de régression linéaire
linear_model <- lm(lat ~ Date_réception_DPE, data = df_principale)

# Interface utilisateur (UI)
ui <- dashboardPage(
  dashboardHeader(
  title = tags$div(
    style = "display: flex; align-items: center; height: 50px;",  
    tags$img(src = "logo_savoie.jpg", height = "40px", style = "margin-right: 10px; margin-top: 5px;"),  
    tags$span(style = "line-height: 40px; font-size: 20px;", "Logements en Savoie")
  )
),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Présentation", tabName = "info", icon = icon("info-circle")),
      menuItem("Cartographie", tabName = "cartography", icon = icon("map")),
      menuItem("Graphiques", tabName = "data", icon = icon("table")),
      actionButton("theme_btn", "Changer en thème sombre", icon = icon("moon"))
    )
  ),
   dashboardBody(
     useShinyjs(),
    # Chargement du fichier CSS
    tags$head(
      tags$style(HTML("
      body {
        transition: background-color 0.3s, color 0.3s;
        background-color: #f5f5f5;
      }
      .dark-theme {
        background-color: #121212;
        color: #ffffff;
      }
      .dark-theme .box {
        background-color: #1e1e1e;
        color: #ffffff;
      }
      .dark-theme .shiny-output-error {
        color: #ff4d4d;
      }
      .dark-theme .leaflet-container {
        background: #121212;
      }
      .dark-theme .main-header, .dark-theme .main-sidebar {
        background-color: #1e1e1e;
        color: #ffffff;
      }
      .dark-theme .main-sidebar .sidebar-menu a {
        color: #ffffff;
      }
      .dark-theme .main-header .navbar {
        background-color: #1e1e1e;
      }
      .dark-theme .main-header .navbar .sidebar-toggle {
        color: #ffffff;
      }
      .dark-theme #Savoie_map {
        background-color: #121212;
      }
      .dark-theme .content-wrapper {
        background-color: #121212;
      }
    ")),
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      tabItem(tabName = "cartography",
              leafletOutput("Savoie_map", height = "600px")
      ),
      tabItem(tabName = "info",
              h2("Présentation du projet"),
              tags$div(class = "gras", "Ce projet a été réalisé par Anthony et Lucas."),
              p("Cette application permet de visualiser les logements en Savoie en fonction de leur consommation énergétique et de leur étiquette DPE."),
              p("L'étiquette DPE (Diagnostic de Performance Énergétique) est un document qui classe les logements de ", 
                tags$span(class = "italique", "A à G"), " selon leur consommation d'énergie."),
              p("Rénover les logements pour améliorer leur lettre DPE est crucial pour réduire la consommation d'énergie et lutter contre le changement climatique. Une meilleure performance énergétique permet également de diminuer les factures de chauffage."),
              p("Les utilisateurs peuvent explorer les données, visualiser les logements existants et neufs, et analyser différentes métriques concernant l'énergie."),
              tags$img(src = "/Savoie_image.jpg", alt = "Image de Savoie", style = "width: 100%; height: auto;")
      ),
      # Onglet Données avec l'histogramme et la boîte à moustache
      tabItem(tabName = "data",
              h2("Analyse des données"),
              
              # Nuage de points pour la consommation énergétique
              plotOutput("scatter_plot"),
              downloadButton("download_scatter", "Exporter le graphique en PNG"),
              downloadButton("download_scatter_data", "Exporter les données en CSV"),
              
              # Histogramme pour les étiquettes DPE
              plotOutput("bar_plot"),
              downloadButton("download_bar", "Exporter le graphique en PNG"),
              downloadButton("download_bar_data", "Exporter les données en CSV"),
              
              # Filtres
              fluidRow(
                column(6,
                       selectInput("type_logement_filter", "Type de logement:", 
                                   choices = unique(df_logement$type_logement), 
                                   selected = unique(df_logement$type_logement),
                                   multiple = TRUE)
                ),
                column(6,
                       sliderInput("coût_chauffage_filter", "Coût du chauffage:", 
                                   min = min(df_logement$Coût_chauffage, na.rm = TRUE), 
                                   max = max(df_logement$Coût_chauffage, na.rm = TRUE), 
                                   value = c(min(df_logement$Coût_chauffage, na.rm = TRUE), max(df_logement$Coût_chauffage, na.rm = TRUE)))
                )
              ),
              # Boîte à moustaches pour le Coût_chauffage
              plotOutput("boxplot_coût_chauffage"),
              downloadButton("download_boxplot", "Exporter le graphique en PNG"),
              downloadButton("download_boxplot_data", "Exporter les données en CSV"),

              # Diagramme circulaire pour la proportion des étiquettes DPE
              plotOutput("pie_chart"),
              downloadButton("download_pie", "Exporter le graphique en PNG"),
              downloadButton("download_pie_data", "Exporter les données en CSV"),
              
              # Tableau de Régression Linéaire simplifié
              tableOutput("linear_model_output"),
              verbatimTextOutput("correlation_output"),
              downloadButton("download_lin", "Exporter le graphique en PNG"),
              downloadButton("download_lin_data", "Exporter les données en CSV"),
              
              
      )    
      )
    )
  )

# Serveur
server <- function(input, output, session) {

  # Variable pour suivre l'état du thème
  theme_dark <- reactiveVal(FALSE)
  
  # Filtrage des données en fonction des sélections
  filtered_data <- reactive({
    df_filtered <- df_logement
    if (length(input$type_logement_filter) > 0) {
      df_filtered <- df_filtered[df_filtered$type_logement %in% input$type_logement_filter, ]
    }
    df_filtered <- df_filtered[df_filtered$Coût_chauffage >= input$coût_chauffage_filter[1] & 
                                 df_filtered$Coût_chauffage <= input$coût_chauffage_filter[2], ]
    return(df_filtered)
  })
  
  # Carte Leaflet
  output$Savoie_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(
        lng = df_principale$lon,
        lat = df_principale$lat,
        popup = paste("Logement ID:", df_principale$`N°DPE`, "<br>",
                      "Etiquette DPE:", df_principale$Etiquette_DPE, "<br>",
                      "Date de réception DPE:", df_principale$Date_réception_DPE),
        clusterOptions = markerClusterOptions()
      ) %>%
      setView(lng = 5.9162, lat = 45.6884, zoom = 8)
  })
  
  output$scatter_plot <- renderPlot({
    ggplot(df_principale, aes(x = Surface_habitable_logement, y = Conso_5_usages_é_finale, color = type_logement)) +
      geom_point() +
      scale_y_log10() +  
      labs(
        title = "Consommation énergétique selon la surface habitable",
        x = "Surface habitable (m²)",
        y = "Consommation énergétique (kWh, échelle log)"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Téléchargement du nuage de points
  output$download_scatter <- downloadHandler(
    filename = function() {
      paste("scatter_plot", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      png(file)
      print(ggplot(df_principale, aes(x = Surface_habitable_logement, y = Conso_5_usages_é_finale, color = type_logement)) +
              geom_point() +
              scale_y_log10() +  
              labs(
                title = "Consommation énergétique selon la surface habitable",
                x = "Surface habitable (m²)",
                y = "Consommation énergétique (kWh, échelle log)"
              ) +
              theme_minimal() +
              theme(axis.text.x = element_text(angle = 45, hjust = 1)))
      dev.off()
    }
  )
  
  # Téléchargement des données du nuage de points
  output$download_scatter_data <- downloadHandler(
    filename = function() {
      paste("scatter_plot_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(df_principale, file, row.names = FALSE)
    }
  )
  
  # Histogramme pour les étiquettes DPE
  output$bar_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = Etiquette_DPE, fill = type_logement)) +
      geom_bar(position = "dodge") + 
      theme_minimal() +
      labs(title = "Comparaison des étiquettes DPE entre les logements existants et neufs",
           x = "Etiquette DPE",
           y = "Nombre de logements",
           fill = "Type de logement") +
      theme(legend.position = "right")
  })
  
  # Téléchargement de l'histogramme
  output$download_bar <- downloadHandler(
    filename = function() {
      paste("bar_plot", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      png(file)
      print(ggplot(filtered_data(), aes(x = Etiquette_DPE, fill = type_logement)) +
              geom_bar(position = "dodge") + 
              theme_minimal() +
              labs(title = "Comparaison des étiquettes DPE entre les logements existants et neufs",
                   x = "Etiquette DPE",
                   y = "Nombre de logements",
                   fill = "Type de logement") +
              theme(legend.position = "right"))
      dev.off()
    }
  )
  
  # Téléchargement des données de l'histogramme
  output$download_bar_data <- downloadHandler(
    filename = function() {
      paste("bar_plot_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(as.data.frame(table(filtered_data()$Etiquette_DPE)), file, row.names = FALSE)
    }
  )
  
  # Boîte à moustaches pour le Coût_chauffage
  output$boxplot_coût_chauffage <- renderPlot({
    ggplot(filtered_data(), aes(x = type_logement, y = Coût_chauffage, fill = type_logement)) +
      geom_boxplot() +
      theme_minimal() +
      labs(title = "Boîte à moustaches du coût du chauffage par type de logement",
           x = "Type de logement",
           y = "Coût du chauffage")
  })
  
  # Téléchargement de la boîte à moustaches
  output$download_boxplot <- downloadHandler(
    filename = function() {
      paste("boxplot", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      png(file)
      print(ggplot(filtered_data(), aes(x = type_logement, y = Coût_chauffage, fill = type_logement)) +
              geom_boxplot() +
              theme_minimal() +
              labs(title = "Boîte à moustaches du coût du chauffage par type de logement",
                   x = "Type de logement",
                   y = "Coût du chauffage"))
      dev.off()
    }
  )
  
  # Téléchargement des données de la boîte à moustaches
  output$download_boxplot_data <- downloadHandler(
    filename = function() {
      paste("boxplot_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data()[, c("type_logement", "Coût_chauffage")], file, row.names = FALSE)
    }
  )
  
  # Diagramme circulaire pour la proportion des étiquettes DPE
  output$pie_chart <- renderPlot({
    dpe_counts <- as.data.frame(table(df_logement$Etiquette_DPE))
    colnames(dpe_counts) <- c("Etiquette_DPE", "Count")
    dpe_counts$Percentage <- dpe_counts$Count / sum(dpe_counts$Count) * 100
    
    # Définir les couleurs pour les étiquettes DPE
    dpe_counts$Color <- factor(dpe_counts$Etiquette_DPE,
                               levels = c("A", "B", "C", "D", "E", "F", "G"),
                               labels = c("#005f00", "#008000", "#00b300", "#b3b300", "#b38f00", "#b30000", "#ff0000")) # Vert à Rouge
    
    ggplot(dpe_counts, aes(x = "", y = Count, fill = Etiquette_DPE)) +
      geom_bar(stat = "identity", width = 1) +
      geom_label(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5), color = "white") +
      coord_polar(theta = "y") +
      scale_fill_manual(values = c("A" = "#005f00", "B" = "#008000", "C" = "#00b300", 
                                   "D" = "#b3b300", "E" = "#b38f00", "F" = "#b30000", 
                                   "G" = "#ff0000")) +  # Définir les couleurs dans la légende
      theme_void() +
      labs(title = "Proportion des étiquettes DPE") +
      theme(legend.title = element_blank(), legend.position = "right")
  })
  
  # Téléchargement du diagramme circulaire
output$download_pie <- downloadHandler(
  filename = function() {
    paste("pie_chart", Sys.Date(), ".png", sep = "")
  },
  content = function(file) {
    png(file)
    print(ggplot(dpe_counts, aes(x = "", y = Count, fill = Etiquette_DPE)) +
            geom_bar(stat = "identity", width = 1) +
            geom_label(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5), color = "white") +
            coord_polar(theta = "y") +
            scale_fill_manual(values = c("A" = "#005f00", "B" = "#008000", "C" = "#00b300", 
                                         "D" = "#b3b300", "E" = "#b38f00", "F" = "#b30000", 
                                         "G" = "#ff0000")) +
            theme_void() +
            labs(title = "Proportion des étiquettes DPE") +
            theme(legend.title = element_blank(), legend.position = "right"))
    dev.off()
  }
)

# Téléchargement des données du diagramme circulaire
output$download_pie_data <- downloadHandler(
  filename = function() {
    paste("pie_chart_data", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(dpe_counts, file, row.names = FALSE)
  }
)

# Tableau de régression linéaire simplifié
output$linear_model_output <- renderTable({
  title <- h3("Tableau de régression linéaire simplifié")
  model_summary <- summary(linear_model)$coefficients
  concise_output <- data.frame(
    Coefficient = c(model_summary[1, 1], model_summary[2, 1]),  # Intercept et pente
    p_value = c(model_summary[1, 4], model_summary[2, 4])  # Valeurs de p
  )
  rownames(concise_output) <- c("Intercept", "Date de réception DPE")
  concise_output
}, rownames = TRUE)

# Télécharger en CSV
output$download_lin_data <- downloadHandler(
  filename = function() {
    paste("regression_table_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(output$linear_model_output(), file, row.names = TRUE)
  }
)

# Télécharger en PNG
output$download_lin <- downloadHandler(
  filename = function() {
    paste("regression_table_", Sys.Date(), ".png", sep = "")
  },
  content = function(file) {
    png(file, width = 800, height = 600)
    grid::grid.newpage()
    grid::grid.table(output$linear_model_output())
    dev.off()
  }
)

# Affichage des résultats de la corrélation
output$correlation_output <- renderPrint({
  cor(df_principale$lat, df_principale$Conso_5_usages_é_finale, use = "complete.obs")
})

# Changement de thème
observeEvent(input$theme_btn, {
  theme_dark(!theme_dark())
  session$sendCustomMessage(type = "toggle_theme", message = theme_dark())
  updateActionButton(session, "theme_btn", 
                     label = ifelse(theme_dark(), "Changer en thème clair", "Changer en thème sombre"), 
                     icon = icon(ifelse(theme_dark(), "sun", "moon")))
  if (theme_dark()) {
    shinyjs::addClass(selector = "body", class = "dark-theme")
  } else {
    shinyjs::removeClass(selector = "body", class = "dark-theme")
  }
})
}

shinyApp(ui = ui, server = server)
