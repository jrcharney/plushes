#!/bin/bash
# File: ~/bin/diecisiete
# Info: "diecisiete" (or "seventeen" in Spanish")
# 	is the number that when multiplied by 15 is 255.
#	This program increases and decreases the screen
#	power level by 17 which allows for 16 power levels (0-15).
# The default power level is 15 (100% brightness!)
# You probably don't want to set it to 0 (0% brightness)
# 17 was chosen as the interval since we can't use 256.
# The scale is between 0 and 255 (256-1), and since the minimum can't
# be -1, we use 17.

nivel=/sys/class/backlight/rpi_backlight/brightness

# Don't run if the file does not exist
if [[ ! -f ${nivel} ]]; then
  echo "Sorry, we can't adjust the brightness."
  echo "The file that we need to use does not exist."
  exit 1
fi

# If there are no argumets, just show the power level
if [[ $# -lt 1 ]]; then
  cat ${nivel}
  exit 0
fi

ayuda() {
 cat <<EOF
# Diecisiete (17)
Use this program to adjust the brightness of a Raspberry Pi screen.

## Commands
diescisiete help		This prompt
diescisiete [status]		Show the current value
diescisiete up			Increase the value by 17
diescisiete down		Decrease the value by 17
diescisiete min			Set the value to the min value (17) (Don't use zero!)
diescisiete max			Set the value to the max value (255)
diescisiete level [1-15]	Change the value to a power level x 17
diescisiete value [17-255]	Change the value to a power level

## Why 17?
2^8 = 256
15 * 17 = 255, which we can add and subtract 17 at 15 times.
It would be 16, but if we set our value to zero, we get darkness.
This program prevents that.

---
Created by Jason Charney (jrcharneyATgmailDOTcom)
EOF
}

# Clamp a value between 17 and 255
clamp(){
  if [[ ${1} -lt 17 ]]; then
    echo "17"
  elif [[ ${1} -gt 255 ]]; then
    echo "255"
  else
    echo "${1}"
  fi
}

# Check to see if a value is a number (specifically an integer)
isNumber(){
  re='^[0-9]+$'
  [[ ${1} =~ ${re} ]]
}

isNaN() {
 ! isNumber ${1}
}

# Our changes must be done as root
change(){
  sudo bash -c "echo ${1} > ${nivel}"
}

# syntax: answer=$(askNum "What is the question?")
askNum () {
  # Three tries before rejecting
  local tries=0
  while true; do
    read -r -p "${1}: " val	    # read a value
    if isNumber ${val}; then break
    else
      if [[ $((++tries)) -lt 3 ]]; then
        echo "Invalid entry. Please try again."
      else
	echo "After three tries, I quit."
	exit 1
      fi
    fi
  done
  echo ${val}		# just to be sure, let's echo our valid answer
}

case $1 in
  status|estado) cat ${nivel} ;;
  up|enciende|encendiendo) 
    # Increase the power level by 17 if the current level is less than max
    valor=$(cat ${nivel})
    if [[ ${valor} -lt 255 ]]; then
      change $((${valor}+17))
    fi
    ;;
  down|apaga|apagando) 
    # Decrease the power level by 17 if the current level is more than min
    valor=$(cat ${nivel})
    if [[ ${valor} -gt 17 ]]; then
      change $((${valor}-17))
    fi
    ;;
  min)  change "17"  ;;		# We don't want to use 0
  max)  change "255" ;;
  level|nivel)
    if [[ ! ${2} ]]; then
      valor=$(askNum "Enter a power level (1-15)")
    else
      # TODO: Check to make sure this is a number
      if isNumber ${2}; then
        valor=${2}
      else
	echo "Invalid power level. Aborting."
	exit 1
      fi
    fi
    valor=$((${valor}*17))
    change $(clamp ${valor})
    ;;
  value|valor)
    # TODO: What is spanish for "set a value"?
    if [[ ! ${2} ]]; then
      valor=$(askNum "Enter a power level (17-255)")
    else
      # Check to make sure this is a number
      if isNumber ${2}; then
        valor=${2}
      else
        echo "Invalid power level. Aborting."
        exit 1
      fi
    fi
    change "$(clamp ${valor})"	# clamp then change
    ;;
  help|ayuda) ayuda ;;
  *) 
    echo "Invalid command. Try using 'diecisiete help'."
    exit 1
    ;;
esac

