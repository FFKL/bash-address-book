#!/bin/bash

BOOK="$(dirname "$0")/.addressbook"
source "$(dirname "$0")/colorizer.lib.sh"
source "$(dirname "$0")/crud.lib.sh"

trap 'start' SIGINT

header() {
  echo -en "${WELCOME_STYLE}"
  echo -e "      ______ ______"
  echo -e "    _/      Y      \_"
  echo -e "   // ~~ ~~ | ~~ ~  \\\\"
  echo -e "  // ~ ~ ~~ | ~~~ ~~ \\\\      Welcome to"
  echo -e " //________.|.________\\\\     The Address Book"
  echo -e "'----------'-'----------'${DEFAULT_STYLE}"
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
