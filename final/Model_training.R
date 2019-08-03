library(RMySQL)
#library(ggplot2)
library(caret)
library(car)
library(stringr)
#library(gcookbook)
#library(Hmisc)


con<-dbConnect(MySQL(), user='root', password='hrbbwx.com', dbname='assessment_dev')
dbSendQuery(con,'SET NAMES utf8')

input_akey<-function(a){
	x<-paste0("SELECT aval FROM apart_a where akey='",a,"'")
	return(x)
}

ff<-function(x) {
	        a<-x[1]
	        if (length(x) > 1) {
		    a<-mean(as.numeric(x[1]),as.numeric(x[2]))
		    }
	        return(a)
}

read_data<-function(x){
	
	a<-input_akey(x)
	res<-dbSendQuery(con,a)
	data<-dbFetch(res,n=-1)
    attach(data)
        #因变量
    	if (x=="成交价"){
    		aval<- sub(pattern = "万", replacement = "", aval) 
            var_name<-as.numeric(aval)
            return(var_name)
            rm(aval)
    	}
    	#自变量
    	if(x=="建筑面积"){
    		aval<- sub(pattern = "㎡", replacement = "", aval)
            var_name<-as.numeric(aval)
            return(var_name)
            rm(aval)
        }
        if(x=="均价"){
        	var_name<-as.numeric(aval)
        	return(var_name)
            rm(aval)
        }
        if(x=="物业费用"){
        	aval<- sub(pattern = "元/平米/月", replacement = "", aval)
            f<-strsplit(aval, "至")
            var_name<-(as.numeric(lapply(f,ff)))
            return(var_name)
            rm(aval)
        }
    	if(x=="建成年代"){
    		aval<-as.numeric(aval)
            var_name<-(2017-aval)
            return(var_name)
            rm(aval)
            #FL10<-ifelse(FL>=10,1,0)
    	}
    	if((x=="房屋年限")
    		| (x=="装修情况")
    		| (x=="配备电梯")
    		| (x=="房权所属")
    		#& x=""
    		){
    		var_name<-as.factor(aval)
    		return(var_name)
            rm(aval)
    	}
        if(x=="产权年限"){
            aval<-sub(pattern = "年", replacement = "", aval)
            var_name<-as.numeric(aval)
            return(var_name)
            rm(aval)
        }
    	if(x=="房屋户型"){
    		WS<-as.numeric(substring(aval,1,1))
    		KT<-as.numeric(substring(aval,3,3))
    		CS<-as.numeric(substring(aval,5,5))
    		var_name<-data.frame(WS,KT,CS)
    		return (var_name)
            rm(aval)
    	}
    	if(x=="所在楼层"){
    		aval<-gsub("\\(.*\\)","",aval)
            aval<-sub(pattern = " ", replacement = "", aval)
            var_name<-as.factor(aval)
            return (var_name)
    	}
        if(x=="房屋朝向"){
        	var_name<-aval
        	#var_name<-as.factor(f)
            return (var_name)
        }  

}

#命名赋值
CJ<-read_data("成交价")
MJ<-read_data("建筑面积")
XJ<-read_data("均价")
WY<-read_data("物业费用")
FL<-read_data("建成年代")
FX<-read_data("房屋年限")
ZX<-read_data("装修情况")
LC<-read_data("所在楼层")
CX<-read_data("房屋朝向")
DT<-read_data("配备电梯")
CQ<-read_data("产权年限")
FS<-read_data("房权所属")
HX<-read_data("房屋户型")
FL10<-ifelse(FL>=10,1,0) #房龄大于10年
WS<-HX$WS                #卧室数量
KT<-HX$KT                #客厅数量
CS<-HX$CS                #卫生间数量
CQ70<-ifelse(CQ>=60,1,0)
KT1<-ifelse(KT>=1,1,0)   #客厅数大于等于1个
NB<-ifelse(CX%in%('南 北'),1,0)
#print(NB)

#nb<-ifelse(CX%in%'南 北',1,0)
#print(CX)

x<-data.frame(CJ=log(CJ),
		      MJ=log(MJ),
		      XJ=log(XJ),
		      WY=log(WY),
	          FL=log(FL),
	          FL10=FL10,
	          FX=FX,
	          ZX=ZX,
	          LC=LC,
	          DT=DT,
	          FS=FS,
	          WS=WS,
	          KT=KT,
	          KT1=KT1,
	          CS=CS,
	          NB=NB,
              CQ70=CQ70
	          )

dmy<-dummyVars(~.,data=x)
trsf<-data.frame(predict(dmy,newdata=x))

lm<-lm(CJ~MJ+WS*MJ+WS*KT*CS+XJ+LC*DT+FL10+WY+FX+KT1+FS+NB+CQ70+ZX,data=x)
summary(lm)

#saveRDS(lm, "last_model.rds")

save(lm, file="last_model.Rdata")



