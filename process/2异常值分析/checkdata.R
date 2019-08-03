library(RMySQL)
library(ggplot2)
library(gcookbook)
#library(Hmisc)
#library(dplyr)

con<-dbConnect(MySQL(), user='root', password='hrbbwx.com', dbname='assessment_dev')
dbSendQuery(con,'SET NAMES utf8')
res<-dbSendQuery(con, "SELECT r_id,aval FROM apartdata1 where akey='单价'")
data<-dbFetch(res, n=-1)
#print(data)
attach(data)
#substring(aval,0,-1)
#print aval
aval <- sub(pattern = "元/平", replacement = "", aval)  
aval<-as.numeric(aval)
dotchart(x=aval)

#print(id)
#cat(r_id)
#cat(akey)
#cat(aval)
#dim(apartdata2)


#dbClearResult(apartdata3)
dbDisconnect(con)
