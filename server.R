library(shiny)

shinyServer(function(input, output) {
  
  murder_map_df = reactive({
    
    #Filter dataset by victim gender as selected by the user in the genderCheckGroup
    if(is.null(input$ageCheckGroup)){
      murder_map_df = murder_database
    } else {
      murder_map_df = murder_database %>% filter(., `Victim Age` %in% input$ageCheckGroup)
    }
    
    #Filter dataset by victim age as selected by the user in the ageCheckGroup
    #if(is.null(input$ageCheckGroup)){
     # murder_map_df = murder_map_df
    #} else {
    #  murder_map_df = murder_map_df %>% filter(., `Victim Age` %in% input$ageCheckGroup)
    #}
    
    #Filter dataset by year as selected by the user in the yearSlider
    #Group dataset by State and create outputs to be used to color the map
    murder_map_df = 
      murder_map_df %>% 
      filter(., between(Year, input$yearSlider[1], input$yearSlider[2])) %>% 
      group_by(., State, `Victim Age`) %>% 
      summarise(., log_murders=log(sum(Incident)), total_murders = sum(Incident))
    
    #murder_map_df = 
      #murder_database %>% 
      #filter(., between(Year, input$yearSlider[1], input$yearSlider[2])) %>% 
      #filter(., `Victim Sex` %in% ifelse(is.null(input$genderCheckGroup), victim.genders, input$genderCheckGroup)) %>% 
      #group_by(., State) %>% 
      #summarise(., log_murders = log(sum(Incident)), total_murders = sum(Incident))
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