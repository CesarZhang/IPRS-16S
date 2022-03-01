rm(list = ls())
setwd("M://Code/IPRS/Beta/")

library(vegan)

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") 
meta$Type<-factor(meta$Type,levels = c("Gut","Gill","Sediment","Water"))
meta<-meta[order(meta$Type),]


data<-read.csv("../Result/Beta/weighted_unifrac/distance-matrix.tsv",
                sep = "\t",row.names = 1,header = T,check.names = F)
data<-data[meta$sample.id,meta$sample.id]

ord<-metaMDS(data)

NMDS<-list()
NMDS[[1]]<-data.frame(x=ord$points[,1],y=ord$points[,2], 
                      meta1= as.factor(meta[,"Type"]))

#NMDS[[i]][,3]<-factor(NMDS[[i]][,3],levels = c("Chuff","Oral","Fecal","Rectal","Skin","Freshwater"))
colnames(NMDS[[1]])<-c("x","y",colnames(meta)[3])
color_munual<-c("#FFB415","#3983AD","#64638E","#A43E55")

tiff(filename = paste(colnames(meta)[3], ".tiff",sep = ""),
    width = 1080,height = 1080)
print(ggplot(data = NMDS[[1]],aes(x,y,col=NMDS[[1]][,3]))+
        geom_point(size=15)+
        scale_color_manual(values=color_munual)+
        theme_light()+
        guides(color = guide_legend(""))+
        theme(title= element_text(size=25),
              axis.text= element_text(size=25),
              legend.text = element_text(size = 25))+
        
        labs(x="NMDS1",y="NMDS2"))
dev.off()
