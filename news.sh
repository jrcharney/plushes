#!/bin/bash
# File: news.sh
# Info: All the news that fits to TERMINAL (powered by Reuters).
# TODO: Time stamps need to be put into a sortable format.

site="http://feeds.reuters.com/reuters"
#category="topNews"
cols=$(tput cols)

usage(){
cat << EOF
news.sh - News on the command line (powered by Reuters)

-c            view a list of channels.
-c <channel>  view a channel. If not used, 'topNews' is used.
              This will only show the headline unless -d or -l
              are used.

-n N          show the Nth most recent article in that channel. 
              (More than likely limited to 10) Default is 5.

-d            view the descriptions (work in progress)

-l            view the link to the story. (work in progress)
              (Ideal if you are using a virtual terminal on another computer)

-h            Help. You're looking at it.

EOF
}

IFS='' read -r -d '' chs <<"EOF"
# Channels
topNews           # Top News (Latest Headlines, default)
domesticNews      # US News
worldNews         # World News
MostRead          # Most Read Articles
artsculture       # Arts
businessNews      # Business News
companyNews       # Company News
entertainment     # Entertainment News
environment       # Environmental News
healthNews        # Health News
lifestyle         # Lifestyle News
wealth            # Money
oddlyEnoughNews   # Oddly Enough (strange news)
ReutersPictures   # Pictures (Not available)
peopleNews        # People
PoliticsNews      # Politics
scienceNews       # Science
sportsNews        # Sports
technologyNews    # Technology

# Video (Not that it would do us any good in a text terminal)
USVideoBreakingviews    # Breaking Views (breaking news video)
USVideoBusiness         # Business Video
USVideoBusinessTravel   # Business Travel Video
USVideoChrystiaFreeland # Chrystia Freeland Video (who?)
USVideoEntertainment    # Entertainment Video (at least it's not TMZ)
USVideoEnvironment      # Environment Video
USVideoFelixSalmon      # Felix Salmon Video (who?)
USVideoGigaom           # GigaOm Video (tech news, I think.)
USVideoLifestyle        # Lifestyle Video (sorry, you'll have to add your own Robin Leach voice over)
USVideoMostWatched      # Most Watched Video (popular video)
USVideoLatest           # Most Recent Video (new video)
USVideoNewsmakers       # Newsmakers (what's that?)
USVideoOddlyEnough      # Oddly Enough Video (strange news now in video format)
USVideoPersonalFinance  # Personal Finance
USVideoPolitics         # Politics (why read about the downfall of western civilization when you can watch it)
USVideoRoughCuts        # Rough Cuts (what's this about?)
USVideoSmallBusiness    # Small Business (a.k.a. rich people)
USVideoTechnology       # Technology
USVideoTopNews          # Top News
USVideoWorldNews        # World News
EOF

  # echo ${array[@]}
  #for item in "${array[@]}"; do
  #  echo "${item}"
  #done

  # Print out any lines, but remove empty lines, lines that start with comments and strip out any comments
  # And since video is of no use to us here, let's remove the video channels
  #echo "${chs}" | sed -n -e '/^$/d;/^#.*/d;s/^\([^ \t]*\)[ \t]*#.*/\1/g;p' | sed -n -e '/^USVideo.*/d;p'

channels(){
  if [[ "$1" ]]; then
    channel_search "$1"
  else
    # With comments
    echo "${chs}" \
      | sed -n -e '/^$/d;p' \
      | sed -n -e '/^# Video.*/,$d;p' \
      | sed -e '2iall               # All the news! (not really a feed, but a command)'
      # that last command doesn't have a -n because -n would not output anything.
  fi
}

channels_no_desc(){
  [[ "$1" ]] && channel_search_no_desc "$1" || channel_list
}

channel_list(){
  # Without comments
  channels | sed -n -e '/^#.*/d;p' | sed -n -e 's/^\([a-zA-Z0-9]*\)\s\+# .*$/\1/;p'
}

channel_array(){
  # This line is typically how arrays are done.
  IFS=$'\n' declare -a cha=($(channel_list))
  # Display as an array. Honestly, we don't have to.
  local i=0; for ch in "${cha[@]}"; do printf "%d\t%s\n" $((i++)) "$ch"; done
}

