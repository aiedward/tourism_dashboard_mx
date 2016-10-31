#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



source("helpers.R")


dashboardPage(skin = "green",
  dashboardHeader(title="Tourism in Mexico"), 
  dashboardSidebar(
    sidebarMenu(
      menuItem("Trends by State", tabName = "states", icon = icon("line-chart"))
      , menuItem("Beach Tourism", tabName = "beach", icon=icon("camera", lib = "glyphicon")) 
      , selectInput("year", label = "Select Year", choices=c('2015','2016'), selected='2015')
      , menuItem("UNESCO World Heritage Sites", tabName = "maps", icon=icon("bank"))
    )
  ), 
  dashboardBody(
    tabItems(
      tabItem(tabName = "states", 
              fluidRow(
                box(status="danger", 
                    solidHeader=T, 
                    title="Occupation by State",
                    sliderInput("year_ch", "Choose year", 
                                min = 2010, 
                                max = 2014,
                                step = 1,
                                round = T,  
                                sep = '',
                                animate = animationOptions(interval = 1200),
                                value = 2010),
                    
                    selectInput("var_ch", "Select an indicator", 
                                choices=names(hoteles)[3:9]
                                , selected = names(hoteles)[4]),
                    plotlyOutput("mexChoropleth"))
              )
              )
      , tabItem(
        tabName = "beach",
        fluidRow(
          tabBox(
            title= "Occupation",
              tabPanel("Absolute", plotlyOutput("boxPlots"),status="danger")
            , tabPanel("Relative", plotlyOutput("pctChart"), status="danger")  
            , tabPanel("Domestic vs Foreign", plotlyOutput("barPlots"))
            )
          , 
            box(status="danger",solidHeader = T,
                title = "Revenue in USD", plotlyOutput("revPlot")
            )
          )
        
        , fluidRow(
          # box (status="danger", solidHeader = T, title="Wikipedia Quick Facts",
          #      selectInput("city","Choose a city", choices = c("Ixtapa","Cancun"), selected = "Cancun")
          #      , dataTableOutput("cityTable"))  
          # ,  
          box(status='danger', solidHeader = T, title="Major beach destinations",
                leafletOutput('citiesMap'))  
          
        )
        )
      
      
      , tabItem(
        tabName = "maps"
        
        ,fluidRow(
            box(status="danger", solidHeader = T, title = "Filter map", 
                selectInput("site", 
                            "Select a site", 
                            choices = levels(unesco$name_en), 
                            selected = levels(unesco$name_en)[2])
              , dataTableOutput("siteDescription"))
        , box(status='danger', solidHeader = T, title = "UNESCO World Heritage Sites in Mexico",
              leafletOutput('unescoMap'))  
        )
        
        
        
        

      )
      
    )
  )
)
