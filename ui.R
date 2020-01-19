dashboardPage(skin = "black",
  
  # Define header with app title, author name, and links to GitHub and LinkedIn accounts
  dashboardHeader(
    title="U.S. Murders",
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
    
    sidebarMenu(id = "sidebar",
      menuItem("Murder Maps", tabName = "maps", icon = icon("globe-americas")),
      menuItem("Murder Profile", tabName = "murderprofile", icon = icon("skull")),
      menuItem("Graphs", tabName = "graphs", icon = icon("chart-line")),
      shiny::conditionalPanel(condition="input.tabset == 'Demographics' & input.sidebar == 'graphs'",   #Only display dropdown  when Graphs tab is selected
                              selectizeInput("graphvariable",
                                             "Select Analysis Variable:",
                                             c('Victim', 'Perpetrator'))
                              ),
      menuItem("Data", tabName = "data", icon = icon("table")),
      menuItem("About", tabName = "about", icon = icon("info"))
      
    )
  ),
  
  
  
  # Define body with tabs to be selected in the sidebar
  dashboardBody(
    #Add custom CSS styling  ###CUSTOM SHEET LINK DOES NOT SEEM TO WORK - CONFIRM WITH SOMEONE?
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$style((HTML('a {color:#de2d26}')))
    ),
    
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
      
      #Define tab that contains an interactive user experience to profile where and how a user may get murdered
      tabItem(tabName = "murderprofile",
              box(
                width = 12,
                position = "center",
                column(
                  4,
                  align = "center",
                  fluidRow(uiOutput("topstate1")),
                  fluidRow(uiOutput("topstate2")),
                  fluidRow(uiOutput("topstate3")),
                  fluidRow(uiOutput("topstate4")),
                  fluidRow(uiOutput("topstate5"))
                ),
                column(
                  4,
                  align = "center",
                  fluidRow(uiOutput("topmethod1")),
                  fluidRow(uiOutput("topmethod2")),
                  fluidRow(uiOutput("topmethod3")),
                  fluidRow(uiOutput("topmethod4")),
                  fluidRow(uiOutput("topmethod5"))
                ),
                column(2, offset = 1,
                       fluidRow(
                         column(
                           6,
                           fluidRow(
                             checkboxGroupInput(
                               "profileGenderCheckGroup",
                               label = h5("Your Gender:", style =
                                            "font-weight:bold"),
                               choices = c("Male", "Female")
                             )
                           ),
                           fluidRow(
                             checkboxGroupInput(
                               "profileAgeCheckGroup",
                               label = h5("Your Age:", style =
                                            "font-weight:bold"),
                               choices = victim.ages
                             )
                           )
                         ),
                         column(
                           6,
                           checkboxGroupInput(
                             "profileRaceCheckGroup",
                             label = h5("Your Race:", style =
                                          "font-weight:bold"),
                             choices = victim.races
                           )
                         )
                       ),
                       fluidRow(
                         sliderInput(
                           "profileYearSlider",
                           label = "Year Range:",
                           min = 1980,
                           max = 2014,
                           value = c(1980, 2014),
                           step = 1,
                           sep = ""
                         )
                       ))
              )),
      
      
      
      #Define tab that contains various graphs of the data showing relationships between variables
      tabItem(tabName = "graphs", tags$style((HTML('a {color: black}'))),
              
              tabsetPanel(id = "tabset",
                tabPanel("Murder Rate",
                         box(width = "100%",
                             fluidRow(
                               column(12, align = "center",
                                      htmlOutput("yearlymurderrate"),
                                      tags$br(),
                                      tags$br(),
                                      htmlOutput("yearlymurderratebyweapon"),
                                      tags$br(),
                                      tags$br(),
                                      htmlOutput("yearlymurderratebysolved"),
                                      tags$br(),
                                      tags$br(),
                                      htmlOutput("yearlymurderratebystate")
                                      )
                               )
                             )
                         ),
                
                tabPanel("Demographics",
                         box(width = "100%",
                             fluidRow(
                               fluidRow(
                                 column(
                                   6,
                                   align = "center",
                                   p("Breakdown by Gender", style = "font-size: 18px"),
                                   htmlOutput("genderpiechart")
                                 ),
                                 column(
                                   6,
                                   align = "center",
                                   p("Breakdown by Race", style = "font-size: 18px"),
                                   htmlOutput("racebarchart")
                                 )
                               ),
                               tags$br(),
                               tags$br(),
                               fluidRow(
                                 align = "center",
                                 p("Breakdown by Murder Method & Solved Percentage", style = "font-size: 18px")
                               ),
                               fluidRow(column(12, align = "center",
                                               htmlOutput("solvedchart"))
                                        )
                             ))
                  )
                )
              ),
      
      
      
      #Define tab that contains a table of the data
      tabItem(tabName = "data",
              fluidRow(
                box(
                  width = 12, 
                  dataTableOutput("table")))
              ),
      
      #Define tab that contains information about the data set and myself
      tabItem(tabName = "about",
              box(width = 12,
              fluidRow(
                column(8, align = "center", style = "margin-top: 50px",
                         tags$img(src = "MurderAccountabilityProject.png",
                                  width = "50%")
                       ),
                column(4, align = "center",
                       tags$img(src = "Me.jpg",
                                width = "50%",
                                style="border-radius: 50%")
                       )
              ),
              fluidRow(
                #Column describing the underlying data
                column(8, align = "center",
                       tagList(#tags$br(),
                         #tags$br(),
                         tags$h4("About the Data"),
                         tags$br(),
                         "The data for this project was primarily sourced from the ",
                         tags$a("Murder Accountability Project", href = "http://www.murderdata.org/"),
                         ", a non-profit organization that tracks homicide reports in the United States of America, 
                         with particular focus on unsolved homicides.",
                         tags$br(),
                         tags$br(),
                         "The dataset upon which the majority of the underlying analysis rests on the Murder Accountability 
                         Project's data of homicides from 1980 through 2014. The dataset can be found on Kaggle ",
                         tags$a("here", href = "https://www.kaggle.com/murderaccountability/homicide-reports"),
                         ". That data in turn was sourced from the FBI's Supplementary Homicide Report (covering 1976 to 
                         the present day) and numerous Freedom of Information Act requests. The factors in the data are based 
                         on the FBI report's structure; that report as well as the documentation for it, which explains the 
                         factor naming conventions, can be accessed ",
                         tags$a("here", href = "http://www.murderdata.org/p/data-docs.html"),
                         ".",
                         tags$br(),
                         tags$br(),
                         "Finally, to aid in visualization and to normalize data by state population (in other words, to provide 
                         data on murders per every one-thousand people), U.S. state population data was sourced from the Federal 
                         Reserve Economic Data databases, compiled by the Bank of St. Louis Economic Research based on data sourced 
                         from the U.S. Census Bureau. A list of U.S. states with their resepective population data can be accessed ",
                         tags$a("here", href = "https://fred.stlouisfed.org/release/tables?rid=118&eid=259194", style = "color:#de2d26"),
                         "."
                         )
                       ),
                #Column describing myself
                column(4, align = "center",
                       tagList(tags$h4("About the Creator"),
                               tags$br(),
                               "Christian Opperman is a data scientist and analyst based in New York City. 
                               Originally from South Africa, he was raised in the Bay Area, California, and after
                               college lived in Tokyo, Japan, working in the energy sector, for a number of years
                               before moving back to the U.S.", 
                               tags$br(),
                               tags$br(),
                               "Please feel free to explore Christian's ",
                               tags$a("GitHub Account", href = "https://github.com/christianopperman"), 
                              "or ", 
                              tags$a("LinkedIn Profile", href = "https://www.linkedin.com/in/christian-opperman/"), 
                              ".")
                       )
                )
              )
      ))
    )
  )
