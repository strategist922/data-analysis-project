import csv
import sys

reader = csv.reader(open(sys.argv[1], 'rU'), dialect='excel')
for row in reader:
    try:
        print row[2]
    except IndexError:
        continue
