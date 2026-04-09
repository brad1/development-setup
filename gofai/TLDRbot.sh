#!/usr/bin/env bash

# --- state ---
STATE="idle"
NAME=""
LAST_INTENT=""
PENDING_COMMAND=""
PENDING_FIELD=""
PENDING_UNKNOWN_PHRASE=""
MAX_REQUEST_CHARS=120
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUES_DIR="$SCRIPT_DIR/cues"

WAKE_WORDS=("assistant" "bot" "tldrbot")
GREET_PHRASES=("hi" "hello" "hey" "greetings" "salutations" "hello there" "good morning" "good afternoon" "good evening")
SET_NAME_PREFIXES=("my name is " "name is " "i am " "i m " "im " "call me " "you can call me " "you may call me " "refer to me as " "my designation is " "register " "register me as ")
SET_NAME_BUILDERS=("register" "register me" "register identity" "register user")
GET_NAME_PHRASES=("what is my name" "what s my name" "who am i" "do you know my name" "do you remember my name" "remind me of my name" "what name do you have for me" "what did i tell you my name is" "identify me" "who do you think i am")
HELP_PHRASES=("help" "assistance" "options" "commands" "list commands" "show commands")
CAPABILITY_PHRASES=("what can you do" "what do you do" "what are your capabilities" "what capabilities do you have" "capabilities" "functions" "what functions do you have" "how can you help" "what services do you provide" "list functions" "show capabilities" "show functions" "available commands" "available functions" "tell me what you can do" "tell me your capabilities" "what are you able to do" "describe your capabilities" "describe functions" "summarize capabilities" "capability report" "function report")
STATUS_PHRASES=("status" "report" "status report" "report status" "system status" "give me a report" "give me status" "give me a status report" "provide a report" "provide status" "provide a status report" "operational report" "operations report" "readiness report" "system report" "condition report" "how are you" "are you online" "all systems nominal" "state your status")
EXIT_PHRASES=("exit" "quit" "bye" "goodbye" "stop" "end program" "terminate" "shutdown" "disengage" "close" "halt" "sign off")
MAP_PREFIXES=("map to " "assign to " "alias to ")

DYNAMIC_GREET_PHRASES=()
DYNAMIC_SET_NAME_BUILDERS=()
DYNAMIC_GET_NAME_PHRASES=()
DYNAMIC_HELP_PHRASES=()
DYNAMIC_STATUS_PHRASES=()

# --- helpers ---
first_request_segment() {
  local msg="$1"

  msg=${msg:0:$MAX_REQUEST_CHARS}
  msg=${msg%%.*}
  msg=$(printf '%s\n' "$msg" | sed -E 's/[[:space:]]+$//')

  printf '%s\n' "$msg"
}

normalize() {
  printf '%s\n' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E "s/[^[:alnum:]]+/ /g; s/[[:space:]]+/ /g; s/^ //; s/ $//"
}

load_dynamic_cues() {
  local intent file line normalized

  mkdir -p "$CUES_DIR"

  for intent in greet build_set_name get_name help status; do
    file="$CUES_DIR/$intent.txt"
    if [[ -f "$file" ]]; then
      while IFS= read -r line; do
        normalized=$(normalize "$line")
        if [[ -z "$normalized" ]]; then
          continue
        fi
        case "$intent" in
          greet) DYNAMIC_GREET_PHRASES+=("$normalized") ;;
          build_set_name) DYNAMIC_SET_NAME_BUILDERS+=("$normalized") ;;
          get_name) DYNAMIC_GET_NAME_PHRASES+=("$normalized") ;;
          help) DYNAMIC_HELP_PHRASES+=("$normalized") ;;
          status) DYNAMIC_STATUS_PHRASES+=("$normalized") ;;
        esac
      done < "$file"
    fi
  done
}

