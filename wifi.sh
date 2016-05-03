#!/bin/bash
# File: Wifi.sh
# Info: Simplify what all those wifi commands mean
#	Also make connecting to networks easier.
# Author: Jason Charney, BSCS (jrcharneyATgmailDOTcom)
# Date: 1 April 2016
# NOTE: On our `read` commands, `-r` is added.
#	It will disable the interpretation of backslash escapes
#	and line-continuation.  It script worked fine without it,
#	but it still works fine with it, so it is recommended to
#	use that option anyway.
# TODO: Find out how to connect to networks that don't require
#	a password.  While it is generally a good practice to use
#	networks that hgave the ssid & psk format, not ever
#	network does this.
#
# TODO: Find a way to add security info to the table.
# TODO: JSONify list output
# TODO: How do I connect to the net using tethering with a smartphone

usage(){
	cat << EOF
wifi.sh
----------------------------------
scan		List networks but in a human-friendly table.
list		List networks. Find a network you can connect to and add it.
			More infor than just with './wifi scan'
json		Does './wifi list' but in a JSON format. (COMING SOON!)
raw		List networks but without any of my meddling. Completely messy.
			This just runs 'sudo iwlist wlan0 scan'
restart		combo of stop and start
stop		stop wifi from running
start		start up wifi if it is not running.
		You may get three lines about some kind of error, but that's normal.
status		Is it connected?
add		Add a new network to /etc/wpa_supplicant/wpa_supplicant.conf
		I support WPA/WPA2, WEP, Open Networks, and Hidden Networks.
		WPA/WPA2 and Open should definitely work.
		I still need to try WEP and Hidden.
help		This prompt!
EOF
	exit 1
}

con_help(){
	cat << EOF
Add connection supports one of four kinds of commands
* WPA and WPA2		These are easy to set up. You need a network and a passworkd.
* WEP			Requires you to connect now and add the WEP Key later.
* Open Networks		Those "Free Wifi" hotspots. CAVEAT EMPTOR! Your security is not guaranteed!
* Hidden Networks	Just as bad as an Open Network, but it is hidden from scanning.
EOF
}

# Func: bad
# Info: Kick out any bad input
bad(){
	printf  "Invalid command \"%s\". Type \"help\" for a list of options.\n" "${1}"
	exit 1
}

# Func: raw_scan
# Info: Get our raw data
raw_scan(){
	sudo iwlist wlan0 scan
}

# Func: Check
# Info: Check to see if raw_scan has found any networks.
#	Quit the program if it has not.
check(){
	# This is what it looks like when we can't find anything
	nothing="wlan0     No scan results"
	if [[ $(raw_scan) = "${nothing}" ]]; then
		raw_scan
		exit 0
	fi
}

# Func: wifi_restart
# Info: Restart Wifi
wifi_restart(){
	sudo ifdown wlan0 && sudo ifup wlan0
}

# Func: ortho
# Info: ortho as in orthodontist, a dentist who specializes in straigtening teeth with braces.
# 1. Use a while loop to read input.
#	Setting IFS here allows us not to save IFS to another variable, change it, and then reset it.
#	This is good espcially if something should go wrong.
#	It also only applies to the `read` command so that any spaces or tabs in $line variable (which reads a line of text) is preserved.
#	echo outputs the $line.
#	This while loop reassembles our multiline input.
#	Had we input a file, we would need to do this
#		while IFS= read line; do echo "${line}"; done < $FILE
#	Where $FILE is a file name or an argument for a file name like $1 or $FILE
# 2. Replace all the "Cell [##] - " prefixes to a more JSON-ish looking "}\n[##] {\n\t\t\t"
# 3. Insert a closing brace at the end.
# 4. Strip out any leading whitespaces on lines with closing braces
# 5. Delete the first two lines of output.
#	One line is likely blank.
#	The other is a closing brace where it shouldn't be.
# 6. Delete any blank lines.
ortho(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e 's/Cell \([0-9][0-9]\) - /}\n[\1] {\n\t\t\t/g;p' \
	| sed -n -e 'p;$i}' \
	| sed -n -e 's/^[ \t]*\(}\)/\1/g;p' \
	| sed -n -e '2d;p' \
	| sed -n -e '/^$/d;p'
}