getAllNews(){
  # all the news will be sorted by time stamp. Organize afterword.
  IFS=$'\n' declare -a cha=($(channel_list))
  for hc in "${cha[@]}"; do
    [[ "$hc" == "all" ]] && continue   # skip this entry
    [[ "$hc" == "companyNews" ]] && continue  # TODO: companyNews is current broken
    getNews "${hc}" | organize_no_desc 
  done | sort -t $'\t' -k2 | fold -w $cols -s   # -w set the width to the terminal width. -s break at spaces only
}

channel_search(){
  # find a channel
  IFS=$'\n' declare -a cha=($(channel_list))
  local q="$1"
  for ch in "${cha[@]}"; do
    if [[ "${q}" == "${ch}" ]]; then
      if [[ "${q}" == "all" ]]; then
        getAllNews
      else
        if [[ "${q}" == "companyNews" ]]; then echo "Sorry, ${q} is currently out of service."; exit 0; fi
        getNews "${q}" | organize | fold -w $cols -s   # -w set the width to the terminal width. -s break at spaces only
      fi
      exit 0
    fi
  done
  echo "Sorry, we don't have a ${q} channel. To see a list of channels available, use -c without ${q}" >&2;
  exit 1
}

channel_search_no_desc(){
  declare -a cha
  IFS=$'\n' cha=($(channel_list))
  local q="$1"
  for ch in "${cha[@]}"; do
    if [[ "${q}" == "${ch}" ]]; then
      if [[ "${q}" == "all" ]]; then
        # all the news will be sorted by time stamp. Organize afterword.
        getAllNews
      else
        if [[ "${q}" == "companyNews" ]]; then echo "Sorry, ${q} is currently out of service."; exit 0; fi
        getNews "${q}" | organize_no_desc | fold -w $cols -s   # -w set the width to the terminal width. -s break at spaces only
      fi
      exit 0
    fi
  done
  echo "Sorry, we don't have a ${q} channel. To see a list of channels available, use -c without ${q}" >&2;
  exit 1
}

getNews(){
  local category="$1"
  curl -sL "${site}/${category}" \
    | tr -d '\r' \
    | sed -n -e '/^<atom10:link/s/\(.*\)\(<item>\)/\1\n\2/g;p' \
    | sed -n -e '1,/^<language>/d;/^<copyright>/,/^<atom10:link/d;p' \
    | sed -n -e '/<description>/,/<\/description>/{s/&lt;/</g;s/&gt;/>/g;};p' \
    | sed -n -e '/<description>/,/<\/description>/{s/^\(.*\)<div class="feedflare">$/\1/g;s/^.*\(<\/description>\)$/\1/g;/^<a href/d;};p' \
    | sed -n -e '/<description>/{N;s/\n//;};p' \
    | sed -n -e 's/\(<\/item>\)/\n\1/g;p' \
    | sed -n -e 's/\(<feedburner:orgLink>\)/\n\1/g;p' \
    | sed -n -e '/^\s*$/d;p' \
    | sed -n -e '/<guid isPermaLink/d;/<feedburner:origLink>/d;/^<\/channel>/d;/<\/rss>/d;p' \
    | sed -n -e 's/^\s\+\(.\+\)$/\t\1/g;p'
    #| sed -n -e '/^\s*<description>/{n;:l N;/<\/description>/b; s/\n//; bl};p'   # companyNews is broken. This is supposed to fix it?
}

get_build_date(){
  local data="$(</dev/stdin)"
  local ts=$( cat <<< ${data} \
    | sed -n -e '/^<lastBuildDate>/p' \
    | sed -n -e 's/<lastBuildDate>\(.*\)<\/lastBuildDate>/\1/g;p')
  ts=$(date -d "${ts}")
  printf "Last updated: %s\n" "$ts"
}

