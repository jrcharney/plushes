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
# TODO: Make changes to the WPA Suplicant file.
#	(/etc/wpa_supplicant/wpa_supplicant.conf)
#	More than likely, make it easier to add a new network to
#	the file.  Comments are permitted.
# TODO: Find out how to connect to networks that don't require
#	a password.  While it is generally a good practice to use
#	networks that hgave the ssid & psk format, not ever
#	network does this.
# TODO: Re-organize our information into a table.
#	In table format we won't be able to see the security info

usage(){
	cat << EOF
wifi.sh
----------------------------------
scan		list networks. Find a network you can connect to and add it to /etc/wpa_supplicant/wpa_supplicant.conf
restart		combo of stop and start
stop		stop wifi from running
start		start up wifi if it is not running. You may get three lines about some kind of error, but that's normal.
status		Is it connected?
help		This prompt!
EOF
	exit 1
}

bad(){
	cat << EOF
Invalid command option. Type "help" for a list of options.
EOF
	exit 1
}

# Func: raw_scan
# Info: Get our raw data
raw_scan(){
	sudo iwlist wlan0 scan
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

# TODO make an ortho2 for all the "Extra" and "IE" commands.
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
better_scan(){
	# What are we doing?
	# 1. Read the input from the previous command (raw_input)
	# 2. Pipe the data through a function to apply brackets and braces on each record (ortho)
	
	# sudo iwlist wlan0 scan \
	# raw_scan
		
	# while IFS= read line; do echo "${line}"; done | ortho | label
	raw_scan | ortho | label | ortho2 | wrapuk
}

[[ $# -eq 0 ]] && usage

nothing="wlan0     No scan results"	# This is what it looks like when we can't find anything

case $1 in
	scan)
		# if [[ $(sudo iwlist wlan0 scan) = "wlan0     No scan results" ]]; then
		if [[ $(raw_scan) = "${nothing}" ]]; then
			raw_scan
			exit 0
		fi
		# printf "ESSID (Address)"
		# raw_scan | better_scan | less -eFMXR		# This works, I just wanted to put the raw_scan into a better place
		better_scan | less -eFMXR
		;;
	restart)
		sudo ifdown wlan0 && sudo ifup wlan0
		;;
	start)
		sudo ifup wlan0
		;;
	stop)
		sudo ifdown wlan0
		;;
	status)
		ifconfig wlan0
		;;
	help)   
		usage
		;;
	*)
		bad
		;;
esac
