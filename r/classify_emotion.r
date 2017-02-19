# Code reference: https://rhandbook.wordpress.com/tag/sentiment-analysis-using-r/

# This code requires Rstem and sentiment.
# RStem: http://cran.cnr.berkeley.edu/src/contrib/Archive/Rstem/
# sentiment: https://cran.r-project.org/src/contrib/Archive/sentiment/

list.of.packages <- c("RMySQL", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) install.packages(new.packages)
  
library('Rstem')
library('sentiment')
library('RMySQL')
library('ggplot2')

# Connect to the MySQL database
mydb = dbConnect(MySQL(), user='root', password='', dbname='trump', host='127.0.0.1')

# Load 50000 tweets 
rs = dbSendQuery(mydb, "select tweet from tweets LIMIT 0,50000")
data = fetch(rs, n=-1)

# classify emotion
class_emotion = classify_emotion(data$tweet, algorithm="bayes", prior=1.0)
# get emotion best fit
emotion = class_emotion[,7]
# substitute NA's by "unknown"
emotion[is.na(emotion)] = "unknown"

# classify polarity
class_polarity= classify_polarity(data$tweet, algorithm="bayes")
# get polarity best fit
polarity = class_polarity[,4]

# data frame with results
tweet_df = data.frame(text=data$tweet, emotion=emotion,
                      polarity=polarity, stringsAsFactors=FALSE)

# sort data frame
tweet_df = within(sent_df,
                  emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))

# Lets generate some plot based on above data set. Plot tweet distribution based on emotions.
ggplot(tweet_df, aes(x=emotion)) +
  geom_bar(aes(y=..count.., fill=emotion))+xlab("Emotions Categories") + ylab("Tweet Count")+ggtitle("Sentiment Analysis of Tweets on Emotions")
