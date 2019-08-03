library(RMySQL)
#library(ggplot2)
library(caret)
library(car)
library(stringr)
#library(gcookbook)
#library(Hmisc)

Args<-commandArgs()

input_aval<-function(inputMJ=Args[6],inputXJ=Args[7],inputWY=Args[8],inputFL=Args[9],inputFX=Args[10],inputZX=Args[11],
                 inputLC=Args[12],inputDT=Args[13],inputCQ=Args[14],inputFS=Args[15],inputKT=Args[16],inputWS=Args[17],inputCS=Args[18],inputNB=Args[19]){
      

      getwd()
      load("last_model.Rdata")

      #my_model <- readRDS("last_model.rds")
      #print(my_model)
      #转换类型

      inputMJ<-as.numeric(inputMJ)
      inputXJ<-as.numeric(inputXJ)
      inputWY<-as.numeric(inputWY)
      inputFL<-as.numeric(inputFL)
      inputCQ<-as.numeric(inputCQ)
      inputWS<-as.numeric(inputWY)
      inputKT<-as.numeric(inputWY)
      inputCS<-as.numeric(inputWY)
      inputCQ<-ifelse(inputCQ>=60,1,0)
      
      #计算处理
      inputFL<-2017-inputFL
      inputFL10<-ifelse(inputFL>=10,1,0)
      inputKT1<-ifelse(inputKT>=1,1,0)
      inputNB<-ifelse(inputNB%in%('南 北'),1,0)
      inputCQ<-ifelse(inputCQ>=60,1,0)

      predict_x<-data.frame(
                      MJ=log(inputMJ),
                      XJ=log(inputXJ),
                      WY=log(inputWY),
                      FL=log(inputFL),
                      FL10=inputFL10,
                      FX=inputFX,
                      ZX=inputZX,
                      LC=inputLC,
                      DT=inputDT,
                      FS=inputFS,
                      WS=inputWS,
                      KT=inputKT,
                      KT1=inputKT1,
                      CS=inputCS,
                      NB=inputNB,
                      CQ70=inputCQ
                      )
      #dmy<-dummyVars(~.,data=predict_x)
      #trsf<-data.frame(predict(dmy,newdata=predict_x))
      predict_lncj<-predict(lm,predict_x)
      predict_cj<-exp(predict_lncj)
      return(predict_cj)
      print(predict_cj)

}
#input_aval(Args[6],Args[7],Args[8],Args[9],Args[10],Args[11],Args[12],Args[13],Args[14],Args[15],Args[16],Args[17],Args[18],Args[19])

input_aval()

