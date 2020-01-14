library(data.table)
library(dplyr)
library(ggplot2)

murder_database = fread(file = "~/Downloads/database.csv")

murder_database %>% group_by(Year, State) %>% summarise(sum(Incident))
by_state = murder_database %>% group_by(State) %>% summarise(Murders = sum(Incident))

