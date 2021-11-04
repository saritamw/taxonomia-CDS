# Compare CDS herbarium species list with global taxonomic databases

## Install packages and functions
source("scripts/01-packages.R")

### Clean data (if necessary, for POWO)
source("scripts/02-adjust-data.R")

cdstaxa <- read_excel("data/taxa-CDS.xlsx")

# Using POWO, Plants of the World Online

# create column names to fill them with information from POWO

cdstaxa$pow_ID        <- rep("", times = length(cdstaxa$fullname))
cdstaxa$pow_status    <- rep("", times = length(cdstaxa$fullname))
cdstaxa$pow_syn       <- rep("", times = length(cdstaxa$fullname))
cdstaxa$pow_syn_aut   <- rep("", times = length(cdstaxa$fullname))
cdstaxa$pow_syn_nr    <- rep("", times = length(cdstaxa$fullname))
cdstaxa$pow_family    <- rep("", times = length(cdstaxa$fullname))

# get species individual ID in pow
for(i in 1:length(cdstaxa$fullname)){
  cdstaxa$pow_ID[i] <- get_pow(sci_com = c(cdstaxa$fullname[i]),
                          ask = TRUE,  # if FALSE write NA if there are multiple options
                          messages = TRUE)
}

# Alternanthera ficoidea: species only exists with different author names
# Amaranthus dubius: 3
# Amaranthus hybridus: 2 

# Add information for each the species from Plants of the World Online based on species-specific ID.

# get information on taxonomic status and synonyms
for (i in 1:length(cdstaxa$pow_ID)){
  if(is.na(cdstaxa$pow_ID[i])){
    cdstaxa$pow_status[i] <- NA
  }else{
    temp <- pow_lookup(id = c(cdstaxa$pow_ID[i]))
    cdstaxa$pow_status[i]   <- temp$meta$taxonomicStatus
    cdstaxa$pow_family[i]   <- temp$meta$family
    cdstaxa$pow_syn[i]      <- paste(temp$meta$synonyms$name, collapse = ", ")
    cdstaxa$pow_syn_aut[i]  <- paste(temp$meta$synonyms$author, collapse = ", ")
    cdstaxa$pow_syn_nr[i]   <- length(temp$meta$synonyms$name)
    rm(temp)
  }
}

# How many are accepted in Plants of the World Online?
length(cdstaxa$pow_status[which(cdstaxa$pow_status == "Accepted")])


# With gbif

gbif_out <- data.frame(matrix(ncol = 6, nrow = length(cdstaxa$fullname)))
colnames(gbif_out) <- c("usageKey", "scientificName", "rank", "status", "fullname", "occ_count")

for(i in 1:length(cdstaxa$fullname)){
  gbif_out[i, "fullname"] <- cdstaxa$fullname[i]
  temp <- name_backbone(cdstaxa$fullname[i])
  
  if("usageKey" %in% colnames(temp)){
    gbif_out[i,"usageKey"] <- temp$usageKey
  }
  
  if("scientificName" %in% colnames(temp)){
    gbif_out[i,"scientificName"] <- temp$scientificName
  }
  
  if("rank" %in% colnames(temp)){
    gbif_out[i,"rank"] <- temp$rank
  }
  
  if("status" %in% colnames(temp)){
    gbif_out[i,"status"] <- temp$status
  }
  
  gbif_out[i,"occ_count"] <- occ_count(taxonKey = temp$usageKey, georeferenced = TRUE)
}

length(gbif_out$status[which(gbif_out$status == "ACCEPTED")])
