#!/bin/sh


# Example data
# -1.39842698606205,50.9358171911636,0
# -1.39827867420864,50.9357745630755,0
# -1.39826007908226,50.93580026447719,0
# -1.39823789069475,50.9358308910189,0

# Example output
# LatLng(50.9358171911636 ,-1.39842698606205),
# LatLng(50.9357745630755 ,-1.39827867420864),
# LatLng(50.93580026447719,-1.39826007908226),
# LatLng(50.9358308910189 ,-1.39823789069475),

# Take data from pbpaste, remove column 3, swap columns 1 and 2, remove last line, convert to LatLng, and output to pbcopy

pbpaste | cut -d, -f1,2 | awk -F, '{print "LatLng("$2" ,"$1"),"}' | sed '$d' | pbcopy

# pbpaste | cut -d, -f1,2 | awk -F, '{print "LatLng("$2" ,"$1"),"}' | pbcopy


														




