# Shell status background jobs with twelve-hour caching.
# Jobs write their output to logs under $jobsd (or a default personal directory).

placeholder-job-run-command() {
  local cmd_text="$1"
  shift || true

  echo "$cmd_text"
  if (( $# )); then
    "$@"
  else
    eval "$cmd_text"
  fi
  echo
  echo
}

shell-status-job-vagrant-global-status-prune() {
  placeholder-job-run-command "vagrant global-status --prune" \
    vagrant global-status --prune
}

shell-status-job-git-remote-branches() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    placeholder-job-run-command "git branch -r" git branch -r
  else
    placeholder-job-run-command "git branch -r" echo "Skipping: not in a git repository."
  fi
}

shell-status-job-grep-todo() {
  local search_dir
  search_dir=${PRIMARY_PROJECT:-}

  if [[ -z "$search_dir" || ! -d "$search_dir" ]]; then
    placeholder-job-run-command "grep TODO in PRIMARY_PROJECT" \
      echo "Skipping: PRIMARY_PROJECT is not set or missing."
    return
  fi

  local search_cmd
  search_cmd="cd \"$search_dir\" && date && grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,\\*venv,\\*java,\\*vendor,\\*server_env,\\*node_modules,\\*dist,\\*release} -r \"TODO\" . && date"
  placeholder-job-run-command "${search_cmd}" zsh -c "$search_cmd"
}

shell-status-job-grep-crawl() {
  placeholder-job-run-command "shell_status_job_crawl" zsh -c "date && shell_status_job_crawl && date"
}

placeholder-jobs-run() {
  emulate -L zsh

  local jobs_dir
  jobs_dir=${jobsd:-${PERSONAL_DIR:-$HOME}/login-splash-jobs}
  mkdir -p "$jobs_dir"

  local -i now
  now=$(date +%s)

  local -i ttl_seconds=43200 # 12 hours
  local -a jobs=(
    vagrant-global-status-prune
    git-remote-branches
    grep-todo
    grep-crawl
  )

  local job log_path run_job last_run job_fn
  local -a pids=()
  for job in $jobs; do
    log_path="$jobs_dir/${job}.log"
    job_fn="shell-status-job-${job}"
    if ! typeset -f "$job_fn" >/dev/null; then
      echo "Skipping '${job}' because function '${job_fn}' is not defined."
      continue
    fi
    run_job=1

    if [[ -f $log_path ]]; then
      last_run=$(date -r "$log_path" +%s)
      if (( now - last_run < ttl_seconds )); then
        run_job=0
      fi
    fi

    if (( run_job )); then
      echo "Starting shell-status job '${job}'..."
      (
        {
          "$job_fn"
        } > "$log_path" 2>&1
      ) &
      pids+=($!)
    else
      echo "Recent output for shell-status job '${job}' (completed within 12h):"
      placeholder-job-run-command "cat '$log_path'" cat "$log_path"
    fi
  done

  local pid
  for pid in $pids; do
    wait $pid
  done
}