# Func: label
# Info: Organize our more important labels
# On the Address lines, remove any leading spaces and tabs and use just tabs instead
# On the ESSID lines, do the same
# On the Protocol lines, do the same.
# On the Mode lines, do the same
# On the Frequency lines, do the same.
# On the Encryption key lines, do the same.
# On the Bit rate lines, do the same
# On the Quality lines, replace all the instances of "/100" with "%"
# On the Quality lines, put Signal level on the next line.
# On the Quality lines, replace the equal sings with colons
# On the Signal level lines, do the same thing.
label(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/Address/s/^[ \t]*\(Address:.*\)/\t\1/g;p' \
	| sed -n -e '/ESSID/s/^[ \t]*\(ESSID:.*\)/\t\1/g;p' \
	| sed -n -e '/Protocol/s/^[ \t]*\(Protocol:.*\)/\t\1/g;p' \
	| sed -n -e '/Mode/s/^[ \t]*\(Mode:.*\)/\t\1/g;p' \
	| sed -n -e '/Frequency/s/^[ \t]*\(Frequency:.*\)/\t\1/g;p' \
	| sed -n -e '/Encryption key/s/^[ \t]*\(Encryption key:.*\)/\t\1/g;p' \
	| sed -n -e '/Bit Rates/s/^[ \t]*\(Bit Rates:.*\)/\t\1/g;p' \
	| sed -n -e '/Quality=/s/\/100/%/g;p' \
	| sed -n -e '/Quality=/s/[ \t]*\(Quality=.*\)/\t\1/g;p' \
	| sed -n -e '/Quality=/s/[ \t]*\(Signal level=.*\)/\n\t\1/g;p' \
	| sed -n -e '/Quality=/s/=/:/g;p' \
	| sed -n -e '/Signal level=/s/=/:/g;p'
	
	# | sed -n -e 's/Encryption key:on/\xF0\x9F\x94\x92/g;p' \

}

# TODO make a  lable2 for all the field names of the IE blocks.

# Func: ortho2
# Info: Put all this Extra, IE, and IE: Unknown data into its own data structure.
# What's going on?
# 1. Create block wher the first line is Extra.  Call it "Security" because it has a bunch of encryption stuff.
# 2. Define the closing block of that block as the line for Authentication Suites, and add a closing brace at a new line after it.
# 3. Put all "IE: " blocks that are not "IE: Unknown" at the beginning of a block.  This is generally after an Extra line.  Adjust tabs.
# 4. Adjust the tabs on the "Group Cipher" lines.
# 5. Adjust the tabs on the "Pairwise Ciphers" lines.
# 6. Adjust the tabs on the "Authentication Suites" lines and add a closing brace for the "IE: " block
# 7. "IE: Unknown" have a bunch of random data, but we can't put it in its own block.  We can adjust the tabs.  We do this so that gawk can deal with this line later.
ortho2(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e 's/^[ \t]*\(Extra:.*\)$/\tSecurity: {\n\t\t\1/g;p' \
	| sed -n -e 's/^\([ \t]*Authentication Suites.*\)$/\1\n\t}/g;p' \
	| sed -n -e 's/^[ \t]*\(IE:\) \([^U].*\)$/\t\t\1 {\n\t\t\t\2/g;p' \
	| sed -n -e 's/^[ \t]*\(Group Cipher .*\)$/\t\t\t\1/g;p' \
	| sed -n -e 's/^[ \t]*\(Pairwise Ciphers .*\)$/\t\t\t\1/g;p' \
	| sed -n -e 's/^[ \t]*\(Authentication Suites .*\)$/\t\t\t\1\n\t\t}/g;p' \
	| sed -n -e 's/^[ \t]*\(IE: Unknown:\) \(.*\)$/\t\1 \t\2/g;p'
	# | sed -n -e 's/^[ \t]*\(IE: Unknown:\) \(.*\)$/\t\1 {\n\t\t\2\n\t}/g;p'
}

