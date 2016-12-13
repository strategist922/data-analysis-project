import sys
import csv
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

analyzer = SentimentIntensityAnalyzer()

f = open(sys.argv[1], 'wt')
try:
    writer = csv.writer(f)
    writer.writerow(('Positive', 'Negative', 'Neutral', 'Compound'))
    for line in sys.stdin:
        x = analyzer.polarity_scores(line)
        writer.writerow([y for y in x.values()])
finally:
    f.close()
