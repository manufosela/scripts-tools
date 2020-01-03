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
    printf "\t${DARKGRAY}create_firebase_polymer_app.sh\n"
    exit 1
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
fi

# QUESTIONS
printf "\n${GREEN}Nombre del proyecto?${NC} "
read MYAPPNAME
printf "\n${GREEN}Número de vistas?${GREEN} "
read NUMVIEW
printf "\n${BLUE}Se necesita node, bower, git, polymer-cli y firebase-tools.\n${NC}"
printf "\n${GREEN}Comenzamos la instalación? [Y/n] "
read RESPONSE
if [[ $RESPONSE -ne 'Y' && $RESPONSE -ne 'y' && $RESPONSE -ne '' ]]
then
    exit 1
fi

# CHECK NODE, BOWER, POLYMER-CLI, FIREBASE-CLI
checkExists node
checkExists bower
checkExists git
checkExists polymer
checkExists firebase

# CREATE PROYECT PATH
[[ -d $MYAPPNAME ]] || mkdir $MYAPPNAME
cd $MYAPPNAME

# INSTALL POLYMER INIT APP-DRAWER
printf "\n${BLUE}Installing firebase hosting.\n\t${RED}1 - Select 'Hosting' option\n\t2 - Select your firebase project${NC}\n"
[[ -d tmp ]] || mkdir tmp
cd tmp
firebase login && firebase init
mv database.rules.json firebase.json functions .firebaserc .gitignore ..
cd ..
rm -rf tmp

# INSTALL POLYMER INIT APP-DRAWER
printf "\n${BLUE}Installing polymer app-drawer.\n\t${RED}1 - Select 'app-drawer-template' option${NC}\n\n"
[[ -d tmp2 ]] || mkdir tmp2
cd tmp2
polymer init
cd ..
mv tmp2 public


# GENERATE polymer.json
cd public
VIEWS=""
for i in `seq 1 $NUMVIEW`; 
do
    VIEWS="$VIEWS\t\t\"./src/$MYAPPNAME-view$i.html\""
    if [[ i -ne $NUMVIEW ]] 
    then
        VIEWS="$VIEWS,"
    fi
    VIEWS="$VIEWS\n"
done
POLYMERJSON="{\n
  \t\"entrypoint\": \"index.html\",\n
  \t\"shell\": \"./src/$MYAPPNAME.html\",\n
  \t\"fragments\": [\n$VIEWS\n\t]\n}\n"
echo -e $POLYMERJSON > polymer.json
cd ..

# GENERATE README.md
cd public
READMEMD="# $MYAPPNAME\nThis base-app is a starting point for building apps using a polymer drawer-based layout and firebase."
echo -e $READMEMD > README.md
cd ..

#ADD MORE DEPENDENCIES TO bower.json
SEARCH="\"polymer\"\:\s\"polymer\/polymer\#\^1\.4\.0\""
SEARCH2="\"name\"\:\s\"app\-drawer\-template\","
NEWSTR2="\"name\"\: \"$MYAPPNAME\","
SEARCH3="The Polymer Authors"
SEARCH4="Already logged in as"
OUTPUT="$(firebase login)" 
NEWSTR3=$(echo $OUTPUT | sed "s/$SEARCH4//")
DEPENDENCIES="\"polymer\"\: \"polymer\/polymer\#\^1\.4\.0\",\n    \"polymerfire\"\: \"https\:\/\/github\.com\/firebase\/polymerfire\.git\#\^0\.10\.3\",\n    \"platinum\-sw\"\: \"https\:\/\/github\.com\/PolymerElements\/platinum\-sw\.git\#\^1\.3\.0\",\n    \"web\-animations\-js\"\: \"https\:\/\/github\.com\/web\-animations\/web\-animations\-js\.git\#\^2\.2\.2\",\n    \"iron\-elements\"\: \"PolymerElements\/iron\-elements\#\^1\.0\.0\",\n    \"paper\-elements\"\: \"PolymerElements\/paper\-elements\#\^1\.0\.1\",\n    \"firebase\-element\"\: \"PolymerElements\/firebase\-element\#\^1\.0\.0\",\n    \"util\-lola\"\: \"https\:\/\/github\.com\/manufosela\/util\-lola\.git\#\^1\.0\.0\""
cd public
pwd
find bower.json -exec sed -i "s/$SEARCH/$DEPENDENCIES/g" {} \;
find bower.json -exec sed -i "s/$SEARCH2/$NEWSTR2/g" {} \;
find bower.json -exec sed -i "s/$SEARCH3/$NEWSTR3/g" {} \;

#REPLACE DEFAULT NAME BY APP NAME
SEARCH="My App"
SEARCH2="my-app"
SEARCH3="my-view"
SEARCH4="MyView"
NEWSTR=$(echo $MYAPPNAME | sed 's/\-/ /g')
NEWSTR3="$MYAPPNAME-view"
NEWSTR4="{$MYAPPNAME}View"

find . -type f -name "*.html" -exec sed -i "s/$SEARCH/$NEWSTR/g" {} \;
find . -type f -name "*.html" -exec sed -i "s/$SEARCH2/$MYAPPNAME/g" {} \;
find . -type f -name "*.html" -exec sed -i "s/$SEARCH3/$NEWSTR3/g" {} \;
find . -type f -name "*.html" -exec sed -i "s/$SEARCH4/$NEWSTR4/g" {} \;

#INSTALL NEW DEPENDENCIES
bower install

#RENAME DEFAULT FILES NAMES TO APP NAME
cd src
mv my-app.html $MYAPPNAME.html 
for i in `seq 1 $NUMVIEW`; 
do
    mv my-view$i.html $MYAPPNAME-view$i.html
done
cd ../..

#Generar login-firebase a partir de login-firebase.base

# AÑADIR LOGIN FIREBASE
SCRIPT_FIREBASE="<script src=\"https://www.gstatic.com/firebasejs/3.7.2/firebase.js\"></script>"
SCRIPT_LOGINFIREBASE="<script src=\"./src/login-firebase.js\"></script>"

#Reemplazar <body> en index.html por
SERVICEWORKER="<body unresolved>\n<platinum-sw-register auto-register skip-waiting clients-claim reload-on-install href=\"..\/sw-import.js\">\n<platinum-sw-cache default-cache-strategy=\"networkFirst\"><\/platinum-sw-cache>\n<\/platinum-sw-register>\n"
UTILLOLA="<util-lola active=\"true\" timeout=\"30\"><\/util-lola>"

#TO ADD TO MYAPPNAME.html
#<link rel="import" href="../bower_components/firebase-element/firebase-auth.html">
#<link rel="import" href="../bower_components/firebase-element/firebase.html">
#<script src="https://www.gstatic.com/firebasejs/3.7.2/firebase.js"></script>

#INICIALIZAR FIREBASE CON DATOS DE LA FIREBASEAPP

#CREAR BEHAVIOR a partir de behavior.base COMO $MYAPPNAME-Behavior.html

#Añadir a app y view:  behaviors: [KoffeeBehavior],

#Añadir app-header con boton de login