# Func: wrapuk
# Info: Wrap Unknown, wrap the "IE: Unknown" lines just to see if we can make something out of it.
# Wraps the unknown characters into smaller parts.
wrapuk(){
	# n is the length outputed by split
	# ieu[1] = ""
	while IFS= read -r line; do echo "${line}"; done \
	| gawk '
	$0 ~ /^\tIE: Unknown:/ {
		split($0,ieu,"\t")
		printf("\t%s{\n",ieu[2])

		n = split(ieu[3],c,"")
		j = 1
		b = 32
		for(i=1;i<=n;i++){
			if(j == 1){
				printf("\t\t%s",c[i])
			}
			else if( j == b ) {
				printf("%s\n",c[i])
				j = 0
			}
			else{
				printf("%s",c[i])
			}
			j++
		}

		printf("\n\t}\n")

	}
	$0 !~ /^\tIE: Unknown:/ { print $0 }
	'
	#	n = split($0,ieu,"\t")
	# for( i = 1; i <= n; i++ )
	#	 print "ieu[" i "] = \"" ieu[i] "\""
}

# TODO: What if ESSID is ""?

# Let's use the better_scan function as the base for better scanning of local networks.
# TODO: Make the scan look much nicer
#	Address | ESSID |
#	Let AWK handle the columns
# TODO: Test for what if no results, you'll have to do this with the regular command.
# What are we doing here:
# 1. Scan for wifi networks
# 2. Spruce up the output data
# 3. ???
# 4. PROFIT!
# TODO: Color code quality and  strenght
# TODO: Use the Unicode Character for a Lock to indicate if 'Encryption key' is on.
# TODO: Insert abbreviations. (s/Channel/Ch./g)
# TODO: If the first line of output includes 'Scan completed :' run the sed part
# What are we doing?
# 1. Read the input from the previous command (raw_input)
# 2. Pipe the data through a function to apply brackets and braces on each record (ortho)
# 3. Organize our more important labels (label)
# 4. Put all the extra info into it's own braced data structure (ortho2)
# 5. Wrap all the unknown data stuff. (wrapuk)
better_scan(){
	# while IFS= read line; do echo "${line}"; done | ortho | label
	raw_scan | ortho | label | ortho2 | wrapuk
}

# Func: get_index
# Info: Get the record number from the better_scan list.
get_index(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\[[0-9][0-9]\]/p' \
	| sed -n -e 's/^\[\([0-9][0-9]\)\].*/\1/g;p'
}

# Func: get_ipaddr
# Info: get the IP address. It will likely be in IPv6 format.
get_ipaddr(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tAddress/p' \
	| sed -n -e 's/^[^:]*: \(.*\)$/\1/g;p'
}

get_essid(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tESSID/p' \
	| sed -n -e 's/^[^:]*:"\(.*\)"$/\1/g;p'
}

get_proto(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tProtocol/p' \
	| sed -n -e 's/^[^:]*:\(.*\)$/\1/g;p'
}

get_mode(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tMode/p' \
	| sed -n -e 's/^[^:]*:\(.*\)$/\1/g;p'
}

get_freqch(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tFrequency/p'\
	| sed -n -e 's/^[^:]*:\([0-9.]* GHz\) (Channel \([0-9]*\))$/\2\t\1/g;p'
}

get_enckey(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tEncryption key/p' \
	| sed -n -e 's/^[^:]*:\(.*\)$/\1/g;p'
	
	# | sed -n -e 's/on/\xF0\x9F\x94\x92/g;p' 	# Lock icon
}

get_bitrate(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tBit Rates/p' \
	| sed -n -e 's/^[^:]*:\([0-9.]* [TGMKk]*b\/s\)$/\1/g;p'	
}

