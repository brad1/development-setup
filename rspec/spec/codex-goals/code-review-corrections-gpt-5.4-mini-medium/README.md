# Overview
- agents shall not modify this file.
- agents working on this this folder may add files to it.
- humans should customize the line beginning with "New variant shall..."

# Note
- I asked that 003 be based on 001 instead of the original, to maximize the number of test cases.

# Recent Output
```
  ./scripts/ci-test.sh just forwards to bundle exec rspec "$@", so I verified each numbered variant explicitly:

  - rspec/spec/codex-goals/code-review-corrections-gpt-5.4-mini-medium/001_visitor_tdd_spec_additional_cases.rb: 18 examples, 0 failures
  - rspec/spec/codex-goals/code-review-corrections-gpt-5.4-mini-medium/002_visitor_tdd_spec_additional_cases.rb: 16 examples, 0 failures
  - rspec/spec/codex-goals/code-review-corrections-gpt-5.4-mini-medium/003_visitor_tdd_spec_additional_cases.rb: 20 examples, 0 failures

  So all three variants are passing.
```

# Agent Task Instructions
- Read all instructions before attempting the task.
- Add a new variant of ../../visitor_tdd_spec.rb to this folder.
- New variant shall add some new test cases for the existing application code. 
- New variant file name shall be numbered.
- When the task is trivial, abort the task and explain why you aborted to the user.
- When the task is impossible, abort the task and explain why you aborted to the user.
- In a comment at the top of the variant, include a full copy of the task instructions.
