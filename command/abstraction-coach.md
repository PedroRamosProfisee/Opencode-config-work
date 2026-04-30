---
description: Start an interactive abstraction coaching session to practice pseudocode-altitude thinking and commenting
---

Load the abstraction-coach skill and begin an interactive coaching session.

If a file path is provided as an argument (e.g. `/abstraction-coach src/api/MyService.cs`):
1. Read the file at that path
2. Let the user know what was loaded and give a brief one-line summary of what the file appears to do
3. Ask the user which method or class they want to focus on — list the top-level members found in the file so they can pick one
4. Begin the 5-step coaching loop on the chosen target

If no file path is provided:
- Ask the user to paste a method or class directly into the chat to begin
