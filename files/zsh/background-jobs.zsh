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
