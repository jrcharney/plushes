#!/bin/bash
# File: geocoord.sh
# Info: Get cooridnates for an address. Only works in the United States because of US Census data.
# TODO: read an address on command like with zippy.sh
# NOTE: This could be used as an alternative to zippy.sh espeically if zippy can't pull up a zip code in some places. The only downside: No nine digit zips. On the other hand, No XML. Everything is JSON.
# NOTE: this is GeoCOORD.sh. GeoCODE is something different that the government uses. Google it.
# TODO: see if you can create another script that just gets the city name with just the address and zipcode or just zipcode

# Single geolookup
site="https://geocoding.geo.census.gov/geocoder/locations/onelineaddress"
otherargs="&benchmark=9&format=json"    # TODO: Do something more computer-hackery later. For now, being lazy

# TODO: Whats the difference between "benchmark=Public_AR_Census2010" and "benchmark=9"?

# Batch site (TODO: set that up!)
#site="https://geocoding.geo.census.gov/geocoder/location/addressbatch"

usage(){
  cat <<EOF
geocoord.sh - fetch coordinates of an address in the United States.

geocoord.sh could be used as an alternative to zippy.sh, but you won't get nine digit zip codes.

geocoord.sh can get city names if you just have the address and the zip code. (The census API is smart!)

There is also the issue that some addresses may appear more than once. For example take this address:

  1600 Pennsylvania Avenue, Washington, DC

You wouldn't believe it but the address for the White House appears three different times
especially since the White House is at 1600 Pennsylvania Avenue **NW**.
That Northwest part makes all the difference.
Also, the correct address has a zipcode of 20502.

Perhaps if I re-write this script in Python and use some sort of artificial intelligence,
it will make a decision. For now, user intervention may be required, and I wouldn't
recommend geocode.sh to generate points for your KML/KMZ file just yet.

Stay tuned. I still need to fix it.
EOF
  exit 0
}

# Didn't get an address? Ask for one.
# TODO: Validate address
getcoords(){
  read -r -p "Please enter an address: " address
}

getcoordsbyaddr(){
  # IFS=',' read -ra arr << "$@"    # We don't need to do that this time.
  IFS='' read -r address <<< "$@"
}

fetchcoords(){
  # TODO: combine these next two lines later.
  address=$(echo "$address" | sed -n -e 's/^[[:space:]]*//g;p' | sed -n -e 's/[[:space:]]*$//g;p') # remove leading and trailing spaces.
  address=$(echo "${address}" | sed -n -e "s/ /+/g;s/,/%2C/g;s/&/%26/g;s/'/%27/g;p" )  # "man ascii" if other characters need to be substituted. 
  curl -sSL "${site}?address=${address}${otherargs}" | jq -C '.result.addressMatches[] | "\(.matchedAddress):\(.coordinates.x),\(.coordinates.y)"'
}

case $# in
  0) getcoords ;;
  1) case ${1,,} in
    help) usage ; exit 0 ;;
    *)
      # TODO: What if an address is quoted?
      echo "Invalid entry. Type 'help' for usage.";
      echo "Did you put your address in quotes? If so, try unquoting it."
      exit 1
      ;;
  esac
  ;;
  #2) TODO: read afile full of addresses
  #3) TODO: read a file and write it to another file
  *) getcoordsbyaddr $@ ;;  # TODO: should I quote $@?
esac

fetchcoords

