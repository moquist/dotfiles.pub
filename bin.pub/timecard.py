#!/usr/bin/python

# interpret an input file like this:
# stop: Fri Aug 29 20:34:55 EDT 2014
# start: Fri Aug 29 19:14:52 EDT 2014
# stop: Fri Aug 29 19:04:55 EDT 2014
# start: Fri Aug 29 18:04:52 EDT 2014

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

for line in fileinput.input():
    (state, datestr) = re.split(": ", line.rstrip(), maxsplit=1)

    state = state.lower()
    if (start_or_stop == state):
        raise Exception("stop-stop, or start-start in input")
    start_or_stop = state

    t = time.mktime(datetime.datetime.strptime(datestr, "%a %b %d %H:%M:%S %Z %Y").timetuple())
    if (state == "stop"):
        stoptime = t
        if (last_stoptime == 0):
            last_stoptime = t
            last_stop_str = datestr
    else:
        total_worked += (stoptime - t)
        first_starttime = t
        first_start_str = datestr

print "Hours worked: ", (total_worked / 3600.0)
print "Hours not-worked: ", (((last_stoptime - first_starttime) - total_worked) / 3600.0)
print "Started: ", first_start_str
print "Ended: ", last_stop_str


