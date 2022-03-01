rm(list = ls())

library(stringr)
library(ggplot2)
library(VennDiagram)


setwd("M://Code/IPRS/Venn/")

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") 
meta$Type<-factor(meta$Type,levels = c("Gut","Gill","Sediment","Water"))


data<-read.table("../Result/OTU/table.tsv",row.names = 1,
                 header = T,check.names = F)
data<-data[,meta$sample.id]


stde <- function(x) sd(x)/sqrt(length(x))
nonzero <- function(x) sum(x != 0)
i<-3
# for(i in 2:ncol(metadata)){
new<-cbind(t(data),meta[,i,drop=F])
colnames(new)[ncol(new)]<-c("Type")

#mean
meann<-new %>% group_by(Type) %>% summarise_all(list(mean = mean)) %>%
  as.data.frame()
rownames(meann)<-meann$Type
meann<-meann[,2:ncol(meann)] %>%
  t() %>% as.data.frame()
rownames(meann)<-str_replace_all(rownames(meann),"_mean","")


rt<-meann[,! colnames(meann) %in% c("Sediment")]
list1<-list()
for(i in colnames(rt)){
  rt1<-rt[rt[,i]!=0,]
  # print(head(rownames(rt1)))
  list1[[i]]=rownames(rt1)
}


color_m<-c("#FFB415","#3983AD","#A43E55")
venn.diagram(list1,
             fill = color_m,
             imagetype = "png",
             height = 2400,width = 2400, resolution = 600,
             compression = "lzw",
             filename = "fish_water.png",
             lty="blank",
             cex=1,
             fontfamily="sans",
             #cat.pos=c(6),
             cat.default.pos="outer",
             cat.dist=c(0.1),
             cat.cex=1.2
)


rt<-meann[,! colnames(meann) %in% c("Water")]
list1<-list()
for(i in colnames(rt)){
  rt1<-rt[rt[,i]!=0,]
  # print(head(rownames(rt1)))
  list1[[i]]=rownames(rt1)
}


color_m<-c("#FFB415","#3983AD","#64638E")
venn.diagram(list1,
             fill = color_m,
             imagetype = "png",
             height = 2400,width = 2400, resolution = 600,
             compression = "lzw",
             filename = "fish_sediment.png",
             lty="blank",
             cex=1,
             fontfamily="sans",
             #cat.pos=c(6),
             cat.default.pos="outer",
             cat.dist=c(0.1),
             cat.cex=1.2
)

###############
rt<-meann
list1<-list()
for(i in colnames(rt)){
  rt1<-rt[rt[,i]!=0,]
  # print(head(rownames(rt1)))
  list1[[i]]=rownames(rt1)
}


color_m<-c("#FFB415","#3983AD","#64638E","#A43E55")
venn.diagram(list1,
             fill = color_m,
             imagetype = "png",
             height = 2400,width = 2400, resolution = 600,
             compression = "lzw",
             filename = "Venn.png",
             lty="blank",
             cex=1,
             fontfamily="sans",
             #cat.pos=c(6),
             cat.default.pos="outer",
             cat.dist=c(0.1),
             cat.cex=1.2
)

