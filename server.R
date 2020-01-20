function(input, output) {
  
  ########Data Processing########
  #Filter dataset by year, gender, age, and weapon, as selected by the user.
  #If no selection is made for a category, that category is treated as being fully selected
  #Group dataset by State and create outputs to be used to color the map
  murder_map_df = reactive({
    murder_map_df = murder_database %>% 
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
  
  #Filter overall dataset by user's racial, gender, and age profiles to be used in determining the
  #most likely murder methods and most murderous states for the user's demographics
  profile_murder_df = reactive({
    profile_murder_df =  murder_database %>% 
      filter(., between(Year, input$profileYearSlider[1], input$profileYearSlider[2])) %>% 
      filter(., `Victim Sex` %in% if(is.null(input$profileGenderCheckGroup)){victim.genders} else {input$profileGenderCheckGroup}) %>% 
      filter(., `Victim_Age_Category` %in% if(is.null(input$profileAgeCheckGroup)){victim.ages} else {input$profileAgeCheckGroup}) %>% 
      filter(., `Victim Race` %in% if(is.null(input$profileRaceCheckGroup)){victim.races} else {input$profileRaceCheckGroup}) %>% 
      filter(., State !="District of Columbia")
  })
  
  #Filter overall dataset by variable (Victim or Perpetrator) selected by user to be used on the graphs page for analysis
  graphs_df = reactive({
    graphs_df = murder_database %>% 
      select(., `State`, `Crime Solved`, starts_with(input$graphvariable), `Weapon`, `Relationship`) %>% 
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
            subtitle = paste("(", round(max(murder_map_df()$victimsper1kpeople), digits = 2),
                             " murders per 1,000 people)", sep =""),
            value = max_state, color = "black", width = "100%",
            icon = icon("long-arrow-alt-up")
            )
  })
  
  #Output an infobox providing the U.S. state with the least murders that matches the criteria as selected with the most murders
  output$minBox = renderInfoBox({
    max_state = murder_map_df()$State[murder_map_df()$victimsper1kpeople == min(murder_map_df()$victimsper1kpeople)]
    infoBox(title = "Least Murderous State", 
            subtitle = paste("(", round(min(murder_map_df()$victimsper1kpeople), digits = 2),
                             " murders per 1,000 people)", sep =""),
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
  
  top_state = reactive({
    top_state = profile_murder_df() %>% 
      group_by(., State) %>% 
      summarise(., victimsper1kpeople = n()/mean(Population.in.1000s, na.rm = TRUE)) %>% 
      arrange(., desc(victimsper1kpeople)) %>% 
      top_n(., 5)
    })
  
  top_method  = reactive({
    profile_murder_df() %>% 
      group_by(., Weapon) %>% 
      summarise(., totalvictims = n()) %>% 
      arrange(., desc(totalvictims)) %>% 
      top_n(., 5)
    })
  
  output$topstate1 = renderUI({
    infoBox(title = "Your Most Dangerous State", value = top_state()$State[1], width = 12, color = "black", fill = T)
    })
  output$topstate2 = renderUI({
    infoBox(title = "Your Second Most Dangerous State", value = top_state()$State[2], width = 12, color = "red", fill = T)
    })
  output$topstate3 = renderUI({
    infoBox(title = "Your Third Most Dangerous State", value = top_state()$State[3], width = 12, color = "red", fill = T)
  })
  output$topstate4 = renderUI({
    infoBox(title = "Your Fourth Most Dangerous State", value = top_state()$State[4], width = 12, color = "red", fill = T)
  })
  output$topstate5 = renderUI({
    infoBox(title = "Your Fifth Most Dangerous State", value = top_state()$State[5], width = 12, color = "red", fill = T)
  })
  
  output$topmethod1 = renderUI({
    infoBox(title = "At Most Risk From", value = top_method()$Weapon[1], width = 12, color = "black", fill = T)
  })
  output$topmethod2 = renderUI({
    infoBox(title = "At Second Most Risk From", value = top_method()$Weapon[2], width = 12, color = "red", fill = T)
  })
  output$topmethod3 = renderUI({
    infoBox(title = "At Third Most Risk From", value = top_method()$Weapon[3], width = 12, color = "red", fill = T)
  })
  output$topmethod4 = renderUI({
    infoBox(title = "At Fourth Most Risk From", value = top_method()$Weapon[4], width = 12, color = "red", fill = T)
  })
  output$topmethod5 = renderUI({
    infoBox(title = "At Fifth Most Risk From", value = top_method()$Weapon[5], width = 12, color = "red", fill = T)
  })
  
  
  
  
  ######### Graphs Tab ########
  ###Murder Rate Tabset
  #Segement dataset by year and calculate total number of murders each year
  yearly_murders_df = 
    murder_database %>% 
    mutate(., Year = as.factor(Year)) %>% 
    group_by(., Year) %>% 
    summarise(., Murders = n())
  output$yearlymurderrate = renderGvis({
    gvisLineChart(yearly_murders_df,
                  xvar = "Year",
                  yvar = "Murders",
                  options = list(title = "Annual Murders - Aggregate",
                                 titleTextStyle = "{fontSize: 14}",hAxis = "{showTextEvery: 2,
                                 format: '0',
                                 ticks: data.getDistinctValues(0)}",
                                 width= "92%",
                                 colors = "['#de2d26']"))
  })
  
  ##Segement dataset by year and murder method and calculate total number of murders each year for each method
  yearly_murders_by_weapon_df = 
    murder_database %>% 
    mutate(., Year = as.factor(Year)) %>% 
    group_by(., Year, Weapon) %>% 
    summarise(., Murders = n()) %>% 
    spread(., key = Weapon, value = Murders)
  output$yearlymurderratebyweapon = renderGvis({
    gvisLineChart(yearly_murders_by_weapon_df,
                  xvar = "Year",
                  yvar = colnames(yearly_murders_by_weapon_df)[-1],
                  options = list(title = "Annual Murders - by Method",
                                 titleTextStyle = "{fontSize: 14}",
                                 height = "500px",
                                 hAxis = "{showTextEvery: 2,
                                 format: '0',
                                 ticks: data.getDistinctValues(0)}",
                                 explorer = "{actions: ['dragToZoom', 'rightClickToReset']}"
                                 ))
  })
  
  yearly_murders_by_state_df = 
    murder_database %>% 
    mutate(., Year = as.factor(Year)) %>% 
    group_by(., Year, State) %>% 
    summarise(., Murders = n()) %>% 
    spread(., key = State, value = Murders)
  output$yearlymurderratebystate = renderGvis({
    gvisLineChart(yearly_murders_by_state_df,
                  xvar = "Year",
                  yvar = colnames(yearly_murders_by_state_df)[-1],
                  options = list(height = "500px",
                                 width = "100%",
                                 title = "Annual Murders - by State",
                                 titleTextStyle = "{fontSize: 14}",
                                 hAxis = "{showTextEvery: 2,
                                 format: '0',
                                 ticks: data.getDistinctValues(0)}",
                                 explorer = "{actions: ['dragToZoom', 'rightClickToReset']}"
                  ))
  })
  
  ##Segement dataset by year and solved state; calculate the total number of murders for each year for solved vs. unsolved murders
  yearly_murders_by_solved_df = 
    murder_database %>% 
    mutate(., Year = as.factor(Year)) %>% 
    group_by(., Year, `Crime Solved`) %>% 
    summarise(., Murders = n()) %>% 
    spread(., key = `Crime Solved`, value = Murders) %>% 
    mutate(., Total = Yes + No, Yes = Yes/Total, No = No/Total)
  output$yearlymurderratebysolved = renderGvis({
    gvisLineChart(yearly_murders_by_solved_df,
                  xvar = "Year",
                  yvar = c("Yes", "No"),
                  options = list(title = "Annual Murders - Solved vs. Unsolved Percentages",
                                 titleTextStyle = "{fontSize: 14}",
                                 width = "92%",
                                 hAxis = "{showTextEvery: 2,
                                 format: '0',
                                 ticks: data.getDistinctValues(0)}",
                                 vAxis = "{format: 'percent'}"
                  ))
  })
  
  ###Demographics Tabset
  #Segment dataset by gender. Dataset pre-filtered by user selection in sidebar tab
  count_by_gender_df = reactive({
    count_by_gender_df = graphs_df() %>%
      group_by(., Sex) %>%
      summarise(., Count = n())
      
  })
  #Output donut chart of gender distribution
  output$genderpiechart = renderGvis({
    gvisPieChart(count_by_gender_df(),
                 labelvar = "Sex", numvar = "Count",
                 options = list(pieHole = "0.25",
                                chartArea = "{width: '75%', height: '100%'}",
                                colors = "['#de2d26','#fc9272','#fee0d2']",
                                legend = "{position: 'labeled'}",
                                pieSliceText = "none"))
  })
  
  #Segment dataset by race. Dataset pre-filtered by user selection in sidebar tab
  count_by_race_df = reactive({
    count_by_race_df = graphs_df() %>%
      group_by(., Race) %>%
      summarise(., Count = n())
  })
  #Output bar chart of racial distribution
  output$racebarchart = renderGvis({
    gvisColumnChart(count_by_race_df(), xvar = "Race", yvar = "Count",
                 options = list(colors = "['#de2d26']",
                                legend = "{position: 'none'}"))
  })
  
  #Segment full dataset by whether solved vs. unsolved murders
  count_solved_df = murder_database %>% 
    group_by(., Solved = `Crime Solved`) %>% 
    summarise(., Count = n())
  #Output pie chart of solved/unsolved distribution
  output$solvedchart = renderGvis({
    gvisPieChart(data = count_solved_df, labelvar = count_solved_df$Solved, numvar = count_solved_df$Count,
                 options = list(pieHole = "0.25",
                                chartArea = "{width: '35%', height: '100%'}",
                                colors = "['#de2d26','#fc9272']",
                                legend = "{position: 'labeled'}",
                                pieSliceText = "none"))
  })
  
    
  
  
  ######### Data Table Tab #########
  #Restrict which columns from the original dataframe to use, so as to not crowd visual output
  m1 = murder_database %>%
    select(., Year, Month, State, City, `Weapon`, 
           `Victim Sex`, `Victim Age`, `Victim Race`, 
           `Perpetrator Sex`, `Perpetrator Age`, `Perpetrator Race`,
           `Relationship`, -Population.in.1000s, -Victim_Age_Category)
  #Output data table with filters to increase ease of searching
  output$table = DT::renderDT(m1,
                              filter = list(position = "top", clear = FALSE, plain = FALSE),
                              options = list(pageLength = 10))
  
}