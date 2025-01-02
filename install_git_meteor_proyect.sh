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
    printf "\t${DARKGRAY}create_meteor_git_proyect.sh ${BLUE}PROYECT_NAME${NC} ${GREEN}GIT_ORIGIN_URL${NC}\n"
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
elif [[ -z $1 || -z $2 ]] 
then
    help_
else
    printf "\n${BLUE}CREATING meteor $1 PROYECT...${NC}\n"
    checkExists meteor
    if [ -e $1 ]
    then
        printf "\n${YELLOW}$1 PROYECT EXISTS YET. Aborting installation${NC}\n"
        exit 1
    else
        meteor create $1 2>&1 || { printf >&2 "\t${YELLOW}Error creating meteor proyect${NC}\n"; exit 1; }
        cd $1 && rm -rf client .gitignore package.json server
    fi
    
    printf "\n${BLUE}GET PROYECT FROM GIT REPOSITORY...${NC}\n"
    checkExists git
    git init 2>&1 || { printf >&2 "\t${YELLOW}ERROR: git init${NC}\n"; exit 1; }
    git remote add origin $2 2>&1 || { printf >&2 "\t${YELLOW}ERROR git add origin${NC}\n"; exit 1; }
    git fetch 2>&1 || { printf >&2 "\t${YELLOW}ERROR git fetch${NC}\n"; exit 1; }
    git checkout -t origin/master 2>&1 || { printf >&2 "\t${YELLOW}ERROR git checkout${NC}\n"; exit 1; }
    
    if [ -e meteor.packages ]
    then
        printf "\n${BLUE}INSTALLING PROYECT METEOR PACKAGES...${NC}\n"
        meteor add `< meteor.packages`
    else
        printf "\n${BLUE}THERE IS NOT meteor.packages FILE TO INSTALL${NC}\n"
    fi

    if [ ! -e package.json]
    then
        printf "package.json doesn't exists. Do you want create it? [Y/n]"
        read RESPONSE_PACKAGEJSON
        if [[ "$REPONSE_PACKAGEJSON" = "" || "$REPONSE_PACKAGEJSON" = "Y"] || "$RESPONSE_PACKAGEJSON" = "y" ]]
        then
            echo '{
  "name": "$1",
  "private": true,
  "scripts": {
    "start": "meteor run"
  },
  "dependencies": {
    "babel-runtime": "^6.23.0",
    "meteor-node-stubs": "~0.2.0"
  }
}' > package.json
        fi
    else
        printf "${BLUE}\nINSTALLING NPM PACKAGES...${NC}\n"
        meteor npm install
    fi

    printf "\n${BLUE}REMOVING PROYECT METEOR INSECURE PACKAGES...${NC}\n"
    meteor remove autopublish insecure

    printf "\n${BLUE}FINISHED INSTALLATION${NC}\n"
    printf "\n\n\t${GREEN}TO START TYPE: cd $1 && meteor npm start${NC}\n"
fi
