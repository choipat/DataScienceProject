######Project codes: https://www.kaggle.com/mrisdal/titanic/exploring-survival-on-the-titanic/notebook

library('ggplot2')
library('ggthemes')
library('scales')
library('dplyr')
library('mice')
library('randomForest')
###########################load and check the data#######################
#explore the data
#stringsAsFactors tells R to keep character variables as they are rather than convert to factors
train <-read.csv('train.csv', stringsAsFactors = F)
test <-read.csv('test.csv', stringsAsFactors = F)
full <-bind_rows(train,test)

str(full)
str(train)

#survived  survived(1), died(0)
#Pclass Passenger's class
#name Passenger's name
#sex Passenger's sex
#age Passenger's age
#SibSp number of siblings/spouse
#Parch number of parents/children
#ticket ticket number
#fare fare
#cabin Cabin
#emabrked Port of embarkation 
################################2.1 Feature engineering#############
#use regular expression using gsub to pull the passenger title. 
full$Title <- gsub('(.*, )|(\\..*)', '', full$Name)
#puts female/male and counts by the title
table(full$Sex, full$Title)
#str(full$Name)
#titles with very low cell counts to be combined to "rare" level
rare_title <-c('Dona', 'Lady', 'the Countess', 'Capt', 'Col', 'Don','Dr', 'Major', 'Rev', 'Sir', 'Jonkheer')
#str(rare_title)
#reassign mlle, ms, and mme
full$Title[full$Title == 'Mlle'] <- 'Miss'
full$Title[full$Title == 'Ms'] <- 'Miss'
full$Title[full$Title == 'Mme'] <- 'Mrs'
full$Title[full$Title %in% rare_title] <- 'Rare Title'

#show title counts by sex again. Cleaner data
table(full$Sex, full$Title)

#grab surname from passenger name
full$Surname <- sapply(full$Name, function(x) strsplit(x, split = '[,.]')[[1]][1])
cat(paste('We have <b>', nlevels(factor(full$Surname)), '</b> unique surnames. I would be interested to infer ethnicity based on surnmae -- another time.'))

#full$Surname <- sapply(full$Name,function(x) strsplit(x, split = '[,.]')[[1]][1])
#cat(paste('We have <b>', nlevels(factor(full$Surname)), '</b> unique surnames. I would be interested to infer ethnicity based on surname --- another time.'))
str(full$Surname)
#######################2.2 Do families sink together?##################
#creates the variable that stores the family size. we get this info by adding the sib the parents and 1 for the
#passenger
full$Fsize <- full$SibSp + full$Parch +1
str(full$Fsize)
full$Family <- paste(full$Surname, full$Fsize, sep = '_')
str(full$Family)
#### use http://www.stat.wisc.edu/~larget/stat302/chap2.pdf to understand ggplot

