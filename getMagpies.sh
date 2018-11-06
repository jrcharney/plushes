#!/bin/bash
# File:         getMagpies.sh
# Info:         Download every issue of MagPi magazine and some other important documents.
# Created by:   Jason Charney (jrcharneyATgmailDOTcom)
# Created:      6 Nov 2018
# Last updated: 6 Nov 2018
# TODO:

site="https://www.raspberrypi.org/magpi-issues"
outdir=~/Documents/Books/magpi-issues
ic=75           # download issues 1 through the latest issue.

# fs = file_string, our list of files as a string.
# fa = file_array, our list of files as an array.
# fc = file_count, the number of items in our array.

# Let's get the non-uniformly named files first.
# This herestring will be converted from a string to an array later.
IFS='' read -r -d '' fs <<"EOF"
Annual2018.pdf
Beginners_Book_v1.pdf
Essentials_AIY_Project_Voice_v1.pdf
Essentials_Bash_v1.pdf
Essentials_C_v1.pdf
Essentials_Camera_v1.pdf
Essentials_GPIOZero_v1.pdf
Essentials_Games_v1.pdf
Essentials_Minecraft_v1.pdf
Essentials_Scratch_v1.pdf
Essentials_SenseHAT_v1.pdf
Essentials_Sonic_Pi-v1.pdf
MagPi-Digital-Test.pdf
MagPi-EduEdition01.pdf
MagPi-EduEdition02.pdf
MagPi31-spread.pdf
MagPi47_Poster.pdf
PagPiSE1.pdf
Projects_Book_v1.pdf
Projects_Book_v2.pdf
Projects_Book_v3.pdf
Projects_Book_v4.pdf
TheMagPi40.pdf
EOF

skip=0    # globally determine if files should be skiped from now on
# 0 is ask
# 1 is always
# 2 is never

#fc=$(echo "$fs" | wc -l)   # This is incorrect!

# Because fs is a string, we need to convert it to an array.
IFS=$'\n' declare -a fa=(${fs})
#Find how many items are in our file array fa.
fc=${#fa[@]}

#tfc=$(echo "$fc+$ic" | bc)    # total file count. Count the number of files expected to be processed.
tfc=$((fc+ic))                # Actually use arithmetic operator instead of bc

download(){
  file="$1"
  #echo "Done"
  curl -#SL "${site}/${file}" -o "${outdir}/${file}"
}

doit(){
 local tries=0
 printf "This program is expected to download up to ${tfc} files and may take up some significant space on your harddrive.\n"
 while read -r -p "Are you sure you want to go through with this? [Y(es)/N(o)] " ans; do
   case ${ans,,} in
     y|yes)
       echo "Awesome. Let's get started."
       break
       ;;
     n|no)
       echo "OK, maybe later. Bye."
       exit 0
       ;;
     *)
       if [ $((++tries)) -lt 3 ]; then
          echo "Invalid entry. Please try again."
       else
          echo "After three tries, I quit!"
          exit 1
       fi
       ;;
   esac
 done
}

fcusage(){
  cat << EOF
Here are a full list of options avaiable
Select Y for "yes" and this file will be overwritten.
Select N for "no"  and this file will not be overwritten.
Select A for "always" and this file along with any other 
            duplicates I run into will be over written.
Select V for "never" and this file along with any other 
            duplicates I find will not be overwritten.
Select P for "filepath" to see where this file will be stored.
You've already selected H for "help", so you know what this does.
Select C for "cancel" to abort this program.
If you don't give me an answer three incorrect tries, I will abort.
EOF
}

filecheck(){
  local file="$1"
  local tries=0
  if [ -f ${file} ]; then
    case ${skip} in
      0)  # ask
        printf "It looks like ${file} already exist in ${outdir}."
        while read -r -p "Should I overwrite it? [Y(es)/N(o)/H(elp for more options)]: " ans; do
          case ${ans,,} in
            p|path|fullpath)
              tries=0
              echo ""
              ;;
            y|yes)
              echo "Overwriting ${file}."
              download "${file}"
              break
              ;;
            n|no)
              echo "Skipping ${file}."
              break
              ;;
            a|all|always)
              skip=1
              echo "I will overwrite any existing files including this one from now on."
              echo "Overwriting ${file}."
              download "${file}"
              break
              ;;
            v|none|never)
              skip=2
              echo "I will skip any existing files including this one from now on."
              echo "Skipping ${file}."
              break
              ;;
            c|cancel|stop|quit|exit)
              echo "Program aborted."
              exit 0
              ;;
            h|help|?)
              tries=0
              fcusage
              ;;
            *)
              if [ $((++tries)) -lt 3 ]; then
                echo "Invalid entry. Please try again or type h for help."
              else
                echo "After three tries, I quit!"
                exit 1
              fi
              ;;
          esac
        done 
        ;;
      1)  # always
        echo "Overwriting ${file}"
        download "${file}"
        ;;
      2)  # never
        echo "Skipping ${file}"
        ;;
      *) 
        echo "Hey! You aren't supposed to be here! Aborting."
        exit 1
        ;;
    esac
  else
    echo "Downloading ${file}"
    download "${file}"
  fi
}


doit

# Create the file path we want to put our files in if it doesn't exist
[ ! -d "${outdir}" ] && mkdir -p "${outdir}"

## Part 1: Getting the non sequential files.

printf "\e[96mGetting \e[93m%d\e[96m other files...\e[0m\n" $fc

i=1
for file in "${fa[@]}"; do
  printf "\e[93m[%02d/%02d]\e[0m \e[95m%s/\e[92m%s\e[0m \e[96m->\e[0m \e[94m%s/\e[92m%s\e[0m\n" $((i++)) ${fc} ${site} ${file} ${outdir} ${file}
  filecheck "${file}"
done

## Part 2: Getting the sequential files.

printf "\n\e[96mGetting \e[93m%d\e[96m issues...\e[0m\n" $ic
i=1
while [ ${i} -le ${ic} ]; do
  file=$(printf "MagPi%02d.pdf" ${i} )
  printf "\e[93m[%02d/%02d]\e[0m \e[95m%s/\e[92m%s\e[0m \e[96m->\e[0m \e[94m%s/\e[92m%s\e[0m\n" $((i++)) ${ic} ${site} ${file} ${outdir} ${file}
  filecheck "${file}"
done 

## Part 3: File count

ffc=$(ls -1 "${outdir}" | wc -l)

if [[ ${ffc} -lt ${tfc} ]]; then
  printf "\e[91m%03d/%03d files. INCOMPLETE!\e[0m\n" ${ffc} ${tfc}
else 
  printf "\e[92m%03d/%03d files. COMPLETE SUCCESS!\e[0m\n" ${ffc} ${tfc}
fi

