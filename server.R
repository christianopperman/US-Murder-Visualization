function(input, output) {
  
  #Filter dataset by year, gender, age, and weapon, as selected by the user.
  #If no selection is made for a category, that category is treated as being fully selected
  #Group dataset by State and create outputs to be used to color the map
  murder_map_df = reactive({
    murder_map_df = 
      murder_database %>% 
      filter(., between(Year, input$yearSlider[1], input$yearSlider[2])) %>% 
      filter(., `Victim Sex` %in% if(is.null(input$genderCheckGroup)){victim.genders} else {input$genderCheckGroup}) %>% 
      filter(., `Victim_Age_Category` %in% if(is.null(input$ageCheckGroup)){victim.ages} else {input$ageCheckGroup}) %>% 
      filter(., `Weapon` %in% if(is.null(input$methodCheckGroup)){murder.methods} else {input$methodCheckGroup}) %>%
      filter(., State !="District of Columbia") %>% 
      group_by(., State) %>% 
      summarise(., totalvictims = n(), 
                victimsper1kpeople = n()/mean(Population.in.1000s, na.rm = TRUE), 
                roundedvictimsper1kpeople = round(n()/mean(Population.in.1000s, na.rm = TRUE)))
  })
  
  #Filter overall dataset by variable (Victim or Perpetrator) selected by user
  regression_df = reactive({
    regression_df = murder_database %>% 
      select(., `State`, `Crime Solved`,starts_with(input$graphvariable), `Weapon`, `Relationship`) %>% 
      rename(., Sex = 3, Age = 4, Race = 5, `Age Category` = 6)
  })
  
  ######### Map Visualization Tab #########
  
  #Output a map color coded by the total number of murders committed that match the criteria as selected
  output$map = renderGvis({
    gvisGeoChart(murder_map_df(),
                 locationvar = "State",
                 colorvar = input$chartDisplay,
                 options=list(region="US",
                              displayMode="regions",
                              resolution="provinces",
                              width="auto", height="auto",
                              colorAxis = "{colors: ['white', 'red']}")
                 )
  })
  
  #Output an infobox providing the U.S. state with the most murders that matches the criteria as selected with the most murders
  output$maxBox = renderInfoBox({
    max_state = murder_map_df()$State[murder_map_df()$victimsper1kpeople == max(murder_map_df()$victimsper1kpeople)]
    infoBox(title = "Most Murderous State", 
            subtitle = paste("(", round(max(murder_map_df()$victimsper1kpeople), digits = 2), " murders per 1,000 people)", sep =""),
            value = max_state, color = "black", width = "100%",
            icon = icon("long-arrow-alt-up")
            )
  })
  
  #Output an infobox providing the U.S. state with the least murders that matches the criteria as selected with the most murders
  output$minBox = renderInfoBox({
    max_state = murder_map_df()$State[murder_map_df()$victimsper1kpeople == min(murder_map_df()$victimsper1kpeople)]
    infoBox(title = "Least Murderous State", 
            subtitle = paste("(", round(min(murder_map_df()$victimsper1kpeople), digits = 2), " murders per 1,000 people)", sep =""),
            value = max_state, color = "black", width = "100%",
            icon = icon("long-arrow-alt-down")
    )
  })
  
  #Output an infobox providing the U.S. state that matches the criteria as selected with the most murders
  output$avgBox = renderInfoBox({
    avg_murders = round(mean(murder_map_df()$victimsper1kpeople), digits = 2)
    infoBox(title = "Average Murders per 1,000 people", 
            value = avg_murders, icon = icon("balance-scale"), color = "black", width = "100%"
            )
  })
  
  ######### Murder Profile Tab #########
  
  #In progress
  
  ######### Regressions and Graphs Tab ########

  ###Histogram for Victim/Perpetrator gender by State
  
  count_by_gender_df = reactive({
    count_by_gender_df = regression_df() %>%
      group_by(., Sex) %>%
      summarise(., Count = n())
      
  })
  
  output$genderchart = renderGvis({
    gvisColumnChart(count_by_gender_df(), xvar = "Sex", yvar = "Count", 
                    options = list(legend = "{position: 'none'}",
                                   colors = "['#de2d26']"))
  })
  
  output$genderpiechart = renderGvis({
    gvisPieChart(count_by_gender_df(),
                 labelvar = "Sex", numvar = "Count",
                 options = list(pieHole = "0.25",
                                chartArea = "{width: '100%', height: '100%'}",
                                colors = "['#de2d26','#fc9272','#fee0d2']"))
  })
  
  count_by_race_df = reactive({
    count_by_race_df = regression_df() %>%
      group_by(., Race) %>%
      summarise(., Count = n())

  })
  
  output$racechart = renderGvis({
    gvisColumnChart(count_by_race_df(), xvar = "Race", yvar = "Count", 
                    options = list(legend = "{position: 'none'}",
                                   colors = "['#de2d26']"))
  })
  
  output$racepiechart = renderGvis({
    gvisPieChart(count_by_race_df(), labelvar = "Race", numvar = "Count",
                 options = list(pieHole = "0.25",
                                chartArea = "{width: '100%', height: '100%'}",
                                colors = "['#fee5d9','#fcae91','#fb6a4a','#de2d26','#a50f15']"))
  })
  
  count_by_weapon_df = murder_database %>% 
      group_by(., Weapon) %>%
      summarise(., Count = n())
  
  output$weaponchart = renderGvis({
    gvisColumnChart(count_by_weapon_df, xvar = "Weapon", yvar = "Count", 
                    options = list(legend = "{position: 'none'}",
                                   colors = "['#de2d26']"))
  })
    
  ######### Data Table Tab #########
  
  #Restrict which columns from the original data-frame to use
  m1 = murder_database %>%
    select(., Year, Month, State, City, `Weapon`, 
           `Victim Sex`, `Victim Age`, `Victim Race`, 
           `Perpetrator Sex`, `Perpetrator Age`, `Perpetrator Race`,
           `Relationship`, -Population.in.1000s, -Victim_Age_Category)
  
  output$table = DT::renderDT(m1,
                              filter = list(position = "top", clear = FALSE, plain = FALSE),
                              options = list(pageLength = 10))
  
  ######### About Tab #########
  #All information 
  
}