get_date(){
  local data="$(</dev/stdin)"
  while IFS= read -r line; do
    local ts=$( echo "${line}" | sed -n -e 's/.*<pubDate>\(.*\)<\/pubDate>.*/\1/g;p')
    date -d "${ts}" | awk '{printf("\033[1;36m%s\033[0m\n",$0);}'
  done <<< "${data}"
}

get_category(){
  local data="$(</dev/stdin)"
  while IFS= read -r line; do
    echo "${line}" \
    | sed -n -e 's/.*<category>\(.*\)<\/category>.*/\1/g;p' \
    | awk '{printf("\033[1;32m%s\033[0m\n",$0);}'
  done <<< "${data}"
}

get_headline(){
  local data="$(</dev/stdin)"
  #echo "Story"
  while IFS= read -r line; do
    echo "${line}" \
    | sed -n -e 's/.*<title>\(.*\)<\/title>.*/\1/g;p' \
    | awk '{printf("\033[1;33m%s\033[0m\n",$0);}'
  done <<< "${data}"
}

get_description(){
  local data="$(</dev/stdin)"
  while IFS= read -r line; do
    echo "${line}" | sed -n -e 's/.*<description>\(.*\)<\/description>.*/\1/g;p'
  done <<< "${data}"
}

get_link(){
  local data="$(</dev/stdin)"
  while IFS= read -r line; do
    echo "${line}" | sed -n -e 's/.*<link>\(.*\)<\/link>.*/\1/g;p'
  done <<< "${data}"
}

# TODO: duplicate this code block such that we have a version with descriptions and without.
get_content(){
  mkfifo categoryp datep headlinep descp #linkp
  trap "rm -f categoryp datep headlinep descp" EXIT HUP QUIT INT KILL TERM
  local data="$(</dev/stdin)"
  #printf "Category\tPosted\t\t\tStory\n"   # header (Could I move these to each function?)
  # TODO: replace &amp; with &
  cat <<< ${data} \
    | while IFS= read -r line; do echo "${line}"; done \
    | sed -n -e '/^<item>/p' \
    | tee \
        >(get_category > categoryp) \
        >(get_date > datep) \
        >(get_headline > headlinep) \
        >(get_description > descp) \
        > /dev/null \
    | paste -d '\t' categoryp datep headlinep descp \
    | awk 'BEGIN{ FS="\t";}
{
  printf("%s\t%s\t%s\n%s\n",$1,$2,$3,$4);
}'
  rm -f categoryp datep headlinep descp
}

get_content_no_desc(){
  mkfifo categoryp datep headlinep
  trap "rm -f categoryp datep headlinep" EXIT HUP QUIT INT KILL TERM
  local data="$(</dev/stdin)"
  #printf "Category\tPosted\t\t\tStory\n"   # header (Could I move these to each function?)
  cat <<< ${data} \
    | while IFS= read -r line; do echo "${line}"; done \
    | sed -n -e '/^<item>/p' \
    | tee \
        >(get_category > categoryp) \
        >(get_date > datep) \
        >(get_headline > headlinep) \
        > /dev/null \
    | paste -d '\t' categoryp datep headlinep \
    | awk 'BEGIN{ FS="\t";}
{
  printf("%s\t%s\t%s\n%s\n",$1,$2,$3,$4);
}'  
  rm -f categoryp datep headlinep
}

organize(){
  # | sed -n -e '/^\s*<description>/{:a;$!N;/<\/description>/b; s/\n//; ba};p' \
  mkfifo updatep newsp  # descriptionp #linkp
  trap "rm -f updatep newsp" EXIT HUP QUIT INT KILL TERM
  
  local data="$(</dev/stdin)"
  cat <<< ${data} \
    | sed -n -e '{:a;$!N;s/\n\t//;ta;P;D;};p' \
    | sed -n -e '{:a;$!N;s/\n\(<\/item>\)/\1/;ta;P;D;};p' \
    | while IFS= read -r line; do echo "${line}"; done \
    | tee \
      >(get_build_date > updatep) \
      >(get_content    > newsp) \
      >/dev/null \
    | paste -d '\n' updatep newsp \
    | sed -n -e '/^$/d;p'
  
  rm -f updatep newsp
    #| sed -n -e '1iPosted\tCategory\Story\n'   # Prepend this line later

  # These two commands need to bet separate. These two patterns put item blocks on a single line 
  #| sed -n -e '{:a;$!N;s/\n\t//;ta;P;D;};p' \            # join with the previous line if this line starts with \t, replace the \t with nothing
  #| sed -n -e '{:a;$!N;s/\n\(<\/item>\)/\1/;ta;P;D;};p'  # join with the previous line if this line starts with </item> and appended to the end of the line

  #while IFS= read -r line; do
  #  echo $line 
  #done <<< "${data}"
}

