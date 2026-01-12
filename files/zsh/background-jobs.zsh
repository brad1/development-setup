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

if [[ -o interactive ]]; then
  if [[ -z ${DEVSETUP_BACKGROUND_JOBS_STARTED:-} ]]; then
    DEVSETUP_BACKGROUND_JOBS_STARTED=1

    # Example test job (non-blocking). Use exec -a to make it obvious in ps.
    exec -a devsetup-bg-sleep-60 command sleep 60 &!

    # Periodic jobs (once per day).
    if background-jobs-should-run-daily; then
      # Example periodic job (commented out for tinkering):
      # exec -a devsetup-bg-sleep-60-daily command sleep 60 &!
      :
    fi

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
