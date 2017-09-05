## Validation du respect du plan de préventifs

library(readr)
WODtidy <- read_csv("~/Github/WorkedHoursAnalytics/WODtidy.csv")
PPMProgram <- read_csv("~/Github/WorkedHoursAnalytics/PPMProgram.csv")

pgm <- unique(PPMProgram[,-c(41,42,43)])

woh <- WODtidy[trimws(WODtidy$BOJ1CD) %in% trimws(pgm$TACHE),]

