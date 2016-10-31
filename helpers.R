library(rgdal)
library(ggplot2)
#install.packages("gpclib", type="source")
library(dplyr)
library(plotly)

library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(leaflet)
library(rvest)
library(rgeos)
library(maptools)


act_df <- read.csv("tourist_activity.csv")


rev_df <- read.csv("revenue_usd.csv")
unesco <- read.csv('unesco.csv')
coords <- read.csv('coords.csv')


mexico <- readOGR(dsn="./",layer ="mexstates", encoding = "UTF-8")
hoteles <- read.csv("hoteles.csv") 

hoteles[3:9] <- sapply(hoteles[3:9], function(x) as.numeric(as.character(x))/1000)
#runApp(appDir = getwd())