get_quality(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tQuality/p' \
	| sed -n -e 's/^[^:]*:\(.*\)$/\1/g;p'	
}

get_siglevel(){
	while IFS= read -r line; do echo "${line}"; done \
	| sed -n -e '/^\tSignal level/p' \
	| sed -n -e 's/^[^:]*:\(.*\)$/\1/g;p'
}

# get_security(){
# 	while IFS= read -r line; do echo "${line}"; done \
#	| sed -n -e '/^\tSecurity/,/\t}/p'
# }

# Func: add_header
# Info:	Add a header to the table with gawk
#add_header(){
#	while IFS= read -r line; do echo "${line}"; done \
#	gawk -F '\t' '{}'
#}

# Func: tablefy
# Info: Take in all that better_scan stuff and process it into a table.
# TODO: Scecurity blocks are not included
tablefy(){
	mkfifo idxp ipaddrp essidp protop modep freqchp enckeyp bitratep qualityp levelp	# secuirtyp
	trap "rm -f idxp ipaddrp essidp protop modep freqchp enckeyp bitratep qualityp levelp" EXIT HUP QUIT INT KILL TERM
	
	# TODO: Apply a header!
	while IFS= read -r line; do echo "${line}"; done \
	| tee \
		>(get_index    > idxp ) \
		>(get_ipaddr   > ipaddrp ) \
		>(get_essid    > essidp ) \
		>(get_proto    > protop ) \
		>(get_mode     > modep ) \
		>(get_freqch   > freqchp ) \
		>(get_enckey   > enckeyp ) \
		>(get_bitrate  > bitratep ) \
		>(get_quality  > qualityp ) \
		>(get_siglevel > levelp ) \
		> /dev/null \
	| paste -d '\t' idxp essidp ipaddrp freqchp modep protop enckeyp bitratep qualityp levelp \
	| gawk '
	function rtp(v){
		sub(/%+$/,"",v);
		return v;
	}
	function color(p){
		if(     rtp(p) == 100){ s = sprintf("\033[1;32m%4s\033[0m",p) }
		else if(rtp(p) >=  80){ s = sprintf("\033[1;32m%4s\033[0m",p) }
		else if(rtp(p) >=  60){ s = sprintf("\033[0;32m%4s\033[0m",p) }
		else if(rtp(p) >=  40){ s = sprintf("\033[1;33m%4s\033[0m",p) }
		else if(rtp(p) >=  20){ s = sprintf("\033[0;33m%4s\033[0m",p) }
		else if(rtp(p) >=  10){ s = sprintf("\033[1;31m%4s\033[0m",p) }
		else{                   s = sprintf("\033[0;31m%4s\033[0m",p) }
		return s
	}
	BEGIN{ FS="\t";
	printf("\033[1;33m%-2s  %-32s  %-17s  %-2s %-11s  %-6s  %-14s  %-3s  %-8s  %-4s  %-4s\033[0m\n", "##", "ESSID", "IP Address (IPv6)", "Ch", "(Freq)", "Mode", "Protocol", "Enc", "Bit Rate", "SQ", "SL") }
	{ printf("%02d  %-32s  %17s  %2s (%9s)  %-6s  %-14s  %-3s  %8s  %s  %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, color($10), color($11)); }'

	# In the color function, I had to add a step for 100%, because it would appear red instead of bright green

	# These functions are for awk
	# function ltrim(s){ sub(/^[ \t\r\n]+/, "", s); return s; }
	# function rtrim(s){ sub(/[ \t\r\n]+$/, "", s); return s; }
	# function  trim(s){ return rtrim(ltrm(s)); }

	rm -f idxp ipaddrp essidp protop modep freqchp enckeyp bitratep qualityp levelp
}

# Func: jsonify
# Info: Take in all that better_scan stuff and process it into a JSON format.
jsonify(){
	echo "This isn't done yet!"	# You shouldn't even be here!
}

##
#
# In all these types, the /etc/wpa_supplicant/wpa_supplicant.conf starts with these two lines
#
#	* add_wpa
#	* add_wep
#	* add_open
#	* add_hidden
#
# ctrl_interface=DIR=/var/run_wpa_supplicant GROUP=netdev
# update_config=1
#
##

# Func: add_wpa
# Info: Add a wpa/wpa2 connection.
#	Your typical network connection.  Enter ssid.  Enter password.  KVETCH! :-P
# Note: We've done this, it just needs to be put in a better spot
# 	network={
#		ssid="network_name"
#		psk="network_password"
#	}
add_wpa(){
	#echo "coming soon!"
	#exit 1
	try=0
	read -r -p "Enter the network name:      " essid
	read -r -p "Enter the network password:  " psk
	read -r -p "Enter where this network is: " info
	network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tpsk=\"%s\"\n}" "${info}" "${essid}" "${psk}" )
	printf "%s\n" "${network}"
	while [ -z "${essid}" -o -z "${psk}" -o -z "${info}" ]; do
		read -r -p "Their is some information missing. Is this OK? [y/n] " ans;
		case ${ans,,} in
			y)	break ;;
			n)	try=0
				read -r -p "Enter the network name:      " essid
				read -r -p "Enter the network password:  " psk
				read -r -p "Enter where this network is: " info
				# network="\n# ${info}\nnetwork={\n\tssid=\"${essid}\"\n\tpsk=\"${psk}\"\n}"
				network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tpsk=\"%s\"\n}" "${info}" "${essid}" "${psk}" )
				printf "%s\n" "${network}"
				;;
			*) if [[ $((++try)) -lt 3 ]]; then
				printf "Invaid entry, please try again.\n"
			   else
				printf "After three tries, I quit. Try again later.\n"
				exit 1
			   fi
			   ;;
		esac
	done

	# Restart the network
	printf "\n%s added to /etc/wpa_supplicant/wpa_supplicant.conf\n" "$essid"
	printf "Restarting the wifi network to complete the connection.\n"

	sudo bash -c "cat << EOF >> /etc/wpa_supplicant/wpa_supplicant.conf
