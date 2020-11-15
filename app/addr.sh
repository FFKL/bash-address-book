#!/bin/bash

BOOK="$(dirname "$0")/.addressbook"
source "$(dirname "$0")/addr.lib.sh"

trap 'start' SIGINT

YELLOW='\e[33m'
LIGHT_BLUE='\e[34m'
GREEN='\e[32m'
RED='\e[31m'
CYAN='\e[36m'
NO_COLOR='\e[0m'

WELCOME_STYLE="$LIGHT_BLUE"
MENU_NUMBER_STYLE="$YELLOW"
DEFAULT_STYLE="$NO_COLOR"
QUESTION_STYLE="$GREEN"
ERROR_STYLE="$RED"
NAME_STYLE="$YELLOW"
INFO_STYLE="$NO_COLOR"

header() {
  echo -en "${WELCOME_STYLE}"
  echo -e "      ______ ______"
  echo -e "    _/      Y      \_"
  echo -e "   // ~~ ~~ | ~~ ~  \\\\"
  echo -e "  // ~ ~ ~~ | ~~~ ~~ \\\\      Welcome to"
  echo -e " //________.|.________\\\\     The Address Book"
  echo -e "'----------'-'----------'${DEFAULT_STYLE}"
}

question() {
  echo -en "${QUESTION_STYLE}$1${DEFAULT_STYLE}"
}

menuItem() {
  echo -e " ${MENU_NUMBER_STYLE}(${1})${DEFAULT_STYLE} ${2}"
}

info() {
  echo -e "$INFO_STYLE$1$DEFAULT_STYLE"
}

error() {
  echo -e "${ERROR_STYLE}$1${DEFAULT_STYLE}"
}

showRecord() {
  echo -e "$NAME_STYLE$1$DEFAULT_STYLE\t$2\t$3"
}

showMenu() {
  header
  menuItem "1" "Search"
  menuItem "2" "Add"
  menuItem "3" "Edit"
  menuItem "4" "Remove"
  menuItem "l" "Show full list"
  menuItem "q" "Quit"
  question "Enter your selection: "
}

start() {
  local input
  while [ "$input" != "q" ]; do
    showMenu
    read input
    input=$(echo "$input" | tr "[:upper:]" "[:lower:]")
    case $input in
    "1") search ;;
    "2") add ;;
    "3") edit ;;
    "4") remove ;;
    "l") showList ;;
    "q")
      info "Bye"
      exit 0
      ;;
    *) error "Unrecognised input" ;;
    esac
    info "Press any key..."
    read -n 1 -s -r
  done
}

if [ ! -f $BOOK ]; then
  info "Creating $BOOK ..."
  touch $BOOK
fi

if [ ! -r $BOOK ]; then
  error "Error: $BOOK not readable"
  exit 1
fi

if [ ! -w $BOOK ]; then
  error "Error: $BOOK not writeable"
  exit 2
fi

start
