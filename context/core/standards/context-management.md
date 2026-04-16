# Context Window Management Rules

- Read files with targeted line ranges using `offset` and `limit` parameters — avoid reading entire large files
- Use `grep` to locate specific code patterns before reading full files — this finds the exact lines you need
- Use `glob` to find files by name pattern instead of recursive directory listing
- When a file read returns >100 lines, immediately summarize the parts relevant to your task in 3-5 lines
- Summarize build and test output: extract pass/fail, error messages, and affected file paths only
- When you notice you're re-reading a file you already processed, use your earlier summary instead
- If you find yourself making repeated identical tool calls, stop and reassess your approach
- Maximum recommended file read: 200 lines at a time. Use `offset` for larger files
- When the conversation feels sluggish or you notice degraded performance, suggest `/compact` to the user
- Prefer specific searches (grep for a class name) over broad exploration (reading entire directories)
