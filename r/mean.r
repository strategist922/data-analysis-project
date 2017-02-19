list.of.packages <- c("RMySQL", "plotly")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) install.packages(new.packages)

library(RMySQL)
library(plotly)

mydb <- dbConnect(MySQL(), user='root', password='', dbname='trump', host='127.0.0.1')

# Get all tweets
rs <- dbSendQuery(mydb, "select pos, neg from tweets as t join twitter_sentiment_analysis as tsa on tsa.tweet_id = t.id LIMIT 0, 100000")
data <- fetch(rs, n=-1)

# Get the mean value of the positive and negative scores.
posTweetsMean <- mean(as.numeric(data$pos))
negTweetsMean <- mean(as.numeric(data$neg))

# Get all reddit submissions

rs <- dbSendQuery(mydb, "select pos, neg from reddit as r join reddit_sentiment_analysis as rsa on rsa.reddit_id = r.id;")
data <- fetch(rs, n=-1)

# Get the mean value of the positive and negative scores.
posSubmissionsMean <- mean(as.numeric(data$pos))
negSubmissionsMean <- mean(as.numeric(data$neg))

# Add the mean values together

tpos <- posTweetsMean + posSubmissionsMean
tneg <- negTweetsMean + negSubmissionsMean

# Create a bar chart
p <- plot_ly(
  x = c("Positive", "Negative"),
  y = c(tpos, tneg),
  name = "The mean of the scores compared.",
  type = "bar"
)

# Display the results
p