${network}
EOF"
	wifi_restart
}

# Func: add_wep
# Info: Add a wep connection.
# 	Enter ssid. No password needed immediately.
#	network={
#		ssid="network_name"
#		key_mgmt=NONE
#		wep_tx_keyidx=0		# this forces it to use wep_key0
#		wep_key0=YOURWEPKEY
#	}
# Instead of a passkey (psk), a wepkey is used.
# TODO: How do I get the wepkey?
add_wep(){
	#echo "coming soon!"
	#exit 1
	try=0
	read -r -p "Enter the network name:      " essid
	# read -r -p "Enter the network password:  " psk
	read -r -p "Enter where this network is: " info
	# network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tpsk=\"%s\"\n}" "${info}" "${essid}" "${psk}" )
	network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n\twep_tx-keyidx=0\n\twep_key0=YOURWEPKEY\n\t}" "${info}" "${essid}" )	# "${wepkey}"
	printf "%s\n" "${network}"
	while [ -z "${essid}" -o -z "${info}" ]; do	# -o -z "${wepkey}"
		read -r -p "Their is some information missing. Is this OK? [y/n] " ans;
		case ${ans,,} in
			y)	break ;;
			n)	try=0
				read -r -p "Enter the network name:      " essid
				# read -r -p "Enter the network password:  " psk
				read -r -p "Enter where this network is: " info
				# network="\n# ${info}\nnetwork={\n\tssid=\"${essid}\"\n\tpsk=\"${psk}\"\n}"
				# network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tpsk=\"%s\"\n}" "${info}" "${essid}" "${psk}" )
				network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n\twep_tx-keyidx=0\n\twep_key0=YOURWEPKEY\n\t}" "${info}" "${essid}" )	# "${wepkey}"
				printf "%s\n" "${network}"
				;;
			*) if [[ $((++try)) -lt 3 ]]; then
				printf "Invaid entry, please try again.\n"
			   else
				printf "After three tries, I quit. Try again later.\n"
				exit 1
			   fi
			   ;;
		esac
	done

	# Restart the network
	printf "\n%s added to /etc/wpa_supplicant/wpa_supplicant.conf\n" "$essid"
	printf "Restarting the wifi network to complete the connection.\n"
	printf "This is a WEP connection. You may need to add the WEPKEY when connected?"	# TODO: Do I?

	sudo bash -c "cat << EOF >> /etc/wpa_supplicant/wpa_supplicant.conf