# Strip optional wake words so requests can be phrased naturally.
strip_wake_words() {
  local msg="$1"
  local wake
  local changed=1

  while (( changed )); do
    changed=0
    for wake in "${WAKE_WORDS[@]}"; do
      if [[ "$msg" == "$wake" ]]; then
        msg=""
        changed=1
        break
      fi
      if [[ "$msg" == "$wake "* ]]; then
        msg="${msg#"$wake "}"
        changed=1
        break
      fi
    done
  done

  printf '%s\n' "$msg"
}

contains_any_phrase() {
  local msg=" $1 "
  shift
  local phrase

  for phrase in "$@"; do
    if [[ "$msg" == *" $phrase "* ]]; then
      return 0
    fi
  done

  return 1
}

equals_any_phrase() {
  local msg="$1"
  shift
  local phrase

  for phrase in "$@"; do
    if [[ "$msg" == "$phrase" ]]; then
      return 0
    fi
  done

  return 1
}

starts_with_any() {
  local msg="$1"
  shift
  local prefix

  for prefix in "$@"; do
    if [[ "$msg" == "$prefix"* ]]; then
      return 0
    fi
  done

  return 1
}

extract_mapping_target() {
  local msg="$1"
  local prefix

  for prefix in "${MAP_PREFIXES[@]}"; do
    if [[ "$msg" == "$prefix"* ]]; then
      printf '%s\n' "${msg#"$prefix"}"
      return 0
    fi
  done

  return 1
}

save_dynamic_cue() {
  local intent="$1"
  local phrase="$2"
  local file="$CUES_DIR/$intent.txt"
  local existing

  mkdir -p "$CUES_DIR"
  touch "$file"

  while IFS= read -r existing; do
    if [[ "$(normalize "$existing")" == "$phrase" ]]; then
      return 0
    fi
  done < "$file"

  printf '%s\n' "$phrase" >> "$file"
}

detect_intent_core() {
  local query="$1"

  if [[ -z "$query" ]]; then echo "greet"
  elif contains_any_phrase "$query" "${EXIT_PHRASES[@]}"; then echo "exit"
  elif equals_any_phrase "$query" "${DYNAMIC_SET_NAME_BUILDERS[@]}"; then echo "build_set_name"
  elif equals_any_phrase "$query" "${SET_NAME_BUILDERS[@]}"; then echo "build_set_name"
  elif starts_with_any "$query" "${SET_NAME_PREFIXES[@]}"; then echo "set_name"
  elif contains_any_phrase "$query" "${DYNAMIC_GET_NAME_PHRASES[@]}"; then echo "get_name"
  elif contains_any_phrase "$query" "${GET_NAME_PHRASES[@]}"; then echo "get_name"
  elif contains_any_phrase "$query" "${CAPABILITY_PHRASES[@]}" || contains_any_phrase "$query" "${DYNAMIC_HELP_PHRASES[@]}" || contains_any_phrase "$query" "${HELP_PHRASES[@]}"; then echo "help"
  elif contains_any_phrase "$query" "${DYNAMIC_STATUS_PHRASES[@]}" || contains_any_phrase "$query" "${STATUS_PHRASES[@]}"; then echo "status"
  elif contains_any_phrase "$query" "${DYNAMIC_GREET_PHRASES[@]}" || contains_any_phrase "$query" "${GREET_PHRASES[@]}"; then echo "greet"
  else echo "unknown"
  fi
}

detect_intent() {
  local msg="$1"
  local query

  query=$(strip_wake_words "$msg")
  detect_intent_core "$query"
}

extract_name() {
  local msg="$1"
  local name

  name=$(printf '%s\n' "$msg" \
    | sed -E "s/^[[:space:]]*(assistant|bot|tldrbot)[[:space:][:punct:]]+//I" \
    | sed -E "s/^[[:space:]]*(my name is|name is|i am|i'm|im|call me|you can call me|you may call me|refer to me as|my designation is|register me as|register)[[:space:]]+//I" \
    | sed -E "s/[[:space:]]+(and|but|please|because|while|with|also|then)\b.*$//I" \
    | sed -E "s/[[:space:]]*[[:punct:]]+$//; s/^[[:space:]]+//; s/[[:space:]]+$//")

  if [[ -z "$name" ]]; then
    name=$(printf '%s\n' "$msg" | awk '{print $NF}')
  fi

  printf '%s\n' "$name"
}

