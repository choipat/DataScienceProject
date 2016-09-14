####ggplot2 examples
##### this is my attempt to understand the ggplot used in the titanic exericise

library('Lock5Data')
library('ggplot2')
data(SleepStudy)
data(heart-rate )
str(SleepStudy)
heart = read.table("heart-rate.txt", header = TRUE)
students = read.csv("students.csv")
#alternative: heart = read.table(file.choose(), header = TRUE)
#str() shows the structure of an object. 
dim(heart)
dim(students)
#you can extract single variables by usn=ing $. 
str(students)
#here we are pulling the values for the variable brothers. even though its in a column, 
#R shows it to us as a row. 
students$Brothers
#The with() command is useful when we want to refer to variables multiple times in the same
#command. Here is an example that finds the number of siblings (brothers plus sisters) for each
#student in two ways.
with(students, Brothers + Sisters)
# or we can 
students$Brothers + students$Sisters
1:6
c(1, 6, 7)
students[1:5, c(1, 6, 7)]
students[1, ]
students$Brothers[1:6]
##cases = rows
#variables = column
#############2. Categorical Variables###############
###table() function is useful for summarizing one or more categorical variables. 

with(students, table(Sex))
with(students, table(Sex, BloodType))
with(students, summary(Sex))

###########2.1 Missing Data and read.csv()##############
#To do this correctly when reading in with read.csv(), we should add an argument to 
#say empty fields are missing. The
#following example tells R to treat the string NA and an empty field between commas as missing
#data. By default, table() skips cases with missing values. We can change this by letting useNA ="always"

#students = read.csv("students.csv", na.strings = c("", "NA"))
#students = read.csv("students.csv", na.strings = c("", "NA"))
students = read.csv("students.csv", na.strings = c("", "NA"))
with(students, table(Sex, BloodType))
with(students, table(BloodType))
with(students, table(BloodType, useNA="always"))

#######2.5 Proportions
tab = with(students, table(BloodType))
tab
tab/sum(tab)

tab = with(students, table(Sex, BloodType))
round(tab/sum(tab), 3)
#######2.4 Bar Graphs
require(ggplot2)
###ggplot() calls the function ggplot
###students calls up the data frame
###aes tells to make the x axis which object
## +geom_bar tells which representation
ggplot(students, aes(x = Level)) + geom_bar()
ggplot(students, aes(x = Major)) + geom_bar()

### reordering. The bar graph with be better if it was reordered. There is a natural order to levels

#create an empty variable foo by 0 for the number of cases in students
foo=rep(0, nrow(students))
#set the positions where Level == 'freshman' to be 1
#foo[with(students, Level == "freshman")] = 1
#foo[with(students, Level == "sophmore")] = 2
#foo[with(students, Level == "junior")] = 3
#foo[with(students, Level == "senior")] = 4
#foo[with(students, Level == "special")] = 5
#foo[with(students, Level == "graduate")] = 6
#look at foo to see if it looks right
foo
#change students$level to the rorderded version and discard foo
foo[with(students, Level == "freshman")] = 1
foo[with(students, Level == "sophomore")] = 2
foo[with(students, Level == "junior")] = 3
foo[with(students, Level == "senior")] = 4
foo[with(students, Level == "special")] = 5
foo[with(students, Level == "graduate")] = 6





students$Level = with(students, reorder(Level, foo))
ggplot(students, aes(x = Level)) + geom_bar()
rm(foo)
with(students, table(Sex, Level))
ggplot(students, aes(x=Level, fill =Sex)) + geom_bar()
#If we want to see the proportion of females and males in each level, 
#we change the position attribute of the bar plot to "fill".
ggplot(students, aes(x=Level, fill =Sex)) + geom_bar(position = "fill")
#Change the position to "dodge" if we want to have separate bars for each sex within each
#level. (The bars dodge each other to avoid overlapping.)
ggplot(students, aes(x=Level, fill =Sex)) + geom_bar(position = "dodge")

######3 One Quantitative Variable########
###There are multiple ways to graphically display the distribution of a single 
#quantitative variable
######3.1 Dot plots
#for small data sets, a dot plot is an effective way to visualize all of the data.
#A dot is placed at tha appropriate value on the x axis for each case, and dots
#stack up. Here is how to make a dotplot with ggplot2 for the height from variable students

ggplot(students, aes(x = Height)) + geom_dotplot()
###3.2 Another popular way to graph a single quantitative variable is 
#with a histogram. use geom_histogram()
ggplot(students, aes(x = Height)) + geom_histogram(binwidth = 2)