organize_no_desc(){
  mkfifo updatep newsp  # descriptionp #linkp
  trap "rm -f updatep newsp" EXIT HUP QUIT INT KILL TERM
  
  local data="$(</dev/stdin)"
  cat <<< ${data} \
    | sed -n -e '{:a;$!N;s/\n\t//;ta;P;D;};p' \
    | sed -n -e '{:a;$!N;s/\n\(<\/item>\)/\1/;ta;P;D;};p' \
    | while IFS= read -r line; do echo "${line}"; done \
    | tee \
      >(get_build_date > updatep) \
      >(get_content_no_desc > newsp) \
      >/dev/null \
    | paste -d '\n' updatep newsp \
    | sed -n -e '/^$/d;p'
  
  rm -f updatep newsp
    #| sed -n -e '1iPosted\tCategory\Story\n'   # Prepend this line later

  # These two commands need to bet separate. These two patterns put item blocks on a single line 
  #| sed -n -e '{:a;$!N;s/\n\t//;ta;P;D;};p' \            # join with the previous line if this line starts with \t, replace the \t with nothing
  #| sed -n -e '{:a;$!N;s/\n\(<\/item>\)/\1/;ta;P;D;};p'  # join with the previous line if this line starts with </item> and appended to the end of the line

  #while IFS= read -r line; do
  #  echo $line 
  #done <<< "${data}"
}

    
# TODO: Format lastbuild update (first line)
#getNews | fold -w $cols -s   # -w set the width to the terminal width. -s break at spaces only
# getNews | organize | fold -w $cols -s   # -w set the width to the terminal width. -s break at spaces only

# lastBuildDate = last time updated?

# <item>
#   <title>       = headline  -> Story (3)
#   <description> = brief description of the story, totally keeping this  -> [put this on the next line; follow headline in ticker mode; omit in page mode) (4)
#   <link>        = link to the new story (we can drop this since we can't tuck it away like HTML)  -> omitted or put on the next line after description (5)
#   <category> = the news category (I don't think we need this if we are pulling up one channel -> Category (2)
#   <pubDate> = when the story was posted (needs timestamp conversion)  -> Posted (1)
# </item>

if [[ $# == 0 ]]; then
  # TODO: Check internet connectivity
  getNews "topNews" | organize | fold -w $cols -s   # -w set the width to the terminal width. -s break at spaces only
  exit 0;
fi

case $1 in
  -a) channel_array ;;
  -c) shift; [[ "$1" ]] && channels "$1" || channels ;;             # Typical mode. (Show descriptions with headlines except for all headlines)
  -d) shift; [[ "$1" ]] && channels_no_desc "$1" || channel_list ;; # Terse mode. (Show only the headlines)
  #-l) shift; [[ "$1" ]] && channels_link_only "$1" || channel_list ;;
  -r) shift; [[ "$1" ]] && getNews "$1" || getNews "topNews" fi ;;  # Raw mode. (Just uses getNews. Typically used for debugging) 
  -h) usage ;;
  #-v) shift; [[ "$1" ]] && channels_no_desc "$1" || channel_list ;;  # Verbose mode
  *) echo "Invalid arguments detected." >&2; exit 1 ;;
esac

## Parse flag options (and their arguments)
#while getopts c:h: OPT; do
#  case "$opt" in
#    c) channels ;;
#    h) usage ;;
#    *) echo "Invalid arguments detected." >&2; exit 1 ;;
#  esac
#done
#
#shift $(($OPTIND-1))   # get rid of the just-finished flag arguments

