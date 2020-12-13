library(rgdal)
library(dplyr)
library(leaflet)
library(rgeos)

# Transformations
library(sf)

# Color palettes
library(RColorBrewer)

# Geodata from here - https://geoportaal.maaamet.ee/est/Andmed-ja-kaardid/Haldus-ja-asustusjaotus-p119.html
# Tutorial from here - https://www.r-graph-gallery.com/183-choropleth-map-with-leaflet.html

# Setting the current working directory to be the one that the script is in
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# verbose - report progress
tartu_voronoi_spdf <- readOGR(
  dsn = paste0(getwd(), "/shape_files/tartu_linn_voronoi"),
  layer = "tartu_linn_voronoi_v3",
  verbose = FALSE
)

ev_home_locations_spdf <- readOGR(
  dsn = paste0(getwd(), "/shape_files/ev_home_locations"),
  layer = "ev_home_locations",
  verbose = FALSE
)

public_charger_locations_spdf <- readOGR(
  dsn = paste0(getwd(), "/shape_files/public_charger_locations"),
  layer = "public_charger_locations",
  verbose = FALSE
)

grid_locations_spdf <- readOGR(
  dsn = paste0(getwd(), "/shape_files/grid_locations"),
  layer = "grid_locations",
  verbose = FALSE
)

# Clean data
tartu_voronoi_spdf@data$field_1 <- as.numeric(as.character(tartu_voronoi_spdf@data$field_1))
grid_locations_spdf@data$field_1 <- as.numeric(as.character(grid_locations_spdf@data$field_1))

tartu_voronoi_spdf@data$max_curren <- as.numeric(as.character(tartu_voronoi_spdf@data$max_curren))
grid_locations_spdf@data$max_curren <- as.numeric(as.character(grid_locations_spdf@data$max_curren))

tartu_voronoi_spdf@data$load_ratio_percent <- as.numeric(tartu_voronoi_spdf@data$field_1/tartu_voronoi_spdf@data$max_curren*100)
grid_locations_spdf@data$load_ratio_percent <- as.numeric(grid_locations_spdf@data$field_1/grid_locations_spdf@data$max_curren*100)

# Create a color palette for the map:
mybins_tartu <- c(0, 25, 50, 75, 100, 125, 150, 200)
mybins_load_ratio <- c(0, 25, 50, 75, 100, 125, 150, 200, Inf)

# https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html#:~:text=The%20RColorBrewer%20package%20offers%20several%20color%20palette%20for%20R.&text=There%20are%203%20types%20of,colors%20for%20high%20data%20values.

mypalette_tartu <- colorBin( 
  palette="YlOrBr", 
  domain=tartu_voronoi_spdf@data$field_1, 
  na.color="transparent", 
  bins=mybins_tartu)

mypalette_load_ratio <- colorBin( 
  palette="RdYlGn", 
  # palette="Spectral", 
  # palette="RdYlBu", 
  reverse = TRUE,
  domain=tartu_voronoi_spdf@data$load_ratio_percent, 
  na.color="transparent", 
  bins=mybins_load_ratio
)

# Prepare the text for tooltips:
mytext_tartu <- paste(
  "<b>Electricity Grid Voronoi Polygon</b><br>",
  "<b>Cadaster: </b>", tartu_voronoi_spdf@data$cadaster,"<br/>", 
  "<b>Max Load:</b> ", tartu_voronoi_spdf@data$max_curren, " kWh<br/>", 
  "<b>Predicted Load:</b> ", tartu_voronoi_spdf@data$field_1, " kWh<br/>",
  "<b>Load Ratio Percent:</b> ", tartu_voronoi_spdf@data$load_ratio_percent, "%", 
  sep="") %>%
  lapply(htmltools::HTML)

mytext_grid <- paste(
  "<b>Electricity Grid Station</b><br>",
  "<b>Cadaster:</b> ", grid_locations_spdf@data$cadaster,"<br/>", 
  "<b>Address:</b> ", grid_locations_spdf@data$address,"<br/>", 
  "<b>Max Load:</b> ", grid_locations_spdf@data$max_curren, " kWh<br/>", 
  "<b>Predicted Load:</b> ", grid_locations_spdf@data$field_1, " kWh<br/>", 
  "<b>Load Ratio Percent:</b> ", grid_locations_spdf@data$load_ratio_percent, "%",
  sep="") %>%
  lapply(htmltools::HTML)

mytext_ev_home <- paste(
  "<b>Home EV Charger</b><br>",
  "<b>Cadaster:</b> ", ev_home_locations_spdf@data$cadaster,"<br/>", 
  "<b>Address:</b> ", ev_home_locations_spdf@data$address,"<br/>", 
  sep="") %>%
  lapply(htmltools::HTML)

mytext_public <- paste(
  "<b>Public EV Charger</b><br>",
  "<b>Cadaster:</b> ", public_charger_locations_spdf@data$cadaster,"<br/>", 
  "<b>Address:</b> ", public_charger_locations_spdf@data$address,"<br/>",  
  sep="") %>%
  lapply(htmltools::HTML)

