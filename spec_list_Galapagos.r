# Compare Floreana species list with global taxonomic databases

# read in data
library(readxl)

taxall <- read_excel("taxones-floreana-2021-sub.xlsx")

# As examples I will use POWO and gbif as examples for comparison

# Prepare table in a way that genus, species etc are separated. The background is that different databases use different spelling of "subs.", "ssp.", "subsp". and other worlds.

library(taxize)

# create full names without author names (for pow)
taxall$fullname <- NA

for(i in 1:nrow(taxall)){
  if(is.na(taxall$Subsp[i]) && is.na(taxall$Var[i])){
    taxall$fullname[i] <- paste0(taxall$Genus[i], " ", taxall$Epiethon[i])
  }
  if(!is.na(taxall$Subsp[i])){
    taxall$fullname[i] <- paste0(taxall$Genus[i], " ", taxall$Epiethon[i], " subsp. ", taxall$Subsp[i])
  }
  if(!is.na(taxall$Var[i])){
    taxall$fullname[i] <- paste0(taxall$Genus[i], " ", taxall$Epiethon[i], " var. ", taxall$Var[i])
  }
}

rm(i)


# create column names to fill them with information from POWO

taxall$pow_ID        <- rep("", times = length(taxall$fullname))
taxall$pow_status    <- rep("", times = length(taxall$fullname))
taxall$pow_syn       <- rep("", times = length(taxall$fullname))
taxall$pow_syn_aut   <- rep("", times = length(taxall$fullname))
taxall$pow_syn_nr    <- rep("", times = length(taxall$fullname))
taxall$pow_family    <- rep("", times = length(taxall$fullname))

# get species individual ID in pow
for(i in 1:length(taxall$fullname)){
  taxall$pow_ID[i] <- get_pow(sci_com = c(taxall$fullname[i]),
                          ask = TRUE,  # if FALSE write NA if there are multiple options
                          messages = TRUE)
}

# Alternanthera ficoidea: species only exists with different author names
# Amaranthus dubius: 3
# Amaranthus hybridus: 2 

# Add information for each the species from Plants of the World Online based on species-specific ID.

# get information on taxonomic status and synonyms
for (i in 1:length(taxall$pow_ID)){
  if(is.na(taxall$pow_ID[i])){
    taxall$pow_status[i] <- NA
  }else{
    temp <- pow_lookup(id = c(taxall$pow_ID[i]))
    taxall$pow_status[i]   <- temp$meta$taxonomicStatus
    taxall$pow_family[i]   <- temp$meta$family
    taxall$pow_syn[i]      <- paste(temp$meta$synonyms$name, collapse = ", ")
    taxall$pow_syn_aut[i]  <- paste(temp$meta$synonyms$author, collapse = ", ")
    taxall$pow_syn_nr[i]   <- length(temp$meta$synonyms$name)
    rm(temp)
  }
}

# How many are accepted in Plants of the World Online?
length(taxall$pow_status[which(taxall$pow_status == "Accepted")])



# gbif

library(rgbif)

gbif_out <- data.frame(matrix(ncol = 6, nrow = length(taxall$fullname)))
colnames(gbif_out) <- c("usageKey", "scientificName", "rank", "status", "fullname", "occ_count")

for(i in 1:length(taxall$fullname)){
  gbif_out[i, "fullname"] <- taxall$fullname[i]
  temp <- name_backbone(taxall$fullname[i])
  
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
