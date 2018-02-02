##Downloading and extracting the data
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "dataset.zip")
unzip("dataset.zip")
oldwd <- getwd()
setwd(file.path(oldwd, "UCI HAR Dataset"))


##libraries
library(data.table)
library(dplyr)
library(plyr)
library(tidyr)

##read datas
data_Act_Train <- read.table(file.path(".", "train", "Y_train.txt"),header = FALSE)
data_Act_Test  <- read.table(file.path(".", "test" , "Y_test.txt" ),header = FALSE)
data_Sub_Train <- read.table(file.path(".", "train", "subject_train.txt"),header = FALSE)
data_Sub_Test  <- read.table(file.path(".", "test" , "subject_test.txt"),header = FALSE)
data_Fea_Train <- read.table(file.path(".", "train", "X_train.txt"),header = FALSE)
data_Fea_Test  <- read.table(file.path(".", "test" , "X_test.txt" ),header = FALSE)
data_Fea_Names <- read.table(file.path(".", "features.txt"),head=FALSE)
data_Act_Labels <- read.table(file.path(".", "activity_labels.txt"),header = FALSE)

##1 merges datas
#merges train and test
data_Sub <- rbind(data_Sub_Train, data_Sub_Test)
data_Act<- rbind(data_Act_Train, data_Act_Test)
data_Fea<- rbind(data_Fea_Train, data_Fea_Test) 

#merges subject, activity and features data 
names(data_Sub)<-c("subject")
names(data_Act)<- c("activity")
names(data_Fea)<- data_Fea_Names$V2

data_Sub_Act <- cbind(data_Sub, data_Act)
Data <- cbind(data_Fea, data_Sub_Act)


##2 extract mean and std features
#create subset with mean and std measurement
subset_data_Fea_Names<-data_Fea_Names$V2[grep("mean\\(\\)|std\\(\\)", data_Fea_Names$V2)]
#get activity and subject with subset
selectedNames<-c(as.character(subset_data_Fea_Names), "subject", "activity" )
#creat the ultimate dataset
Data<-subset(Data,select=selectedNames)


##3 descriptives names for activity
Data$activity <- factor(Data$activity,levels=data_Act_Labels[,1],labels = data_Act_Labels[,2])


##4 label the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

##5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Data2<-aggregate(.~subject + activity,Data,  mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
