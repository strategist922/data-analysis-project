import praw
import schedule
import time
import pymysql
import config

resources = [
    'politics',
    'worldnews',
    'news',
    'worldpolitics',
    'worldevents',
    'business',
    'economics',
    'environment'
]

keywords = [
    'President-elect Trump',
    'Donald Trump',
    'Trump'
]

db = pymysql.connect(host=config.host,
                     user=config.user,
                     password=config.password,
                     db=config.db,
                     charset='utf8mb4',
                     cursorclass=pymysql.cursors.DictCursor)

r = praw.Reddit(user_agent='Donald Trump')


def main():
    scrape()
    schedule.every(5).minutes.do(scrape)
    while 1:
        schedule.run_pending()
        time.sleep(1)


def scrape():
    for resource in resources:
        submissions = r.get_subreddit(resource).get_new()
        for submission in submissions:
            for keyword in keywords:
                if keyword in submission.title:
                    with db.cursor() as cursor:
                        sql = "SELECT * " \
                              "FROM reddit " \
                              "WHERE reddit_id = %s " \
                              "OR submission_title = %s"
                        cursor.execute(sql, [submission.id, submission.title])
                        if not cursor.fetchone():
                            sql = "INSERT INTO reddit (submission_title, reddit_id, insert_datetime)" \
                                  "VALUES (%s, %s, now())"
                            cursor.execute(sql, [submission.title, submission.id])
                            db.commit()


if __name__ == '__main__':
    main()
