
# **Git Cheatsheet**

## **Branching and Merging**
- **Squash all commits into one:**
  ```bash
  git reset --soft master && git commit -m 'Squashed all new commits since branching off master'
  ```
  or
  ```bash
  git diff master dev > changes.patch
  git checkout master
  git checkout -b dev2
  git apply changes.patch
  git add .
  git commit -m "All changes"
  ```

- **Rebase a branch:**
  ```bash
  git rebase --onto master release feature
  ```
  Moves the feature branch’s commits to be on top of master instead of release.

- **Find the fork point between two branches:**
  ```bash
  git merge-base <branch1> <branch2>
  ```

- **Delete and recreate a remote branch:**
  ```bash
  git branch -D branchname
  git checkout --track origin/branchname
  ```

- **Show branches that have been merged:**
  ```bash
  git branch --merged
  ```

- **Prune remote tracking branches:**
  ```bash
  git remote prune origin
  ```

---

## **Commit History and Log**
### **Log Format**
- **Custom format for logs:**
  ```bash
  git log --pretty=format:"%h - %an, %ar : %s" --shortstat
  ```

- **Find deleted files:**
  ```bash
  git log -- <filepath>
  ```

- **Log of commits for a file with history:**
  ```bash
  git log --follow <filepath>
  ```

### **Useful Commands:**
- **Show all commits in a simple format:**
  ```bash
  git log --oneline
  ```

- **Graphical commit history:**
  ```bash
  git log --graph --oneline --decorate
  ```

- **Filter commits by author:**
  ```bash
  git log --author="John Doe"
  ```

- **Commits since a date:**
  ```bash
  git log --since="YYYY-MM-DD"
  ```

- **Commits before a date:**
  ```bash
  git log --until="YYYY-MM-DD"
  ```

- **Search commits by message:**
  ```bash
  git log --grep="fix"
  ```

- **Exclude merge commits:**
  ```bash
  git log --no-merges
  ```

- **Show number of commits between two branches:**
  ```bash
  git rev-list --count test ^main
  ```

### **File Specific Logs**
- **Show commit history for a specific file:**
  ```bash
  git log --oneline -- <file>
  ```

- **Log all changes made to a file:**
  ```bash
  git log -p -- <file>
  ```

---

## **Rebasing and Cherry-Picking**
- **Interactive rebase (edit commits):**
  ```bash
  git rebase -i HEAD~5
  ```
  Use 'e' to edit commits.

- **Partial cherry-pick (no commit):**
  ```bash
  git cherry-pick -n <commit>
  ```

---

## **Stashing**
- **Stash with a comment:**
  ```bash
  git stash save "your message"
  ```

- **Show stash list:**
  ```bash
  git stash list
  ```

- **Apply the most recent stash:**
  ```bash
  git stash pop
  ```

- **Apply stash but keep in stash:**
  ```bash
  git stash apply
  ```

- **Show stash contents with a patch:**
  ```bash
  git stash show -p
  ```

---

## **Diffing and Blame**
- **Show full diffs between commits:**
  ```bash
  git diff HEAD~7 HEAD
  ```

- **Show diff for one file:**
  ```bash
  git diff -- <file>
  ```

- **Blame for a file:**
  ```bash
  git blame <filepath>
  ```

- **Find changes to a file since the last release/tag:**
  ```bash
  git blame --since="YYYY-MM-DD" -- <file>
  ```

---

## **Miscellaneous**
- **Find checked out branches:**
  ```bash
  git reflog | grep 'checkout: moving from master' | head -n 20
  ```

- **Restore a file to a previous version:**
  ```bash
  git checkout <commit>~1 -- <file>
  ```

- **Show all files changed in the last 3 commits by a specific author:**
  ```bash
  git log --author="Your Name" -n3 --pretty=tformat: --name-only | sort -u
  ```

- **Delete a file from the repository:**
  ```bash
  git rm <file>
  ```

- **Update local tags:**
  ```bash
  git fetch --tags
  ```

---
