library(shiny)

shinyServer(function(input, output) {
  murder_map_df = reactive({
    if (!is.null(input$genderCheckGroup)) {
      #Check to see if there are inputs in the gender selection boxes
      if (!is.null(input$ageCheckGroup)) {
        #Check to see if there are inputs in the age selection boxes
        if (!is.null(input$methodCheckGroup)) {
          #Check to see if there are inputs in the method selection boxes
          #Gender, age, and method selection exist
          murder_map_df = murder_database %>%
            filter(
              .,
              `Victim Sex` %in% input$genderCheckGroup &
                `Victim Age` %in% input$ageCheckGroup &
                `Weapon` %in% input$methodCheckGroup
            )
        } else {
          #Gender and age selection exist, method does not
          murder_map_df = murder_database %>%
            filter(
              .,
              `Victim Sex` %in% input$genderCheckGroup &
                `Victim Age` %in% input$ageCheckGroup
            )
        }
      } else {
        #Gender selection exists, age does not; check for method
        if (!is.null(input$methodCheckGroup)) {
          # Gender and method selection exist, age does not
          murder_map_df = murder_database %>%
            filter(
              .,
              `Victim Sex` %in% input$genderCheckGroup &
                `Weapon` %in% input$methodCheckGroup
            )
        } else {
          #Gender selection exists, age and method do not
          murder_map_df = murder_database %>%
            filter(., `Victim Sex` %in% input$genderCheckGroup)
        }
      }
    } else {
      #Gender selection doesn't exist; check for age and method
      if (!is.null(input$ageCheckGroup)) {
        #Age selection exists, gender does not; check for method
        if (!is.null(input$methodCheckGroup)) {
          #Age and method selection exist, gender does not
          murder_map_df = murder_database %>%
            filter(
              .,
              `Victim Age` %in% input$ageCheckGroup &
                Weapon %in% input$methodCheckGroup
            )
        } else {
          #Age selection exists, gender and method do not
          murder_map_df = murder_database %>%
            filter(., `Victim Age` %in% input$ageCheckGroup)
        }
      } else {
        #Gender and age selection don't exist; check for method
        if (!is.null(input$methodCheckGroup)) {
          murder_map_df = murder_database %>%
            filter(., `Weapon` %in% input$methodCheckGroup)
        } else{
          murder_map_df = murder_database
        }
      }
    }
    
    #Filter dataset by year as selected by the user in the yearSlider
    #Group dataset by State and create outputs to be used to color the map
    murder_map_df =
      murder_map_df %>%
      filter(., between(Year, input$yearSlider[1], input$yearSlider[2])) %>%
      group_by(., State) %>%
      summarise(.,
                log_murders = log(sum(Incident)),
                total_murders = sum(Incident))
  })
  
  output$map = renderGvis({
    gvisGeoChart(
      murder_map_df(),
      locationvar = "State",
      colorvar = "total_murders",
      #hovervar = "total_murders",
      options = list(
        region = "US",
        displayMode = "regions",
        resolution = "provinces",
        width = "auto",
        height = "auto",
        colorAxis = "{colors: ['white', 'red']}"
      )
    )
  })
})