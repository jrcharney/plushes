#!/bin/bash
# File: geocode.sh
# Info: 

# Single geolookup
site="https://geocoding.geo.census.gov/geocoder/locations/onelineaddress"
otherargs="&benchmark=9&format=json"    # TODO: Do something more computer-hackery later. For now, being lazy

# TODO: Whats the difference between "benchmark=Public_AR_Census2010" and "benchmark=9"?

# Batch site
#site="https://geocoding.geo.census.gov/geocoder/location/addressbatch"

read -r -p "Please enter an address: " address

# TODO: Validate address

address=$(echo "${address}" | sed -n -e "s/ /+/g;s/,/%2C/g;s/&/%26/g;s/'/%27/g;p" )  # "man ascii" if other characters need to be substituted. 

#echo "${address}"
curl -sSL "${site}?address=${address}${otherargs}" | jq -C '.result.addressMatches[] | "\(.matchedAddress):\(.coordinates.x),\(.coordinates.y)"'

# What if there is more than one address?
# See: 1600 Pennsyvania Ave, Washington DC
# There are THREE listings. the NW listing with 20502 zip code is the correct address.
# Should user intevervention be required?

