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
full$Surname <- sapply(full$Name, function(x) strsplit(x, split = '[,]')[[1]][1])
full$Surname
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
ggplot(full[1:891,], aes(x = Fsize, fill = factor(Survived))) +
  geom_bar(stat='count', position='dodge') +
  scale_x_continuous(breaks=c(1:11)) +
  labs(x = 'Family Size') +
  theme_few()
###aes = aesthetics

####2.3 Treat a few more variables
#probably useful informatin in the passenger cabin variable, including their deck.
full$Cabin[1:28]
strsplit(full$Cabin[2], NULL)[[1]]
full$Deck<-factor(sapply(full$Cabin, function(x) strsplit(x, NULL)[[1]][1]))
full$Deck
##strsplit practice
#so strsplit splits the vectors in a word. strsplit(x, split, fixed=FALSE)
#x = the string
#split = the character string to split. if the split is an empty string(""), then x is split between
#every character
x<- "Split the words in a sentence."
strsplit(x, NULL)
x<- "Do you wish you were Mr. Jones?"
strsplit(x, NULL)[[1]]
strsplit(full$Cabin[2], NULL)
full$Deck

###############3.1 Sensible value imputation###########
##passengers 62 and 830 are missing EMbarkment
full[c(62, 830), 'Embarked']
cat(paste('We will infer their values for **embarkment** based on present data that we can imagine may be relevant: 
          **passenger class** and **fare**. We see that they paid<b> $', full[c(62, 830), 'Fare']
          [[1]][1], '</b>and<b> $', full[c(62, 830), 'Fare'][[1]][2], '</b>respectively and their classes are<b>', 
          full[c(62, 830), 'Pclass'][[1]][1], '</b>and<b>', full[c(62, 830), 'Pclass'][[1]][2], '</b>. 
          So from where did they embark?'))
#we will infer their values for embarkment based on present data that we can 
#imagine may be relevant: passenger class and fare. We see that they paid $80 and $80 
#respectively and their classes are 1 and 1. so from where did they embark?
#get rid of our missing passenger IDs
embark_fare <- full %>%
  filter(PassengerId != 62 & PassengerId != 830)
ggplot(embark_fare, aes(x = Embarked, y = Fare, fill= factor(Pclass)))

geom_boxplot() 
  geom_hline(aes(yintercept=80), 
             colour = 'red', linetype='dashed', lwd=2) 
    scale_y_continuous(labels=dollar_format()) 
  theme_few()
  # Get rid of our missing passenger IDs
  embark_fare <- full %>%
    filter(PassengerId != 62 & PassengerId != 830)
### this line works. Figure out why the previous line didnt. 
  # Use ggplot2 to visualize embarkment, passenger class, & median fare
  ggplot(embark_fare, aes(x = Embarked, y = Fare, fill = factor(Pclass))) +
    geom_boxplot() +
    geom_hline(aes(yintercept=80), 
               colour='red', linetype='dashed', lwd=2) +
    scale_y_continuous(labels=dollar_format()) +
    theme_few()

  