##################################################
##################################################
################## packages ######################
##################################################
##################################################


# install.packages("RDSTK")
# install.packages("base64enc")
# install.packages("httr")
# install.packages("devtools")
# install.packages("XML")
# install.packages("rvest")
# install.packages("purrr")
# install.packages("RCurl")
# install.packages("RJSONIO")
# install.packages("ggmap")
# install.packages("readr")
# install.packages("sp")
# install.packages("rgdal")
# install.packages("jsonlite")
# install.packages("rworldmap")
# install.packages("geonames")
# install.packages("dplyr")
# install.packages("rworldxtra")
# install.packages("googleway")
# install.packages("Hmisc")
# install.packages("rJava")
# install.packages("NLP")
# install.packages("openNLP")

library("RDSTK")
library(base64enc)
library(httr)
library(devtools)
library(XML)
library("rvest")
library(purrr)
library(RCurl)
library(RJSONIO)
library(ggmap)
library(readr)
library(sp)
library(rgdal)
library(jsonlite)
library(rworldmap)
library(geonames)
library(dplyr)
library(rworldxtra)
library(googleway)
library(Hmisc)
library(rJava)
library(NLP)
library(openNLP)
library(stringr)




##################################################
##################################################
################## Funtions ######################
##################################################
##################################################


# Geocode #

## Method street2coordinates : unrestricted but only avaible for US or UK adresses
street2coordinates2 <- function (full_adress) { return(tryCatch(street2coordinates(full_adress), error=function(e) "NULL"))}
### Function pour Traitement variable caractère :
extract_character_var=function(numvar,full_adress){
  extract=as.vector(map(full_adress, numvar))
  extract=lapply(extract, `[[`,1)
  for (i in 1:length(extract)){if(!is.null(extract[[i]])){extract[[i]]=gsub("levels: "," ",extract[[i]],fixed=T)}else{extract[[i]]=NA}}
  extract=unlist(extract)
  return(extract)
}
### Function pour Traitement variable num :
extract_numeric_var=function(numvar,full_adress){
  extract=as.vector(map(full_adress, numvar))
  for (i in 1:length(extract)){if(!is.null(extract[[i]])){extract[[i]]=extract[[i]]}else{extract[[i]]=NA}}
  extract=unlist(extract)
  return(extract)
}
extract_numeric_var2 <- function (full_adress, numvar) { return(tryCatch(extract_numeric_var(full_adress, numvar), error=function(e) "NULL"))}

### Fonction pour wrapper le tout dans une matrice
extract_localisation=function(full_adress){
  full_adress_vect=as.vector(full_adress)
  full_adress_vect=lapply(full_adress_vect,street2coordinates2)
  Localisation = matrix(0,length(full_adress_vect),11)
  colnames(Localisation)= c("country_code","country_code2","country_name","code_admin_niv_1","postal_code","locality","latitude","longitude","street_name","street_number","confidence")
  Localisation[,"country_code2"]=extract_character_var(2,full_adress_vect)
  Localisation[,"country_code"]=extract_character_var(13,full_adress_vect)
  Localisation[,"country_name"]=extract_character_var(4,full_adress_vect)
  Localisation[,"code_admin_niv_1"]=extract_character_var(7,full_adress_vect)
  Localisation[,"postal_code"]=as.numeric(as.character(extract_character_var(12,full_adress_vect)))
  Localisation[,"locality"]=extract_character_var(10,full_adress_vect)
  Localisation[,"latitude"]=as.numeric(as.character(extract_numeric_var(3,full_adress_vect)))
  Localisation[,"longitude"]=as.numeric(as.character(extract_numeric_var(5,full_adress_vect)))
  Localisation[,"street_name"]=extract_character_var(11,full_adress_vect)
  Localisation[,"street_number"]=as.numeric(as.character(extract_character_var(9,full_adress_vect)))
  Localisation[,"confidence"]=extract_numeric_var(8,full_adress_vect)
  Localisation=data.frame(cbind(full_adress_vect,Localisation),stringsAsFactors =F)
  
  return(Localisation)
}

