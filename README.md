# Story Builder - a Celbridge package for slide decks and branching stories

**Story Builder** is a [Celbridge](https://celbridge.org/) package that adds an editor for `.story` files: slide
decks and choose-your-own-adventure stories built from Markdown passages, laid out as a graph or a list, previewed
as you type, presented full screen, and exported to PDF.

Each passage (node) is one [Marp](https://marp.app/) slide, so a node can hold headings, lists, code with syntax
highlighting, maths, images - and **diagrams written as text**:

- ```` ```mermaid ```` - flowcharts, state diagrams, sequence diagrams (Marp's Mermaid plugin)
- ```` ```nomnoml ```` - UML class and object diagrams ([nomnoml](https://nomnoml.com/), through the package's own plugin)

Because diagrams are text inside the slide, they can be edited, reused and updated like the rest of the deck.

The current release is **version 6**, which adds fullscreen play with keyboard controls, and PDFs that are
smaller, have selectable and searchable text, and keep the story's choice links clickable.

## What's here

| Path | What it is |
|---|---|
| `tools/story-builder/` | the package itself: `package.toml`, the editor (`index.html`, `js/`, `css/`), localization, the "Empty Story" template, and the design notes (`README_PROTOTYPE.md`, and the design and implementation plan for each version in `TDDs/`, e.g. `TDDs/version06_design.md`) |
| `stories/` | example decks: Marp/Mermaid/nomnoml examples, an introduction to design patterns, a one-slide maths deck, and a week's slides on the Observer pattern |
| `web_pages/` | standalone HTML pages of Mermaid examples (flowchart, pie chart, class diagram, Kanban board) sharing `style.css`; they load Mermaid from a CDN |
| `scripts/story_pdf.ts` | builds a deck's PDF from the command line, using the editor's own PDF export (see below) |
| `celbridge-package-story-tool.celbridge` | this folder is itself a Celbridge project - open it to try the editor |

## Using it

1. Open this folder in Celbridge. `README.md` and `stories/examples.story` open by themselves.
2. In the Story editor:
   - the **graph** view shows the passages as boxes and the links between them as arrows; the **list** view shows the
     default sequence, which you can reorder by dragging
   - select a node to edit its Markdown; the text-view buttons switch between source, preview, and side-by-side or
     stacked splits
   - **Play** presents the deck from the selected node (or the first one), with optional previous/next arrows and
     slide numbers (set in **Settings**); the slide grows to fill the space available
   - while playing, the **Fullscreen** button (or `F`) hides the rest of the editor; `Esc` leaves fullscreen,
     `→` / `Page Down` / `Space` and `←` / `Page Up` move through the default sequence, and `Home` / `End` jump to
     the first and last node
   - **Download PDF** writes one page per slide, in the default sequence, at *Standard* (smaller file) or *High*
     quality. The text can be selected, searched and copied, and choice links jump to the right page
   - **Export** writes a spreadsheet of the passages for translation
3. To use the editor in another Celbridge project, copy `tools/story-builder/` into that project's `tools/` folder,
   as it is here.

A `.story` file is a pretty-printed JSON object - the story's name and description, its settings, and a `nodes`
array of `{ name, x, y, text }` in default-sequence order - so it diffs well in version control. Links between
passages are ordinary Markdown links whose target is a node name: `[Open the door](Hallway)`.

## Building PDFs from the command line

`scripts/story_pdf.ts` opens the real editor page in headless Chromium, hands it the `.story` file through a small
stand-in for the Celbridge client, and presses the editor's own **Download PDF** button - so the result is the same
PDF the button makes inside Celbridge. It needs [Deno](https://deno.com/), a network connection (the editor loads
Marp, html2canvas and jsPDF from esm.sh), a headless Chromium (`CHROME`, default Playwright's
`chrome-headless-shell` on macOS) and an installed Celbridge (`CELBRIDGE_CLIENT`, default inside
`/Applications/Celbridge.app`):

```bash
deno run -A scripts/story_pdf.ts stories/examples.story
deno run -A scripts/story_pdf.ts stories
```

## Notes

- **Fullscreen on macOS fills the editor, not the screen.** Celbridge's macOS WebView has no Fullscreen API, so the
  button hides the toolbar and the slide fills the document area. Windows should get true fullscreen (not yet
  tested).
- **PDF text is Latin-1 only.** Each page is a picture of the slide with invisible text over it. Characters outside
  Latin-1 (arrows, maths symbols, CJK, emoji) show in the picture but can't be selected; curly quotes and dashes
  copy as plain ASCII. Text inside Mermaid, nomnoml and KaTeX isn't selectable.
- **Slide layout in PDFs.** The PDF export rasterises each slide as plain HTML, so Marp's split backgrounds
  (`![bg right:40%](...)`) overlap the text there, and `<!-- fit -->` text keeps its natural size. Inline images work
  well: size wide pictures with `w:` and tall ones with `h:`.
- **Diagram size.** Mermaid and nomnoml diagrams are stretched to the slide width, with a capped height; a diagram
  under a few lines of text fits best when it is much wider than it is tall (`flowchart LR`, `#direction: right`).
- **nomnoml is vendored, with a fix.** nomnoml 1.7.0's SVG output gave every arrowhead and edge label in a diagram
  the colour of the last arrowhead drawn, so labels could vanish or hollow inheritance triangles turn solid. The
  package carries nomnoml in `tools/story-builder/js/vendor/nomnoml-1.7.0-patched.js` with a two-line fix (see
  `README_PROTOTYPE.md`, section 7, and the top of that file). nomnoml is MIT licensed
  (`tools/story-builder/js/vendor/LICENSE-nomnoml`).
- **Mermaid quirks** in the renderer used (beautiful-mermaid, behind Marp's plugin): entity codes such as `#lt;` show
  literally (write `<` inside a quoted label instead); a dashed back-edge can scramble a flowchart's layout;
  `Note over` in sequence diagrams may be dropped. `<br/>`, `<b>` and `<i>` work in labels.
- **Libraries load from a CDN** on first play, preview render or PDF export; the editor still opens, edits and saves
  offline.

## Licence

MIT - see [LICENSE](LICENSE). The vendored nomnoml is also MIT licensed, under its own copyright
(`tools/story-builder/js/vendor/LICENSE-nomnoml`).
