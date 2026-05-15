# git helper functions

# Legacy version that wrote selection to a temp file
# for later `git checkout`. Provided for comparison.
git-branch-hop-old() {
    git reflog | grep -o 'moving from.*' | head -n25 \
      | sed 's/moving //; s/from //; s/to //' \
      | xargs -n 1 | sort | uniq | fzf > "$PERSONAL_DIR/tmp/branch"
    git checkout "$(cat "$PERSONAL_DIR/tmp/branch")"
}

# Modern approach using a shell variable
# and skipping the intermediate temp file
# Requires `fzf` for selection
git-branch-hop() {
  local branch
  branch=$(git reflog | grep -o 'moving from.*' | head -n25 \
    | sed 's/moving //; s/from //; s/to //' \
    | xargs -n 1 | sort | uniq | fzf)
  [[ -n $branch ]] && git checkout "$branch"
}
