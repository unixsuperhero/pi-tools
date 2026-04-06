---
description: Save previous response as markdown and convert to HTML with mdoc
---
Take my previous response and:

1. Save it as a markdown file in `~/pi/mds/` with filename: ${1:-response}.md
2. Run `mdoc --toc --title "${2:-Documentation}" ~/pi/mds/${1:-response}.md` to convert to HTML
3. ${@:3} contains options:
   - If "noopen" is specified, don't open the HTML file
   - If "noopen" is NOT specified, open the HTML file in the browser

Use appropriate title based on the content if no title argument provided.