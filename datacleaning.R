state_abbreviations = read.csv(file = '~/Downloads/data.csv')
state_file_list = paste('~/Downloads/State Populations/', list.files(path = '~/Downloads/State Populations/', pattern = '*.csv'), sep='')

#Define a function to extract the state abbreviation from a filepath (**** from './names/yob****.txt)
extract_state = function(filepath){    
  substr(filepath, 31, 32)
}

#Define a function to read a single file and returns an appropriately formatted dataframe
read_single_file = function(file){
  temp_df = read.csv(file=file, header=T, col.names = c('Date', 'Population in 1000s'), stringsAsFactors = F)
  temp_df$state = extract_state(file) #Calculates the state from the file name and stores it in a column
  temp_df$Year = format(as.Date(temp_df$Date, "%Y-%m-%d"), "%Y")
  return(temp_df)
}

#Create a single data frame from all .txt files in the data folder
aggregated_population_df = 
  lapply(state_file_list, read_single_file) %>% 
  bind_rows(.)

#Merge data frame so that state name exists in the dataframe
aggregated_population_df = 
  merge(x = aggregated_population_df, y = state_abbreviations, by.x = "state", by.y = "Code") %>% 
  select(., Year, Population.in.1000s, State = State) %>% 
  filter(., Year >= 1980 & Year <= 2014)

#Write the file to a CSV file to be used in the Shiny App
write.csv(aggregated_population_df, file = "~/Desktop/NYCDSA/Projects/ShinyMurderApp/state_populations_by_year.csv", row.names=F)
View(aggregated_population_df)