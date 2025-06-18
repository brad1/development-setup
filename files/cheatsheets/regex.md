Here is a compact yet dense **Regex Cheatsheet** optimized for reference:

---

### **REGEX CHEATSHEET (Compact)**

#### **1. BASICS**

* `.`      → Any char except newline
* `^`      → Start of string
* `$`      → End of string
* `\A` / `\Z` → Start / End of entire string
* `\b` / `\B` → Word boundary / Non-boundary
* `\n \r \t \f \v` → Newline, carriage return, tab, formfeed, vertical tab
* `\\`     → Literal backslash

#### **2. CHAR CLASSES**

* `[abc]`   → a, b, or c
* `[^abc]`  → Not a, b, or c
* `[a-z]`   → a to z
* `[0-9]`   → Digit
* `\d`     → Digit `[0-9]`
* `\D`     → Non-digit
* `\w`     → Word char `[a-zA-Z0-9_]`
* `\W`     → Non-word
* `\s`     → Whitespace
* `\S`     → Non-whitespace

#### **3. QUANTIFIERS**

* `*`     → 0 or more
* `+`     → 1 or more
* `?`     → 0 or 1
* `{n}`    → Exactly n
* `{n,}`   → n or more
* `{n,m}`  → Between n and m
* Append `?` to make *lazy*: `*?`, `+?`, etc.

#### **4. GROUPS & LOOKAROUNDS**

* `(abc)`   → Capturing group
* `(?:abc)`  → Non-capturing group
* `(?P<name>abc)` → Named group
* `(?=abc)`  → Lookahead
* `(?!abc)`  → Negative lookahead
* `(?<=abc)` → Lookbehind
* `(?<!abc)` → Negative lookbehind

#### **5. ALTERNATION**

* `a|b`   → a or b

#### **6. FLAGS (inline or in code)**

* `(?i)`     → Ignore case
* `(?m)`    → ^/\$ match linewise (multiline)
* `(?s)`    → Dot matches newline
* `(?x)`    → Ignore whitespace/comments
* `(?U)`    → Default lazy matching

#### **7. ESCAPES / SPECIALS**

* `\1, \2...`  → Backrefs
* `(?P=name)` → Named backref
* `\Q...\E`  → Quote literal chars
* `\cX`     → Control char
* `[\0-\x7F]` → ASCII range
* `\uFFFF` / `\xFF` → Unicode/hex

#### **8. COMMON PATTERNS**

* Email: `\b[\w.-]+@[\w.-]+\.\w{2,}\b`
* IP: `\b(?:\d{1,3}\.){3}\d{1,3}\b`
* URL: `https?://[^\s]+`
* Date: `\d{4}-\d{2}-\d{2}`
* Time: `\d{2}:\d{2}(:\d{2})?`

---

Let me know if you want a visual version or language-specific syntax (e.g., Python, JavaScript).

