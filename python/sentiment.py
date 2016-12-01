from vaderSentiment.vaderSentiment import sentiment as vaderSentiment
import pymysql
import csv

connection = pymysql.connect(host='127.0.0.1',
                             user='root',
                             password='',
                             db='trump',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)

with connection.cursor() as cursor:
    sql = "SELECT id, tweet " \
          "FROM tweets "
    cursor.execute(sql)
    result = cursor.fetchall()

p = {}
for tweet in result:
    vs = vaderSentiment(tweet['tweet'].encode('utf-8'))
    sql = "INSERT INTO twitter_sentiment_analysis (neg, neu, pos, compound, tweet_id) VALUES (%s, %s, %s, %s, %s)"
    with connection.cursor() as cursor:
        cursor.execute(sql, [vs['neg'], vs['neu'], vs['pos'], vs['compound'], tweet['id']])

    connection.commit()

with connection.cursor() as cursor:
    sql = "SELECT id, submission_title " \
          "FROM reddit "
    cursor.execute(sql)
    result = cursor.fetchall()

l = {}

for submission in result:
    vs = vaderSentiment(submission['submission_title'].encode('utf-8'))
    sql = "INSERT INTO reddit_sentiment_analysis (neg, neu, pos, compound, reddit_id) VALUES (%s, %s, %s, %s, %s)"
    with connection.cursor() as cursor:
        cursor.execute(sql, [vs['neg'], vs['neu'], vs['pos'], vs['compound'], submission['id']])

    connection.commit()


