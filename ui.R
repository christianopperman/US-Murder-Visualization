library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = "purple",
  
  # Define header with app title, author name, and links to GitHub and LinkedIn accounts
  dashboardHeader(
    title="Murders in the U.S.",
    tags$li("Christian Opperman", 
            style = "padding-right: 15px; padding-top: 15px; font-weight: bold; font-size: 13px; color: white",
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
                     subtitle = "Fellow @ NYCDSA"),
    
    sidebarMenu(
      menuItem("Murder Maps", tabName = "maps", icon = icon("globe-americas")),
      menuItem("Your Murder Profile", tabName = "murderprofile", icon = icon("skull")),
      menuItem("Regressions", tabName = "regressions", icon = icon("chart-line")),
      menuItem("Data", tabName = "data", icon = icon("table"))
    )
  ),
  
  # Define body with tabs to be selected in the sidebar
  dashboardBody(
    tabItems(
      tabItem(tabName = "maps",
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
              )
            ),
      tabItem(tabName = "murderprofile",
              "To be replaced with an interface where the user can select their profile characteristics and see where/how they are most likely to be murdered"),
      tabItem(tabName = "regressions",
              "To be replaced with regression analysis of the dataset"),
      tabItem(tabName = "data",
              "To be replaced with the dataset used in the Shiny App (possibly reactive?)")
    )
  )
))
