// Draws ```nomnoml code blocks as UML diagrams, the way Marp's Mermaid plugin draws ```mermaid blocks. It has the
// same shape as Marp's own plugins (a default export that makes a markdown-it plugin), so the story editor loads
// it beside them. nomnoml lays a diagram out synchronously, which is what lets it render inside Marp's render().
//
// nomnoml itself is vendored in vendor/nomnoml-1.7.0-patched.js, with a fix for arrowhead and edge-label colours
// in SVG output (see the top of that file). It is the package's UMD build, which reads its one dependency,
// graphre (the layout engine), from globalThis - so graphre is loaded first and put there.
import * as graphreModule from "https://esm.sh/graphre@0.1.3";

globalThis.graphre = graphreModule.default ?? graphreModule;
await import(new URL("./vendor/nomnoml-1.7.0-patched.js", import.meta.url).href);
const { renderSvg } = globalThis.nomnoml;

const LANGUAGE = "nomnoml";

// nomnoml draws a diagram small, with text smaller than the slide's own, so it is enlarged up to twice its natural
// size, as js/pele-plugin.js does for Mermaid, but never stretched to fill the slide. A diagram too big for the
// room a slide has (the width inside the default theme's padding, and the height the theme gives a diagram) is
// scaled down to fit instead.
const MAX_SCALE = 2;
const MAX_WIDTH = 1120;
const MAX_HEIGHT = 563;

// Sets the size the diagram is shown at on the <svg> element itself. The viewBox is left as drawn, so the
// drawing scales with it.
function sizeDiagram(svg) {
  return svg.replace(/^<svg\b[^>]*>/, (tag) => {
    const width = parseFloat(tag.match(/\swidth="([\d.]+)"/)?.[1]);
    const height = parseFloat(tag.match(/\sheight="([\d.]+)"/)?.[1]);
    if (!(width > 0 && height > 0)) return tag;

    const scale = Math.min(MAX_SCALE, MAX_WIDTH / width, MAX_HEIGHT / height);
    return tag
      .replace(/\swidth="[\d.]+"/, ` width="${Math.round(width * scale)}"`)
      .replace(/\sheight="[\d.]+"/, ` height="${Math.round(height * scale)}"`);
  });
}

// A custom style directive, such as `#.tesco: visual=package fill=pink`: the name and colon, then the options.
const STYLE_DIRECTIVE = /^(\s*#\.[^:\s]+\s*:)(.*)$/gm;

// nomnoml draws a package's tab at its left, just as wide as the name, and its built-in <package> style
// left-aligns the name to sit in it. A custom style centres its title unless told otherwise, so a custom style
// drawn as a package puts its name in the middle of the package, outside the tab. The alignment is filled in
// here, unless the style already says where its title goes (title=left or title=center, or align=).
function alignPackageTitles(source) {
  return source.replace(STYLE_DIRECTIVE, (directive, head, options) => {
    if (!/(^|\s)visual=package(\s|$)/.test(options) || /(^|\s)align=/.test(options)) return directive;

    const title = options.match(/(^|\s)title=([^\s]*)/);
    if (!title) return `${head}${options.replace(/\s*$/, "")} title=left`;
    if (/\b(left|center)\b/.test(title[2])) return directive;
    return head + options.replace(`title=${title[2]}`, `title=${title[2] ? `${title[2]},` : ""}left`);
  });
}

export default function nomnomlPlugin() {
  return (md) => {
    // Wraps the fence renderer already in place (Shiki's, when it is loaded first), so any other code block,
    // and a diagram that fails to parse, still renders as highlighted code.
    const renderFence = md.renderer.rules.fence;

    md.renderer.rules.fence = (tokens, idx, options, env, self) => {
      const token = tokens[idx];
      const [language] = md.utils.unescapeAll(token.info).trim().split(/\s+/, 1);

      if (language === LANGUAGE) {
        try {
          const svg = sizeDiagram(renderSvg(alignPackageTitles(token.content))).replace(/^<svg\b/, "<svg data-nomnoml");
          return `<p>${svg}</p>\n`;
        } catch (e) {
          // A syntax error shows the source as a code block, so the author can see what to fix. The
          // preview renders as the author types, so only the message is logged, not the stack.
          console.warn("[Story] Failed to draw a nomnoml diagram:", e?.message ?? e);
        }
      }

      return renderFence(tokens, idx, options, env, self);
    };
  };
}
