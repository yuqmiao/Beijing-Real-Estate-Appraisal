library(RMySQL)
library(ggplot2)
library(caret)
#library(gcookbook)
#library(Hmisc)
#library(dplyr)

con<-dbConnect(MySQL(), user='root', password='hrbbwx.com', dbname='assessment_dev')
dbSendQuery(con,'SET NAMES utf8')

#装修
res<-dbSendQuery(con, "SELECT r_id,aval FROM apartdata1 where akey='装修情况'")
data<-dbFetch(res,n=-1)
attach(data)
ZX<-as.factor(aval)
#str(ZX)

#成交价
res<-dbSendQuery(con,"SELECT r_id,aval FROM apartdata1 where akey='成交价'")
data<-dbFetch(res,n=-1)
attach(data)
aval<- sub(pattern = "万", replacement = "", aval) 
CJ<-as.numeric(aval)
#CJ<-as.factor(CJ)
rm(aval)

#房龄
res<-dbSendQuery(con, "SELECT r_id,aval FROM apartdata1 where akey='建成年代'")
data<-dbFetch(res, n=-1)
attach(data)
aval<-as.numeric(aval)
FL<-(2017-aval)
#FL<-as.factor(aval)
#str(FL)


#设置虚拟变量
x<-data.frame(CJ=CJ,ZX=ZX,FL=FL)
dmy<-dummyVars(~.,data=x)
trsf<-data.frame(predict(dmy,newdata=x))
#str(trsf)

#相关性分析
#data$ZX=relevel(data$ZX,ref=CJ) 
#lm<-lm(y~CJ+FL,data=x)
#summary(lm)
lm<-lm(CJ~FL+ZX,data=x)
summary(lm)










