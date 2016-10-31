#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

## grepl(df,regex,column)

source("helpers.R")


shinyServer(function(input, output) {
  
  
  activity <- reactive({
    act_df %>% filter(grepl(input$year,Periodo))
    })
  
  output$boxPlots <- renderPlotly({
    gg <- activity() %>%
      ggplot(aes(x=Destino, y=Visitantes/1000, fill=Destino))+geom_boxplot()+theme_bw()
    ggplotly(gg)
    
  })
  
  output$pctChart <- renderPlotly({
    gg <- activity() %>%
      ggplot(aes(x=Destino, 
                 y=Porcentaje.Ocupacion.promedio, 
                 color=Destino))+geom_point(position = "jitter")+theme_bw()
    ggplotly(gg)
  })
  
  
  avgVisitors <- reactive({
    avgVisitors <-  activity() %>%
      filter(grepl(input$year,Periodo)) %>% 
      group_by(Destino) %>%
      summarise(LocalPct=100*mean(Nacional/Visitantes)
                , ForeignPct = 100*mean(Internacional/Visitantes)) 
  })
  
  output$barPlots <- renderPlotly({
    # avgVisitors <-  activity %>%
    #   filter(grepl('2015',Periodo)) %>% 
    #   group_by(Destino) %>%
    #   summarise(LocalPct=100*mean(Nacional/Visitantes)
    #             , ForeignPct = 100*mean(Internacional/Visitantes)) 
    
    gg <- avgVisitors() %>%
      ggplot(aes(x=LocalPct, y=ForeignPct, color=Destino))+
      geom_point()+geom_abline(intercept = 0,slope=1, linetype="dotted")+
      xlim(0,100)+ylim(0,100)+xlab("Local Visitors")+ylab("Foreign Visitors")+theme_bw()
    ggplotly(gg)
  })
  
  
  output$revPlot <- renderPlotly({
    gg <- rev_df %>% filter(!grepl("Total ",CIP), 
                      grepl(input$year,Periodo) ) %>% 
      ggplot(aes(x=Periodo,y=Millones.de.dolares, fill=CIP))+
      geom_bar(stat = 'identity')+coord_flip()+theme_bw()
    ggplotly(gg)
  })
  
  output$cityTable <- renderDataTable({
      url <- paste0("https://en.wikipedia.org/wiki/",input$city)
      # url <- paste0("https://en.wikipedia.org/wiki/",'Ixtapa')
      data <- read_html(url) %>% 
      html_node('table.infobox') %>%
      html_table(header=F, fill=T) %>%
      slice(7:25)
      
      names(data) <- c("Attribute","Value")
      data
    
  }, options=list(pageLength = 5))
  
  
  output$citiesMap <- renderLeaflet({
    
    coords %>% 
      leaflet %>% 
      addTiles() %>% 
      addMarkers(~Long, ~Lat, popup = ~as.character(Destino))
    
  })
  
  
  output$unescoMap <- renderLeaflet({
    unesco %>% 
      leaflet %>% setView(lng = -99.1013, lat = 19.2465, zoom = 5) %>%
      addTiles() %>%
      addMarkers(~longitude, ~latitude, popup = ~as.character(name_en))
    
  })
  
  
  chosenSite <- reactive({
    desc <- unesco%>%filter(name_en==input$site)
    desc
  })
  
  
  observe({
    proxy <- leafletProxy("unescoMap", data=chosenSite())%>%
        removeMarker("chosen")%>%
      addCircleMarkers(~longitude, ~latitude,
                       color = "red", stroke = F,
                       fillOpacity = 0.7,
                       popup = ~as.character(name_en), layerId = "chosen")
  })
  
  output$siteDescription <- renderDataTable({
    chosenSite()%>%select(Category = category,Description = short_description_en)  
  }, options = list(pageLength = 5, dom = 'tip'), escape = F)
  

  hotelesFiltr <- reactive({
      hoteles%>% 
      filter(Ano==input$year_ch) %>%
      rename(id=Estado) %>% 
      mutate_(indicator = input$var_ch)
  })
  
  output$mexChoropleth <- renderPlotly({
    mx <- fortify(mexico, region = "ADMIN_NAME" )

    plotData <- left_join(mx,hotelesFiltr())
    
    
    gg <- plotData %>% 
      ggplot(aes(x=long, y=lat, group=group, fill=indicator))+
      geom_polygon()+
      theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(), #legend.position="none",
            panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),plot.background=element_blank())
    
    ggplotly(gg)
    
  })
  
})