respond() {
  local intent="$1"
  local raw_msg="$2"
  local map_target
  local mapped_intent
  local normalized_target

  case "$intent" in
    greet)
      echo "Assistant ready."
      ;;

    set_name)
      NAME=$(extract_name "$raw_msg")
      if [[ -n "$NAME" ]]; then
        STATE="idle"
        PENDING_COMMAND=""
        PENDING_FIELD=""
        echo "Acknowledged. I will address you as $NAME."
      else
        echo "Unable to determine an identity from that input."
      fi
      ;;

    build_set_name)
      STATE="awaiting_parameter"
      PENDING_COMMAND="set_name"
      PENDING_FIELD="identity"
      PENDING_UNKNOWN_PHRASE=""
      echo "Specify."
      ;;

    get_name)
      if [[ -n "$NAME" ]]; then
        echo "You are identified as $NAME."
      else
        echo "No identity record is currently stored."
      fi
      ;;

    help)
      echo "Available functions: greetings, identity registration, identity recall, status reports, capability queries, and session termination."
      ;;

    status)
      echo "Assistant online. All monitored systems nominal."
      ;;

    map_intent)
      if [[ -z "$PENDING_UNKNOWN_PHRASE" ]]; then
        echo "Unable to comply. No phrase is awaiting assignment."
        return
      fi

      map_target=$(extract_mapping_target "$(normalize "$raw_msg")")
      normalized_target=$(normalize "$map_target")
      mapped_intent=$(detect_intent "$normalized_target")

      if [[ -z "$normalized_target" || "$mapped_intent" == "unknown" || "$mapped_intent" == "map_intent" || "$mapped_intent" == "exit" ]]; then
        echo "Unable to comply. Specify a known command to map to: greet, register, identify, help, status."
        return
      fi

      save_dynamic_cue "$mapped_intent" "$PENDING_UNKNOWN_PHRASE"

      case "$mapped_intent" in
        greet) DYNAMIC_GREET_PHRASES+=("$PENDING_UNKNOWN_PHRASE") ;;
        build_set_name) DYNAMIC_SET_NAME_BUILDERS+=("$PENDING_UNKNOWN_PHRASE") ;;
        get_name) DYNAMIC_GET_NAME_PHRASES+=("$PENDING_UNKNOWN_PHRASE") ;;
        help) DYNAMIC_HELP_PHRASES+=("$PENDING_UNKNOWN_PHRASE") ;;
        status) DYNAMIC_STATUS_PHRASES+=("$PENDING_UNKNOWN_PHRASE") ;;
      esac

      PENDING_UNKNOWN_PHRASE=""
      echo "Acknowledged. Mapping stored."
      ;;

    unknown)
      PENDING_UNKNOWN_PHRASE=$(strip_wake_words "$(normalize "$raw_msg")")
      echo "Unable to comply. Please restate the request."
      ;;
  esac
}

# --- loop ---
load_dynamic_cues
echo "TLDRbot ready. Say 'exit' to end session."

while true; do
  if ! read -rp "tldr> " USER_INPUT; then
    echo
    echo "Session terminated."
    break
  fi

  REQUEST=$(first_request_segment "$USER_INPUT")
  MSG=$(normalize "$REQUEST")

  if [[ "$STATE" == "awaiting_parameter" && -n "$REQUEST" ]]; then
    INTENT="$PENDING_COMMAND"
  elif extract_mapping_target "$(strip_wake_words "$MSG")" >/dev/null 2>&1; then
    INTENT="map_intent"
  else
    INTENT=$(detect_intent "$MSG")
  fi

  if [[ "$INTENT" == "exit" ]]; then
    STATE="idle"
    PENDING_COMMAND=""
    PENDING_FIELD=""
    PENDING_UNKNOWN_PHRASE=""
    echo "Session terminated."
    break
  fi

  respond "$INTENT" "$REQUEST"
  LAST_INTENT="$INTENT"
done
