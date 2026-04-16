# Context Window Rules
- Targeted reads: use `offset`+`limit`, max 200 lines. Use `grep`/`glob` first.
- Summarize >100 line reads in 3-5 lines. Reuse prior summaries, don't re-read.
- Suggest `/compact` when sluggish.
