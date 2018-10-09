#!/bin/bash
# File: zippy.sh
# Info: A tool for finding zip codes for a specific address.

prefs=~/.zippyrc    # Store your Web Tools API User ID and Password.

if [ ! -f "${prefs}" ]; then
  cat << EOF 
It looks like this may be your first time running zippy.
I can get you started by creating a $prefs file to store that information.
You need to get a User ID and Passwrod from the United States Post Office's 
Web Tools API. You can get it for free at
https://www.usps.com/business/web-tools-apis/welcome.htm
If you have that information we can get started.

EOF
  
  try=0 
  while : ; do 
    read -r -p "Would you like to create $prefs? [y/n]: " ans;
    case ${ans,,} in
    y) break ;;
    n)
      echo "OK, but you won't be able to use this program until then."
      exit 0
      break 
      ;;
    *) 
      if [[ $((++try)) -lt 3 ]]; then 
        printf "Invalid entry, please try again.\n"
      else 
        printf "After three tries, I quit! Try again later.\n"
        exit 1
      fi
    esac
  done
  
  echo "OK! Let's get started!"
  echo

  try=0
  while : ; do
    while : ; do      # same as "while true; do"
      read -r -p "Enter your Web Tools API User ID:  " uid  
      read -r -p "Enter your Web Tools API Password: " pw
      echo

      if [ -z "${uid}" -o -z "${pw}" ]; then    # We can't do double brackets here.
        echo "It looks like some information is missing."
        [[ -z "${uid}" ]] && echo "I need your Web Tools API User ID."
        [[ -z "${pw}" ]] && echo "I need your Web Tools API Password." #Not really, but it is best to keep them together.
        if [[ $((++try)) -lt 3 ]]; then
          printf "Please enter the required information and try again.\n"
        else
          printf "After three tries, I quit! Try again later.\n"
          exit 1
        fi
      else 
        break
      fi
    done

    echo "User ID:  ${uid}"
    echo "Password: ${pw}"
    echo

    try=0 
    canbreak=0
    while : ; do 
      read -r -p "Is this correct? [y/n]: " ans;
      case ${ans,,} in
        y) canbreak=1; break ;;
        n) canbreak=0; break ;;
        *) 
          if [[ $((++try)) -lt 3 ]]; then 
            printf "Invalid entry, please try again.\n"
          else 
            printf "After three tries, I quit! Try again later.\n"
            exit 1
          fi
      esac
    done
    [[ "$canbreak" -ne 1 ]] || break # This should end our do-while
  done            # end of do-while

  cat << EOF > $prefs
uid="${uid}"
pw="${pw}"
EOF

  if [ -f "$prefs" ]; then
    echo "Awesome! You can now use zippy to look up zip codes."
    exit 0
  else
    echo "Hmm...something didn't work right."
    echo "Let me know in the Github Issues."
    exit 1
  fi
fi

source $prefs

if [ -z "${uid}" ]; then
  # NOTE: if you quote your EOF, you don't need to backslash escape characters.
  cat <<'EOF'
Sorry, this program will not work unless you edit it and add a User ID to the $uid variable.
You can get a User ID by signing up for the United States Post Office's Web Tools API at
https://www.usps.com/business/web-tools-apis/welcome.htm
EOF
  exit 1
fi

usage(){
  cat <<EOF
zippy.sh 

You will be asked to enter an address to find a zip code.
Note: I have not set this up for Puerto Rico or military locations.

There are arguments you can use.

"123 Address St, [Apt 4,] City Name, ST"    COMMA-SEPARATED address.
  Do not use brackets around the possible apartment.
  This will definitely work better if everything is enclosed in quotes,
  such that bash can split the string into an array.
help      THIS PROMPT.
EOF
  exit 0
}

spacer(){
  cat <<EOF
BUGFIX: This function exists so that the heredoc in fetchzip works.
EOF
}

