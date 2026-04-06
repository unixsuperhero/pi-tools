---
description: Convert current session to markdown and HTML with custom pi-session template
---
Convert the current pi session to markdown and HTML using the existing session JSONL file.

Please use your bash tool to:
1. Find the current session file in `~/.pi/agent/sessions/--<project-path>--/`
2. Convert it to markdown and HTML using: `jsonl2md <session-file> --html --title "${1:-Session Documentation}" ${@:2}`

This uses a custom pandoc template specifically designed for pi sessions with:
- Beautiful technical editorial design
- Role-specific message styling (user/assistant/tool)
- Collapsible thinking blocks
- Smooth animations and modern typography

Args:
- $1: HTML title (default: "Session Documentation")
- $2+: additional options (e.g., "--no-open")
