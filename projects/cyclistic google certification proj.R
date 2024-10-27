library (tidyverse)
library(lubridate)
library (janitor)
library (dplyr)
library (ggplot2)



cycJan <- read.csv("/Users/shravann/Downloads/cyclistic/202201-divvy-tripdata.csv")
cycFeb <- read.csv("/Users/shravann/Downloads/cyclistic/202202-divvy-tripdata.csv")
cycMar <- read.csv("/Users/shravann/Downloads/cyclistic/202203-divvy-tripdata.csv")
cycApr <- read.csv("/Users/shravann/Downloads/cyclistic/202204-divvy-tripdata.csv") 
cycMay <- read.csv("/Users/shravann/Downloads/cyclistic/202205-divvy-tripdata.csv")
cycJun <- read.csv("/Users/shravann/Downloads/cyclistic/202206-divvy-tripdata.csv")
cycJul <- read.csv("/Users/shravann/Downloads/cyclistic/202207-divvy-tripdata.csv")
cycAug <- read.csv("/Users/shravann/Downloads/cyclistic/202208-divvy-tripdata.csv")
cycSep <- read.csv("/Users/shravann/Downloads/cyclistic/202209-divvy-publictripdata.csv")
cycOct <-read.csv("/Users/shravann/Downloads/cyclistic/202210-divvy-tripdata.csv")
cycNov <- read.csv("/Users/shravann/Downloads/cyclistic/202211-divvy-tripdata.csv")
cycDec <- read.csv("/Users/shravann/Downloads/cyclistic/202212-divvy-tripdata.csv")

cycdb <-rbind(cycJan,cycFeb,cycMar,cycApr,cycMay,cycJun,cycJul,cycAug,cycSep,cycOct,cycNov,cycDec)

#view(cycdb)


cycdb <- cycdb %>%
  select(-c(start_lat,start_lng, end_lat,end_lng, start_station_id,end_station_id,end_station_name))

colnames(cycdb)

nrow(cycdb)
dim(cycdb)
head(cycdb,6)
str(cycdb)
summary(cycdb)


cycdb$date <- as.Date(cycdb$started_at)
cycdb$month <- format(as.Date(cycdb$date), "%m")
cycdb$day <- format(as.Date(cycdb$date),"%d")
cycdb$year <- format(as.Date(cycdb$date),"%Y")
cycdb$day_of__week<- format(as.Date(cycdb$date),"%A")
cycdb$time <- format(cycdb$started_at,format="%H:%M")
cycdb$time <- as.POSIXct(cycdb$time,format="%H:%M")


cycdb$ride_length <- (as.double(difftime(cycdb$ended_at,cycdb$started_at)))/60


str(cycdb)


cycdb$ride_length <-as.numeric(as.character(cycdb$ride_length))


#cycdb<- cycdb[!(cycdb$start_station_name=="HQ QR" | cycdb$ride_lenth<0),]



summary(cycdb$ride_length)


aggregate(cycdb$ride_length ~ cycdb$member_casual,FUN=mean)
aggregate(cycdb$ride_length ~ cycdb$member_casual, FUN=median)
aggregate(cycdb$ride_length ~ cycdb$member_casual, FUN=max)
aggregate(cycdb$ride_length ~ cycdb$member_casual, FUN=min)


cycdb$day_of__week <- ordered(cycdb$day_of__week, levels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))


cycdb %>% mutate(day_of__week=wday(started_at,label=TRUE)) %>% group_by(member_casual,day_of__week) %>% summarise(number_of_rides=n())


cycdb$day_of__week <- format(as.Date(cycdb$date),"%A")

cycdb %>% group_by(member_casual,day_of__week) %>% summarise(number_of_rides = n()) %>% arrange(member_casual, day_of__week) %>% ggplot(aes(x=day_of__week, y= number_of_rides, fill=member_casual)) +geom_col(position="dodge") + 
  labs(x="Day of the Week", y = " Total number of rides", title = "Rides per day of the week",fill="Type of membership") + 
  scale_y_continuous(breaks =c(250000,400000, 550000),labels=c("250K","400K","550K"))

cycdb %>% group_by(member_casual,month) %>% summarise(total_rides = n(),'average_duration_(mins)'=mean(ride_length)) %>%
  arrange(member_casual) %>% ggplot(aes(x=month, y= total_rides, fill=member_casual))+geom_col(position="dodge") + labs(x="Month",y="Total Number of Rides", title="Rides per month", fill="Type of membership") + scale_y_continuous(breaks = c(100000,200000,300000,400000),labels=c("100K","200K","300K","400K")) +
  theme(axis.text.x = element_text(angle = 45))


cycdb %>%
  ggplot(aes(x=rideable_type,fill=member_casual)) + geom_bar(position="dodge") + 
  labs(x="Type of bike",y="number of rentals",title="Which bike works the most", fill= "Type of membership") + 
  scale_y_continuous(breaks =c(500000,1000000,1500000),labels=c("500K","1Mil","1.5Mil"))


cycdb%>%
  mutate(day_of__week = wday(started_at,label=TRUE)) %>%
  group_by(member_casual,day_of__week)%>%
  summarise(number_of_rides=n(),average_duration=mean(ride_length)) %>%
  arrange(member_casual,day_of__week) %>%
  ggplot(aes(x=day_of__week,y=average_duration,fill=member_casual))+geom_col(postion="dodge") +
  labs(x="Days of the week", y="Average duration-Hrs", title="average ride time per week", fill="Type of membership")