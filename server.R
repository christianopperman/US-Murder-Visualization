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
      filter(., State !="District of Columbia") %>% 
      group_by(., State) %>% 
      summarise(., totalvictims = sum(`Total Victims`, na.rm = TRUE), 
                victimsper1kpeople = sum(`Total Victims`, na.rm = TRUE)/mean(Population.in.1000s, na.rm = TRUE), 
                roundedvictimsper1kpeople = round(sum(`Total Victims`, na.rm = TRUE)/mean(Population.in.1000s, na.rm = TRUE)))
  })
  
  #Output a map color coded by the total number of murders committed that match the criteria as selected
  output$map = renderGvis({
    gvisGeoChart(murder_map_df(),
                 locationvar = "State",
                 colorvar = input$chartDisplay,
                 #hovervar = list('roundedvictimsper1kpeople'),
                 options=list(region="US",
                              displayMode="regions",
                              resolution="provinces",
                              width="auto", height="auto",
                              colorAxis = "{colors: ['white', 'red']}")
                 )
  })
  
  #Output an infobox providing the U.S. state that matches the criteria as selected with the most murders
  output$maxBox = renderInfoBox({
    max_state = murder_map_df()$State[murder_map_df()$victimsper1kpeople == max(murder_map_df()$victimsper1kpeople)]
    infoBox(title = "Most Murderous State", 
            subtitle = paste("(", round(max(murder_map_df()$victimsper1kpeople), digits = 2), " murders per 1,000 people)", sep =""),
            value = max_state, color = "black", width = "100%",
            icon = icon("long-arrow-alt-up")
            )
  })
  
  #Output an infobox providing the U.S. state that matches the criteria as selected with the most murders
  output$avgBox = renderInfoBox({
    avg_murders = round(mean(murder_map_df()$victimsper1kpeople), digits = 2)
    infoBox(title = "Average Murders per 1,000 people", 
            value = avg_murders, icon = icon("balance-scale"), color = "black", width = "100%"
            )
  })
  
})