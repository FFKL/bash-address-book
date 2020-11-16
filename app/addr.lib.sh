recordsNumber() {
  grep --ignore-case "$@" $BOOK | wc -l | xargs echo
}

showList() {
  local tempIFS=$IFS
  IFS=":"
  local name email phone
  local line
  cat $BOOK | while read line; do
    read -r name email phone <<<"$line"
    showRecord $name $email $phone
  done
  IFS="$tempIFS"
}

add() {
  info "Add a new record: "
  local name email phone

  question "Name: "
  read name
  if [ $(recordsNumber "^${name}:") -ne "0" ]; then
    echo "Sorry, you already have a record with name - ${name}."
    return
  fi
  question "Email: "
  read email
  question "Phone: "
  read phone

  echo "$name:$email:$phone" >>"$BOOK"
}

search() {
  findRecord
  local foundRecord="$?"
  if [ "$foundRecord" -eq "0" ]; then
    info "Records not found"
  else
    info "You found $(head -$foundRecord $BOOK | tail -1)"
  fi
}

findRecord() {
  local term
  read -p "Search: " term
  local found=$(grep "$term" "$BOOK")

  if [ -n "$found" ]; then
    local count=$(recordsNumber "$term")
    if [ "$count" -eq "1" ]; then
      return $(grep -in "$record" "$BOOK" | cut -d: -f1)
    fi

    echo "Found $count records"
    echo "$found" | awk '{print "("FNR") - "$0}'
    local recordNumber
    read -p "Enter the record number [1-$count]: " recordNumber
    while [[ ! $recordNumber =~ ^[0-9]+$ ]] || [[ "$recordNumber" -lt "1" ]] || [[ "$recordNumber" -gt "$count" ]]; do
      read -p "Incorrect record number. Please, try again: " recordNumber
    done
    local record=$(echo "$found" | sed --silent "${recordNumber}p")
    return $(grep -in "$record" "$BOOK" | cut -d: -f1)
  fi
}

edit() {
  findRecord
  local record=$(head -$? $BOOK | tail -1)
  if [ -n "$record" ]; then
    local tempIFS=$IFS
    IFS=":"
    local currentName currentEmail currentPhone
    read -r currentName currentEmail currentPhone <<<"$record"
    IFS="$tempIFS"

    local name email phone
    read -p "Name [$currentName]: " name
    read -p "Email [$currentEmail]: " email
    read -p "Phone [$currentPhone]: " phone

    local newRecord="${name:-$currentName}:${email:-$currentEmail}:${phone:-$currentPhone}"

    sed --in-place "s/$record/$newRecord/" "$BOOK"
  fi
}

remove() {
  findRecord
  local record=$(head -$? $BOOK | tail -1)
  if [ -n "$record" ]; then
    local answer
    read -p "Do you want to remove found record? [y/n] " answer
    if [ "$answer" == "y" ]; then
      sed --in-place "/${record}/d" "$BOOK"
    fi
  fi
}
