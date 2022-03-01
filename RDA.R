rm(list = ls())
library(stringr)
library(ggplot2)
library(dplyr)
library(ggvegan)
library(ggrepel)

setwd("M://Code/IPRS/RDACCA/")

meta<-read.csv("../Result/metadata.tsv",header = T,
               sep = "\t") 
meta<-subset(meta,Type=="Water" & Site %in% c(1,2,3,4,5,6))


data<-read.table("../Result/OTU/table.tsv",row.names = 1,
                 header = T,check.names = F)
data<-data[,meta$sample.id]
data<-data[rowSums(data) > 0 ,]

stde <- function(x) sd(x)/sqrt(length(x))
nonzero <- function(x) sum(x != 0)
i<-4
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

###############
#### https://blog.sciencenet.cn/blog-3334560-1104737.html
#### https://mp.weixin.qq.com/s/8D4vlBIhyYg0ZHtsdGn_kA
#### https://programmer.ink/think/r-redundancy-analysis-rda-ggplot2.html
#### https://eead-csic-compbio.github.io/barley-agroclimatic-association/HOWTORDA.html
otu.tab <- meann
env.data <- read.csv("../Result/Env/Env.tsv", row.names = 1, fill = T, header=T, sep="\t")
#transform data
otu <- t(otu.tab)
#data normolization (Legendre and Gallagher,2001)
##by log
env.data.log <- log1p(env.data)##
##delete NA
env <- na.omit(env.data.log)
###hellinger transform
otu.hell <- decostand(otu, "hellinger")


sel <- decorana(otu.hell)
sel
otu.tab.1<- rda(otu.hell ~ ., env)
vif.cca(otu.tab.1)

###remove max one and NA
otu.tab.1<- rda(otu.hell ~ NO2N+PO4+TN+DTN, env)

otu.tab.0 <- rda(otu.hell ~ 1, env) #no variables

mod.u <- step(otu.tab.0, scope = formula(otu.tab.1), test = "perm")
mod.d <- step(otu.tab.0, scope = (list(lower = formula(otu.tab.0), upper = formula(otu.tab.1))))
mod.d

anova(otu.tab.1)
anova(otu.tab.1, by = "term")
anova(otu.tab.1, by = "axis")

################
uu=otu.tab.1#RDA Analysis
ii=summary(uu)  #View analysis results
grp=data.frame(group=c("Outside",rep("Inside",3),
                       rep("Outside",2)))#Grouping by Square Type
sp=as.data.frame(ii$species[,1:2])*2#Depending on the drawing result, the drawing data can be enlarged or reduced to a certain extent, as follows
st=as.data.frame(ii$sites[,1:2]) %>%
  cbind(grp)
yz=as.data.frame(ii$biplot[,1:2])



tiff("RDA2.tiff",width = 1280,height = 1280)
ggplot() +
  #geom_text_repel(data = st,aes(RDA1,RDA2,label=row.names(st)),size=4)+#Show a Square
  geom_point(data = st,aes(RDA1,RDA2,col=grp$group),size=15)+
  scale_color_manual(values=c("#5DA5DAFF","#FAA43AFF"))+
  geom_text_repel(data = st,aes(RDA1,RDA2,label=row.names(st)),size=25)+

  geom_segment(data = yz,aes(x = 0, y = 0, xend = RDA1, yend = RDA2),
               arrow = arrow(angle=22.5,length = unit(2,"cm"),
                             type = "closed"),linetype=1, 
                             size=4,colour = "#87B9D5FF")+
  geom_text_repel(data = yz,aes(RDA1,RDA2,label=row.names(yz)),size=25)+
  labs(x=paste("RDA 1 (", format(100 *ii$cont[[1]][2,1], digits=4), "%)", sep=""),
       y=paste("RDA 2 (", format(100 *ii$cont[[1]][2,2], digits=4), "%)", sep=""),size=40)+
  geom_hline(yintercept=0,linetype=3,size=3) + 
  geom_vline(xintercept=0,linetype=3,size=3)+
  guides(shape=guide_legend(title=NULL,color="black"),
         color=guide_legend(title=""))+
  theme_bw()+theme(panel.grid=element_blank(),legend.position = "right",
                   title= element_text(size=40),
                   axis.text = element_text(size = 40),
                   legend.key.height = unit(4,"line"),
                   legend.text = element_text(size = 40),
                   legend.title = element_text(size = 40))
dev.off()
