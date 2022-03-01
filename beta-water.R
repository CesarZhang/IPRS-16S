rm(list = ls())
setwd("M://Code/IPRS/Beta/")

library(vegan)
library(dplyr)
library(ggplot2)

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") %>% subset(Type=="Water")
# meta$Type<-factor(meta$Type,levels = c("Gut","Gill","Sediment","Water"))
# meta<-meta[order(meta$Type),]


data<-read.csv("../Result/Beta/weighted_unifrac/distance-matrix.tsv",
                sep = "\t",row.names = 1,header = T,check.names = F)
data<-data[meta$sample.id,meta$sample.id]

ord<-metaMDS(data)

NMDS<-list()
NMDS[[1]]<-data.frame(x=ord$points[,1],y=ord$points[,2], 
                      meta1= as.factor(meta[,"Site"]),
                      meta2= as.factor(meta[,"IOR"]))


colnames(NMDS[[1]])<-c("x","y",colnames(meta)[c(4,5)])
color_munual<-c("#5DA5DAFF","#FAA43AFF")

tiff(filename = paste(colnames(meta)[4], ".tiff",sep = ""),
    width = 1080,height = 1080)
print(
  ggplot(data = NMDS[[1]],aes(x,y,col=NMDS[[1]][,4]))+
        geom_point(size=15)+
        scale_color_manual(values=color_munual)+
        theme_light()+
        guides(color = guide_legend(""),
               shape = guide_legend(""))+
        theme(title= element_text(size=25),
              axis.text= element_text(size=25),
              legend.text = element_text(size = 25))+
        
        labs(x="NMDS1",y="NMDS2")
  )
dev.off()