${network}
EOF"
	wifi_restart
}

# Func: add_open
# Info: Those "Free Wifi Spots" you're not supposed to use anymore, because there's always one jerk in the crowd.
#	TODO: Add something to this program to give him a little taste of his medicine.  Never use the same poison twice.  Call it Agatha (as in Agatha Christie)
#	WARNING! CAVEAT EMPTOR! YOUR SAFETY IS NOT GUARANTEED!  If you use this function and get hacked, I claim no fault in that.
#	TODO: This is probably why Metasploit, Kali Linux, and Armatage might be a good idea to look into.
#	network={
#		ssid="network_name"
#		key_mgmt=NONE			# There's a special place in hell for these kind of people!
#	}
#
add_open(){
	#echo "coming soon!"
	#exit 1
	try=0
	read -r -p "Enter the network name:      " essid
	read -r -p "Enter where this network is: " info
	network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n}" "${info}" "${essid}" )
	printf "%s\n" "${network}"
	while [ -z "${essid}" -o -z "${info}" ]; do
		read -r -p "Their is some information missing. Is this OK? [y/n] " ans;
		case ${ans,,} in
			y)	break ;;
			n)	try=0
				read -r -p "Enter the network name:      " essid
				read -r -p "Enter where this network is: " info
				# network="\n# ${info}\nnetwork={\n\tssid=\"${essid}\"\n\tpsk=\"${psk}\"\n}"
				network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n}" "${info}" "${essid}" )
				printf "%s\n" "${network}"
				;;
			*) if [[ $((++try)) -lt 3 ]]; then
				printf "Invaid entry, please try again.\n"
			   else
				printf "After three tries, I quit. Try again later.\n"
				exit 1
			   fi
			   ;;
		esac
	done

	# Restart the network
	printf "\n%s added to /etc/wpa_supplicant/wpa_supplicant.conf\n" "$essid"
	printf "Restarting the wifi network to complete the connection.\n"

	sudo bash -c "cat << EOF >> /etc/wpa_supplicant/wpa_supplicant.conf
${network}
EOF"
	wifi_restart
}

# Func: agatha
# Info: Find our "special friends", take them to church, then behind the woodshed, then bury the body Jimmy Hoffa style.
#	I've been up all night adding new stuff to this script!  Can't you tell!
# 	COMING SOON!
agatha(){
	echo "Coming soon!"
	exit 1
}

