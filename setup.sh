#!/bin/bash
# File: setup.sh
# Author: Jason Charney, BSCS (jrcharneyATgmailDOTcom)
# Info: Create all the softlinks in the PLUSHES project to put in ~/bin
# Date: 2 May 2016

printf "PLUSHES: Power Linux User SHEll Scripts\n\n"

printf "This script will set up PLUSHES!\n"

try=0
while read -r -p "Do you want to execute this script? [Y/n]: " ans; do
	case ${ans,,} in
		y|yes) break ;;
		n|no) 
			printf "Script aborted.\n"
			exit 0 
			;;
		*)
			if [[ $((++try)) -lt 3 ]]; then
				printf "Invalid entry, please try again.\n"
			else
				printf "After three tries, I quit. Try again later.\n"
				exit 1
			fi
			;;
	esac
done

printf "OK, let's go!\n"

if [ ! -d ~/bin ]; then
	mkdir ~/bin
	cat << EOF
~/bin created. Assuming there is a few lines in ~/.profile that add it
to the beginning of the PATH.  You will need to close this terminal
and open it up again to complete these changes.
EOF
else
	printf "It appears ~/bin already exists. So we won't need to create it with this script.\n"
fi

# list=$(ls -1 *.sh)
# Using Sed and Gawk, we filterout the current file and the non-execultable files.
list=$(ls -l *.sh | gawk 'BEGIN{FS=" "}/^-rwx/{print $9}' | sed -n -e "/${0##*/}/!p")
ct=$(echo "${list[@]}" | wc -l)
idx=0

okall=0		# This will override any question about replacing files.
try=0
for file in $list; do
	link="$HOME/bin/${file%.*}"
	file="$PWD/$file"
	skip=0
	if [ -h $link -a $okall -eq 0 ]; then
		# skip=0
		while read -r -p "The file '$link' exists, do you still want to replace it? [Yes/No/yes All/Cancel/Help]: " ans; do
			case ${ans,,} in
				y|yes)	# If yes, apply for just this file.
					try=0
					break
					;;
				n|no)	# If no, go on to the next one.
					try=0
					printf "%2d/%2d Skipped\n" $((++idx)) $ct	# We'll still want to increase the index
					skip=1						# Use the continue step outside of this loop
					break
					;;
				a|all)	# If all, apply yes for all files.
					try=0
					okall=1
					break
					;;
				c|cancel)
					printf "Script cancelled.\n"
					exit 1
					;;
				h|help)
					try=0
					cat <<EOF
Enter y or yes to create a new soft link for a file.
Enter n or no  to no create a new soft link for a file.
Enter a or all to create softlinks for all the rest of the files in the list (Recommended)
Enter c or cancel to abort this script and not create any more softlinks
Enter h or help for this message.
EOF
					;;
				*)
					if [ $((++try)) -lt 3 ]; then
						printf "Invalid entry, please try again.\n"
					else
						printf "After three invalid entries, I quit! Try again later.\n"
						exit 1
					fi
					;;
			esac
		done
	fi
	# TODO: Should I add -f to the ln command?
	[[ $skip -eq 1 ]] && continue
	printf 	"%2d/%2d: ln -s %s %s\n" $((++idx)) $ct "$file" "$link"
	# [ "$1" -ne "-t" ] && 
	ln -f -s -T $file $link
	# [ "$file" = ${0##*/} ] && continue		# Do this for all files except setup.sh
	#if [ -x "$file" ]; then				# Look for the executable files
		# printf 	"%2d/%2d: ln -s %s %s\n" $((++idx)) $ct "$file" "~/bin/${file%.*}"
		# ln -s $file ~/bin/${file%.*}"
	#fi
done

