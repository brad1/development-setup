# Placeholder background jobs with simple twelve-hour caching.
# Jobs write their output to logs under $jobsd (or a default personal directory).
placeholder-jobs-run() {
  emulate -L zsh

  local jobs_dir
  jobs_dir=${jobsd:-${PERSONAL_DIR:-$HOME}/login-splash-jobs}
  mkdir -p "$jobs_dir"

  local -i now
  now=$(date +%s)

  local -i ttl_seconds=43200 # 12 hours
  local -a jobs=(alpha beta gamma)

  local job log_path run_job last_run
  for job in $jobs; do
    log_path="$jobs_dir/${job}.log"
    run_job=1

    if [[ -f $log_path ]]; then
      last_run=$(date -r "$log_path" +%s)
      if (( now - last_run < ttl_seconds )); then
        run_job=0
      fi
    fi

    if (( run_job )); then
      echo "Starting placeholder job '${job}'..."
      (
        {
          echo "placeholder job '${job}'"
          echo "Started: $(date)"
          # Replace this section with real work for '${job}'.
          sleep 1
          echo "Finished: $(date)"
        } > "$log_path" 2>&1
      ) &
    else
      echo "Recent output for placeholder job '${job}' (completed within 12h):"
      cat "$log_path"
    fi
  done
}