# Func: add_hidden
# Info: Add a Hidden Network
# 	Just as bad as an open network but only fewer people know about.
#	Basically an open network with a encrypted name and "unscannable".  Whatever.
#	network={
#		ssid="network_name"	# It can be any encrypted type. just be sure to add "scan_ssid=1" at the end of your settings.
#		key_mgmt=NONE		# You monster.
#		scan_ssid=1		# The cheese in this unhealty happy meal.
#	}
add_hidden(){
	#echo "coming soon!"
	#exit 1
	try=0
	read -r -p "Enter the network name:      " essid
	# read -r -p "Enter the network password:  " psk
	read -r -p "Enter where this network is: " info
	network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n\tscan_ssid=1\n}" "${info}" "${essid}" )
	printf "%s\n" "${network}"
	while [ -z "${essid}" -o -z "${info}" ]; do
		read -r -p "Their is some information missing. Is this OK? [y/n] " ans;
		case ${ans,,} in
			y)	break ;;
			n)	try=0
				read -r -p "Enter the network name:      " essid
				# read -r -p "Enter the network password:  " psk
				read -r -p "Enter where this network is: " info
				# network="\n# ${info}\nnetwork={\n\tssid=\"${essid}\"\n\tpsk=\"${psk}\"\n}"
				# network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tpsk=\"%s\"\n}" "${info}" "${essid}" "${psk}" )
				network=$( printf "\n# %s\nnetwork={\n\tssid=\"%s\"\n\tkey_mgmt=NONE\n\tscan_ssid=1\n}" "${info}" "${essid}" )
				printf "%s\n" "${network}"
				;;
			*) if [[ $((++try)) -lt 3 ]]; then
				printf "Invaid entry, please try again.\n"
			   else
				printf "After three tries, I quit. Try again later.\n"
				exit 1
			   fi
			   ;;
		esac
	done

	# Restart the network
	printf "\n%s added to /etc/wpa_supplicant/wpa_supplicant.conf\n" "$essid"
	printf "Restarting the wifi network to complete the connection.\n"

	sudo bash -c "cat << EOF >> /etc/wpa_supplicant/wpa_supplicant.conf
${network}
EOF"
	wifi_restart
}

# Func: add_new_network
# Info: Interactively add a new network to /etc/wpa_supplicant/wpa_supplicant.conf
# TODO: https://www.raspberrypi.org/forums/viewtopic.php?p=797363#p797363
#	Go to the sectoion for /etc/wpa_supplicant/wpa_supplicant.conf
add_new_network(){
	cat << EOF
This operation will add a new network to /etc/wpa_supplicant/wpa_supplicant.conf.
To apply these changes you need to have adminstrator access (sudo!).
EOF

	# TODO: ask to scan first to FIND networks to add.

	# confirm that you want to add a new network
	try=0
	while read -r -p "Do you want to add a new network? [y/n]: " ans; do
		case ${ans,,} in
			y) break ;;
			n) printf "Command aborted.\n"; exit 0 ;;
			*)
				if [[ $((++try)) -lt 3 ]]; then
					 printf "Invaid entry, please try again.\n"
			 	else
					 printf "After three tries, I quit. Try again later.\n"
					 exit 1
				fi
				;;
		esac
	done

	cat << EOF
Currently the wifi script only works with networks that have a network name (essid) and a password (psk).
I also recommend adding some information about where this network is.
EOF

	try=0
	while read -r -p "What type of connection will you be using? [wpa/wpa2/wep/open/hidden/help]: " $con; do
		case ${con,,} in
			1|wpa|wpa2) 	add_wpa ;;
			2|wep)		add_wep ;;
			3|open)		add_open ;;
			4|hidden)	add_hidden ;;
			5|help)		con_help ;;
			*)		
				if [[ $((++try)) -lt 3 ]]; then
					 printf "Invaid entry, please try again.\n"
			 	else
					 printf "After three tries, I quit. Try again later.\n"
					 exit 1
				fi
				;;
		esac
	done
}

[[ $# -eq 0 ]] && usage

# TODO: Add an option to present a scan in a table. Use the Metro scraping program to use named pipes 
case $1 in
	raw)		raw_scan | less -eFMXR ;;
	list)
		check
		better_scan | less -eFMXR
		;;
	json)
		# 'list' isn't in JSON format, and it would be a P.I.T.A.
		# to make it so. So I propose running it through a different
		# command first.
		echo "Sorry, that feature isn't complete yet."
		exit 0
		# check
		# better_scan | jsonify
		;;
	scan|table|tbl)
		check
		better_scan | tablefy | less -eFMXR
		;;
	restart)	wifi_restart ;;
	start)		sudo ifup wlan0 ;;
	stop)		sudo ifdown wlan0 ;;
	status)		ifconfig wlan0 ;;
	add)		add_new_network ;;
	help)   	usage ;;
	*)		bad $1 ;;
esac
