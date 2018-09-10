#!/usr/bin/env python
# This is useful to take my records of the day and turn it into the numbers
# I need to fill out a timecard.
#
# I create the reverse-chronological file by using vim and using :r!date after
# start: stop: headers.
#
# Then I cat that file into this script.
#
# Lines beginning with a space are ignored as comments.
# Lines matching ^# *time logged$ cause remaining input to be ignored.

# input like this:
# stop: Fri Aug 29 20:34:55 EDT 2014
# start: Fri Aug 29 19:14:52 EDT 2014
#     - fed the chickens
# stop: Fri Aug 29 19:04:55 EDT 2014
# start: Fri Aug 29 18:04:52 EDT 2014
#    - designed a new space station

# ... yields output like this:
# Hours worked:  2.335
# Hours not-worked:  0.165833333333
# Started:  Fri Aug 29 18:04:52 EDT 2014
# Ended:  Fri Aug 29 20:34:55 EDT 2014
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
    if (re.match("^# *time logged$", line)):
        break
    if (re.match("^ +", line) or re.match ("^$", line)):
        continue
    print "Parsing...", line.rstrip()
    (state, datestr) = re.split(": ", line.rstrip(), maxsplit=1)

    state = state.lower()
    if (start_or_stop == state):
        raise Exception("stop-stop, or start-start in input")
    start_or_stop = state

    dt = datetime.datetime.strptime(datestr, "%a %b %d %H:%M:%S %Z %Y")
    daybucket = dt.date()
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

print "Hours worked: ", (total_worked / 3600.0)
print "Hours not-worked: ", (((last_stoptime - first_starttime) - total_worked) / 3600.0)
print "Started: ", first_start_str
print "Ended: ", last_stop_str
for daybucket in sorted(daybuckets.keys()):
    print "Day bucket: ", daybucket, (daybuckets[daybucket] / 3600)


