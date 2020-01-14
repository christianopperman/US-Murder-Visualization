library(shiny)

shinyServer(function(input, output) {
  
  murder_map_df = reactive({
    
    #Filter dataset by year, gender, age, and weapon, as selected by the user
    #Group dataset by State and create outputs to be used to color the map
    ### TO DO: Figure out how to deal with the use case when no boxes are selected
    murder_map_df = 
      murder_database %>% 
      filter(., between(Year, input$yearSlider[1], input$yearSlider[2])) %>% 
      filter(., `Victim Sex` %in% input$genderCheckGroup) %>% 
      filter(., Victim_Age_Category %in% input$ageCheckGroup) %>% 
      filter(., `Weapon` %in% input$methodCheckGroup) %>%
      group_by(., State) %>% 
      summarise(., log_murders=log(sum(Incident)), total_murders = sum(Incident))
  })
  
  output$map = renderGvis({
    gvisGeoChart(murder_map_df(),
                 locationvar = "State",
                 colorvar = "total_murders",
                 #hovervar = "total_murders",
                 options=list(region="US",
                              displayMode="regions",
                              resolution="provinces",
                              width="auto", height="auto",
                              colorAxis = "{colors: ['white', 'red']}")
                 )
  })
})