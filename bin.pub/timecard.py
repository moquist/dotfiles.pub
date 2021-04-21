#!/usr/bin/env python
# This is useful to take my records of the day and turn it into the numbers
# I need to fill out a timecard.
#
# I create the reverse-chronological file by using vim and using :r!date after
# start: stop: headers.
#
# Then I cat that file into this script.
#
# 1. Lines beginning with a space are ignored as comments.
# 2. Lines matching ^# *time logged$ cause remaining input to be ignored.
# 3. 'start:' lines with ': suffixes' get separated out into separate buckets, like
#    the CharageCode57.3 example below.

# input like this:
# -----------------------------------
# stop: Fri Aug 29 20:34:55 EDT 2014
# start: Fri Aug 29 19:14:52 EDT 2014
#     - fed the onions
# stop: Fri Aug 29 19:04:55 EDT 2014
# start: Fri Aug 29 18:04:52 EDT 2014: ChargeCode57-3
# stop: Thu Aug 28 17:04:55 EDT 2014
# start: Thu Aug 28 16:04:52 EDT 2014
#    - designed a new space station
#
# ... yields output like this:
# -----------------------------------
# Hours worked:  3.33583333333
# Hours not-worked:  25.165
# Started:  Thu Aug 28 16:04:52 EDT 2014
# Ended:  Fri Aug 29 20:34:55 EDT 2014
# Day bucket:  2014-08-28  1.00083333333
# Day bucket:  2014-08-29  1.33416666667
# Day bucket:  2014-08-29 CharageCode57-3 1.00083333333
#
# TODO: implement a -r flag to read chronologically-ordered input

import datetime
import fileinput
import time
import re

start_or_stop = "start"
total_worked = 0
last_stoptime = 0
last_stop_str = ""
first_starttime = 0
first_start_str = ""
stoptime = 0
daybuckets = {}

for line in fileinput.input():
    try:
        if (re.match("^# *time logged$", line)):
            break
        if (re.match("^ +", line) or re.match ("^$", line)):
            continue
        #print "Parsing...", line.rstrip()
        #(state, datestr, comment) = re.split(": ", line.rstrip(), maxsplit=1)
        splitline = re.split(": ", line.rstrip(), maxsplit=2)
        state = splitline[0]
        datestr = splitline[1]
        comment = ""
        if len(splitline) > 2:
            comment = splitline[2]

        state = state.lower()
        if (start_or_stop == state):
            raise Exception("stop-stop, or start-start in input")
        start_or_stop = state

        dt = datetime.datetime.strptime(datestr, "%a %b %d %H:%M:%S %Z %Y")
        daybucket = str(dt.date()) + " " + comment
        t = time.mktime(dt.timetuple())
        if (state == "stop"):
            stoptime = t
            if (last_stoptime == 0):
                last_stoptime = t
                last_stop_str = datestr
        else:
            if daybucket not in daybuckets:
                daybuckets[daybucket] = 0
            daybuckets[daybucket] += (stoptime - t)
            total_worked += (stoptime - t)
            first_starttime = t
            first_start_str = datestr
    except:
        print ("Unexpected error:", line)
        raise


print "Hours worked: ", (total_worked / 3600.0)
print "Hours not-worked: ", (((last_stoptime - first_starttime) - total_worked) / 3600.0)
print "Started: ", first_start_str
print "Ended: ", last_stop_str
for daybucket in sorted(daybuckets.keys()):
    print "Day bucket: ", daybucket, (daybuckets[daybucket] / 3600)


