# Example GitLab CI Setup
- This is a simplified representation of a past real-world GitLab CI/CD setup.
- The example is intended to demonstrate pipeline structure, job organization and operational patterns
- `.gitlab-ci.yml` is intentionally stripped down, untested. 

# Known Pitfalls 
- venv/ pathing is brittle, do not copy or move
- venv/ needs to be archived at the same path you intend to extract 
- use gitlab cache keys sparingly, because gotchas
- `image:` keyword is not used here to avoid performance hit on the main build node.  
- monorepo w/ botched LFS and large history makes the above worse
