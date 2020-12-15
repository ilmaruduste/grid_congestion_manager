

# Color palettes
library(RColorBrewer)
library(rgdal)
library(dplyr)
library(leaflet)
library(rgeos)
library(shiny)
library(shinythemes) #For stylization
library(shinyWidgets) #For more elegant category selection

# Set Working Directory to the folder where this script is located
getwd()


# verbose - report progress
tartu_voronoi_spdf <- readOGR(
    dsn = paste0(getwd(), "/shape_files/tartu_linn_voronoi"),
    layer = "tartu_linn_grid_voronois_v9_ordered",
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
    layer = "grid_locations_v9",
    verbose = FALSE
)

# QGIS shape files lose column names for some reason. Renaming them here.
names(grid_locations_spdf@data)[names(grid_locations_spdf@data) == "predicted_"] <- "predicted_ev_load"
names(grid_locations_spdf@data)[names(grid_locations_spdf@data) == "combined_l"] <- "combined_load"
names(grid_locations_spdf@data)[names(grid_locations_spdf@data) == "predicte_1"] <- "predicted_combined_load"
# grid_locations_spdf@data[is.na(grid_locations_spdf@data)] <- 0


# names(tartu_voronoi_spdf@data)[names(tartu_voronoi_spdf@data) == "predicted_"] <- "predicted_ev_load"
# names(tartu_voronoi_spdf@data)[names(tartu_voronoi_spdf@data) == "combined_l"] <- "combined_load"
# names(tartu_voronoi_spdf@data)[names(tartu_voronoi_spdf@data) == "predicte_1"] <- "predicted_combined_load"
# tartu_voronoi_spdf@data[is.na(tartu_voronoi_spdf@data)] <- 0

names(grid_locations_spdf@data)
names(tartu_voronoi_spdf@data)

# Clean data
# tartu_voronoi_spdf@data$predicted_combined_load <- as.numeric(as.character(tartu_voronoi_spdf@data$predicted_combined_load))
grid_locations_spdf@data$combined_load <- round(as.numeric(as.character(grid_locations_spdf@data$combined_load)),2)
grid_locations_spdf@data$predicted_combined_load <- round(as.numeric(as.character(grid_locations_spdf@data$predicted_combined_load)),2)
grid_locations_spdf@data$p_throttle <- round(as.numeric(as.character(grid_locations_spdf@data$p_throttle)),2)
grid_locations_spdf@data$throttle <- round(as.numeric(as.character(grid_locations_spdf@data$throttle)),2)
grid_locations_spdf@data$total_char <- round(as.numeric(as.character(grid_locations_spdf@data$total_char)))

# tartu_voronoi_spdf@data$max_curren <- as.numeric(as.character(tartu_voronoi_spdf@data$max_curren))
grid_locations_spdf@data$max_curren <- as.numeric(as.character(grid_locations_spdf@data$max_curren))

# tartu_voronoi_spdf@data$load_ratio_percent <- round(as.numeric(tartu_voronoi_spdf@data$predicted_combined_load/tartu_voronoi_spdf@data$max_curren*100), 2)
grid_locations_spdf@data$load_ratio_percent <- round(as.numeric(grid_locations_spdf@data$predicted_combined_load/grid_locations_spdf@data$max_curren*100), 2)
grid_locations_spdf@data$load_ratio_percent_with_synthetic <- round(as.numeric(grid_locations_spdf@data$combined_load/grid_locations_spdf@data$max_curren*100), 2)

grid_locations_spdf@data$hour <- as.numeric(as.character(grid_locations_spdf@data$hour))
grid_locations_spdf@data$grid_id <- as.numeric(as.character(grid_locations_spdf@data$grid_id))
tartu_voronoi_spdf@data$grid_id <- as.numeric(as.character(tartu_voronoi_spdf@data$grid_id))

# Doing this since there are only 50 voronois, but I need all 
tartu_voronoi_spdf@data <- grid_locations_spdf@data
tartu_voronoi_spdf@data
grid_locations_spdf@data
# Sort by cadaster and then hour

# time_filtered_grids <- grid_locations_spdf
# time_filtered_grids@data <- time_filtered_grids@data %>% 
#     filter(hour == 0)
# time_filtered_grids@data$field_1
# time_filtered_grids@coords[time_filtered_grids@data$field_1,]

# time_filtered_data <- tartu_voronoi_spdf
# time_filtered_data@data <- time_filtered_data@data %>% 
#     filter(hour == 8) %>% 
#     arrange(grid_id)
# 
# # There's something wrong here. Try not to select all 1200 grid locations.
# # Yep, it's selecting all 1200 pairs of coords
# time_filtered_grids <- grid_locations_spdf
# time_filtered_grids@data <- time_filtered_grids@data %>%
#     filter(hour == 8) %>% 
#     arrange(grid_id)
# 
# grid_locations_spdf@data 
# time_filtered_data@data
# time_filtered_data@data[order(time_filtered_data@data$grid_id),]
# time_filtered_data@data$grid_id
# Create a color palette for the map:
mybins_tartu <- c(0, 25, 50, 75, 100, 125, 150, 200, Inf)
mybins_load_ratio <- c(0, 25, 50, 75, 100, 125, 150, 200, Inf)


