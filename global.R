library(data.table)
library(dplyr)
library(ggplot2)
library(googleVis)

#Import database
murder_database = fread(file = "~/Desktop/NYCDSA/Projects/ShinyMurderApp/database.csv")
statepop_by_year = fread(file="~/Desktop/NYCDSA/Projects/ShinyMurderApp/state_populations_by_year.csv")

murder_database = murder_database %>% 
  mutate(., `Victim_Age_Category` = 
           ifelse(`Victim Age`<=10, "0-10",
                  ifelse(`Victim Age`<=20, "11-20",
                         ifelse(`Victim Age`<=30, "21-30",
                                ifelse(`Victim Age`<=40, "31-40",
                                       ifelse(`Victim Age`<=50, "41-50",
                                              ifelse(`Victim Age`<=60, "61-70", "70+")))))))

murder_database = inner_join(murder_database, statepop_by_year, by = c("State", "Year")) %>%
  mutate(., `Total Victims` = `Victim Count` + 1) %>% 
  select(., -`Record ID`, -`Agency Code`, -`Agency Name`, -`Agency Type`, -`Victim Ethnicity`, -`Record Source`, -`Incident`, -`Victim Count`)

#Define generic US map
state_stat <- data.frame(state.name = rownames(state.x77), state.x77)

#Define choice selections for map visualization
victim.genders = unique(murder_database$`Victim Sex`)
victim.ages = c('0-10', '11-20', '21-30', '31-40','41-50', '51-60', '61-70', '70+')
murder.methods = sort(unique(murder_database$Weapon))
