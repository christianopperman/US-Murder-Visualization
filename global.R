library(data.table)
library(dplyr)
library(ggplot2)
library(googleVis)

#Import database
murder_database = fread(file = "~/Desktop/NYCDSA/Projects/ShinyMurderApp/database.csv")

#Define generic US map
state_stat <- data.frame(state.name = rownames(state.x77), state.x77)

#Define choice selections for map visualization

victim.genders = unique(murder_database$`Victim Sex`)
victim.ages = c('0-10', '11-20', '21-30', '31-40','41-50', '51-60', '61-70', '70+')
murder.methods = sort(unique(murder_database$Weapon))
