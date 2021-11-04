# Compare CDS herbarium species list with global taxonomic databases

## Data visualization and cleaning

library(readxl) # read in data
library(taxize) # to  separate genus, species and subspecies

## For the species comparison with GBIF

#install.packages("rgbif")
library(rgbif)


