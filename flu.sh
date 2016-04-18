#!/bin/bash
# TODO: find more filters
# gem install lolcat
# ./flush UNICORNS

# fonts are in usr/share/figlet
# filters are gay (rainbow) and metal. try `--filter list`.

# toilet -w $(tput cols) -F gay -f bigmono12 $1
toilet -w $(tput cols) -f bigmono9 $1 | lolcat