fetchzip(){
xml=$(cat <<EOF
<ZipCodeLookupRequest USERID="${uid}">
<Address ID="1">
<Address1>${address2}</Address1>
<Address2>${address1}</Address2>
<City>${city}</City>
<State>${state}</State>
<Zip5></Zip5>
<Zip4></Zip4>
</Address>
</ZipCodeLookupRequest>
EOF
)

  # TODO: Substitue for apostrophes, hyphens, and ampersands...and octothorpes.
  # apostrophes have to be escaped
  # hyphens do not
  #
  # Subtitutes spaces with HTML spaces
  xml=$(echo "$xml" \
    | sed -n -e 's/ /%20/g;p' \
    | sed -n -e ':a;N;$!ba;s/\n//g;p'
  )

  # -s to remove the progress information
  # -w '\n' to remove that trailing % at the end of a curl
  # NOTE: I tried curl -s -o /dev/null -I -w "%{http_code}" 'http://testing.blah.blah.blah' and still got a 200 code. So we need to read the response
  res=$(curl -s -w '\n' 'http://testing.shippingapis.com/ShippingAPITest.dll?API=ZipCodeLookup&XML='$xml | sed -n -e '2p')

  #echo "$res"

  if [[ "$res" =~ ^\<ZipCodeLookupResponse\>* ]]; then 
    if [[ "$res" =~ \<Error\> ]]; then
      err=$(echo "ERROR! $res" | sed -n -e 's/.*<Description>\(.*\) *<\/Description>.*/\1/g;p')
      if [[ "$err" = "Address Not Found." ]]; then
        echo "ANF"    # Report that the address was not found.
      else
        echo "ERR"    # Some other Error. Rather than leave it blank, investigate what went wrong.
      fi
    else
      echo "$res" \
        | sed -n -e 's/.*<Zip5>\([0-9]\+\)<\/Zip5><Zip4>\([0-9]\+\)<\/Zip4>.*/\1-\2/g;p' \
        | sed -n -e '/<Zip4\/>/s:.*<Zip5>\([0-9]\+\)</Zip5><Zip4/>.*:\1:g;p'
        # This should happen. (That second line was added because some addresses don't have zip4s!
      #echo "$res" | sed -n -e 's/.*<Zip5>\([0-9]\+\)<\/Zip5>.*/\1/g;p'    # Do this if you just want the five digits instead of the five+four
    fi
  else
    echo "ERROR! $res"    # Generally this happens because of an authentication error. This shouldn't happen. If it does, you need to get your username and password set up.
  fi

  # If the Authorization Missing, it responds with this
  # <Error><Number>80040B19</Number><Description>XML Syntax Error: Please check the XML request to see if it can be parsed.</Description><Source>USPSCOM::DoAuth</Source></Error>
  # If it is a bad address, it reponse with this
  # <ZipCodeLookupResponse><Address ID="1"><Error><Number>-2147219401</Number><Source>clsAMS</Source><Description>Address Not Found.  </Description><HelpFile/><HelpContext/></Error></Address></ZipCodeLookupResponse>
  # <ZipCodeLookupResponse><Address ID="1"><Address2>911 WASHINGTON AV</Address2><City>SAINT LOUIS</City><State>MO</State><Zip5>63101</Zip5><Zip4>1243</Zip4></Address></ZipCodeLookupResponse>
  # So we can apply this sed filter
  #  | sed -n -e '2{s/.*<Zip5>\([0-9]\+\)<\/Zip5><Zip4>\([0-9]\+\)<\/Zip4>.*/\1-\2/g;p}'
}

getzip(){
  # local address="$@"    # Ask for several things first
  # This next code block is how bash does do-while loops
  try=0
  while : ; do
    while : ; do      # same as "while true; do"
      read -r -p "Enter the street address: " address1 
      read -r -p "Enter the apartment number. If there is none, press enter.: " address2
      read -r -p "Enter the city: " city 
      read -r -p "Enter the two letter state: " state
      echo

      if [ -z "${address1}" -o -z "${city}" -o -z "${state}" ]; then    # We can't do double brackets here. We'll have to settle for single brackets to avoid error. 
        echo "It looks like some information is missing."
        [[ -z "${address1}" ]] && echo "I need a street address."
        [[ -z "${city}" ]] && echo "I need a city."
        [[ -z "${state}" ]] && echo "I need a state."
        if [[ $((++try)) -lt 3 ]]; then
          printf "Please enter the required information and try again.\n"
        else
          printf "After three tries, I quit! Try again later.\n"
          exit 1
        fi
      else 
        break
      fi
    done

    echo "Address1: ${address1}"
    [[ ! -z "${address2}" ]] && echo "Address2: ${address2}"
    echo "City:     ${city}"
    echo "State:    ${state}"
    echo
    
    try=0 
    canbreak=0
    while : ; do 
      read -r -p "Is this correct? [y/n]: " ans;
      case ${ans,,} in
        y) canbreak=1; break ;;
        n) canbreak=0; break ;;
        *) 
          if [[ $((++try)) -lt 3 ]]; then 
            printf "Invalid entry, please try again.\n"
          else 
            printf "After three tries, I quit! Try again later.\n"
            exit 1
          fi
      esac
    done
    #echo "canbreak: $canbreak"
    [[ "$canbreak" -ne 1 ]] || break # This should end our do-while
  done            # end of do-while
  # fetchzip
}

# Note: I use `$@` not `"$@"` because I want to remove any extra spaces between my arguments.
# See https://stackoverflow.com/questions/37141039/is-there-any-difference-between-and 

getzipbyaddr(){
  IFS=',' read -ra arr <<< "$@"
  for (( i=0 ; i < ${#arr[@]}; i++ )); do 
    arr[$i]=$(
      echo "${arr[$i]}" \
      | sed -n -e 's/^[[:space:]]*//g;p' \
      | sed -n -e 's/[[:space:]]*$//g;p' 
      )
      # Remove leading and trailing spaces.
  done

  case ${#arr[@]} in 
    3)    # does not have an apartment/suite number
      address1="${arr[0]}"
      city="${arr[1]}"
      state="${arr[2]}"
      ;;
    4)    # has an apartment/suite number
      address1="${arr[0]}"
      address2="${arr[1]}"
      city="${arr[3]}"
      state="${arr[4]}"
      ;;
    *)    # Should not be here!
      echo "Sorry, this is not a valid address."
      echo "Remember: '{address1}, [{address2},] {city}, {state}'"
      ;;
  esac
  #fetchzip
  
  # Uncomment this to see what you entered, don't do this if you are into bulk data.
  #echo "Address1: ${address1}"
  #[[ ! -z "${address2}" ]] && echo "Address2: ${address2}"
  #echo "City:     ${city}"
  #echo "State:    ${state}" 
}

case $# in
  0) getzip ;;
  1)
    case ${1,,} in
      help ) usage ; exit 0;;
      *) 
        # TODO: What if an address is quoted?
        echo "Invalid entry. Type 'help' for usage."; 
        echo "Did you put your address in quotes? If so, try unquoting it."
        exit 1 
        ;;
    esac
    ;;
  #2) TODO: read a file full of addresses.
  #3) TODO: read a file and write it to another file.
  *) getzipbyaddr $@ ;; # TODO: should I quote $@?
esac

fetchzip 
