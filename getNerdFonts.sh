#!/bin/bash
# File: getNerdFonts.sh
# Info: Fetch the Nerdfonts binaries from Nerdfonts.com
# Status: Beta (I haven't checked on this lately, but it should work.)
# TODO: Remember to use install.sh settings for more glyphs?
# TODO: Remember to change the resolution/terminal settings in the raw terminal. (Video on youtube?)

site="https://www.nerdfonts.com"
output=~/Downloads/NerdFonts  # Change this directory to something else if you want. I recommend here since it is just where the zip files go.
errlog=${output}/errors.log

[[ ! -d ${output} ]] && mkdir -p ${output}    # create the output directory if it doesn't exist
[[ -f ${errlog} ]] && rm ${errlog}            # delete the error log if it does exist

getFontList(){
  curl -sL "${site}" \
    | sed -n -e '/<h1>Downloads<\/h1>/,/<div id="cheat-sheet" class="section p-cheat-sheet">/p' \
    | sed -n -e '/.*<li>.*<\/li>/p' \
    | sed -n -e 's/.*<li><a href="\(.*\)">.*<\/a><\/li>/\1/g;p'
}

# getFontList | less -eFMXR

echo "Please wait a few seconds for me to fetch the list of fonts from NerdFonts.com..."

files="$(getFontList)"                      # get the list of files
file_ct=$( cat <<< "${files}" | wc -l )     # count how many files there should be

if [[ $file_ct -gt 0 ]]; then
  printf "\033[1;32mReady!\033[0m Found \033[1;33m%d\033[0m files to download.\n" ${file_ct}
else
  printf "\t\033[1;31mERROR\033[0m: %s failed! Aborting.\n" "${site}" | tee -a ${errlog}
  exit 1 
fi

fct=0   # file count
ect=0   # error count
while read -r line; do
  zipfile=${output}/${line##*/}             # Define where zipfile will go
  printf "\033[1;33m%02d/%02d\033[0m\t%s -> %s\n" $((++fct)) ${file_ct} "${line}" "${zipfile}"
  curl -# -L "${line}" -o "${zipfile}"      # download the file
  if [[ -f "${zipfile}" ]]; then
    printf "\t%s Downloaded\n" "${zipfile}"
    filedir=${zipfile%.zip}
    printf "\t%s -> %s\n" "${zipfile}" "${filedir}"
    unzip "${zipfile}" -d "${filedir}"        # extract to a directory
    if [[ -d "${filedir}" ]]; then
      printf "\t%s Extracted\n" "${filedir}"
      rm "${zipfile}"                           # delete the zip file
      printf "\t%s Deleted\n" "${zipfile}"
    else
      printf "\t\033[1;31mERROR\033[0m: %s didn't extract to %s!\n" "${zipfile}" "${filedir}" | tee -a ${errlog}
      ((ect++))
      # TODO: tee to an error log
    fi
  else
    printf "\t\033[1;31mERROR\033[0m: %s didn't download!\n" "${zipfile}" | tee -a ${errlog}
    ((ect++))
    # TODO: tee to an error log
  fi
done <<< "${files}"
#echo "Done!"
# TODO: Count the number of directories created. If it is less than the file count, tee to an error log
dir_ct=$( ls -l ${output} | grep -c '^d' )
if [[ $dir_ct -lt $file_ct ]]; then
  printf "\033[1;31mERROR\033[0m: some files didn't download! (%02d/%02d)\n" $dir_ct $file_ct | tee -a ${errlog} 
  ((ect++))
  # TODO: tee to an error log
else
  printf "\033[1;32mSUCCESS!\033[0m All files accounted for! (%02d/%02d)\n" $dir_ct $file_ct
fi
# TODO: Report if there were errors (error count!)
if [[ $ect -gt 0 ]]; then
  printf "\033[1;31mERROR\033[0m: There were %d errors. They should be logged in %s\n" ${errlog} | tee -a ${errlog}
  cat ${errlog} | sed -n -e 's/^\t\(.*\)/\1/g;p' > ${errlog}  # remove the leading tabs
fi
echo "DONE!"
cat << EOF
"So what do I do now?"
You should move the folders that succeded in downloading and extraction to one of your fonts directories.

Ryan L. McIntyre (a.k.a. ryanoasis) does have a few suggestions. But they need some improvements.

For instance when he mentions the "font directory" he's talking about putting the fonts into a
user-specific font directory located at ~/.local/share/fonts, which only installs the font for
one user.

System-wide fonts are either stored in /usr/share/fonts (especially if they were installed with apt)
or /usr/local/share/fonts (user installed). We want to put our new fonts in /usr/local/share/fonts.
EOF
