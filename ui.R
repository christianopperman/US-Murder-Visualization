library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = "black",
  
  # Define header with app title, author name, and links to GitHub and LinkedIn accounts
  dashboardHeader(
    title="Murders in the U.S.",
    tags$li("Christian Opperman", 
            style = "padding-right: 15px; padding-top: 15px; font-weight: bold; font-size: 13px",
            class = "dropdown"),
    tags$li(a(href="https://github.com/christianopperman", icon("github-square")),
            style = "font-size: 20px",
            class = "dropdown"),
    tags$li(a(href="https://www.linkedin.com/in/christian-opperman/", icon("linkedin")),
            style = "font-size: 20px",
            class = "dropdown")
  ),
  
  # Define sidebar with relevant tab options for navigation
  dashboardSidebar(
    sidebarUserPanel("Christian Opperman",
                     subtitle = "Fellow @ NYCDSA",
                     image = "Me.jpg"),
    
    sidebarMenu(
      menuItem("Murder Maps", tabName = "maps", icon = icon("globe-americas")),
      menuItem("Your Murder Profile", tabName = "murderprofile", icon = icon("skull")),
      menuItem("Regressions and Graphs", tabName = "regressions", icon = icon("chart-line")),
      menuItem("Data", tabName = "data", icon = icon("table")),
      menuItem("About", tabName = "about", icon = icon("info"))
    )
  ),
  
  # Define body with tabs to be selected in the sidebar
  dashboardBody(
    tabItems(
      
      #Define tab that contains the landing page map, which visualizes the number of murders by type,
      #victim age, and victim gender on a map of the United States using googleVis
      tabItem(tabName = "maps",
              #Row that contains summary info boxes displaying most murderous state and the average murders (both in murders/1000 people)
              fluidRow(
                infoBoxOutput("maxBox"),
                infoBoxOutput("minBox"),
                infoBoxOutput("avgBox")
                ),
              
              #Row that contains map visualization and selection criteria
              fluidRow(
                column(8, box(htmlOutput("map"), position = "center", height = "auto", width = "auto")),
                column(2,
                       checkboxGroupInput("genderCheckGroup",
                                          label = h5("Victim Gender:", style="font-weight:bold"),
                                          choices = victim.genders,
                                          selected = victim.genders),
                       checkboxGroupInput("ageCheckGroup",
                                          label = h5("Victim Age:", style="font-weight:bold"),
                                          choices = victim.ages,
                                          selected = victim.ages),
                       sliderInput("yearSlider",
                                   label = "Year Range:",
                                   min = 1980, max = 2014,
                                   value = c(1980, 2014),
                                   step = 1,
                                   sep = "")),
                column(2,
                       checkboxGroupInput("methodCheckGroup",
                                          label = h5("Method Type:", style="font-weight:bold"),
                                          choices = murder.methods,
                                          selected = murder.methods)
                       )
              ),
              
              #Row that includes selection for whether to color the map by total murders or murders per 1000 people
              fluidRow(column(8,
                       radioButtons("chartDisplay", label = "Display murders by:", 
                                    choices = list("Total Murders" = "totalvictims", "Murders per 1,000 People" = "victimsper1kpeople"),
                                    selected = "totalvictims", inline = TRUE, width = "100%"))
              )
            ),
      
      tabItem(tabName = "murderprofile",
              "To be replaced with an interface where the user can select their profile characteristics and see where/how they are most likely to be murdered"),
      
      tabItem(tabName = "regressions",
              "To be replaced with regression analysis of the dataset"),
      
      #Define tab that contains a table of the data
      tabItem(tabName = "data",
              fluidRow(
                box(DT::dataTableOutput("table"), width = 12))
              
              #Possible to-do: add filters for the data table?
              ),
      
      tabItem(tabName = "about",
              "To be replaced with information about the dataset and about me")
    )
  )
))
