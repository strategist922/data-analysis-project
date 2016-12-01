from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
import json
import pymysql
import config

db = pymysql.connect(host=config.host,
                     user=config.user,
                     password=config.password,
                     db=config.db,
                     charset='utf8mb4',
                     cursorclass=pymysql.cursors.DictCursor)


class MyStreamListener(StreamListener):
    def on_data(self, data):
        obj = json.loads(data)
        try:
            text = obj['text'].encode('utf-8')
            if 'http' not in text and not text.startswith('RT'):
                try:
                    with db.cursor() as cursor:
                        sql = "INSERT INTO `tweets` (`created_at`, `tweet`) " \
                              "VALUES (NOW(), %s)"
                        cursor.execute(sql, text)
                        db.commit()
                except pymysql.err.InternalError as p:
                    print(p.message)
                    pass
        except KeyError:
            pass

    def on_error(self, status):
        print status


if __name__ == '__main__':
    l = MyStreamListener()
    auth = OAuthHandler(config.consumer_key, config.consumer_secret)
    auth.set_access_token(config.access_key, config.access_secret)
    stream = Stream(auth, l)
    stream.filter(languages=["en"], track=['#TrumpPresident', 'President-elect Trump', 'Donald Trump', 'Trump'])
