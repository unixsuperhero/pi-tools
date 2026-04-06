# Save Session as HTML

Export the current Claude session as a beautifully formatted HTML file.

## Instructions

### Step 1: Find the session transcript

Find this session's `.jsonl` transcript file in `~/.pi/agent/sessions/`. The file matching the current session ID is the one to parse. Use the most recently modified `.jsonl` file if the session ID is ambiguous.

### Step 2: Determine the filename

- If `{{slug}}` is provided, use it as the descriptive slug
- Otherwise, derive a 2-3 word slug from the session's main topic
- Format: `YYYYmmddHHMMSS-subject-matter.html`
- Examples: `20260307181500-gitignore-setup.html`, `20260307190000-ruby-refactoring.html`
- Save to `~/claude/prompts/exports/` (create the directory if it doesn't exist)

### Step 3: Parse the JSONL

Read the `.jsonl` file and process each line:

**Skip these entries entirely:**
- Messages where `isMeta: true`
- Entries of type `file-history-snapshot`
- The **last** user message containing `/save-prompt` or `save-prompt` and all turns after it (earlier `/save-prompt` calls mid-session should be included normally — only the final triggering invocation is excluded)

**For user messages:** extract text from content blocks; handle XML tags like `<bash-input>`, `<bash-stdout>` clearly

**For assistant messages:** show text blocks as-is; format `tool_use` blocks with tool name and input; associate `tool_result` entries (which appear as subsequent user messages) with their preceding tool call

### Step 4: Build the HTML

---

### Table of Contents
- Add a **Table of Contents** section at the top, after the header
- List each exchange as a numbered link (e.g., `<a href="#turn-1">`)
- Each link text should be a **concise 5-10 word summary** of what that Human prompt was about
- Style the TOC as a clean, scannable list with subtle styling matching the theme

### Content Organization
- Each Human message is a primary accordion section (expanded by default)
- Inside each Human section, show the Assistant's response
- Tool calls/results should be nested accordions (collapsed by default)
- The Assistant's final text response should be prominently highlighted

### Anchor Links for Sharing

Every turn and every tool/result accordion must have a unique `id` attribute:
- Conversation turns: `id="turn-{N}"` where N is the zero-based index
- Tool calls inside a turn: `id="turn-{N}-tool-{M}"` where M is the tool index within that turn
- Tool results: `id="turn-{N}-result-{M}"`

Each turn's role label (the header bar showing "👤 Human" or "🤖 Assistant") must include an anchor link `<a href="#{id}">` in the top-right corner styled as a subtle `§` symbol that becomes visible on hover. Clicking it updates the URL hash.

Add a JavaScript snippet that:
1. On page load, if there is a hash in the URL, scrolls to and opens (`open`) the matching `<details>` element and its parent `<details>` if nested
2. When an anchor link is clicked, updates `window.location.hash` to the element's id

### CRITICAL: Verbatim Content Preservation
- **NEVER rewrite, summarize, paraphrase, or abbreviate** the Human's prompts — include the full, exact text as written
- **NEVER rewrite, summarize, paraphrase, or abbreviate** the Assistant's responses — include the full, exact text as written
- The only content that may be summarized is the TOC link text (which is a brief label, not a replacement for the actual content)
- HTML-escape special characters (`<`, `>`, `&`, etc.) but do NOT alter the wording in any way
- If a message is long, that's fine — display it in full. Do NOT truncate or add "..." or "[continued]"

### Tool Call Details
For each tool call, include comprehensive details (all collapsed by default):
- **Tool name** prominently displayed in the summary
- **Input/Parameters**: Show the full parameters passed to the tool (file paths, commands, content)
- **Output/Result**: Show the actual result returned by the tool
- Format code/content in tool calls with proper syntax highlighting
- For file edits: show old_string and new_string
- For bash commands: group the command and output in one code block with `$ ` prefix:
  ```
  $ pwd
  /Users/josh
  ```
- For file reads/writes: show the file path and relevant content

---

## Design Direction: "Obsidian Editorial"

A sophisticated, high-contrast design inspired by luxury magazine editorial layouts meets Bloomberg terminal aesthetics. Think: Monocle magazine meets financial data visualization.

### Typography (Google Fonts)
- **Display/Headers:** "Instrument Serif" — elegant, sharp serifs with editorial character
- **Body text:** "DM Sans" — clean, geometric sans with excellent readability
- **Code/Technical:** "IBM Plex Mono" — distinctive monospace with personality

### Color Palette

```css
:root {
  /* Backgrounds - Deep obsidian with warm undertones */
  --bg-void: #08080a;
  --bg-surface: #121217;
  --bg-elevated: #1a1a22;
  --bg-overlay: #242430;
  
  /* Accent: Warm gold/champagne - NOT typical cyan */
  --accent-primary: #d4a853;
  --accent-glow: rgba(212, 168, 83, 0.15);
  --accent-bright: #f0c96d;
  
  /* Secondary accent: Soft coral for contrast */
  --accent-secondary: #e8735a;
  --accent-secondary-muted: rgba(232, 115, 90, 0.2);
  
  /* Text hierarchy - warm whites, not pure white */
  --text-headline: #faf8f5;
  --text-body: #d8d4cc;
  --text-muted: #8a8680;
  --text-faint: #5a5854;
  
  /* Code colors - mint green for readability */
  --code-text: #a8e6cf;
  --code-bg: #0d0d12;
  
  /* Borders and lines */
  --border-subtle: rgba(212, 168, 83, 0.12);
  --border-accent: rgba(212, 168, 83, 0.3);
  
  /* Shadows */
  --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.4);
  --shadow-md: 0 8px 32px rgba(0, 0, 0, 0.5);
  --shadow-glow: 0 0 40px rgba(212, 168, 83, 0.1);
}
```

### Visual Details

**Background Treatment:**
- Base: Near-black with subtle warm undertones (#08080a)
- Subtle grain texture overlay (CSS noise pattern, opacity 0.03)
- NO scan-lines (too cliché)

**Cards & Containers:**
- Subtle gradient backgrounds (vertical, very subtle)
- Thin gold border on left edge only (editorial accent line)
- Generous padding (2rem+)
- Rounded corners: 2px only (sharp, not bubbly)

**Human Messages:**
- Left border: 3px solid gold accent
- Background: slightly elevated surface
- Header: Gold text on transparent, uppercase tracking

**Assistant Responses:**
- Background: Darker than human messages
- Header: Coral accent color
- Final response: Elevated background with subtle gold glow

**Tool Calls:**
- Collapsed by default
- Summary: Monospace font, muted appearance
- Expanded: Dark code background with mint-green text

**Typography Details:**
- Headlines: Instrument Serif, normal weight, generous letter-spacing (-0.02em)
- Body: DM Sans, 1.1rem, line-height 1.7
- Code: IBM Plex Mono, 0.9rem
- Uppercase labels with wide tracking (0.15em)

**Micro-interactions:**
- Hover on cards: subtle elevation increase (shadow)
- Accordion open/close: 250ms ease-out
- Anchor links: fade in on hover (opacity 0 → 1)
- No bouncy or playful animations (keep it refined)

**Layout:**
- Max-width: 820px (narrower = more editorial)
- Asymmetric margins on content blocks
- TOC: Fixed position on wide screens, inline on mobile

---

### HTML Template Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Session — [TOPIC]</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&family=Instrument+Serif&display=swap" rel="stylesheet">
  <style>
    /* CSS variables from palette above */
    /* Reset and base styles */
    /* Grain texture overlay */
    /* Container and layout */
    /* Header styles */
    /* TOC styles */
    /* Human block styles */
    /* Assistant block styles */
    /* Tool call styles */
    /* Code block styles */
    /* Accordion animations */
    /* Anchor link hover states */
    /* Responsive breakpoints */
  </style>
</head>
<body>
  <div class="grain-overlay"></div>
  
  <main class="container">
    <header class="masthead">
      <div class="masthead-label">SESSION TRANSCRIPT</div>
      <h1 class="masthead-title">[Topic Title]</h1>
      <time class="masthead-date">[Formatted Date]</time>
    </header>

    <nav class="toc">
      <div class="toc-label">CONTENTS</div>
      <ol class="toc-list">
        <!-- TOC items -->
      </ol>
    </nav>

    <section class="transcript">
      <!-- Exchange blocks -->
      <article class="exchange" id="turn-0">
        <details class="human-block" open>
          <summary class="human-header">
            <span class="role-label">HUMAN</span>
            <span class="turn-number">#1</span>
            <a class="anchor" href="#turn-0">§</a>
          </summary>
          <div class="human-body">
            <!-- Content -->
          </div>
          
          <div class="assistant-block" id="turn-1">
            <div class="assistant-header">
              <span class="role-label">ASSISTANT</span>
              <a class="anchor" href="#turn-1">§</a>
            </div>
            
            <details class="tools-block">
              <summary class="tools-summary">
                <span class="tools-count">N tool calls</span>
              </summary>
              <!-- Tool details -->
            </details>
            
            <div class="response-body">
              <!-- Final response -->
            </div>
          </div>
        </details>
      </article>
    </section>
  </main>

  <script>
    /* Hash navigation */
    /* Accordion state management */
  </script>
</body>
</html>
```

---

### Execution

1. Find and read the session's `.jsonl` transcript from `~/.pi/agent/sessions/`
2. Parse entries per the rules above
3. Build the HTML with all exchanges using the "Obsidian Editorial" design
4. Write the file with the timestamped name to `~/claude/prompts/exports/`
5. Run: `open [filename]` to preview

Now generate the complete HTML file with all the conversation content from this session and open it.
