# Background jobs launched at the start of an interactive shell session.
# Related background job helpers live in $INCLUDE/fn_jobs.zsh; see shell-status
# there for examples of status jobs that could move here once validated.
# Next step: import the candidate job(s) here, then manually test by opening a
# fresh zsh session and confirming the background job runs non-blocking.

background-jobs-should-run-daily() {
  local stamp_dir stamp_file
  stamp_dir=${PERSONAL_DIR:-$HOME}/login-splash-jobs
  stamp_file="$stamp_dir/background-jobs-last-run"
  mkdir -p "$stamp_dir"

  local -i now last
  if [[ -f "$stamp_file" ]]; then
    last=$(date -r "$stamp_file" +%s)
    now=$(date +%s)
    if (( now - last < 86400 )); then
      return 1
    fi
  fi

  touch "$stamp_file"
  return 0
}

background-jobs-should-run-hourly() {
  local stamp_dir stamp_file
  stamp_dir=${PERSONAL_DIR:-$HOME}/login-splash-jobs
  stamp_file="$stamp_dir/background-jobs-last-run-hourly"
  mkdir -p "$stamp_dir"

  local -i now last
  if [[ -f "$stamp_file" ]]; then
    last=$(date -r "$stamp_file" +%s)
    now=$(date +%s)
    if (( now - last < 3600 )); then
      return 1
    fi
  fi

  touch "$stamp_file"
  return 0
}

bg-now-git-remote-branches() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git branch -r
  else
    echo "Skipping: not in a git repository."
  fi
}

codex-53-background-jobs-log() {
  emulate -L zsh

  local stamp_dir debug_log ts message
  stamp_dir=${PERSONAL_DIR:-$HOME}/login-splash-jobs
  debug_log="$stamp_dir/codex-53-background-jobs-debug.log"
  mkdir -p "$stamp_dir"

  ts=$(date '+%Y-%m-%dT%H:%M:%S%z')
  message="[codex-53-jobs][$ts][pid=$$] $*"

  print -- "$message"
  print -- "$message" >> "$debug_log"
}

codex-53-background-jobs-should-run() {
  emulate -L zsh

  local cadence=$1
  local -i min_age_seconds=$2
  local stamp_name=$3
  local stamp_dir stamp_file
  stamp_dir=${PERSONAL_DIR:-$HOME}/login-splash-jobs
  stamp_file="$stamp_dir/$stamp_name"
  mkdir -p "$stamp_dir"

  codex-53-background-jobs-log "[$cadence] evaluating throttle with stamp file '$stamp_file' and min age ${min_age_seconds}s."

  local -i now last age
  if [[ -f "$stamp_file" ]]; then
    last=$(date -r "$stamp_file" +%s)
    now=$(date +%s)
    age=$(( now - last ))
    codex-53-background-jobs-log "[$cadence] existing stamp found; last run age=${age}s."
    if (( age < min_age_seconds )); then
      codex-53-background-jobs-log "[$cadence] skipping: age ${age}s is below threshold ${min_age_seconds}s."
      return 1
    fi
  else
    codex-53-background-jobs-log "[$cadence] no existing stamp file found."
  fi

  touch "$stamp_file"
  codex-53-background-jobs-log "[$cadence] throttle passed and stamp touched."
  return 0
}

codex-53-background-jobs-run() {
  emulate -L zsh

  local cadence=$1
  shift

  codex-53-background-jobs-log "[$cadence] scheduling ${#@} job(s)."

  local job_fn job_log_dir job_log
  job_log_dir=${PERSONAL_DIR:-$HOME}/login-splash-jobs/codex-53-jobs
  mkdir -p "$job_log_dir"

  for job_fn in "$@"; do
    codex-53-background-jobs-log "[$cadence] preparing job '$job_fn'."

    if ! typeset -f "$job_fn" >/dev/null; then
      codex-53-background-jobs-log "[$cadence] skipping '$job_fn': function is not defined."
      continue
    fi

    job_log="$job_log_dir/${job_fn}.log"
    codex-53-background-jobs-log "[$cadence] launching '$job_fn' in a detached subshell; output -> '$job_log'."
    (
      local start_ts end_ts rc
      start_ts=$(date '+%Y-%m-%dT%H:%M:%S%z')
      print -- "[codex-53-jobs][$start_ts][pid=$$] BEGIN job '$job_fn'" >> "$job_log"
      "$job_fn" >> "$job_log" 2>&1
      rc=$?
      end_ts=$(date '+%Y-%m-%dT%H:%M:%S%z')
      print -- "[codex-53-jobs][$end_ts][pid=$$] END job '$job_fn' rc=$rc" >> "$job_log"
      codex-53-background-jobs-log "[$cadence] completed '$job_fn' with rc=$rc."
    ) &!
    codex-53-background-jobs-log "[$cadence] detached '$job_fn' with pid=$!."
  done
}

