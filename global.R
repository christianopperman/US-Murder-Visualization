library(shiny)
library(shinydashboard)
library(data.table)
library(dplyr)
library(googleVis)
library(DT)
library(tidyr)

#Import database
murder_database = fread(file = "./data/database.csv", stringsAsFactors = T)
statepop_by_year = fread(file="./data/state_populations_by_year.csv", stringsAsFactors = T)

murder_database = murder_database %>% 
  mutate(., `Victim_Age_Category` = 
           ifelse(`Victim Age`<=9, "0-9",
                  ifelse(`Victim Age`<=19, "10-19",
                         ifelse(`Victim Age`<=29, "20-29",
                                ifelse(`Victim Age`<=39, "30-39",
                                       ifelse(`Victim Age`<=49, "40-49",
                                              ifelse(`Victim Age`<=59, "50-59",
                                                    ifelse(`Victim Age` <= 69, "60-69",
                                                           ifelse(`Victim Age` != 998, "70+", "Unknown")))))))))

murder_database = inner_join(murder_database, statepop_by_year, by = c("State", "Year")) %>%
  select(., -`Record ID`, -`Agency Code`, -`Agency Name`, -`Agency Type`, -`Victim Ethnicity`, -`Record Source`, -`Incident`, -`Victim Count`, -`Perpetrator Count`, -`Perpetrator Ethnicity`, -`Crime Type`)
murder_database$State = as.factor(murder_database$State)

#Define generic US map
state_stat <- data.frame(state.name = rownames(state.x77), state.x77)

#Define choice selections for map visualization
victim.genders = unique(murder_database$`Victim Sex`)
victim.ages = c('0-9', '10-19', '20-29', '30-39','40-49', '50-59', '60-69', '70+', 'Unknown')
victim.races = unique(murder_database$`Victim Race`)
murder.methods = sort(unique(murder_database$Weapon))