# Color palettes
# https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html#:~:text=The%20RColorBrewer%20package%20offers%20several%20color%20palette%20for%20R.&text=There%20are%203%20types%20of,colors%20for%20high%20data%20values.
mypalette_tartu <- colorBin( 
    palette="YlOrBr", 
    domain=tartu_voronoi_spdf@data$predicted_combined_load, 
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


# Define UI for application that draws a histogram
ui <- fluidPage(
    # theme = shinytheme("lumen"), # http://rstudio.github.io/shinythemes/
    # theme = shinytheme("paper"), # http://rstudio.github.io/shinythemes/
    theme = shinytheme("flatly"), # http://rstudio.github.io/shinythemes/
    # theme = shinytheme("superhero"), # http://rstudio.github.io/shinythemes/
    
    navbarPage("P29 - Electricity Grid Congestion",
               
               tabPanel("Interactive Map",
                        
                        sidebarLayout(
                            sidebarPanel(
                                sliderInput("selected_hour",
                                            strong("Select the Hour of Day:"),
                                            min = 0,
                                            max = 23,
                                            value = 8)),
                        
                            mainPanel(
                                h1("Interacive Electricity Grid Congestion Map"),
                                
                                leafletOutput("map",
                                              width = "90%",
                                              # height = "1080px") # NB! Do not use % in height! Otherwise it will not display the map.
                                              height = "700px") # NB! Do not use % in height! Otherwise it will not display the map.
                            ))
                        ),
               
               tabPanel("Data Explanation",
                        mainPanel(
                            p("Hi, I should be filled with text!")
                        )),
               
               tabPanel("About"),
                        mainPanel(
                            p("Created by Ilmar Uduste, Joonas Ariva, Sille Habakukk and Katrin Raigla from the Data Science curriculum at the University of Tartu."),
                            p("This dashboard was made for a Machine Learning project in collaboration with Eesti Energia, 2020.")
                        )),
    
    # leafletOutput("map", width = "100%", height = "100%")
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$map <- renderLeaflet({
        leaflet() %>% 
            addProviderTiles(providers$Esri.WorldGrayCanvas)  %>% 
            setView( lat=58.37, lng=26.72 , zoom=13) %>%
    
            hideGroup("Public EV Chargers") %>%
            hideGroup("Home EV Chargers")
    })
    
    # https://rstudio.github.io/leaflet/shiny.html
    observe({
        
        # time_filtered_data <- tartu_voronoi_spdf %>% 
            # filter("hour" == input$selected_hour)
        
        time_filtered_data <- tartu_voronoi_spdf
        time_filtered_data@data <- time_filtered_data@data %>% 
            filter(hour == input$selected_hour) %>% 
            arrange(grid_id)
        
        # There's something wrong here. Try not to select all 1200 grid locations.
        # Yep, it's selecting all 1200 pairs of coords
        time_filtered_grids <- grid_locations_spdf
        time_filtered_grids@data <- time_filtered_grids@data %>%
            filter(hour == input$selected_hour) %>% 
            arrange(grid_id)
        
        # This method doesn't completely work. It doesn't select some of the grids
        time_filtered_grids@coords <- time_filtered_grids@coords[time_filtered_grids@data$grid_id,]
            
        mytext_tartu <- paste(
            "<b>Electricity Grid Voronoi Polygon</b><br>",
            "<b>Cadaster: </b>", time_filtered_data@data$cadaster,"<br/>", 
            "<b>Address:</b> ", time_filtered_data@data$address,"<br/>",
            "<b>Max Load:</b> ", time_filtered_data@data$max_curren, " kWh<br/>", 
            "<b>Nr. of Connected Chargers:</b> ", time_filtered_data@data$total_char, "<br/>", 
            "<br><b>Combined Load:</b> ", time_filtered_data@data$combined_load, " kWh<br/>", 
            "<b>Load Ratio Percent:</b> ", time_filtered_data@data$load_ratio_percent_with_synthetic, "%<br/>", 
            "<b>Throttle:</b> ", time_filtered_data@data$throttle, " kWh<br/>", 
            "<br><b>Predicted Combined Load:</b> ", time_filtered_data@data$predicted_combined_load, " kWh<br/>", 
            "<b>Predicted Load Ratio Percent:</b> ", time_filtered_data@data$load_ratio_percent, "%<br/>",
            "<b>Predicted Throttle:</b> ", time_filtered_data@data$p_throttle, " kWh",
            sep="") %>%
            lapply(htmltools::HTML)
        
        mytext_tartu_synthetic <- paste(
            "<b>Electricity Grid Voronoi Polygon</b><br>",
            "<b>Cadaster: </b>", time_filtered_data@data$cadaster,"<br/>", 
            "<b>Address:</b> ", time_filtered_data@data$address,"<br/>",
            "<b>Max Load:</b> ", time_filtered_data@data$max_curren, " kWh<br/>", 
            "<b>Nr. of Connected Chargers:</b> ", time_filtered_data@data$total_char, "<br/>", 
            "<br><b>Combined Load:</b> ", time_filtered_data@data$combined_load, " kWh<br/>", 
            "<b>Load Ratio Percent:</b> ", time_filtered_data@data$load_ratio_percent_with_synthetic, "%<br/>", 
            "<b>Throttle:</b> ", time_filtered_data@data$throttle, " kWh<br/>", 
            "<br><b>Predicted Combined Load:</b> ", time_filtered_data@data$predicted_combined_load, " kWh<br/>", 
            "<b>Predicted Load Ratio Percent:</b> ", time_filtered_data@data$load_ratio_percent, "%<br/>",
            "<b>Predicted Throttle:</b> ", time_filtered_data@data$p_throttle, " kWh",
            sep="") %>%
            lapply(htmltools::HTML)
        
        mytext_grid <- paste(
            "<b>Electricity Grid Station</b><br>",
            "<b>Cadaster:</b> ", time_filtered_grids@data$cadaster,"<br/>", 
            "<b>Address:</b> ", time_filtered_grids@data$address,"<br/>", 
            "<b>Max Load:</b> ", time_filtered_grids@data$max_curren, " kWh<br/>", 
            "<b>Nr. of Connected Chargers:</b> ", time_filtered_grids@data$total_char, "<br/>", 
            "<br><b>Combined Load:</b> ", time_filtered_grids@data$combined_load, " kWh<br/>", 
            "<b>Load Ratio Percent:</b> ", time_filtered_grids@data$load_ratio_percent_with_synthetic, "%<br/>",
            "<b>Throttle:</b> ", time_filtered_data@data$throttle, " kWh<br/>",  
            "<br><b>Predicted Combined Load:</b> ", time_filtered_grids@data$predicted_combined_load, " kWh<br/>", 
            "<b>Predicted Load Ratio Percent:</b> ", time_filtered_grids@data$load_ratio_percent, "%<br/>",
            "<b>Predicted Throttle:</b> ", time_filtered_grids@data$p_throttle, " kWh",
            sep="") %>%
            lapply(htmltools::HTML)
        
        
        proxy <- leafletProxy("map") %>% 
            
        clearShapes() %>%
        clearMarkers() %>%
            
        # Adding voronoi polygons - Load Ratio
        addPolygons(
            data = time_filtered_data,
            fillColor = ~mypalette_load_ratio(load_ratio_percent_with_synthetic),
            stroke=TRUE,
            fillOpacity = 0.6,
            color="white",
            weight=2.5,
            label = mytext_tartu_synthetic,
            highlightOptions = highlightOptions(color = "black", weight = 7,
                                                bringToFront = TRUE),
            labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "13px",
                direction = "auto"
            ),
            group = "Load Ratio Percent - Synthetic"

        ) %>%
            
        # Adding voronoi polygons - Load Ratio
        addPolygons(
            data = time_filtered_data,
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

        # # Adding voronoi polygons - Absolute values
        addPolygons(
            data = time_filtered_data,
            fillColor = ~mypalette_tartu(predicted_combined_load),
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
            group = "Predicted Absolute Grid Loads"

        ) %>% 
            
        # # Adding voronoi polygons - Absolute values
        addPolygons(
            data = time_filtered_data,
            fillColor = ~mypalette_tartu(combined_load),
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
            group = "Absolute Grid Loads - Synthetic"

        ) %>% 
            
        addMarkers(
                data = time_filtered_grids,
                label = mytext_grid,
                icon = list(
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
                    # iconUrl = 'https://static.thenounproject.com/png/45441-200.png',
                    iconSize = c(30, 30)
                ),
                labelOptions = labelOptions( 
                    style = list("font-weight" = "normal", padding = "3px 8px"), 
                    textsize = "13px", 
                    direction = "auto"
                ),
                group = "Public EV Chargers"
            ) %>%
            
        clearControls() %>% 
        # Adding legend
        addLegend( pal=mypalette_load_ratio, 
                   values=tartu_voronoi_spdf@data$load_ratio_percent, 
                   opacity=0.9, title = "Load Ratio Percent (%)", 
                   position = "bottomleft", 
                   group = "Predicted Load Ratio Percent") %>% 
        
        # Adding legend
        addLegend( pal=mypalette_tartu, 
                   values=tartu_voronoi_spdf@data$predicted_combined_load, 
                   opacity=0.9, title = "Absolute Predicted Loads (kWh)", 
                   position = "bottomright", 
                   group = "Absolute Predicted Loads") %>%
        
        addLayersControl(
            baseGroups = c("Load Ratio Percent - Synthetic", 
                           "Absolute Grid Loads - Synthetic",
                           "Predicted Load Ratio Percent", 
                           "Predicted Absolute Grid Loads"),
            overlayGroups = c("Electricity Grid Stations", "Public EV Chargers", "Home EV Chargers"),
            options = layersControlOptions(collapsed = FALSE)
        ) 
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
