#!/bin/bash

#COLORS TO TEXT MESSAGES
RED='\033[0;31m'
DARKGRAY='\033[1;30m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# USE: printf "text whitout color ${RED}text with color${NC} text whitout color"

#CTRl+C Capture to exit
trap ctrl_c INT
function ctrl_c() {
    exit 1
}

#HELP INFO
function help_ {
    printf "\n${RED}USE:${NC}\n"
    printf "\t${DARKGRAY}init_polymer.sh ${BLUE}PROYECT_OR_ELEMENT_NAME${NC}\n"
}

#SHOW ERROR MESSAGES
function showError {
    printf >&2 "${YELLOW}\t$1 is required but it's not installed. Aborting.${NC}\n\n";
    if [[ $1 = "meteor" ]]
    then
        printf "${GREEN}You can install $1 with:\n\n\t${BLUE}curl https://install.meteor.com/ | sh${NC}\n"
    elif [[ $1 = "git" ]]
    then
        printf "${GREEN}You can install $1 with:\n\n\t${BLUE}npm install git -g${NC}\n"
    fi
    exit 1
}

#CHECK IF MANDATORY COMMANDS EXISTS
function checkExists {
    command -v $1 >/dev/null 2>&1 || { showError $1; }
}

if [[ "$1" = "--help" || "$1" = "-h" ]]
then
    help_
elif [[ -z $1 ]]
then
    help_
else
   printf "\n${BLUE}CREATING POLYMER PROYECT...${NC}\n"
   checkExists bower
   checkExists git
   mkdir -p $1 2>&1 || { printf >&2 "\t${YELLOW}ERROR: creating $1 dir${NC}\n"; exit 1; }
   cd $1
   bower init 2>&1 || { printf >&2 "\t${YELLOW}ERROR: bower init${NC}\n"; exit 1; }
   bower install --save Polymer/polymer#^1.8.0 2>&1 || { printf >&2 "\t${YELLOW}ERROR: bower init${NC}\n"; exit 1; }

   echo '<dom-module id="'$1'">
  <template>
    <style>
      :host {
        display: block;
      }
    </style>
    
  </template>
  <script>
    Polymer({
      is: "'$1'"
    });
  </script>
</dom-module>
' > $1.html

fi
