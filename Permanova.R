# setwd("C:/Users/Cesar/Documents/Code/IPRS/PERMANOVA/")
setwd("M:/Code/IPRS/PERMANOVA/")
rm(list = ls())
library(vegan)

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") 
meta$Type<-factor(meta$Type,levels = c("Gut","Gill","Sediment","Water"))
meta<-meta[order(meta$Type),]


data<-read.csv("../Result/Beta/weighted_unifrac/distance-matrix.tsv",
               sep = "\t",row.names = 1,header = T,check.names = F)
data<-data[meta$sample.id,meta$sample.id]

for(i in c(3)){
  sink(paste(colnames(meta)[i],".txt",sep = ""))  
  print(adonis2(data ~ meta[,i],data = meta,permutations = 999))
  sink()
}

type<-unique(meta$Type)
for(i in 1:(length(type)-1)){
  for (k in (i+1):length(type)) {
  tmeta<-subset(meta,Type %in% type[c(i,k)])
  tdata<-data[tmeta$sample.id,tmeta$sample.id]
  sink(paste(type[i],"-",type[k],".txt",sep = ""))  
  print(adonis2(tdata ~ tmeta[,"Type"],data = tmeta,permutations = 999))
  sink()
  } 
}

for(i in c(5)){
  tmeta<-subset(meta,Type %in% c("Water"))
  tdata<-data[tmeta$sample.id,tmeta$sample.id]
  sink(paste(colnames(tmeta)[i],".txt",sep = ""))  
  print(adonis2(tdata ~ tmeta[,i],data = meta,permutations = 999))
  sink()
}