unlist2 <- function(data) {
  ListCols <- sapply(data, is.list)
  cbind(data[!ListCols], t(apply(data[ListCols], 1, unlist)), stringsAsFactors =F)
}

## Methode googleway geocode : restricted to 2500 query per day.
extract_Location_google=function(full_adress,key){
  short=matrix(NA,nrow = 2,ncol = 2)
  coord_google=list()
  loc_google=list()
  loc_google_2=list()
  cb_loc_google=list()
  df_loc_google=list()
  df_coord_google=list()
  for (i in 1:length(full_adress)){
    print(paste0("Processing adress ", i, ". out of ",length(full_adress),"..."))
    if(google_geocode(full_adress[i], key = key)[[2]]=="OK"){
      coord_google[[i]]=google_geocode(full_adress[i], key = key)[[1]][[3]][["location"]]
      loc_google[[i]]=google_geocode(full_adress[i], key = key)[[1]][[1]][[1]]
      for (j in 1:length(loc_google[[i]][[3]])){
        loc_google[[i]][[3]][[j]]=loc_google[[i]][[3]][[j]][1]
      }
      loc_google[[i]]=as.matrix(t(loc_google[[i]]))
      colnames(loc_google[[i]])=loc_google[[i]][3,]
      loc_google_2[[i]]=loc_google[[i]][1:2,]
      
      rownames(short) = c("long_name", "short_name")
      colnames(short)=c("code_admin_niv_1","country_code")
      short[1,1]=unlist(loc_google[[i]]["short_name","administrative_area_level_1"])
      short[1,2]=unlist(loc_google[[i]]["short_name","country"])
      loc_google[[i]]=cbind(loc_google_2[[i]],short)
      
    }else {
      loc_google[[i]]= matrix(unlist(google_geocode(information_base_google$full_adress[i], key = key)[[2]]),nrow=2,ncol=1)
      coord_google[[i]]=matrix(NA,nrow=1,ncol=2)
    }
    cb_loc_google[[i]]=as.matrix(loc_google[[i]][1,])
    df_loc_google[[i]]=as.data.frame(loc_google[[i]][1,],stringsAsFactors =F)
    df_coord_google[[i]] = as.data.frame(coord_google[[i]][1,])
  }
  df_loc_google=rbind.fill(df_loc_google)
  df_coord_google=rbind.fill(coord_google)
  extract_brut=cbind.data.frame(full_adress,df_loc_google,df_coord_google,stringsAsFactors =F)
  names(extract_brut)[names(extract_brut)=="country"] <- "country_name"
  names(extract_brut)[names(extract_brut)=="lng"] <- "longitude"
  names(extract_brut)[names(extract_brut)=="lat"] <- "latitude" 
  names(extract_brut)[names(extract_brut)=="postal_code_suffix"] <- "postal_code"
  names(extract_brut)[names(extract_brut)=="route"] <- "street_name"
  
  return(extract_brut)
}


# extract info#
extract_bloomberg=function(target_html_extract,Name,target_extract_type,label){    
  split=list()
  if (!is_empty(target_html_extract)){
    target_html_extract=sapply(as.character(target_html_extract),gsub,pattern="(^[\\\n]{1,3})", replacement="")
    target_html_extract=sapply(as.character(target_html_extract),gsub,pattern="[\\\n]{1,3}$", replacement="")
    split=mapply(str_split,target_html_extract,"([\\\n]|(,[:space:]))+", simplify = TRUE)
    if (class(split)=="matrix"){split=t(rbind.fill.matrix(split))}
    if (class(split)=="list"){split= rbind.fill.matrix(split)}
    target_extract_type=as.data.frame(split, stringsAsFactors =F)
    colnames(target_extract_type)=paste0("Info", seq.int(ncol(target_extract_type)))
    target_extract_type$Name=Name
    target_extract_type$TABLE=label
    target_extract_type$INDEX= paste0(Name,".",label, seq.int(nrow(target_extract_type)))
    target_extract_type <- target_extract_type %>% select(INDEX,Name,TABLE,everything())
  }else{
    target_extract_type=data.frame(INDEX=paste0(Name,".",label, "NONE"), Name=Name,TABLE=label,Info1=NA)}
  return(target_extract_type)
}


