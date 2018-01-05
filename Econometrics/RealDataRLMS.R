#Midterm test: Example of work with real data. Data =  Russia Longitudinal Monitoring Survey (RLMS). Data is acquired from hse.ru.

install.packages("devtools")
devtools::install_github("bdemeshev/rlms")


library("Ecdat")
library("sandwich")
library("lmtest")
library("car")
library("dplyr")
library("broom")
library("ggplot2")
library("quantmod")
library("sophisthse")
library("Quandl")
library("psych")
library("memisc")
library("rlms")

#loading data
df <- rlms_read("r22i_os26a.sav")
saveRDS(df, "r22i_os26a.sav")
df <- readRDS("r22i_os26a.sav")

#Chosing needed info
data <- dplyr::select(df, rj13.2, rh5, rh6, r_diplom, status, rj1.1.1)
data <- dplyr::rename(data, salary=rj13.2, sex=rh5, age=rh6, education=r_diplom, settlement=status, satisfied=rj1.1.1)
data <- mutate(data, age = 2013 - age)

data <- filter(data, settlement=="город"|settlement=="областной центр")
data <- filter(data, satisfied =="ПОЛНОСТЬЮ УДОВЛЕТВОРЕНЫ" | satisfied == "СКОРЕЕ УДОВЛЕТВОРЕНЫ")
data <- filter(data, education =="окончил 0 - 6 классов"|
                 education =="незаконченное среднее образование (7 - 8 кл)"|
                 education =="незаконченное среднее образование (7 - 8 кл) + что-то еще"|
                 education =="законченное среднее образование"|
                 education =="законченное среднее специальное образование"|
                 education =="законченное высшее образование и выше")

#Creating dummy-variables
data$dumstatus <- memisc::recode(data$settlement, "город" -> 1, "областной центр" -> 0)
data$dumsatisfied <- memisc::recode(data$satisfied, "ПОЛНОСТЬЮ УДОВЛЕТВОРЕНЫ" -> 1, "СКОРЕЕ УДОВЛЕТВОРЕНЫ" -> 0)
data$dumsex <- memisc::recode(data$sex, "МУЖСКОЙ" -> 1, "ЖЕНСКИЙ" -> 0)


data <- mutate(data, dumeduc = ifelse(education == "окончил 0 - 6 классов" | education== "незаконченное среднее образование (7 - 8 кл)" | education== "незаконченное среднее образование (7 - 8 кл) + что-то еще", 1,
                                      
                                      ifelse(education== "законченное среднее образование", 2,
                                             
                                             ifelse(education== "законченное среднее специальное образование", 3,
                                                    
                                                    ifelse(education== "законченное высшее образование и выше", 4, 0)))))


data <- mutate(data,ed1 = ifelse (dumeduc == 1, 1, 0))
data <- mutate(data,ed2 = ifelse (dumeduc == 2, 1, 0))
data <- mutate(data,ed3 = ifelse (dumeduc == 3, 1, 0))
data <- mutate(data,ed4 = ifelse (dumeduc == 4, 1, 0))

#
dataNoNA <- na.omit(data)

#occumulating Data we are going to Work with
wd <- dplyr::select(dataNoNA, salary, age, dumstatus,dumsatisfied,dumsex, ed1, ed2,ed3,ed4)
wd$ed1 <- factor(wd$ed1)
wd$ed2 <- factor(wd$ed2)
wd$ed3 <- factor(wd$ed3)
wd$ed4 <- factor(wd$ed4)
wd



#----------------------------------------------------------------------
#Conducting experiments to answer test questions
#question 1: maximum age (before omiting NA)
max(data$age)

#question 2: how much NA in salary
temp <- data$salary
length(temp) - length(na.omit(temp))

#question 3:
dataNoNA$salary = dataNoNA$salary / 1000 
qplot(data = dataNoNA, salary)

#4
qplot(data = dataNoNA, salary, fill = dumsex)
qplot(data = dataNoNA, age, fill = dumsex)

#5 - 10
wd
modelx <- lm(data = wd, salary ~ age + dumsex + ed2 + ed3 + ed4 + dumstatus + dumsatisfied)
summary(modelx)
qf(0.95, df1 =7, df2=2976)
vcovHAC(modelx)
coeftest(modelx, vcov. = vcovHC(modelx))
sqrt(778311.390)
sqrt(666720.325)
