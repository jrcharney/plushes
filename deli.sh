#!/bin/bash

die(){
 echo "$1" && exit 1
}

fetch(){
 case $# in
  0) die "No arguments. Fetching nothing. Aborting." ;;
  1) 
	  fn=${1##*/}
	  if [[ -f ./{$fn} ]]; then
		  read -p "The file $fn already exists. Overwrite it? [y/n]: " yn
		  case $yn in
			  y|Y) curl -SLO $1 ;;
			  n|N) echo "File will not be downloaded." ;; # rename it?
			  *) die "Invalid entry. Aborting program." ;;
		  esac
	  else
	   curl -SLO $1
      fi
      ;;
  2)  # curl -SL $1 -o $2 
	  # fn1=${1##*/}	# filename of the first argument.
	  # fn2=${2##*/}	# filename of the second argument.
	  # pt2=${2%/*}	# path of the second argument.
	  # TODO: verify that $2 has a valid path later.
	  if [[ -f ${2} ]]; then
		  read -p "The file $2 already exists. Overwrite it? [y/n]: " yn
		  case $yn in
			  y|Y) curl -SL $1 -o $2 ;;
			  n|N) echo "File will not be downloaded.";;	# Pick a different name?
			  *) die "Invalid entry. Aborting program."
		  esac
	  else
	   curl -SL $1 -o $2
      fi
	  ;;
  *) die "Too many arguments. Fetching nothing. Aborting." ;;
 esac
}

while true; do 
 echo "Enter url to download. Optionally, also where to put it."
 read -p "> " url
 [[ "$url" = "done" ]] && break
 url=($url)
 fetch ${url[@]}
done
