---
title: "Analyse des Logements Neufs et Anciens"
output: 
  flexdashboard::flex_dashboard:
    orientation: rows
    vertical_layout: fill
runtime: shiny
---

```{r setup, include=FALSE}
library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(flexdashboard)

# Calcul des KPI
total_logements <- nrow(df)
logements_neufs <- df %>% filter(logement == "neufs") %>% nrow()
logements_anciens <- df %>% filter(logement == "anciens") %>% nrow()

# Pourcentages
percent_neufs <- round((logements_neufs / total_logements) * 100, 2)
percent_anciens <- round((logements_anciens / total_logements) * 100, 2)

# Affichage des KPI
valueBox(
  value = total_logements, 
  caption = "Total Logements"
)
valueBox(
  value = paste0(percent_neufs, "%"), 
  caption = "Logements Neufs"
)
valueBox(
  value = paste0(percent_anciens, "%"), 
  caption = "Logements Anciens"
)

# Répartition des logements
df_repartition <- df %>% 
  group_by(logement) %>% 
  summarise(count = n())

# Graphique en camembert
ggplot(df_repartition, aes(x="", y=count, fill=logement)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y") +
  labs(title="Répartition des Logements", x=NULL, y=NULL) +
  theme_void() +
  scale_fill_manual(values=c("neufs" = "#00BFC4", "anciens" = "#F8766D"))

# Graphique de distribution des prix (selon le type de logement)
ggplot(df, aes(x=logement, y=prix, fill=logement)) +
  geom_boxplot() +
  labs(title="Distribution des Prix par Type de Logement", x="Type de Logement", y="Prix") +
  scale_fill_manual(values=c("neufs" = "#00BFC4", "anciens" = "#F8766D")) +
  theme_minimal()

# Tableau récapitulatif des données
datatable(df, options = list(pageLength = 10, autoWidth = TRUE))

# Filtre pour les logements
selectInput("logement_type", "Choisissez le type de logement", 
            choices = c("Tous" = "all", "Neufs" = "neufs", "Anciens" = "anciens"))

filtered_data <- reactive({
  if (input$logement_type == "all") {
    df
  } else {
    df %>% filter(logement == input$logement_type)
  }
})

# Tableau récapitulatif avec filtre
output$table <- DT::renderDataTable({
  datatable(filtered_data(), options = list(pageLength = 10))
})

DT::dataTableOutput("table")
