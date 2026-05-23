# Notes

## 001_animals_tools.py
- model: gpt-5.4-mini-low
- results: pass

## 002_animals_tools.py
- model: gpt-5.4-mini-low
- results: chose a rule over another, audit failed to state that.

## 003_animals_tools.py
- model: gpt-5.4-mini-low
- results: fails underwater lantern use, even when the audit promptlet provides a hint up front.

## 004_animals_tools.py
- model: gpt-5.4-mini-low (clear context)
- results: fails, also cheats by looking at NOTES.md 

## 005_animals_tools.py
- model: gpt-5.4-mini-medium
- results: fails

## 006_animals_tools.py
- model: gpt-5.4-mini-low (tighter audit hint)
- results: fails

## 007_animals_tools.py
- model: gpt-5.4-mini-medium (same tighter audit hint from 006)
- results: pass, "explain red flag" fixes it

## 008_animals_tools.py
- model: gpt-5.5-high (revert audit hint)
- results: fail, handwaves, saw previous versions of code 

## 009_animals_tools.py
- model: gpt-5.5-high (no peeking at previous runs)
- results: fail, handwaves

## 010_animals_tools.py
- model: gpt-5.5-high (no audit, but "strict plausibility")
- results: pass, produces "sealed lantern" and "octopus hides in bucket" unprompted.

## 011_animals_tools.py
- model: gpt-5.4-mini-high (no audit, but "strict plausibility")
- results: pass, but lower quality than 5.5-high 
