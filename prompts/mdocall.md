---
description: Convert current Pi session to professional HTML documentation with editorial design
---
# Export Pi Session as Professional HTML Documentation

Convert the current Pi coding session to a beautifully formatted HTML document with professional editorial design.

## Instructions

### Step 1: Find the Current Session
Locate this session's `.jsonl` transcript in `~/.pi/agent/sessions/--<project-path>--/`. Use the most recently modified file matching the current session.

### Step 2: Generate Documentation
Execute the conversion using our enhanced system:
```bash
jsonl2md <session-file> --html --title "${1:-Pi Session Documentation}" ${@:2}
```

### Step 3: Content Processing
The system processes the JSONL with these improvements:

**Enhanced Organization:**
- **Conversation pairs** - User prompts grouped with complete agent responses
- **Tool call integration** - Commands and outputs paired together
- **Professional navigation** - Table of contents with clickable user prompt previews
- **Anchor linking** - Each conversation can be directly shared via URL hash

**Content Preservation:**
- **NEVER summarize or truncate** user prompts or agent responses
- **Complete tool outputs** - Full command results, not abbreviated
- **Exact file paths** with copy buttons for easy reuse
- **Verbatim code blocks** with syntax highlighting

### Step 4: Professional Design Features

**"Obsidian Editorial" Aesthetic:**
- **Typography**: Editorial-quality fonts (Instrument Serif headlines, DM Sans body)
- **Color Palette**: Deep obsidian backgrounds with warm gold accents
- **Layout**: Magazine-inspired with asymmetric margins and generous whitespace
- **Interactive Elements**: Smooth accordions, hover states, anchor links

**Technical Sophistication:**
- **Responsive design** - Perfect on desktop and mobile
- **Fast navigation** - TOC with user prompt previews
- **Copy functionality** - One-click copying of commands, outputs, file paths
- **Hash navigation** - Direct linking to specific conversations

### Step 5: Output Location
- **Markdown**: `~/pi/mds/` (intermediate format)
- **HTML**: `~/claude/docs/` (final professional documentation)
- **Auto-open**: Browser preview unless `--no-open` specified

## Usage Examples

```bash
# Basic conversion with auto-generated title
/mdocall

# Custom title
/mdocall "API Integration Session"

# Generate without opening browser
/mdocall "Backend Refactoring" --no-open

# With additional pandoc options
/mdocall "Database Migration" --standalone
```

## Design Philosophy

This generates **professional-grade technical documentation** suitable for:
- **Project retrospectives** - Review development decisions and problem-solving approaches
- **Knowledge sharing** - Share detailed technical sessions with team members
- **Documentation archives** - Preserve complete context of development processes
- **Learning resources** - Study problem-solving patterns and tool usage

The output combines the comprehensive detail of development logs with the visual polish of professional technical publications.

Args:
- $1: HTML document title (default: "Pi Session Documentation")
- $2+: additional options (e.g., "--no-open", pandoc flags)
