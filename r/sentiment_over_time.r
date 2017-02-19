list.of.packages <- c("RMySQL", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) install.packages(new.packages)

library(RMySQL)
library(ggplot2)
library(reshape2)

mydb <- dbConnect(MySQL(), user='root', password='', dbname='trump', host='127.0.0.1')

rs <- dbSendQuery(mydb, "select distinct day(created_at) as d, round(avg(pos), 3) as pos_avg, round(avg(neg), 3) as neg_avg 
                         from tweets as t 
                         join twitter_sentiment_analysis as tsa 
                         on tsa.tweet_id = t.id group by d")
data <- fetch(rs, n=-1)

x <- data$d
y <- data$pos_avg  
z <- data$neg_avg

df <- data.frame(x, y, z)
ggplot(df, aes(x, y = value, color = variable)) + geom_point(aes(y = y, col = "y")) + geom_point(aes(y = z, col = "z"))
