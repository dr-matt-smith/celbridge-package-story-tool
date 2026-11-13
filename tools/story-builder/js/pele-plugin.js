// Draws ```mermaid code blocks with Pele (https://github.com/obsidianmd/pele), in place of Marp's own Mermaid
// plugin (beautiful-mermaid). It has the same shape as Marp's plugins and the nomnoml one (a default export that
// makes a markdown-it plugin), so the story editor loads it beside them. Pele lays a diagram out synchronously,
// which is what lets it render inside Marp's render().
//
// Why Pele: it supports every diagram type built into Mermaid 12.1.0 (beautiful-mermaid silently drops what it
// doesn't understand), and its SVG is self-contained: every colour is a CSS variable set on the <svg> element
// itself, with a fallback value, and every label is plain SVG <text> (no foreignObject).
//
// What you see is what the PDF gets: each diagram is put on the slide as an <img> holding that SVG, not as an
// inline <svg>. The PDF export (html2canvas) mis-places and crops an inline <svg> that is narrower than the
// slide, but paints an <img> exactly where the browser shows it. So play, the node preview and the PDF page all
// draw the very same image, and nothing in it depends on the page's stylesheets. For the same reason no
// --pele-* theme variables are set from the slide theme: Pele's own default colours are used everywhere.
//
// Pele itself is vendored in vendor/pele-1.13.0.js (its dist/pele.js, MIT licence in vendor/LICENSE-pele). It has
// no dependencies, so the editor needs no network to draw a diagram.
import { render } from "./vendor/pele-1.13.0.js";

const LANGUAGE = "mermaid";

// A font every viewer has, so the text Pele measures is the text that is drawn: on screen and in the PDF.
const FONT_FAMILY = "'Helvetica Neue', Helvetica, Arial, sans-serif";

// Pele draws at 16px text. A diagram is shown at up to this many times its natural size, so its text comes out
// about the size of the slide's own text, instead of a small diagram being blown up to fill the whole width.
const MAX_SCALE = 2;

// The room a diagram has on a slide: the width inside the default theme's padding on a 1280 x 720 slide, and the
// height the default theme gives a Mermaid diagram. A larger diagram is scaled down HERE, to fit, rather than left
// to CSS: Celbridge's PDF export paints an image at the size it was made, so an image shrunk by CSS
// (max-width: 100%) came out at full size in the PDF and was cut off at the slide's edge.
const MAX_WIDTH = 1120;
const MAX_HEIGHT = 563;

// Transition labels in a state diagram: Pele puts each one in the middle of its arrow, on a small box in the
// background colour, so the arrow is drawn with a gap. By default this plugin moves the label of a horizontal arrow
// to just above the line and drops the box, so the arrow is unbroken (the usual look of a UML state chart). Labels
// on vertical or slanted arrows are left as Pele placed them, since lifting them would put them on the line.
//
// In a crowded diagram a lifted label can run into a state or another label. To get Pele's own placement back,
// write this comment on the slide, anywhere before the diagram (it applies to every diagram after it on that slide):
//
//   <!-- pele: labels-on-line -->
//
// or put this line inside the ```mermaid block itself (a Mermaid comment, so it is ignored everywhere else):
//
//   %% pele: labels-on-line
const LABELS_ON_LINE = "labels-on-line";
const LABEL_GAP = 4; // between the line and the bottom of the label text (descenders included)
const LABEL_DESCENT = 4; // how far 14px text reaches below its baseline

// The straight horizontal pieces of an SVG path, as {y, x1, x2}. Pele writes absolute commands; curves (C, Q, ...)
// only move the current point here, since a curve is never a straight horizontal line.
function horizontalSegments(d) {
  const segments = [];
  let x = 0, y = 0;
  for (const [, command, args] of d.matchAll(/([A-Za-z])([^A-Za-z]*)/g)) {
    const n = args.split(/[\s,]+/).filter(Boolean).map(Number);
    if (command === "L" || command === "H") {
      const [nx, ny] = command === "L" ? n.slice(-2) : [n[n.length - 1], y];
      if (Math.abs(ny - y) < 0.5) segments.push({ y, x1: Math.min(x, nx), x2: Math.max(x, nx) });
      [x, y] = [nx, ny];
    } else if (command === "V") y = n[n.length - 1];
    else if (n.length >= 2) [x, y] = n.slice(-2);
  }
  return segments;
}

