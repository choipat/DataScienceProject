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
