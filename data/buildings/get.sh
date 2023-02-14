#!/bin/sh


# https://data.southampton.ac.uk/building/2.kml


BUILDINGS=$(awk -F "," '{print $1}' highfield.csv | tail -n 8)

# Iterate through buildings and run wget on https://data.southampton.ac.uk/building/<building>.kml
for BUILDING in $BUILDINGS
do
    wget https://data.southampton.ac.uk/building/"$BUILDING".kml
done