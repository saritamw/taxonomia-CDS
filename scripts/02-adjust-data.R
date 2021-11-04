### For Plants of the World Online we first need to adjust the data

# create full names without author names (for pow)
cdstaxa$fullname <- NA

for(i in 1:nrow(cdstaxa)){
  if(is.na(cdstaxa$Subsp[i]) && is.na(cdstaxa$Var[i])){
    cdstaxa$fullname[i] <- paste0(cdstaxa$Genus[i], " ", cdstaxa$Epiethon[i])
  }
  if(!is.na(cdstaxa$Subsp[i])){
    cdstaxa$fullname[i] <- paste0(cdstaxa$Genus[i], " ", cdstaxa$Epiethon[i], " subsp. ", cdstaxa$Subsp[i])
  }
  if(!is.na(cdstaxa$Var[i])){
    cdstaxa$fullname[i] <- paste0(cdstaxa$Genus[i], " ", cdstaxa$Epiethon[i], " var. ", cdstaxa$Var[i])
  }
}

rm(i)
