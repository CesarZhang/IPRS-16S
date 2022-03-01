rm(list = ls())
library(reshape2)
library(stringr)
library(ggplot2)
library(dplyr)
library(pheatmap)

setwd("M://Code/IPRS/FS-Barplot/")

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") %>% subset(Type1 %in% c("Fish","Sediment")) 
meta$Type1<-factor(meta$Type1,levels = c("Fish","Sediment"))
meta<-meta[order(meta$Type1),]

##############
data<-read.table("../Result/OTU/Relative-table.tax.tsv",row.names = 1,
                 header = T,check.names = F,sep = "\t")

tax<-data[,"taxonomy",drop=F]

data<-data[,meta$sample.id]
data<-data[rowSums(data) >0,]

stde <- function(x) sd(x)/sqrt(length(x))
i<-6
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

#se

se<-new %>% group_by(Type) %>% summarise_all(list(se = stde)) %>%
  as.data.frame()
rownames(se)<-se$Type
se<-se[,2:ncol(se)] %>% 
  t() %>% as.data.frame()
rownames(se)<-str_replace_all(rownames(se),"_se","")


x<-as.data.frame(t(data)) %>%
  cbind(meta[,6,drop=F])
nr<-nrow(x)
pv<-data.frame()
for (i in 1:(ncol(x)-1)) {
  tmp<-x[1:nr,c(i,ncol(x))]
  colnames(tmp)<-c("v","t")
  kt<-kruskal.test(v ~ t, data=tmp)
  pv[i,1]<-kt$p.value
}
rownames(pv)<-colnames(x)[1:(ncol(x)-1)]


###### merge
all<-merge(meann,se,by=0,all=T) %>%
  merge(pv,by.x="Row.names",by.y = 0,all = T)
######
# 
# sigb<-subset(all,V1<=0.05 & Fish.x>0 & Sediment.x>0)
# sigb<-subset(all,V1<=0.05)
# sigd<-data[sigb$Row.names,]
# cal_z_score <- function(x){
#   (x - mean(x)) / sd(x)
# }
# 
# sigd <- t(apply(sigd, 1, cal_z_score))

# pheatmap(sigd,
#          # colorRampPalette(c("white","grey50","grey30","grey10","grey1","black"))(250) ,
#          show_rownames = T,show_colnames = T,
#          cluster_rows = T,cluster_cols = T,
#          scale = "row",
#          clustering_distance_rows = "binary",
#          clustering_method = "average",
#          legend = T,
#          border_color = "white",
#          #kmeans_k = 30,
#          # legend_breaks = c(0.7,0.5,0.3,0.1),
#          treeheight_col = 0,
#          # annotation_col = map,
#          # annotation_names_col = T,
#          cellwidth=14, cellheight=10,
#          fontsize_row = 30,
#          fontsize_col = 30,
#          fontsize = 30)

tarb<-subset(all,V1<=0.05 & Fish.x>0 & Sediment.x>0.01 &
              Sediment.x > Fish.x)
tarbt<-merge(tarb,tax,by.x = "Row.names",by.y=0,all.x = T)

tmp<-str_split_fixed(tarbt[,"taxonomy"],";",7)
tmp[,6]<-str_replace_all(tmp[,6],"g__","")
tmp[,7]<-str_replace_all(tmp[,7],"s__","")
tmp[tmp[,7] == "",]<-tmp[tmp[,7] == "",6]
tarbt[,"name"]<-tmp[,7]

df<-data.frame(Type= c(rep("Fish",3),rep("Sediment",3)),
               Name= rep(tarbt[,"name"],2),
               Mean= c(tarbt[,"Fish.x"],tarbt[,"Sediment.x"]),
               Se= c(tarbt[,"Fish.y"],tarbt[,"Sediment.y"]))
             
cols<-c("#FFB415","#64638E")

tiff("Fish-Sediment2.tiff",width = 1640,height = 1080)
ggplot(data=df, aes(x=Name, y=Mean,fill=Type)) +
  geom_bar(stat="identity", position=position_dodge())+
  scale_fill_manual(values = cols)+
  coord_flip()+
  # scale_y_discrete(position = "right")+
  geom_errorbar(aes(ymin=Mean-Se, ymax=Mean+Se), width=.3,size=2,
                position=position_dodge(.9)
                )+
  xlab("")+ylab("")+
  # theme_classic()+
  guides(fill=guide_legend(title = ""))+
  theme(axis.text.x=element_text(size=35),
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