# wrap function #
bloomberg<- function(page_ref, path_sauvegarde){
  # Recuperation du nombre de page
  lien=page_ref
  
  
  ## recuperation de la pagge Blizzard
  htmlpage <- read_html(lien)
  
  NBPage <- htmlpage %>%
    html_nodes("div.pagination") %>%
    html_text()
  
  Page=strsplit(gsub("[^([:digit:][:space:])]+","A", NBPage),"[ ]")[[1]]
  Page=as.numeric(Page)
  Page=Page[!is.na(Page)]
  NBPage=tail(Page,1)
  
  
  ## Récupération de tous les liens de toutes les pages;
  Liens.info=list()
  for (j in 1:NBPage) {
    print(paste0("Processing page ", j, ". out of ",NBPage,"..."))
    lieninfo = paste0("https://www.bloomberg.com/bcom/sitemaps/people-", j ,".html")
    
    #recuperation de la page Blizzard
    htmlpage <- read_html(lieninfo)
    
    #Recuperation de tous les liens de la page j 
    Liens <- htmlpage %>% html_nodes("a") %>%  html_attr("href")  %>% as.vector()
    Liens.info[[j]]=Liens
  } 
  
  ## Etape tri : Recuperation des liens qui nous interesse: 
  #ceux qui contiennent le mot "people" et "https" 
  for (j in 1:length(Liens.info)){
    Liens.info[[j]] = grep("people", Liens.info[[j]], value = TRUE, ignore.case = TRUE)
    Liens.info[[j]] = grep("https",Liens.info[[j]],value = TRUE, ignore.case = TRUE)
  } 
  Liens.info=unlist(Liens.info)
  Liens.info.sauv=Liens.info
  
  # Recuperation des informations de base pour éventuellement filtrer une liste de noms ou par location;
  Name=vector()
  information_base=matrix(0,nrow = length(Liens.info), ncol = 7)
  colnames(information_base)= c("Name","Title","sub_title1","sub_title2","full_adress","corporate_Website","corporate_phone")
  for (i in 1:length(Liens.info)){
    print(paste0("Processing people ", i, ". out of ",length(Liens.info),"..."))
    
    #recuperation de la page i
    htmlpage <- read_html(Liens.info[i])
    
    #recuperation du info de base pour croiser avec liste de nom issue de la fsma (autorité des marché financier belges); 
    Name <- htmlpage %>% html_nodes("h1.name") %>% .[[1]] %>% html_text()
    if (length(Name)==1){information_base[i,1]=Name}
    Title <- htmlpage %>%  html_nodes("h2.title") %>% .[[1]] %>% html_text()
    if (length(Title)==1){information_base[i,2]=Title}
    sub_title1 <- htmlpage %>%  html_nodes("div.header") %>%  html_nodes("a") %>%  html_text()
    if (length(sub_title1)==1){information_base[i,3]=sub_title1}
    sub_title2 <- htmlpage %>%  html_nodes("div.header") %>% html_nodes("div.byline")  %>%html_text()
    if (length(sub_title2)==1){information_base[i,4]=gsub("^.*,\\\n","",sub_title2)}
    corporate_Location <- htmlpage %>% html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.corporate_info") %>% html_nodes("div.address")%>% html_text()
    if (length(corporate_Location)==1){information_base[i,5]=gsub("[\\\n]+"," ",corporate_Location)}
    corporate_Website <- htmlpage %>% html_nodes("div.basic_profile") %>% html_nodes("a") %>%  html_attr("href") %>% as.character()
    if (length(corporate_Website)==1){information_base[i,6]=corporate_Website}
    corporate_phone<- htmlpage %>% html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.corporate_info") %>% html_nodes("div.phone") %>% html_nodes("a") %>% html_text()
    if (length(corporate_phone)==1){information_base[i,7]=corporate_phone}
  }
  
  information_base=as.data.frame(information_base, stringsAsFactors =F)
  information_base$num=seq.int(nrow(information_base))
  information_base <- information_base %>% select(num, everything())
  
  # traitepment full adress #
  ## traitement des informations localisation pour la rendre utilisable 
  information_base_sauvegarde=information_base  
  ### restrcition to relevant row in order to "economize" queries
  #### supression des NA in NAME :
  information_base=filter(information_base,!is.na(information_base$Name))
  information_base=filter(information_base,information_base$Name!=0)
  information_base=filter(information_base,!is_empty(information_base$Name))
  information_base=filter(information_base,information_base$Name!="")
  #### supression des NA in fulladress :
  information_base=filter(information_base,!is.na(full_adress))
  information_base=filter(information_base,!is_empty(full_adress))
  information_base=filter(information_base,full_adress!=" ")
  doublon=which(duplicated(information_base$full_adress))
  information_base=filter(information_base,row_number() %nin% doublon)
  
  Localisation=extract_localisation(information_base$full_adress)
  Localisation_DSTK=data.frame(cbind.data.frame(information_base$full_adress, Localisation, stringsAsFactors =F),stringsAsFactors =F)
  drop="full_adress_vect"
  Localisation_DSTK=Localisation_DSTK[,!(names(Localisation_DSTK) %in% drop)]
  Localisation_DSTK=unlist2(Localisation_DSTK)
  Localisation_DSTK$latitude=as.numeric(Localisation_DSTK$latitude)
  Localisation_DSTK$longitude=as.numeric(Localisation_DSTK$longitude)
  names(Localisation_DSTK)[names(Localisation_DSTK)=="information_base.full_adress"] <- "full_adress"
  
  Localisation_google=Localisation_DSTK
  ### API Key of a google account
  key <- "AIzaSyBMrkHx3JGG6Qfd60sGdJOkuGu-ZGGhFKg"
  
  ### restrcition to relevant row non resolves by street2coordinates "economize" queries
  Localisation_google=filter(Localisation_google,is.na(Localisation_google$country_code))
  
  Localisation_google=extract_Location_google(Localisation_google$full_adress, key= key)
  Localisation_google=as.data.frame(Localisation_google, stringsAsFactors=FALSE)
  Localisation_google$quartier=with(Localisation_google, paste(administrative_area_level_3, neighborhood, political,sep = " "))
  Localisation_google$quartier=gsub("NA","", Localisation_google$quartier)
  Localisation=rbind.fill(Localisation_google,Localisation_DSTK)
  Localisation=filter(Localisation, !is.na(Localisation$country_name))
  Localisation <- Localisation %>% select(full_adress, latitude, longitude, country_name, country_code, postal_code, locality, administrative_area_level_1, code_admin_niv_1, street_number, street_name, premise, quartier)
  information_base=left_join(information_base_sauvegarde, Localisation, by="full_adress")
  write.csv(information_base, paste0(path_sauvegarde,"information-base.csv"))
 
  
  # Recupération autres informations
  extract_bloomberg=function(target_html_extract,Name,target_extract_type,label){    
    split=list()
    if (!is_empty(target_html_extract)){
      target_html_extract=sapply(as.character(target_html_extract),gsub,pattern="(^[\\\n]{1,3})", replacement="")
      target_html_extract=sapply(as.character(target_html_extract),gsub,pattern="[\\\n]{1,3}$", replacement="")
      split=mapply(str_split,target_html_extract,"([\\\n]|(,[:space:]))+", simplify = TRUE)
      if (class(split)=="matrix"){split=t(rbind.fill.matrix(split))}
      if (class(split)=="list"){split= rbind.fill.matrix(split)}
      target_extract_type=as.data.frame(split, stringsAsFactors =F)
      colnames(target_extract_type)=paste0("Info", seq.int(ncol(target_extract_type)))
      target_extract_type$Name=Name
      target_extract_type$TABLE=label
      target_extract_type$INDEX= paste0(Name,".",label, seq.int(nrow(target_extract_type)))
      target_extract_type <- target_extract_type %>% select(INDEX,Name,TABLE,everything())
    }else{
      target_extract_type=data.frame(INDEX=paste0(Name,".",label, "NONE"), Name=Name,TABLE=label,Info1=NA)}
    return(target_extract_type)
  }
  
  split=list()
  for (i in 1:length(Liens.info)){
    print(paste0("Processing people ", i, ". out of ",length(Liens.info),"..."))
    
    htmlpage <- read_html(Liens.info[i])
    Name <- htmlpage %>% html_nodes("h1.name") %>% .[[1]] %>% html_text()
    if (length(Name)==1){
      
      ##Table career;
      all_experiences <- htmlpage %>%  html_nodes("div.item.page_module") %>% html_nodes("div.bio_career")  %>% html_nodes("div.section.first.last") %>% html_nodes("li.record")%>%html_text()
      career=extract_bloomberg(all_experiences,Name,career,"career") 
      assign(paste0("career",i),career)
      if (i==1){table.career=career}
      if (i>1){table.career=rbind.fill(get(paste0("career",i)),table.career)}
      
      # ##Table Education;
      all_education <- htmlpage %>%  html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.personal_info")  %>% html_nodes("div.education.first.last.section") %>% html_nodes("li.record")%>% html_text()
      education=extract_bloomberg(all_education,Name,education,"education") 
      assign(paste0("education",i),education)
      if (i==1){table.education=education}
      if (i>1){table.education=rbind.fill(get(paste0("education",i)),table.education)}
      
      ##Table Membership;
      all_membership <- htmlpage %>%  html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.bio_membership") %>% html_nodes("li.record")%>% html_text()
      membership=extract_bloomberg(all_membership,Name,membership,"membership") 
      assign(paste0("membership",i),membership)
      if (i==1){table.membership=membership}
      if (i>1){table.membership=rbind.fill(get(paste0("membership",i)),table.membership)}
      
      ##Table achievment;
      
      all_certification  <- htmlpage %>%  html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.award_publication") %>%  html_nodes("div.certificates.section") %>% html_nodes("li.record")%>% html_text()
      certification=extract_bloomberg(all_certification,Name,certification,"certification")
      assign(paste0("certification",i),certification)
      if (i==1){table.certification=certification}
      if (i>1){table.certification=rbind.fill(get(paste0("certification",i)),table.certification)}
      
      all_awards <- htmlpage %>%  html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.award_publication") %>%  html_nodes("div.awards.first.section") %>% html_nodes("li.record")%>% html_text()
      awards=extract_bloomberg(all_awards,Name,awards,"awards")
      assign(paste0("awards",i),awards)
      if (i==1){table.awards=awards}
      if (i>1){table.awards=rbind.fill(get(paste0("awards",i)),table.awards)}    
      
      all_publications <- htmlpage %>%  html_nodes("div.item.page_module") %>%  html_nodes("div.markets_module.award_publication") %>%  html_nodes("div.last.publications.section") %>% html_nodes("li.record")%>% html_text()
      publications=extract_bloomberg(all_publications,Name,publications,"publications")
      assign(paste0("publications",i),publications)
      if (i==1){table.publications=publications}
      if (i>1){table.publications=rbind.fill(get(paste0("publications",i)),table.publications)}
    }
  }
  table.achievment=rbind.fill(table.awards, table.publications, table.certification)
  table.achievment=table.achievment[with(table.achievment, order(INDEX)), ]
  
  # Merge table detail
  table.global=rbind.fill(table.career,table.education,table.membership,table.achievment)
  table.global=table.global[with(table.global, order(INDEX)), ]
  write.csv(table.global,paste0(path_sauvegarde,"table-global.csv"))
  rm(list = ls()[grep("publication", ls())])
  rm(list = ls()[grep("awards", ls())])
  rm(list = ls()[grep("career", ls())])
  rm(list = ls()[grep("certification", ls())])
  rm(list = ls()[grep("education", ls())])
  rm(list = ls()[grep("membership", ls())])
  return(list(table.global, Localisation, information_base, information_base_sauvegarde, Localisation_DSTK, Localisation_google))
  write.csv(Localisation,paste0(path_sauvegarde,"Localisation.csv"))
  write.csv(information_base_sauvegarde,paste0(path_sauvegarde,"information_base_sauvegarde.csv"))
  }


##################################################
##################################################
################## exécution ######################
##################################################
##################################################

options(nwarnings=10000)






  