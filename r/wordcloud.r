# Code reference: https://www.r-bloggers.com/building-wordclouds-in-r/
list.of.packages <- c("RMySQL", "tm", "SnowballC", "wordcloud")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) install.packages(new.packages)
 
# Load the required libraries

library(tm)
library(SnowballC)
library(wordcloud)
library(RMySQL)

# Connect to the MySQL database
mydb = dbConnect(MySQL(), user='root', password='', dbname='trump', host='127.0.0.1')

# Load 1000 of the most positive tweets 

rs = dbSendQuery(mydb, "select tweet from tweets as t join twitter_sentiment_analysis as tsa on tsa.tweet_id = t.id ORDER BY tsa.pos DESC LIMIT 0,1000")
data = fetch(rs, n=-1)

# Create a function for the Wordcloud as we call it several times here.

wc <- function(x){
  # We will perform a series of operations on the text data to simplify it. First, we need to create a corpus.
  jeopCorpus <- Corpus(VectorSource(x))
  
  # Next, we will convert the corpus to a plain text document.
  jeopCorpus <- tm_map(jeopCorpus, PlainTextDocument)
  
  # Then, we will remove all punctuation and stopwords. 
  # Stopwords are commonly used words in the English language such as I, me, my, etc. 
  # You can see the full list of stopwords using stopwords('english').
  jeopCorpus <- tm_map(jeopCorpus, removePunctuation)
  jeopCorpus <- tm_map(jeopCorpus, removeWords, c(stopwords('english'), 'Trump', 'trump', 'Donald Trump'))
  
  # Next, we will perform stemming. 
  # This means that all the words are converted to their stem (Ex: learning -> learn, walked -> walk, etc.). 
  # This will ensure that different forms of the word are converted to the same form and plotted only once in the wordcloud.
  jeopCorpus <- tm_map(jeopCorpus, stemDocument)
  
  # Create a term-document matrix. 
  # A term-document matrix is a two-dimensional matrix whose rows are the terms and columns are the documents, 
  # so each entry (i, j) represents the frequency of term i in document j.
  dtm <- TermDocumentMatrix(jeopCorpus)
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  head(d, 10)
  
  # Now, we will plot the wordcloud.
  wordcloud(jeopCorpus, max.words = 250, random.order = FALSE)
}

wc(data$tweet)


# Next we will do the same but for negative tweets

rs = dbSendQuery(mydb, "select tweet from tweets as t join twitter_sentiment_analysis as tsa on tsa.tweet_id = t.id ORDER BY tsa.neg DESC LIMIT 0,1000")
data = fetch(rs, n=-1)
wc(data$tweet)

# Now, we will create a wordcloud for the Reddit submissions. 
# The first wordcloud is based on positive submissions.
# The second is based on the most negative submissions.

rs = dbSendQuery(mydb, "select submission_title from reddit as r join reddit_sentiment_analysis as rsa on rsa.reddit_id = r.id ORDER BY rsa.pos DESC")
data = fetch(rs, n=-1)
wc(data$submission_title)

rs = dbSendQuery(mydb, "select submission_title from reddit as r join reddit_sentiment_analysis as rsa on rsa.reddit_id = r.id ORDER BY rsa.neg DESC")
data = fetch(rs, n=-1)
wc(data$submission_title)
