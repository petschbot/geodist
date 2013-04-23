# GeoDist

## A simple script to group geolocation relative to reference points

The following script groups geolocations relative to a list of reference points. The script calculates the distance between the location and each reference point, checks if the location is inside a given radius around the point and recommends the nearest reference point. The output is put both to the terminal and a output.csv file. 

Usage:  

    geodist.rb list_of_reference_points.csv list_of_locations.csv output.csv



### Columns Locations-CSV

* id (string or integer)
* lat (Location Latitude as float like 59.1234)
* long (Location Longitude as float like 6.1234)
* name (simple string)

### Columns list_of_reference_points.csv

* id
* lat
* long
* radius (radius around this reference point in meter)


## Columns output.csv

* id
* name
* lat
* long
* ref matches (Amount of matching reference points)
* ref recommendation (recommended reference point)
* ref shortest distance (distance between recommended reference point and location in meter)
* ref %id% (is location inside the radius of reference point %id% (true/false))
* ref %id% distance (distance between the location and reference point %id%)

