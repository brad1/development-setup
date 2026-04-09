#!/usr/bin/env bash

# --- state ---
STATE="idle"
NAME=""
LAST_INTENT=""

RE_GREET='(^|[[:space:]])(hi|hello|hey)([[:space:]]|$)'
RE_SET_NAME='(name is|i am|i'\''m)'
RE_GET_NAME='(what is my name|who am i)'
RE_HELP='(^|[[:space:]])help([[:space:]]|$)'
RE_CAPABILITIES='(what can you do|what do you do|capabilities|what are your capabilities)'
RE_EXIT='(^|[[:space:]])(exit|quit)([[:space:]]|$)'

# --- helpers ---
lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

detect_intent() {
  local msg="$1"
  if [[ "$msg" =~ $RE_GREET ]]; then echo "greet"
  elif [[ "$msg" =~ $RE_SET_NAME ]]; then echo "set_name"
  elif [[ "$msg" =~ $RE_GET_NAME ]]; then echo "get_name"
  elif [[ "$msg" =~ $RE_CAPABILITIES ]]; then echo "help"
  elif [[ "$msg" =~ $RE_HELP ]]; then echo "help"
  elif [[ "$msg" =~ $RE_EXIT ]]; then echo "exit"
  else echo "unknown"
  fi
}

extract_name() {
  local msg="$1"
  # naive extraction: take last word
  echo "$msg" | awk '{print $NF}'
}

respond() {
  local intent="$1"
  local msg="$2"

  case "$intent" in
    greet)
      echo "Hello."
      ;;

    set_name)
      NAME=$(extract_name "$msg")
      echo "Noted. Name set to $NAME."
      ;;

    get_name)
      if [[ -n "$NAME" ]]; then
        echo "You are $NAME."
      else
        echo "I don't know your name yet."
      fi
      ;;

    help)
      echo "I can greet you, remember your name, tell you the name I know, and exit when you ask."
      ;;

    unknown)
      echo "Unrecognized input."
      ;;
  esac
}

# --- loop ---
echo "SimpleBot ready. Type 'exit' to quit."

while true; do
  if ! read -rp "> " USER_INPUT; then
    echo
    echo "Goodbye."
    break
  fi
  MSG=$(lower "$USER_INPUT")

  INTENT=$(detect_intent "$MSG")

  if [[ "$INTENT" == "exit" ]]; then
    echo "Goodbye."
    break
  fi

  respond "$INTENT" "$MSG"
  LAST_INTENT="$INTENT"
done
