list.of.packages <- c("RMySQL", "plotly")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) install.packages(new.packages)
  
library(RMySQL)
library(plotly)

# Connect to the MySQL database
mydb = dbConnect(MySQL(), user='root', password='', dbname='trump', host='127.0.0.1')

# Query the data
rs = dbSendQuery(mydb, "select round(sum(tsa.pos), 2) as p, round(sum(tsa.neg), 2) as n from tweets as t join twitter_sentiment_analysis as tsa on t.id = tsa.tweet_id limit 0, 100000")
data = fetch(rs, n=-1)

# Create a bar chart
p <- plot_ly(
  x = c("Positive", "Negative"),
  y = c(as.numeric(data$p), as.numeric(data$n)),
  name = "Positive and Negative sum comparison.",
  type = "bar"
)

# Calculate the sentiment score for reddit submissions.
# Query the data
rs = dbSendQuery(mydb, "select round(sum(rsa.pos), 2) as p, round(sum(rsa.neg), 2) as n from reddit as r join reddit_sentiment_analysis as rsa on r.id = rsa.reddit_id;")
data = fetch(rs, n=-1)

# Create a bar chart
p <- plot_ly(
  x = c("Positive", "Negative"),
  y = c(as.numeric(data$p), as.numeric(data$n)),
  name = "Positive and Negative sum comparison.",
  type = "bar"
)

p

