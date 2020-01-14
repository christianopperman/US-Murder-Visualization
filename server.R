library(shiny)

shinyServer(function(input, output) {
  
  murder_map_df = reactive({
    
    #Filter dataset by year, gender, age, and weapon, as selected by the user.
    #If no selection is made for a category, that category is treated as being fully selected
    #Group dataset by State and create outputs to be used to color the map
    murder_map_df = 
      murder_database %>% 
      filter(., between(Year, input$yearSlider[1], input$yearSlider[2])) %>% 
      filter(., `Victim Sex` %in% if(is.null(input$genderCheckGroup)){victim.genders} else {input$genderCheckGroup}) %>% 
      filter(., Victim_Age_Category %in% if(is.null(input$ageCheckGroup)){victim.ages} else {input$ageCheckGroup}) %>% 
      filter(., `Weapon` %in% if(is.null(input$methodCheckGroup)){murder.methods} else {input$methodCheckGroup}) %>%
      group_by(., State) %>% 
      summarise(., "Log of Murders"=log(sum(`Total Victims`)), "Log of Murders.html.tooltip" = sum(`Total Victims`))
  })
  
  #Output a map color coded by the total number of murders committed that match the criteria as selected above
  output$map = renderGvis({
    gvisGeoChart(murder_map_df(),
                 locationvar = "State",
                 colorvar = "Log of Murders",
                 options=list(region="US",
                              displayMode="regions",
                              resolution="provinces",
                              width="auto", height="auto",
                              colorAxis = "{colors: ['white', 'red']}")
                 )
  })
})