codex-53-background-jobs-run-cadence() {
  emulate -L zsh

  local cadence=$1
  local fn_glob=$2
  local -a job_fns
  job_fns=(${(k)functions[(I)$fn_glob]})

  codex-53-background-jobs-log "[$cadence] discovered ${#job_fns[@]} job(s) with pattern '$fn_glob'."
  if (( ${#job_fns[@]} == 0 )); then
    codex-53-background-jobs-log "[$cadence] no jobs to run."
    return 0
  fi

  codex-53-background-jobs-run "$cadence" "${job_fns[@]}"
}

codex-53-background-jobs-startup() {
  emulate -L zsh

  codex-53-background-jobs-log "[startup] CODEX_53_JOBS=true detected; using alternate background jobs mechanism."
  codex-53-background-jobs-log "[startup] checking startup guard CODEX_53_BACKGROUND_JOBS_STARTED."
  if [[ -n ${CODEX_53_BACKGROUND_JOBS_STARTED:-} ]]; then
    codex-53-background-jobs-log "[startup] guard already set; skipping duplicate startup."
    return 0
  fi

  CODEX_53_BACKGROUND_JOBS_STARTED=1
  codex-53-background-jobs-log "[startup] set CODEX_53_BACKGROUND_JOBS_STARTED=1."

  codex-53-background-jobs-log "[startup] launching sentinel sleep job (60s) for visibility."
  exec -a devsetup-bg-sleep-60 command sleep 60 &!
  codex-53-background-jobs-log "[startup] sentinel sleep launched with pid=$!."

  codex-53-background-jobs-log "[startup] scheduling immediate jobs."
  codex-53-background-jobs-run-cadence "immediate" "bg-now-*"

  codex-53-background-jobs-log "[startup] evaluating hourly jobs."
  if codex-53-background-jobs-should-run "hourly" 3600 "codex-53-background-jobs-last-run-hourly"; then
    codex-53-background-jobs-run-cadence "hourly" "bg-hourly-*"
  else
    codex-53-background-jobs-log "[hourly] throttle check failed; not running hourly jobs."
  fi

  codex-53-background-jobs-log "[startup] evaluating daily jobs."
  if codex-53-background-jobs-should-run "daily" 86400 "codex-53-background-jobs-last-run-daily"; then
    codex-53-background-jobs-run-cadence "daily" "bg-daily-*"
  else
    codex-53-background-jobs-log "[daily] throttle check failed; not running daily jobs."
  fi

  codex-53-background-jobs-log "[startup] alternate scheduling complete."
}

background-jobs-run() {
  emulate -L zsh

  local job_fn
  for job_fn in "$@"; do
    if ! typeset -f "$job_fn" >/dev/null; then
      echo "Skipping background job '${job_fn}' because function '${job_fn}' is not defined."
      continue
    fi

    # Run in a subshell to keep the startup non-blocking.
    ( "$job_fn" ) &!
  done
}

background-jobs-run-immediate() {
  emulate -L zsh

  local -a job_fns
  job_fns=(${(k)functions[(I)bg-now-*]})

  if (( ${#job_fns[@]} == 0 )); then
    return 0
  fi

  background-jobs-run "${job_fns[@]}"
}

background-jobs-run-daily() {
  emulate -L zsh

  if ! background-jobs-should-run-daily; then
    return 0
  fi

  local -a job_fns
  job_fns=(${(k)functions[(I)bg-daily-*]})

  if (( ${#job_fns[@]} == 0 )); then
    return 0
  fi

  background-jobs-run "${job_fns[@]}"
}

background-jobs-run-hourly() {
  emulate -L zsh

  if ! background-jobs-should-run-hourly; then
    return 0
  fi

  local -a job_fns
  job_fns=(${(k)functions[(I)bg-hourly-*]})

  if (( ${#job_fns[@]} == 0 )); then
    return 0
  fi

  background-jobs-run "${job_fns[@]}"
}

if [[ -o interactive ]]; then
  if [[ ${CODEX_53_JOBS:-} == true ]]; then
    codex-53-background-jobs-startup
  else
    if [[ -z ${DEVSETUP_BACKGROUND_JOBS_STARTED:-} ]]; then
      DEVSETUP_BACKGROUND_JOBS_STARTED=1

      # Example test job (non-blocking). Use exec -a to make it obvious in ps.
      exec -a devsetup-bg-sleep-60 command sleep 60 &!

      background-jobs-run-immediate

      background-jobs-run-hourly
      background-jobs-run-daily

      # Other ideas for easy-to-spot background jobs (commented out for tinkering):
      # command sleep 60 &!
      # zsh -c 'exec -a devsetup-bg-sleep-60 sleep 60' &!
      # bash -c 'exec -a devsetup-bg-sleep-60 sleep 60' &!
      # perl -e '$0="devsetup-bg-sleep-60"; sleep 60' &!
      # python -c 'import time; time.sleep(60)' &!
      # setproctitle devsetup-bg-sleep-60 sleep 60
      # ~/bin/devsetup-bg-sleep-60 &!
    fi
  fi
fi