# Final Map - Tartu
# Map with load percent ratio
m <- leaflet() %>% 
  # TODO: Experiment with different tiles
  #addTiles()  %>% 
  addProviderTiles(providers$Esri.WorldGrayCanvas)  %>% 
  setView( lat=58.37, lng=26.72 , zoom=13) %>%
  
  # Adding voronoi polygons - Load Ratio
  addPolygons(
    data = tartu_voronoi_spdf,
    fillColor = ~mypalette_load_ratio(load_ratio_percent), 
    stroke=TRUE, 
    fillOpacity = 0.6, 
    color="white", 
    weight=2.5,
    label = mytext_tartu,
    highlightOptions = highlightOptions(color = "black", weight = 7,
                                        bringToFront = TRUE),
    labelOptions = labelOptions( 
      style = list("font-weight" = "normal", padding = "3px 8px"), 
      textsize = "13px", 
      direction = "auto"
    ),
    group = "Predicted Load Ratio Percent"
    
  ) %>%
  
  # Adding voronoi polygons - Absolute values
  addPolygons(
    data = tartu_voronoi_spdf,
    fillColor = ~mypalette_tartu(field_1), 
    stroke=TRUE, 
    fillOpacity = 0.6, 
    color="white", 
    weight=2.5,
    label = mytext_tartu,
    highlightOptions = highlightOptions(color = "black", weight = 7,
                                        bringToFront = TRUE),
    labelOptions = labelOptions( 
      style = list("font-weight" = "normal", padding = "3px 8px"), 
      textsize = "13px", 
      direction = "auto"
    ),
    group = "Absolute Predicted Loads"
    
  ) %>%

  addMarkers(
    data = grid_locations_spdf,
    label = mytext_grid,
    icon = list(
      # iconUrl = 'http://icons.iconarchive.com/icons/artua/star-wars/128/Master-Joda-icon.png',
      # iconUrl = 'https://static.thenounproject.com/png/104287-200.png',
      iconUrl = 'https://cdn0.iconfinder.com/data/icons/mobile-device/512/electricity-electrical-plug-blue-round-2-512.png',
      iconSize = c(40, 40)
    ),
    labelOptions = labelOptions( 
      style = list("font-weight" = "normal", padding = "3px 8px"), 
      textsize = "13px", 
      direction = "auto"
    ),
    group = "Electricity Grid Stations"
  ) %>%

  addMarkers(
    data = ev_home_locations_spdf,
    label = mytext_ev_home,
    icon = list(
      iconUrl = 'https://cdn0.iconfinder.com/data/icons/smart-home/454/16-_Smart_home-512.png',
      # iconUrl = 'https://cdn.iconscout.com/icon/premium/png-256-thumb/home-charger-2773008-2336757.png',
      iconSize = c(30, 30)
    ),
    labelOptions = labelOptions( 
      style = list("font-weight" = "normal", padding = "3px 8px"), 
      textsize = "13px", 
      direction = "auto"
    ),
    group = "Home EV Chargers"
  ) %>%

  addMarkers(
    data = public_charger_locations_spdf,
    label = mytext_public,
    icon = list(
      iconUrl = 'https://www.ohmhomenow.com/wp-content/uploads/2017/08/004-car.png',
      iconSize = c(30, 30)
    ),
    labelOptions = labelOptions( 
      style = list("font-weight" = "normal", padding = "3px 8px"), 
      textsize = "13px", 
      direction = "auto"
    ),
    group = "Public EV Chargers"
  ) %>%
  
  # Adding legend
  addLegend( pal=mypalette_load_ratio, 
             values=tartu_voronoi_spdf@data$load_ratio_percent, 
             opacity=0.9, title = "Load Ratio Percent (%)", 
             position = "bottomleft", 
             group = "Predicted Load Ratio Percent") %>% 
  
  # Adding legend
  addLegend( pal=mypalette_tartu, 
             values=tartu_voronoi_spdf@data$field_1, 
             opacity=0.9, title = "Absolute Predicted Loads (kWh)", 
             position = "bottomright", 
             group = "Absolute Predicted Loads") %>%
  
  addLayersControl(
    baseGroups = c("Predicted Load Ratio Percent", "Absolute Predicted Loads"),
    overlayGroups = c("Electricity Grid Stations", "Public EV Chargers", "Home EV Chargers"),
    options = layersControlOptions(collapsed = FALSE)
  )  %>% 
  hideGroup("Public EV Chargers") %>% 
  hideGroup("Home EV Chargers") 
  


  

m  

# Look at layer controls here: https://rstudio.github.io/leaflet/showhide.html
# TODO: Make a Shiny dashboard
# TODO: Find a way to visualize 24h of data
# TODO: Find suitable icons for home and public charger locations
# TODO: Add border to whole Tartu polygon
# TODO: Change color scheme
# TODO: Legend dependent on active layer - undoable without some particular hacks
