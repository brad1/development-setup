# Background jobs launched at the start of an interactive shell session.
# Related background job helpers live in $INCLUDE/fn_jobs.zsh; see shell-status
# there for examples of status jobs that could move here once validated.
# Next step: import the candidate job(s) here, then manually test by opening a
# fresh zsh session and confirming the background job runs non-blocking.

if [[ -o interactive ]]; then
  if [[ -z ${DEVSETUP_BACKGROUND_JOBS_STARTED:-} ]]; then
    DEVSETUP_BACKGROUND_JOBS_STARTED=1
    # Example test job (non-blocking).
    command sleep 60 &!
  fi
fi
