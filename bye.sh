#!/bin/bash
# File: bye.sh
# Author: Jason Charney, BSCS (jrcharneyATgmailDOTcom)
# Date: 26 Apr 2016
# Info: shutdown your computer with one word instead of four.
# Note: Yeah, I could have put this in ~/.bash_aliases, but a script would be better.

usage(){
	cat << EOF
It shouldn't be this hard to use.
"-y", "y", or "yes", to turn off the computer.
"-r", "r", or "reboot", to restart the computer.
      "n", or "no", to cancel this program.
"-h", "h", or "help", for this prompt.
I don't have a "logout" option, because you can simply do that by typing "exit".
I don't have a "sleep" or "hibernate" option, because the Raspberry Pi doesn't have that option.
EOF
}

case $# in
	0)
		try=0
		while read -r -p "Are you sure you want to shutdown? [Y(es)/N(o)/R(eboot)]: " ans; do
			case ${ans,,} in
				y|q|yes)
					if [ ${ans,,} == 'q' ]; then
						echo "BYE Q!"			# And everybody said "YATTA!!!" :3
					else
						echo "Shutting down. Goodbye."
					fi
					sudo shutdown -h now
					exit 0
					;;
				r|reboot|restart) 
					echo "Rebooting. See you soon."
					sudo reboot 
					exit 0
					;;
				n|no)
					echo "Staying up."
					exit 0
					;;
				h|help|huh)
					try=0
					usage
					;;
				*)
					if [ $((++try)) -lt 3 ]; then
						echo "Invalid entry, please try again."
					else
						echo "After three tries, I'm going to stay up."
						exit 1
					fi
					;;
			esac
		done
		;;
	1)	case $1 in
			-y|-f|-q|--yes|--force)
				if [ ${1} == '-q' ]; then
					echo "BYE Q!"			# And everybody said "YATTA!!!" :3
				else
					echo "Shutting down. Goodbye."
				fi
				sudo shutdown -h now
				;;		# shutdown immediately
			-r|--reboot|--restart)	
				echo "Rebooting. See you soon."
				sudo reboot 
				;;		# reboot
			-h|--help)
				usage
				exit 0
				;;
			*)
				echo "Invalid option. I'm staying up."
				exit 1
				;;
		esac
		;;
	*) 	echo "ERROR: Too many arguments! I'm not going to bed yet!"
		exit 1
		;;
esac