// Moves the labels of horizontal transitions above the line (see LABELS_ON_LINE). Returns the SVG and its height,
// which grows if a label in the top row would otherwise stick out of the picture.
function labelsAboveArrows(svg, height) {
  if (!/class="pele pele-state\b/.test(svg)) return { svg, height };
  const edgePaths = new Map();
  for (const [, id, d] of svg.matchAll(/<g class="pele-edge\b[^"]*" data-id="([^"]+)"><path d="([^"]+)"/g)) {
    edgePaths.set(id, d);
  }
  let top = 0;
  const lifted = svg.replace(
    /(<g class="pele-edge-label" data-id="([^"]+)">)<rect x="([\d.-]+)" y="([\d.-]+)" width="([\d.-]+)" height="([\d.-]+)"[^>]*\/>(<text[^>]*?) y="[\d.-]+"/g,
    (match, open, id, rx, ry, rw, rh, text) => {
      const cx = +rx + +rw / 2;
      const cy = +ry + +rh / 2;
      const line = horizontalSegments(edgePaths.get(id) ?? "")
        .find((s) => Math.abs(s.y - cy) < 1 && s.x1 <= cx && cx <= s.x2);
      if (!line) return match;
      const baseline = line.y - LABEL_GAP - LABEL_DESCENT;
      top = Math.min(top, baseline - +rh + LABEL_DESCENT);
      return `${open}${text} y="${baseline}"`;
    },
  );
  if (top >= 0) return { svg: lifted, height };
  // Grow the picture upwards: the viewBox starts higher and the height goes up by the same amount.
  const extra = Math.ceil(-top);
  const grown = lifted.replace(/viewBox="([\d.-]+) ([\d.-]+) ([\d.-]+) ([\d.-]+)"/, (_, x, y, w, h) =>
    `viewBox="${x} ${+y - extra} ${w} ${+h + extra}"`);
  return { svg: grown.replace(/\bheight="[\d.]+"/, `height="${height + extra}"`), height: height + extra };
}

// Whether the author asked for Pele's own label placement for the diagram in tokens[idx]: a %% comment inside the
// block, or a <!-- pele: labels-on-line --> comment earlier on the same slide (Marp turns it into a marpit_comment
// token).
function wantsLabelsOnLine(tokens, idx) {
  if (new RegExp(`^\\s*%%\\s*pele:\\s*${LABELS_ON_LINE}\\s*$`, "m").test(tokens[idx].content)) return true;
  for (let i = idx - 1; i >= 0 && tokens[i].type !== "marpit_slide_open"; i--) {
    if (tokens[i].type === "marpit_comment" && tokens[i].meta?.marpitParsedDirectives?.pele === LABELS_ON_LINE) {
      return true;
    }
  }
  return false;
}

const escapeAttribute = (text) => text.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;");

// The diagram as an <img>. The SVG is given the exact size it is shown at as plain width and height attributes,
// so nothing has to stretch or shrink the image afterwards, and Pele's own inline sizing (max-width:100%;
// height:auto) is taken out, since inside a standalone image a percentage width means something else.
function diagramImage(svg, width, height, alt) {
  const scale = Math.min(MAX_SCALE, MAX_WIDTH / width, MAX_HEIGHT / height);
  const w = Math.round(width * scale);
  const h = Math.round(height * scale);
  const standalone = svg
    .replace(/\bwidth="[^"]*"/, `width="${w}"`)
    .replace(/\bheight="[^"]*"/, `height="${h}"`)
    .replace(/\bstyle="max-width:100%;height:auto;/, 'style="');
  const src = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(standalone)}`;
  return `<img data-pele width="${w}" height="${h}" alt="${escapeAttribute(alt)}" src="${src}">`;
}

export default function pelePlugin() {
  return (md) => {
    // Wraps the fence renderer already in place (Shiki's, when it is loaded first), so any other code block,
    // and a diagram that fails to parse, still renders as highlighted code.
    const renderFence = md.renderer.rules.fence;

    md.renderer.rules.fence = (tokens, idx, options, env, self) => {
      const token = tokens[idx];
      const [language] = md.utils.unescapeAll(token.info).trim().split(/\s+/, 1);

      if (language === LANGUAGE) {
        try {
          const drawn = render(token.content, { fontFamily: FONT_FAMILY });
          const { width, type } = drawn;
          const { svg, height } = wantsLabelsOnLine(tokens, idx) ? drawn : labelsAboveArrows(drawn.svg, drawn.height);
          return `<p>${diagramImage(svg, width, height, `${type} diagram`)}</p>\n`;
        } catch (e) {
          // A syntax error shows the source as a code block, so the author can see what to fix. The
          // preview renders as the author types, so only the message is logged, not the stack.
          console.warn("[Story] Failed to draw a Mermaid diagram:", e?.message ?? e);
        }
      }

      return renderFence(tokens, idx, options, env, self);
    };
  };
}
