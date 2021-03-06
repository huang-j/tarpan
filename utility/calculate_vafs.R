library(data.table)
library(dplyr)
library(stringr)
## notes: counts are in x,y, where x is tier 1 and y is tier 2. Tier 2 is more permissive. Going with tier 1 cause DP is in tier 1
gm <- read.table("/Users/huangj/Documents/Rotations/KunHuangRotation/genome_muts.txt") %>% as.data.table

####
## Helper Functions

get_base_count <- function(info, format, base){
  # info is normal/tumor. Format is the format column
  target_index <- match(paste0(base, "U"), unlist(str_split(format, ":")))
  count <- unlist(str_split(info, ":"))[target_index] %>% str_split(",") %>% unlist
  return(as.numeric(count[1]))
}

get_snv_vaf <- function(info, format, base){
  # info is normal/tumor. Format is the format column
  format <- str_split(format, ":") %>% unlist
  target_index <- match(paste0(base, "U"), format)
  DP_index <- match("DP", format)
  info <- unlist(str_split(info, ":"))
  DP <- info[DP_index] %>% as.numeric
  count <- info[target_index] %>% str_split(",") %>% unlist
  ## for tier 1 use index of 1, for 2 use index of 2
  return(as.numeric(count[1])/DP %>% toString)
}

## need to edit
get_indel_vaf <- function(info, format){
  # info is normal/tumor. Format is the format column
  format <- str_split(format, ":") %>% unlist
  alt_index <- match("TIR", format)
  DP_index <- match("TAR", format)
  info <- unlist(str_split(info, ":"))
  DP <- info[DP_index] %>% as.numeric
  count <- info[target_index] %>% str_split(",") %>% unlist
  ## for tier 1 use index of 1, for 2 use index of 2
  return(as.numeric(count[1])/(DP) %>% toString)
}


####
## Main function which runs the helper functions

## it seems he doesn't keep mut_tools in the table so I made edits to pretty much grab it from the format column
get_vaf <- function(dt, tool=FALSE){
  ## dt is the data.table, tool is the tool i.e strelka_snvs/indel etc
  s_snvs <- function(dt){
    dt[grepl(":AU:", format), c("normal_vaf", "tumor_vaf") := 
         .(mapply(get_snv_vaf, normal, format, alt),
           mapply(get_snv_vaf, tumor, format, alt))]
    return(dt)
  }
  s_indels <- function(dt){
    # dt[grepl(":TIR:", format), c("normal_vaf", "tumor_vaf") := 
    #     .(mapply(get_indel_vaf, normal, format, alt),
    #       mapply(get_indel_vaf, tumor, format, alt))]
    return(dt)
  }
  
  if (tool == FALSE) {
    ## if false just run both i guess
    dt <- dt %>% s_snvs %>% s_indels
  } else if (tool == "strelka_snvs") { dt <- dt %>% s_snvs}
  else if (tool == "strelka_snvs") { dt <- dt %>% s_indels}
  
  ### change all NAs to char "NA"
  dt[is.na(normal_vaf), normal_vaf := "N/A"]
  dt[is.na(tumor_vaf), normal_vaf := "N/A"]
  
  
  return(dt)
}

