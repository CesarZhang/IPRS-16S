rm(list = ls())
library(dplyr)
library(stringr)
library(ggplot2)
setwd("M:/Code/IPRS/SourceTrack/")

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") %>% subset(Type %in% c("Sediment"))

data<-read.table("../Result/SourceTrack/mixing_proportions-A.txt",sep = "\t",
                 header = T,row.names = 1) 
data<-data[rownames(data) %in% meta$sample.id,]
data[,"Type"]<-rep("Sediment",nrow(meta))


meann<-data %>% group_by(Type) %>% summarise_all(list(mean = mean)) %>%
  as.data.frame()
rownames(meann)<-meann$Type
meann<-meann[,2:ncol(meann)] %>%
  t() %>% as.data.frame()
rownames(meann)<-str_replace_all(rownames(meann),"_mean","")

stde <- function(x) sd(x)/sqrt(length(x))
se<-data %>% group_by(Type) %>% summarise_all(list(se = stde)) %>%
  as.data.frame()
rownames(se)<-se$Type
se<-se[,2:ncol(se)] %>% 
  t() %>% as.data.frame()
rownames(se)<-str_replace_all(rownames(se),"_se","")

all<-merge(meann,se,by=0,all=T) 
all[,"Name"]<-rep("Type",nrow(all))
colnames(all)<-c("Type","Mean","Se","Name")
all$Type<-factor(all$Type,levels = c("Gut","Gill","Water","Unknown"))

df<-all


cols<-c("#FFB415","#3983AD","#A43E55","#707070FF")

tiff("SR-Sediment.tiff",width = 1240,height = 1080)
ggplot(data=df, aes(x=Name, y=Mean,fill=Type)) +
  geom_bar(stat="identity", position=position_dodge())+
  scale_fill_manual(values = cols)+
  geom_errorbar(aes(ymin=Mean-Se, ymax=Mean+Se), width=.3,size=2,
                position=position_dodge(.9)
  )+
  xlab("Type")+ylab("")+
  # theme_()+
  guides(fill=guide_legend(title = ""))+
  theme(axis.text.x=element_blank(),
        axis.ticks.x = element_blank(),
        axis.line.x = element_blank(),
        axis.text= element_text(size=50),
        axis.title.y = element_text(size=60),
        axis.title.x = element_text(size=60),
        axis.line.y = element_blank(),
        legend.text = element_text(size = 60),
        legend.title = element_text(size = 60),
        strip.text = element_text(size=50))
dev.off()
