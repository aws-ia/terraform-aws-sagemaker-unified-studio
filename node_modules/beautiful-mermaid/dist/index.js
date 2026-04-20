// src/theme.ts
var DEFAULTS = {
  bg: "#FFFFFF",
  fg: "#27272A"
};
var MIX = {
  /** Primary text: near-full fg */
  text: 100,
  // just use --fg directly
  /** Secondary text (group headers): fg mixed at 60% */
  textSec: 60,
  /** Muted text (edge labels, notes): fg mixed at 40% */
  textMuted: 40,
  /** Faint text (de-emphasized): fg mixed at 25% */
  textFaint: 25,
  /** Edge/connector lines: fg mixed at 50% for clear visibility */
  line: 50,
  /** Arrow head fill: fg mixed at 85% for clear visibility */
  arrow: 85,
  /** Node fill tint: fg mixed at 3% */
  nodeFill: 3,
  /** Node/group stroke: fg mixed at 20% */
  nodeStroke: 20,
  /** Group header band tint: fg mixed at 5% */
  groupHeader: 5,
  /** Inner divider strokes: fg mixed at 12% */
  innerStroke: 12,
  /** Key badge background opacity (ER diagrams) */
  keyBadge: 10
};
var THEMES = {
  "zinc-light": {
    bg: "#FFFFFF",
    fg: "#27272A"
  },
  "zinc-dark": {
    bg: "#18181B",
    fg: "#FAFAFA"
  },
  "tokyo-night": {
    bg: "#1a1b26",
    fg: "#a9b1d6",
    line: "#3d59a1",
    accent: "#7aa2f7",
    muted: "#565f89"
  },
  "tokyo-night-storm": {
    bg: "#24283b",
    fg: "#a9b1d6",
    line: "#3d59a1",
    accent: "#7aa2f7",
    muted: "#565f89"
  },
  "tokyo-night-light": {
    bg: "#d5d6db",
    fg: "#343b58",
    line: "#34548a",
    accent: "#34548a",
    muted: "#9699a3"
  },
  "catppuccin-mocha": {
    bg: "#1e1e2e",
    fg: "#cdd6f4",
    line: "#585b70",
    accent: "#cba6f7",
    muted: "#6c7086"
  },
  "catppuccin-latte": {
    bg: "#eff1f5",
    fg: "#4c4f69",
    line: "#9ca0b0",
    accent: "#8839ef",
    muted: "#9ca0b0"
  },
  "nord": {
    bg: "#2e3440",
    fg: "#d8dee9",
    line: "#4c566a",
    accent: "#88c0d0",
    muted: "#616e88"
  },
  "nord-light": {
    bg: "#eceff4",
    fg: "#2e3440",
    line: "#aab1c0",
    accent: "#5e81ac",
    muted: "#7b88a1"
  },
  "dracula": {
    bg: "#282a36",
    fg: "#f8f8f2",
    line: "#6272a4",
    accent: "#bd93f9",
    muted: "#6272a4"
  },
  "github-light": {
    bg: "#ffffff",
    fg: "#1f2328",
    line: "#d1d9e0",
    accent: "#0969da",
    muted: "#59636e"
  },
  "github-dark": {
    bg: "#0d1117",
    fg: "#e6edf3",
    line: "#3d444d",
    accent: "#4493f8",
    muted: "#9198a1"
  },
  "solarized-light": {
    bg: "#fdf6e3",
    fg: "#657b83",
    line: "#93a1a1",
    accent: "#268bd2",
    muted: "#93a1a1"
  },
  "solarized-dark": {
    bg: "#002b36",
    fg: "#839496",
    line: "#586e75",
    accent: "#268bd2",
    muted: "#586e75"
  },
  "one-dark": {
    bg: "#282c34",
    fg: "#abb2bf",
    line: "#4b5263",
    accent: "#c678dd",
    muted: "#5c6370"
  }
};
function fromShikiTheme(theme) {
  const c = theme.colors ?? {};
  const dark = theme.type === "dark";
  const tokenColor = (scope) => theme.tokenColors?.find(
    (t) => Array.isArray(t.scope) ? t.scope.includes(scope) : t.scope === scope
  )?.settings?.foreground;
  return {
    bg: c["editor.background"] ?? (dark ? "#1e1e1e" : "#ffffff"),
    fg: c["editor.foreground"] ?? (dark ? "#d4d4d4" : "#333333"),
    line: c["editorLineNumber.foreground"] ?? void 0,
    accent: c["focusBorder"] ?? tokenColor("keyword") ?? void 0,
    muted: tokenColor("comment") ?? c["editorLineNumber.foreground"] ?? void 0,
    surface: c["editor.selectionBackground"] ?? void 0,
    border: c["editorWidget.border"] ?? void 0
  };
}
function buildStyleBlock(font, hasMonoFont) {
  const fontImports = [
    `@import url('https://fonts.googleapis.com/css2?family=${encodeURIComponent(font)}:wght@400;500;600;700&amp;display=swap');`,
    ...hasMonoFont ? [`@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&amp;display=swap');`] : []
  ];
  const derivedVars = `
    /* Derived from --bg and --fg (overridable via --line, --accent, etc.) */
    --_text:          var(--fg);
    --_text-sec:      var(--muted, color-mix(in srgb, var(--fg) ${MIX.textSec}%, var(--bg)));
    --_text-muted:    var(--muted, color-mix(in srgb, var(--fg) ${MIX.textMuted}%, var(--bg)));
    --_text-faint:    color-mix(in srgb, var(--fg) ${MIX.textFaint}%, var(--bg));
    --_line:          var(--line, color-mix(in srgb, var(--fg) ${MIX.line}%, var(--bg)));
    --_arrow:         var(--accent, color-mix(in srgb, var(--fg) ${MIX.arrow}%, var(--bg)));
    --_node-fill:     var(--surface, color-mix(in srgb, var(--fg) ${MIX.nodeFill}%, var(--bg)));
    --_node-stroke:   var(--border, color-mix(in srgb, var(--fg) ${MIX.nodeStroke}%, var(--bg)));
    --_group-fill:    var(--bg);
    --_group-hdr:     color-mix(in srgb, var(--fg) ${MIX.groupHeader}%, var(--bg));
    --_inner-stroke:  color-mix(in srgb, var(--fg) ${MIX.innerStroke}%, var(--bg));
    --_key-badge:     color-mix(in srgb, var(--fg) ${MIX.keyBadge}%, var(--bg));`;
  return [
    "<style>",
    `  ${fontImports.join("\n  ")}`,
    `  text { font-family: '${font}', system-ui, sans-serif; }`,
    ...hasMonoFont ? [`  .mono { font-family: 'JetBrains Mono', 'SF Mono', 'Fira Code', ui-monospace, monospace; }`] : [],
    `  svg {${derivedVars}`,
    `  }`,
    "</style>"
  ].join("\n");
}
function svgOpenTag(width, height, colors, transparent) {
  const vars = [
    `--bg:${colors.bg}`,
    `--fg:${colors.fg}`,
    colors.line ? `--line:${colors.line}` : "",
    colors.accent ? `--accent:${colors.accent}` : "",
    colors.muted ? `--muted:${colors.muted}` : "",
    colors.surface ? `--surface:${colors.surface}` : "",
    colors.border ? `--border:${colors.border}` : ""
  ].filter(Boolean).join(";");
  const bgStyle = transparent ? "" : ";background:var(--bg)";
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}" style="${vars}${bgStyle}">`;
}

// src/text-metrics.ts
var NARROW_CHARS = /* @__PURE__ */ new Set(["i", "l", "t", "f", "j", "I", "1", "!", "|", ".", ",", ":", ";", "'"]);
var WIDE_CHARS = /* @__PURE__ */ new Set(["W", "M", "w", "m", "@", "%"]);
var VERY_WIDE_CHARS = /* @__PURE__ */ new Set(["W", "M"]);
var SEMI_NARROW_PUNCT = /* @__PURE__ */ new Set(["(", ")", "[", "]", "{", "}", "/", "\\", "-", '"', "`"]);
function isCombiningMark(code) {
  return code >= 768 && code <= 879 || code >= 6832 && code <= 6911 || code >= 7616 && code <= 7679 || code >= 8400 && code <= 8447 || code >= 65056 && code <= 65071;
}
function isFullwidth(code) {
  return code >= 4352 && code <= 4447 || // Hangul Jamo
  code >= 11904 && code <= 12031 || // CJK Radicals Supplement
  code >= 12032 && code <= 12255 || // Kangxi Radicals
  code >= 12288 && code <= 12351 || // CJK Symbols and Punctuation
  code >= 12352 && code <= 12447 || // Hiragana
  code >= 12448 && code <= 12543 || // Katakana
  code >= 12544 && code <= 12591 || // Bopomofo
  code >= 12592 && code <= 12687 || // Hangul Compatibility Jamo
  code >= 12688 && code <= 12799 || // Kanbun + extensions
  code >= 12800 && code <= 13311 || // Enclosed CJK + Compatibility
  code >= 13312 && code <= 19903 || // CJK Extension A
  code >= 19968 && code <= 40959 || // CJK Unified Ideographs
  code >= 44032 && code <= 55215 || // Hangul Syllables
  code >= 63744 && code <= 64255 || // CJK Compatibility Ideographs
  code >= 65280 && code <= 65376 || // Fullwidth ASCII
  code >= 65504 && code <= 65510 || // Fullwidth symbols
  code >= 131072;
}
var EMOJI_REGEX = /\p{Emoji_Presentation}|\p{Extended_Pictographic}/u;
function isEmoji(char) {
  return EMOJI_REGEX.test(char);
}
function getCharWidth(char) {
  const code = char.codePointAt(0);
  if (code === void 0) return 0;
  if (isCombiningMark(code)) return 0;
  if (isFullwidth(code) || isEmoji(char)) return 2;
  if (char === " ") return 0.3;
  if (VERY_WIDE_CHARS.has(char)) return 1.5;
  if (WIDE_CHARS.has(char)) return 1.2;
  if (NARROW_CHARS.has(char)) return 0.4;
  if (SEMI_NARROW_PUNCT.has(char)) return 0.5;
  if (char === "r") return 0.8;
  if (code >= 65 && code <= 90) return 1.2;
  if (code >= 48 && code <= 57) return 1;
  return 1;
}
function measureTextWidth(text, fontSize, fontWeight) {
  const baseRatio = fontWeight >= 600 ? 0.6 : fontWeight >= 500 ? 0.57 : 0.54;
  let totalWidth = 0;
  for (const char of text) {
    totalWidth += getCharWidth(char);
  }
  const minPadding = fontSize * 0.15;
  return totalWidth * fontSize * baseRatio + minPadding;
}
var LINE_HEIGHT_RATIO = 1.3;
function measureMultilineText(text, fontSize, fontWeight) {
  const lines = text.split("\n");
  const lineHeight = fontSize * LINE_HEIGHT_RATIO;
  let maxWidth = 0;
  for (const line of lines) {
    const plain = line.replace(/<\/?(?:b|strong|i|em|u|s|del)\s*>/gi, "");
    const w = measureTextWidth(plain, fontSize, fontWeight);
    if (w > maxWidth) maxWidth = w;
  }
  return {
    width: maxWidth,
    height: lines.length * lineHeight,
    lines,
    lineHeight
  };
}

// src/multiline-utils.ts
function normalizeBrTags(label) {
  const unquoted = label.startsWith('"') && label.endsWith('"') ? label.slice(1, -1) : label;
  return unquoted.replace(/<br\s*\/?>/gi, "\n").replace(/\\n/g, "\n").replace(/<\/?(?:sub|sup|small|mark)\s*>/gi, "").replace(/\*\*(.+?)\*\*/g, "<b>$1</b>").replace(/(?<!\*)\*([^\s*](?:[^*]*[^\s*])?)\*(?!\*)/g, "<i>$1</i>").replace(/~~(.+?)~~/g, "<s>$1</s>");
}
function escapeXml(text) {
  return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}
var FORMAT_TAG_REGEX = /<(\/)?(?:(b|strong)|(i|em)|(u)|(s|del))\s*>/gi;
function parseInlineFormatting(line) {
  const segments = [];
  let bold = false, italic = false, underline = false, strikethrough = false;
  let lastIndex = 0;
  FORMAT_TAG_REGEX.lastIndex = 0;
  let match;
  while ((match = FORMAT_TAG_REGEX.exec(line)) !== null) {
    if (match.index > lastIndex) {
      segments.push({ text: line.slice(lastIndex, match.index), bold, italic, underline, strikethrough });
    }
    lastIndex = match.index + match[0].length;
    const isClosing = Boolean(match[1]);
    if (match[2]) bold = !isClosing;
    else if (match[3]) italic = !isClosing;
    else if (match[4]) underline = !isClosing;
    else if (match[5]) strikethrough = !isClosing;
  }
  if (lastIndex < line.length) {
    segments.push({ text: line.slice(lastIndex), bold, italic, underline, strikethrough });
  }
  return segments;
}
var HAS_FORMAT_TAGS = /<\/?(?:b|strong|i|em|u|s|del)\s*>/i;
function renderLineContent(line) {
  if (!HAS_FORMAT_TAGS.test(line)) return escapeXml(line);
  const segments = parseInlineFormatting(line);
  if (segments.length === 0) return "";
  const allPlain = segments.every((s) => !s.bold && !s.italic && !s.underline && !s.strikethrough);
  if (allPlain) return segments.map((s) => escapeXml(s.text)).join("");
  return segments.map((seg) => {
    const escaped = escapeXml(seg.text);
    if (!seg.bold && !seg.italic && !seg.underline && !seg.strikethrough) return escaped;
    const attrs = [];
    if (seg.bold) attrs.push('font-weight="bold"');
    if (seg.italic) attrs.push('font-style="italic"');
    const deco = [];
    if (seg.underline) deco.push("underline");
    if (seg.strikethrough) deco.push("line-through");
    if (deco.length) attrs.push(`text-decoration="${deco.join(" ")}"`);
    return `<tspan ${attrs.join(" ")}>${escaped}</tspan>`;
  }).join("");
}
function renderMultilineText(text, cx, cy, fontSize, attrs, baselineShift = 0.35) {
  const lines = text.split("\n");
  if (lines.length === 1) {
    const dy = fontSize * baselineShift;
    return `<text x="${cx}" y="${cy}" ${attrs} dy="${dy}">${renderLineContent(text)}</text>`;
  }
  const lineHeight = fontSize * LINE_HEIGHT_RATIO;
  const firstDy = -((lines.length - 1) / 2) * lineHeight + fontSize * baselineShift;
  const tspans = lines.map((line, i) => {
    const dy = i === 0 ? firstDy : lineHeight;
    return `<tspan x="${cx}" dy="${dy}">${renderLineContent(line)}</tspan>`;
  }).join("");
  return `<text x="${cx}" y="${cy}" ${attrs}>${tspans}</text>`;
}
function renderMultilineTextWithBackground(text, cx, cy, textWidth, textHeight, fontSize, padding, textAttrs, bgAttrs) {
  const bgWidth = textWidth + padding * 2;
  const bgHeight = textHeight + padding * 2;
  const rect = `<rect x="${cx - bgWidth / 2}" y="${cy - bgHeight / 2}" width="${bgWidth}" height="${bgHeight}" ${bgAttrs} />`;
  const textEl = renderMultilineText(text, cx, cy, fontSize, textAttrs);
  return `${rect}
${textEl}`;
}

// src/parser.ts
function parseMermaid(text) {
  const lines = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("%%"));
  if (lines.length === 0) {
    throw new Error("Empty mermaid diagram");
  }
  const header = lines[0];
  if (/^stateDiagram(-v2)?\s*$/i.test(header)) {
    return parseStateDiagram(lines);
  }
  return parseFlowchart(lines);
}
function parseFlowchart(lines) {
  const headerMatch = lines[0].match(/^(?:graph|flowchart)\s+(TD|TB|LR|BT|RL)\s*$/i);
  if (!headerMatch) {
    throw new Error(`Invalid mermaid header: "${lines[0]}". Expected "graph TD", "flowchart LR", "stateDiagram-v2", etc.`);
  }
  const direction = headerMatch[1].toUpperCase();
  const graph = {
    direction,
    nodes: /* @__PURE__ */ new Map(),
    edges: [],
    subgraphs: [],
    classDefs: /* @__PURE__ */ new Map(),
    classAssignments: /* @__PURE__ */ new Map(),
    nodeStyles: /* @__PURE__ */ new Map(),
    linkStyles: /* @__PURE__ */ new Map()
  };
  const subgraphStack = [];
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    const classDefMatch = line.match(/^classDef\s+(\w+)\s+(.+)$/);
    if (classDefMatch) {
      const name = classDefMatch[1];
      const propsStr = classDefMatch[2];
      const props = parseStyleProps(propsStr);
      graph.classDefs.set(name, props);
      continue;
    }
    const classAssignMatch = line.match(/^class\s+([\w,-]+)\s+(\w+)$/);
    if (classAssignMatch) {
      const nodeIds = classAssignMatch[1].split(",").map((s) => s.trim());
      const className = classAssignMatch[2];
      for (const id of nodeIds) {
        graph.classAssignments.set(id, className);
      }
      continue;
    }
    const styleMatch = line.match(/^style\s+([\w,-]+)\s+(.+)$/);
    if (styleMatch) {
      const nodeIds = styleMatch[1].split(",").map((s) => s.trim());
      const props = parseStyleProps(styleMatch[2]);
      for (const id of nodeIds) {
        graph.nodeStyles.set(id, { ...graph.nodeStyles.get(id), ...props });
      }
      continue;
    }
    const linkStyleMatch = line.match(/^linkStyle\s+(default|[\d,\s]+)\s+(.+)$/);
    if (linkStyleMatch) {
      const target = linkStyleMatch[1].trim();
      const props = parseStyleProps(linkStyleMatch[2]);
      if (target === "default") {
        graph.linkStyles.set("default", { ...graph.linkStyles.get("default"), ...props });
      } else {
        const indices = target.split(",").map((s) => parseInt(s.trim(), 10));
        for (const idx of indices) {
          if (!isNaN(idx)) {
            graph.linkStyles.set(idx, { ...graph.linkStyles.get(idx), ...props });
          }
        }
      }
      continue;
    }
    const dirMatch = line.match(/^direction\s+(TD|TB|LR|BT|RL)\s*$/i);
    if (dirMatch && subgraphStack.length > 0) {
      subgraphStack[subgraphStack.length - 1].direction = dirMatch[1].toUpperCase();
      continue;
    }
    const subgraphMatch = line.match(/^subgraph\s+(.+)$/);
    if (subgraphMatch) {
      const rest = subgraphMatch[1].trim();
      const bracketMatch = rest.match(/^([\w-]+)\s*\[(.+)\]$/);
      let id;
      let label;
      if (bracketMatch) {
        id = bracketMatch[1];
        label = normalizeBrTags(bracketMatch[2]);
      } else {
        label = normalizeBrTags(rest);
        id = rest.replace(/\s+/g, "_").replace(/[^\w]/g, "");
      }
      const sg = { id, label, nodeIds: [], children: [] };
      subgraphStack.push(sg);
      continue;
    }
    if (line === "end") {
      const completed = subgraphStack.pop();
      if (completed) {
        if (subgraphStack.length > 0) {
          subgraphStack[subgraphStack.length - 1].children.push(completed);
        } else {
          graph.subgraphs.push(completed);
        }
      }
      continue;
    }
    parseEdgeLine(line, graph, subgraphStack);
  }
  return graph;
}
function parseStateDiagram(lines) {
  const graph = {
    direction: "TD",
    nodes: /* @__PURE__ */ new Map(),
    edges: [],
    subgraphs: [],
    classDefs: /* @__PURE__ */ new Map(),
    classAssignments: /* @__PURE__ */ new Map(),
    nodeStyles: /* @__PURE__ */ new Map(),
    linkStyles: /* @__PURE__ */ new Map()
  };
  const compositeStack = [];
  const compositeStateIds = /* @__PURE__ */ new Set();
  let startCount = 0;
  let endCount = 0;
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    const dirMatch = line.match(/^direction\s+(TD|TB|LR|BT|RL)\s*$/i);
    if (dirMatch) {
      if (compositeStack.length > 0) {
        compositeStack[compositeStack.length - 1].direction = dirMatch[1].toUpperCase();
      } else {
        graph.direction = dirMatch[1].toUpperCase();
      }
      continue;
    }
    const linkStyleMatch = line.match(/^linkStyle\s+(default|[\d,\s]+)\s+(.+)$/);
    if (linkStyleMatch) {
      const target = linkStyleMatch[1].trim();
      const props = parseStyleProps(linkStyleMatch[2]);
      if (target === "default") {
        graph.linkStyles.set("default", { ...graph.linkStyles.get("default"), ...props });
      } else {
        const indices = target.split(",").map((s) => parseInt(s.trim(), 10));
        for (const idx of indices) {
          if (!isNaN(idx)) {
            graph.linkStyles.set(idx, { ...graph.linkStyles.get(idx), ...props });
          }
        }
      }
      continue;
    }
    const compositeMatch = line.match(/^state\s+(?:"([^"]+)"\s+as\s+)?([\w\p{L}]+)\s*\{$/u);
    if (compositeMatch) {
      const label = compositeMatch[1] ?? compositeMatch[2];
      const id = compositeMatch[2];
      const sg = { id, label, nodeIds: [], children: [] };
      compositeStack.push(sg);
      compositeStateIds.add(id);
      graph.nodes.delete(id);
      continue;
    }
    if (line === "}") {
      const completed = compositeStack.pop();
      if (completed) {
        if (compositeStack.length > 0) {
          compositeStack[compositeStack.length - 1].children.push(completed);
        } else {
          graph.subgraphs.push(completed);
        }
      }
      continue;
    }
    const stateAliasMatch = line.match(/^state\s+"([^"]+)"\s+as\s+([\w\p{L}]+)\s*$/u);
    if (stateAliasMatch) {
      const label = normalizeBrTags(stateAliasMatch[1]);
      const id = stateAliasMatch[2];
      registerStateNode(graph, compositeStack, { id, label, shape: "rounded" });
      continue;
    }
    const transitionMatch = line.match(/^(\[\*\]|[\w\p{L}-]+)\s*(-->)\s*(\[\*\]|[\w\p{L}-]+)(?:\s*:\s*(.+))?$/u);
    if (transitionMatch) {
      let sourceId = transitionMatch[1];
      let targetId = transitionMatch[3];
      const rawTransitionLabel = transitionMatch[4]?.trim();
      const edgeLabel = rawTransitionLabel ? normalizeBrTags(rawTransitionLabel) : void 0;
      if (sourceId === "[*]") {
        startCount++;
        sourceId = `_start${startCount > 1 ? startCount : ""}`;
        registerStateNode(graph, compositeStack, { id: sourceId, label: "", shape: "state-start" });
      } else if (!compositeStateIds.has(sourceId)) {
        ensureStateNode(graph, compositeStack, sourceId);
      }
      if (targetId === "[*]") {
        endCount++;
        targetId = `_end${endCount > 1 ? endCount : ""}`;
        registerStateNode(graph, compositeStack, { id: targetId, label: "", shape: "state-end" });
      } else if (!compositeStateIds.has(targetId)) {
        ensureStateNode(graph, compositeStack, targetId);
      }
      graph.edges.push({
        source: sourceId,
        target: targetId,
        label: edgeLabel,
        style: "solid",
        hasArrowStart: false,
        hasArrowEnd: true
      });
      continue;
    }
    const stateDescMatch = line.match(/^([\w\p{L}-]+)\s*:\s*(.+)$/u);
    if (stateDescMatch) {
      const id = stateDescMatch[1];
      const label = normalizeBrTags(stateDescMatch[2].trim());
      registerStateNode(graph, compositeStack, { id, label, shape: "rounded" });
      continue;
    }
  }
  return graph;
}
function registerStateNode(graph, compositeStack, node) {
  const isNew = !graph.nodes.has(node.id);
  if (isNew) {
    graph.nodes.set(node.id, node);
  }
  if (compositeStack.length > 0) {
    const current = compositeStack[compositeStack.length - 1];
    if (!current.nodeIds.includes(node.id)) {
      current.nodeIds.push(node.id);
    }
  }
}
function ensureStateNode(graph, compositeStack, id) {
  if (!graph.nodes.has(id)) {
    registerStateNode(graph, compositeStack, { id, label: id, shape: "rounded" });
  } else {
    if (compositeStack.length > 0) {
      const current = compositeStack[compositeStack.length - 1];
      if (!current.nodeIds.includes(id)) {
        current.nodeIds.push(id);
      }
    }
  }
}
function parseStyleProps(propsStr) {
  const cleaned = propsStr.replace(/;\s*$/, "");
  const props = {};
  for (const pair of cleaned.split(",")) {
    const colonIdx = pair.indexOf(":");
    if (colonIdx > 0) {
      const key = pair.slice(0, colonIdx).trim();
      const val = pair.slice(colonIdx + 1).trim();
      if (key && val) {
        props[key] = val;
      }
    }
  }
  return props;
}
var ARROW_REGEX = /^(<)?(-->|-.->|==>|---|-\.-|===)(?:\|([^|]*)\|)?/;
var TEXT_ARROW_REGEX = /^(<)?(--|-\.|==)\s+(.+?)\s+(-->|---|\.\->|-\.\-|==>|===)/;
var NODE_PATTERNS = [
  // Triple delimiters (must be first)
  { regex: /^([\w-]+)\(\(\((.+?)\)\)\)/, shape: "doublecircle" },
  // A(((text)))
  // Double delimiters with mixed brackets
  { regex: /^([\w-]+)\(\[(.+?)\]\)/, shape: "stadium" },
  // A([text])
  { regex: /^([\w-]+)\(\((.+?)\)\)/, shape: "circle" },
  // A((text))
  { regex: /^([\w-]+)\[\[(.+?)\]\]/, shape: "subroutine" },
  // A[[text]]
  { regex: /^([\w-]+)\[\((.+?)\)\]/, shape: "cylinder" },
  // A[(text)]
  // Trapezoid variants — must come before plain [text]
  { regex: /^([\w-]+)\[\/(.+?)\\\]/, shape: "trapezoid" },
  // A[/text\]
  { regex: /^([\w-]+)\[\\(.+?)\/\]/, shape: "trapezoid-alt" },
  // A[\text/]
  // Asymmetric flag shape
  { regex: /^([\w-]+)>(.+?)\]/, shape: "asymmetric" },
  // A>text]
  // Double curly braces (hexagon) — must come before single {text}
  { regex: /^([\w-]+)\{\{(.+?)\}\}/, shape: "hexagon" },
  // A{{text}}
  // Single-char delimiters (last — most common, least specific)
  { regex: /^([\w-]+)\[(.+?)\]/, shape: "rectangle" },
  // A[text]
  { regex: /^([\w-]+)\((.+?)\)/, shape: "rounded" },
  // A(text)
  { regex: /^([\w-]+)\{(.+?)\}/, shape: "diamond" }
  // A{text}
];
var BARE_NODE_REGEX = /^([\w-]+)/;
var CLASS_SHORTHAND_REGEX = /^:::([\w][\w-]*)/;
function parseEdgeLine(line, graph, subgraphStack) {
  let remaining = line.trim();
  const firstGroup = consumeNodeGroup(remaining, graph, subgraphStack);
  if (!firstGroup || firstGroup.ids.length === 0) return;
  remaining = firstGroup.remaining.trim();
  let prevGroupIds = firstGroup.ids;
  while (remaining.length > 0) {
    let hasArrowStart;
    let style;
    let hasArrowEnd;
    let edgeLabel;
    const arrowMatch = remaining.match(ARROW_REGEX);
    if (arrowMatch) {
      hasArrowStart = Boolean(arrowMatch[1]);
      const arrowOp = arrowMatch[2];
      const rawEdgeLabel = arrowMatch[3]?.trim();
      edgeLabel = rawEdgeLabel ? normalizeBrTags(rawEdgeLabel) : void 0;
      remaining = remaining.slice(arrowMatch[0].length).trim();
      style = arrowStyleFromOp(arrowOp);
      hasArrowEnd = arrowOp.endsWith(">");
    } else {
      const textMatch = remaining.match(TEXT_ARROW_REGEX);
      if (!textMatch) break;
      hasArrowStart = Boolean(textMatch[1]);
      const rawLabel = textMatch[3].trim();
      edgeLabel = rawLabel ? normalizeBrTags(rawLabel) : void 0;
      const openOp = textMatch[2];
      const closeOp = textMatch[4];
      remaining = remaining.slice(textMatch[0].length).trim();
      style = textArrowStyleFromOps(openOp, closeOp);
      hasArrowEnd = closeOp.endsWith(">");
    }
    const nextGroup = consumeNodeGroup(remaining, graph, subgraphStack);
    if (!nextGroup || nextGroup.ids.length === 0) break;
    remaining = nextGroup.remaining.trim();
    for (const sourceId of prevGroupIds) {
      for (const targetId of nextGroup.ids) {
        graph.edges.push({
          source: sourceId,
          target: targetId,
          label: edgeLabel,
          style,
          hasArrowStart,
          hasArrowEnd
        });
      }
    }
    prevGroupIds = nextGroup.ids;
  }
}
function consumeNodeGroup(text, graph, subgraphStack) {
  const first = consumeNode(text, graph, subgraphStack);
  if (!first) return null;
  const ids = [first.id];
  let remaining = first.remaining.trim();
  while (remaining.startsWith("&")) {
    remaining = remaining.slice(1).trim();
    const next = consumeNode(remaining, graph, subgraphStack);
    if (!next) break;
    ids.push(next.id);
    remaining = next.remaining.trim();
  }
  return { ids, remaining };
}
function consumeNode(text, graph, subgraphStack) {
  let id = null;
  let remaining = text;
  for (const { regex, shape } of NODE_PATTERNS) {
    const match = text.match(regex);
    if (match) {
      id = match[1];
      const label = normalizeBrTags(match[2]);
      registerNode(graph, subgraphStack, { id, label, shape });
      remaining = text.slice(match[0].length);
      break;
    }
  }
  if (id === null) {
    const bareMatch = text.match(BARE_NODE_REGEX);
    if (bareMatch) {
      id = bareMatch[1];
      if (!graph.nodes.has(id)) {
        registerNode(graph, subgraphStack, { id, label: id, shape: "rectangle" });
      }
      remaining = text.slice(bareMatch[0].length);
    }
  }
  if (id === null) return null;
  const classMatch = remaining.match(CLASS_SHORTHAND_REGEX);
  if (classMatch) {
    graph.classAssignments.set(id, classMatch[1]);
    remaining = remaining.slice(classMatch[0].length);
  }
  return { id, remaining };
}
function registerNode(graph, subgraphStack, node) {
  const isNew = !graph.nodes.has(node.id);
  if (isNew) {
    graph.nodes.set(node.id, node);
  }
  trackInSubgraph(subgraphStack, node.id);
}
function trackInSubgraph(subgraphStack, nodeId) {
  if (subgraphStack.length > 0) {
    const current = subgraphStack[subgraphStack.length - 1];
    if (!current.nodeIds.includes(nodeId)) {
      current.nodeIds.push(nodeId);
    }
  }
}
function arrowStyleFromOp(op) {
  if (op === "-.->") return "dotted";
  if (op === "-.-") return "dotted";
  if (op === "==>") return "thick";
  if (op === "===") return "thick";
  return "solid";
}
function textArrowStyleFromOps(openOp, closeOp) {
  if (openOp === "-." || closeOp === ".->" || closeOp === "-.-") return "dotted";
  if (openOp === "==" || closeOp === "==>" || closeOp === "===") return "thick";
  return "solid";
}

// src/ascii/types.ts
var Up = { x: 1, y: 0 };
var Down = { x: 1, y: 2 };
var Left = { x: 0, y: 1 };
var Right = { x: 2, y: 1 };
var UpperRight = { x: 2, y: 0 };
var UpperLeft = { x: 0, y: 0 };
var LowerRight = { x: 2, y: 2 };
var LowerLeft = { x: 0, y: 2 };
var Middle = { x: 1, y: 1 };
function gridCoordEquals(a, b) {
  return a.x === b.x && a.y === b.y;
}
function drawingCoordEquals(a, b) {
  return a.x === b.x && a.y === b.y;
}
function gridCoordDirection(c, dir) {
  return { x: c.x + dir.x, y: c.y + dir.y };
}
function gridKey(c) {
  return `${c.x},${c.y}`;
}
var EMPTY_STYLE = { name: "", styles: {} };

// src/ascii/ansi.ts
var DEFAULT_ASCII_THEME = {
  fg: "#27272a",
  // zinc-800 — primary text
  border: "#a1a1aa",
  // zinc-400 — node borders (12% mix)
  line: "#71717a",
  // zinc-500 — edge lines (35% mix)
  arrow: "#52525b",
  // zinc-600 — arrowheads (60% mix)
  corner: "#71717a",
  // same as line
  junction: "#a1a1aa"
  // same as border
};
function detectColorMode() {
  const proc = globalThis.process;
  if (proc) {
    if (!proc.stdout?.isTTY) {
      return "none";
    }
    const colorTerm = proc.env?.COLORTERM?.toLowerCase() ?? "";
    const term = proc.env?.TERM?.toLowerCase() ?? "";
    if (colorTerm === "truecolor" || colorTerm === "24bit") {
      return "truecolor";
    }
    if (term.includes("256color") || term.includes("256")) {
      return "ansi256";
    }
    if (term && term !== "dumb") {
      return "ansi16";
    }
    return "none";
  }
  if (typeof document !== "undefined") {
    return "html";
  }
  return "none";
}
function parseHex(hex) {
  const h = hex.replace("#", "");
  if (h.length === 3) {
    return {
      r: parseInt(h[0] + h[0], 16),
      g: parseInt(h[1] + h[1], 16),
      b: parseInt(h[2] + h[2], 16)
    };
  }
  return {
    r: parseInt(h.substring(0, 2), 16),
    g: parseInt(h.substring(2, 4), 16),
    b: parseInt(h.substring(4, 6), 16)
  };
}
var ESC = "\x1B[";
var RESET = `${ESC}0m`;
function truecolorFg(hex) {
  const { r: r2, g, b } = parseHex(hex);
  return `${ESC}38;2;${r2};${g};${b}m`;
}
function rgbTo256(r2, g, b) {
  const avg = (r2 + g + b) / 3;
  const maxDiff = Math.max(Math.abs(r2 - avg), Math.abs(g - avg), Math.abs(b - avg));
  if (maxDiff < 10) {
    const gray = Math.round(avg / 255 * 23);
    return 232 + Math.min(23, Math.max(0, gray));
  }
  const toIndex = (v) => {
    if (v < 48) return 0;
    if (v < 115) return 1;
    return Math.min(5, Math.floor((v - 35) / 40));
  };
  const ri = toIndex(r2);
  const gi = toIndex(g);
  const bi = toIndex(b);
  return 16 + 36 * ri + 6 * gi + bi;
}
function ansi256Fg(hex) {
  const { r: r2, g, b } = parseHex(hex);
  const index = rgbTo256(r2, g, b);
  return `${ESC}38;5;${index}m`;
}
function ansi16Fg(hex) {
  const { r: r2, g, b } = parseHex(hex);
  const luma = 0.299 * r2 + 0.587 * g + 0.114 * b;
  const bright = luma > 100 ? 0 : 60;
  let code;
  if (r2 > 180 && g < 100 && b < 100) code = 31;
  else if (g > 180 && r2 < 100 && b < 100) code = 32;
  else if (r2 > 150 && g > 150 && b < 100) code = 33;
  else if (b > 180 && r2 < 100 && g < 100) code = 34;
  else if (r2 > 150 && b > 150 && g < 100) code = 35;
  else if (g > 150 && b > 150 && r2 < 100) code = 36;
  else if (luma > 200) code = 37;
  else if (luma < 50) code = 30;
  else code = 37;
  return `${ESC}${code + bright}m`;
}
function escapeHtml(text) {
  return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}
function htmlSpan(hex, text) {
  return `<span style="color:${hex}">${escapeHtml(text)}</span>`;
}
function getRoleColor(role, theme) {
  switch (role) {
    case "text":
      return theme.fg;
    case "border":
      return theme.border;
    case "line":
      return theme.line;
    case "arrow":
      return theme.arrow;
    case "corner":
      return theme.corner ?? theme.line;
    case "junction":
      return theme.junction ?? theme.border;
    default:
      return theme.fg;
  }
}
function getAnsiColor(role, theme, mode) {
  if (mode === "none") return "";
  const hex = getRoleColor(role, theme);
  switch (mode) {
    case "truecolor":
      return truecolorFg(hex);
    case "ansi256":
      return ansi256Fg(hex);
    case "ansi16":
      return ansi16Fg(hex);
    default:
      return "";
  }
}
function colorizeLine(chars, roles, theme, mode) {
  if (mode === "none") {
    return chars.join("");
  }
  if (mode === "html") {
    return colorizeLineHtml(chars, roles, theme);
  }
  let result = "";
  let currentRole = null;
  let buffer = "";
  for (let i = 0; i < chars.length; i++) {
    const char = chars[i];
    const role = roles[i] ?? null;
    if (char === " ") {
      if (buffer.length > 0) {
        if (currentRole !== null) {
          result += getAnsiColor(currentRole, theme, mode) + buffer + RESET;
        } else {
          result += buffer;
        }
        buffer = "";
        currentRole = null;
      }
      result += char;
      continue;
    }
    if (role === currentRole) {
      buffer += char;
      continue;
    }
    if (buffer.length > 0) {
      if (currentRole !== null) {
        result += getAnsiColor(currentRole, theme, mode) + buffer + RESET;
      } else {
        result += buffer;
      }
    }
    buffer = char;
    currentRole = role;
  }
  if (buffer.length > 0 && currentRole !== null) {
    result += getAnsiColor(currentRole, theme, mode) + buffer + RESET;
  } else if (buffer.length > 0) {
    result += buffer;
  }
  return result;
}
function colorizeLineHtml(chars, roles, theme) {
  let result = "";
  let currentRole = null;
  let buffer = "";
  const flush = () => {
    if (buffer.length === 0) return;
    if (currentRole !== null) {
      result += htmlSpan(getRoleColor(currentRole, theme), buffer);
    } else {
      result += escapeHtml(buffer);
    }
    buffer = "";
    currentRole = null;
  };
  for (let i = 0; i < chars.length; i++) {
    const char = chars[i];
    const role = roles[i] ?? null;
    if (char === " ") {
      flush();
      result += " ";
      continue;
    }
    if (role === currentRole) {
      buffer += char;
      continue;
    }
    flush();
    buffer = char;
    currentRole = role;
  }
  flush();
  return result;
}
function colorizeText(text, hex, mode) {
  if (mode === "none" || text.length === 0) return text;
  if (mode === "html") return htmlSpan(hex, text);
  let code;
  switch (mode) {
    case "truecolor":
      code = truecolorFg(hex);
      break;
    case "ansi256":
      code = ansi256Fg(hex);
      break;
    case "ansi16":
      code = ansi16Fg(hex);
      break;
    default:
      return text;
  }
  return `${code}${text}${RESET}`;
}

// src/ascii/canvas.ts
function mkCanvas(x, y) {
  const canvas = [];
  for (let i = 0; i <= x; i++) {
    const col = [];
    for (let j = 0; j <= y; j++) {
      col.push(" ");
    }
    canvas.push(col);
  }
  return canvas;
}
function copyCanvas(source) {
  const [maxX, maxY] = getCanvasSize(source);
  return mkCanvas(maxX, maxY);
}
function mkRoleCanvas(x, y) {
  const roleCanvas = [];
  for (let i = 0; i <= x; i++) {
    const col = [];
    for (let j = 0; j <= y; j++) {
      col.push(null);
    }
    roleCanvas.push(col);
  }
  return roleCanvas;
}
function increaseRoleCanvasSize(roleCanvas, newX, newY) {
  const currX = roleCanvas.length - 1;
  const currY = (roleCanvas[0]?.length ?? 1) - 1;
  const targetX = Math.max(newX, currX);
  const targetY = Math.max(newY, currY);
  const grown = mkRoleCanvas(targetX, targetY);
  for (let x = 0; x < grown.length; x++) {
    for (let y = 0; y < grown[0].length; y++) {
      if (x < roleCanvas.length && y < roleCanvas[0].length) {
        grown[x][y] = roleCanvas[x][y];
      }
    }
  }
  roleCanvas.length = 0;
  roleCanvas.push(...grown);
  return roleCanvas;
}
function setRole(roleCanvas, x, y, role) {
  if (x >= roleCanvas.length || y >= (roleCanvas[0]?.length ?? 0)) {
    increaseRoleCanvasSize(roleCanvas, x, y);
  }
  roleCanvas[x][y] = role;
}
function getCanvasSize(canvas) {
  return [canvas.length - 1, (canvas[0]?.length ?? 1) - 1];
}
function increaseSize(canvas, newX, newY) {
  const [currX, currY] = getCanvasSize(canvas);
  const targetX = Math.max(newX, currX);
  const targetY = Math.max(newY, currY);
  const grown = mkCanvas(targetX, targetY);
  for (let x = 0; x < grown.length; x++) {
    for (let y = 0; y < grown[0].length; y++) {
      if (x < canvas.length && y < canvas[0].length) {
        grown[x][y] = canvas[x][y];
      }
    }
  }
  canvas.length = 0;
  canvas.push(...grown);
  return canvas;
}
var JUNCTION_CHARS = /* @__PURE__ */ new Set([
  "\u2500",
  "\u2502",
  "\u250C",
  "\u2510",
  "\u2514",
  "\u2518",
  "\u251C",
  "\u2524",
  "\u252C",
  "\u2534",
  "\u253C",
  "\u2574",
  "\u2575",
  "\u2576",
  "\u2577"
]);
function isJunctionChar(c) {
  return JUNCTION_CHARS.has(c);
}
function isAlphanumeric(c) {
  return /^[a-zA-Z0-9]$/.test(c);
}
var JUNCTION_MAP = {
  "\u2500": { "\u2502": "\u253C", "\u250C": "\u252C", "\u2510": "\u252C", "\u2514": "\u2534", "\u2518": "\u2534", "\u251C": "\u253C", "\u2524": "\u253C", "\u252C": "\u252C", "\u2534": "\u2534" },
  "\u2502": { "\u2500": "\u253C", "\u250C": "\u251C", "\u2510": "\u2524", "\u2514": "\u251C", "\u2518": "\u2524", "\u251C": "\u251C", "\u2524": "\u2524", "\u252C": "\u253C", "\u2534": "\u253C" },
  "\u250C": { "\u2500": "\u252C", "\u2502": "\u251C", "\u2510": "\u252C", "\u2514": "\u251C", "\u2518": "\u253C", "\u251C": "\u251C", "\u2524": "\u253C", "\u252C": "\u252C", "\u2534": "\u253C" },
  "\u2510": { "\u2500": "\u252C", "\u2502": "\u2524", "\u250C": "\u252C", "\u2514": "\u253C", "\u2518": "\u2524", "\u251C": "\u253C", "\u2524": "\u2524", "\u252C": "\u252C", "\u2534": "\u253C" },
  "\u2514": { "\u2500": "\u2534", "\u2502": "\u251C", "\u250C": "\u251C", "\u2510": "\u253C", "\u2518": "\u2534", "\u251C": "\u251C", "\u2524": "\u253C", "\u252C": "\u253C", "\u2534": "\u2534" },
  "\u2518": { "\u2500": "\u2534", "\u2502": "\u2524", "\u250C": "\u253C", "\u2510": "\u2524", "\u2514": "\u2534", "\u251C": "\u253C", "\u2524": "\u2524", "\u252C": "\u253C", "\u2534": "\u2534" },
  "\u251C": { "\u2500": "\u253C", "\u2502": "\u251C", "\u250C": "\u251C", "\u2510": "\u253C", "\u2514": "\u251C", "\u2518": "\u253C", "\u2524": "\u253C", "\u252C": "\u253C", "\u2534": "\u253C" },
  "\u2524": { "\u2500": "\u253C", "\u2502": "\u2524", "\u250C": "\u253C", "\u2510": "\u2524", "\u2514": "\u253C", "\u2518": "\u2524", "\u251C": "\u253C", "\u252C": "\u253C", "\u2534": "\u253C" },
  "\u252C": { "\u2500": "\u252C", "\u2502": "\u253C", "\u250C": "\u252C", "\u2510": "\u252C", "\u2514": "\u253C", "\u2518": "\u253C", "\u251C": "\u253C", "\u2524": "\u253C", "\u2534": "\u253C" },
  "\u2534": { "\u2500": "\u2534", "\u2502": "\u253C", "\u250C": "\u253C", "\u2510": "\u253C", "\u2514": "\u2534", "\u2518": "\u2534", "\u251C": "\u253C", "\u2524": "\u253C", "\u252C": "\u253C" }
};
function mergeJunctions(c1, c2) {
  return JUNCTION_MAP[c1]?.[c2] ?? c1;
}
function mergeCanvases(base, offset, useAscii, ...overlays) {
  let [maxX, maxY] = getCanvasSize(base);
  for (const overlay of overlays) {
    const [oX, oY] = getCanvasSize(overlay);
    maxX = Math.max(maxX, oX + offset.x);
    maxY = Math.max(maxY, oY + offset.y);
  }
  const merged = mkCanvas(maxX, maxY);
  for (let x = 0; x <= maxX; x++) {
    for (let y = 0; y <= maxY; y++) {
      if (x < base.length && y < base[0].length) {
        merged[x][y] = base[x][y];
      }
    }
  }
  for (const overlay of overlays) {
    for (let x = 0; x < overlay.length; x++) {
      for (let y = 0; y < overlay[0].length; y++) {
        const c = overlay[x][y];
        if (c !== " ") {
          const mx = x + offset.x;
          const my = y + offset.y;
          const current = merged[mx][my];
          if (!useAscii && isJunctionChar(c) && isJunctionChar(current)) {
            merged[mx][my] = mergeJunctions(current, c);
          } else if (isAlphanumeric(current) && isAlphanumeric(c)) {
          } else {
            merged[mx][my] = c;
          }
        }
      }
    }
  }
  return merged;
}
function canvasToString(canvas, options) {
  const [maxX, maxY] = getCanvasSize(canvas);
  const lines = [];
  const roleCanvas = options?.roleCanvas;
  const colorMode = options?.colorMode ?? "none";
  const theme = options?.theme ?? DEFAULT_ASCII_THEME;
  for (let y = 0; y <= maxY; y++) {
    if (colorMode === "none" || !roleCanvas) {
      let line = "";
      for (let x = 0; x <= maxX; x++) {
        line += canvas[x][y];
      }
      lines.push(line);
    } else {
      const chars = [];
      const roles = [];
      for (let x = 0; x <= maxX; x++) {
        chars.push(canvas[x][y]);
        roles.push(roleCanvas[x]?.[y] ?? null);
      }
      lines.push(colorizeLine(chars, roles, theme, colorMode));
    }
  }
  return lines.join("\n");
}
var VERTICAL_FLIP_MAP = {
  // Unicode arrows
  "\u25B2": "\u25BC",
  "\u25BC": "\u25B2",
  "\u25E4": "\u25E3",
  "\u25E3": "\u25E4",
  "\u25E5": "\u25E2",
  "\u25E2": "\u25E5",
  // ASCII arrows
  "^": "v",
  "v": "^",
  // Unicode corners
  "\u250C": "\u2514",
  "\u2514": "\u250C",
  "\u2510": "\u2518",
  "\u2518": "\u2510",
  // Unicode junctions (T-pieces flip vertically)
  "\u252C": "\u2534",
  "\u2534": "\u252C",
  // Box-start junctions (exit points from node boxes)
  "\u2575": "\u2577",
  "\u2577": "\u2575"
};
function flipCanvasVertically(canvas) {
  for (const col of canvas) {
    col.reverse();
  }
  for (const col of canvas) {
    for (let y = 0; y < col.length; y++) {
      const flipped = VERTICAL_FLIP_MAP[col[y]];
      if (flipped) col[y] = flipped;
    }
  }
  return canvas;
}
function flipRoleCanvasVertically(roleCanvas) {
  for (const col of roleCanvas) {
    col.reverse();
  }
  return roleCanvas;
}
function drawText(canvas, start, text, forceOverwrite = false) {
  increaseSize(canvas, start.x + text.length, start.y);
  for (let i = 0; i < text.length; i++) {
    const x = start.x + i;
    const current = canvas[x][start.y];
    if (forceOverwrite || current === " ") {
      canvas[x][start.y] = text[i];
    }
  }
}
function setCanvasSizeToGrid(canvas, columnWidth, rowHeight) {
  let maxX = 0;
  let maxY = 0;
  for (const w of columnWidth.values()) maxX += w;
  for (const h of rowHeight.values()) maxY += h;
  increaseSize(canvas, maxX - 1, maxY - 1);
}
function setRoleCanvasSizeToGrid(roleCanvas, columnWidth, rowHeight) {
  let maxX = 0;
  let maxY = 0;
  for (const w of columnWidth.values()) maxX += w;
  for (const h of rowHeight.values()) maxY += h;
  increaseRoleCanvasSize(roleCanvas, maxX - 1, maxY - 1);
}

// src/ascii/converter.ts
function convertToAsciiGraph(parsed, config) {
  const nodeMap = /* @__PURE__ */ new Map();
  let index = 0;
  for (const [id, mNode] of parsed.nodes) {
    const asciiNode = {
      // Use the parser ID as the unique identity key to avoid collisions
      // when multiple nodes share the same label (e.g. A[Web Server], C[Web Server]).
      name: id,
      // The label is used for rendering inside the box.
      displayLabel: mNode.label,
      // Preserve shape from parser for shape-aware rendering
      shape: mNode.shape,
      index,
      gridCoord: null,
      drawingCoord: null,
      drawing: null,
      drawn: false,
      styleClassName: "",
      styleClass: EMPTY_STYLE
    };
    nodeMap.set(id, asciiNode);
    index++;
  }
  const nodes = [...nodeMap.values()];
  const edges = [];
  for (const mEdge of parsed.edges) {
    const from = nodeMap.get(mEdge.source);
    const to = nodeMap.get(mEdge.target);
    if (!from || !to) continue;
    edges.push({
      from,
      to,
      text: mEdge.label ?? "",
      path: [],
      labelLine: [],
      startDir: { x: 0, y: 0 },
      endDir: { x: 0, y: 0 },
      style: mEdge.style,
      hasArrowStart: mEdge.hasArrowStart,
      hasArrowEnd: mEdge.hasArrowEnd
    });
  }
  const subgraphs = [];
  for (const mSg of parsed.subgraphs) {
    convertSubgraph(mSg, null, nodeMap, subgraphs);
  }
  deduplicateSubgraphNodes(parsed.subgraphs, subgraphs, nodeMap, parsed);
  for (const [nodeId, className] of parsed.classAssignments) {
    const node = nodeMap.get(nodeId);
    const classDef = parsed.classDefs.get(className);
    if (node && classDef) {
      node.styleClassName = className;
      node.styleClass = { name: className, styles: classDef };
    }
  }
  return {
    nodes,
    edges,
    canvas: mkCanvas(0, 0),
    roleCanvas: mkRoleCanvas(0, 0),
    grid: /* @__PURE__ */ new Map(),
    columnWidth: /* @__PURE__ */ new Map(),
    rowHeight: /* @__PURE__ */ new Map(),
    subgraphs,
    config,
    offsetX: 0,
    offsetY: 0,
    bundles: []
    // Populated by analyzeEdgeBundles() during layout
  };
}
function convertSubgraph(mSg, parent, nodeMap, allSubgraphs) {
  let normalizedDirection;
  if (mSg.direction) {
    normalizedDirection = mSg.direction === "LR" || mSg.direction === "RL" ? "LR" : "TD";
  }
  const sg = {
    name: mSg.label,
    nodes: [],
    parent,
    children: [],
    minX: 0,
    minY: 0,
    maxX: 0,
    maxY: 0,
    direction: normalizedDirection
  };
  for (const nodeId of mSg.nodeIds) {
    const node = nodeMap.get(nodeId);
    if (node) sg.nodes.push(node);
  }
  allSubgraphs.push(sg);
  for (const childMSg of mSg.children) {
    const child = convertSubgraph(childMSg, sg, nodeMap, allSubgraphs);
    sg.children.push(child);
    for (const childNode of child.nodes) {
      if (!sg.nodes.includes(childNode)) {
        sg.nodes.push(childNode);
      }
    }
  }
  return sg;
}
function deduplicateSubgraphNodes(mermaidSubgraphs, asciiSubgraphs, nodeMap, parsed) {
  const sgMap = /* @__PURE__ */ new Map();
  buildSgMap(mermaidSubgraphs, asciiSubgraphs, sgMap);
  const nodeOwner = /* @__PURE__ */ new Map();
  function claimNodes(mSg) {
    const asciiSg = sgMap.get(mSg);
    if (!asciiSg) return;
    for (const child of mSg.children) {
      claimNodes(child);
    }
    for (const nodeId of mSg.nodeIds) {
      if (!nodeOwner.has(nodeId)) {
        nodeOwner.set(nodeId, asciiSg);
      }
    }
  }
  for (const mSg of mermaidSubgraphs) {
    claimNodes(mSg);
  }
  for (const asciiSg of asciiSubgraphs) {
    asciiSg.nodes = asciiSg.nodes.filter((node) => {
      let nodeId;
      for (const [id, n] of nodeMap) {
        if (n === node) {
          nodeId = id;
          break;
        }
      }
      if (!nodeId) return false;
      const owner = nodeOwner.get(nodeId);
      if (!owner) return true;
      return isAncestorOrSelf(asciiSg, owner);
    });
  }
}
function isAncestorOrSelf(candidate, target) {
  let current = target;
  while (current !== null) {
    if (current === candidate) return true;
    current = current.parent;
  }
  return false;
}
function buildSgMap(mSgs, aSgs, result) {
  const flatMermaid = [];
  function flatten(sgs) {
    for (const sg of sgs) {
      flatMermaid.push(sg);
      flatten(sg.children);
    }
  }
  flatten(mSgs);
  for (let i = 0; i < flatMermaid.length && i < aSgs.length; i++) {
    result.set(flatMermaid[i], aSgs[i]);
  }
}

// src/ascii/pathfinder.ts
var MinHeap = class {
  items = [];
  get length() {
    return this.items.length;
  }
  push(item) {
    this.items.push(item);
    this.bubbleUp(this.items.length - 1);
  }
  pop() {
    if (this.items.length === 0) return void 0;
    const top = this.items[0];
    const last = this.items.pop();
    if (this.items.length > 0) {
      this.items[0] = last;
      this.sinkDown(0);
    }
    return top;
  }
  bubbleUp(i) {
    while (i > 0) {
      const parent = i - 1 >> 1;
      if (this.items[i].priority < this.items[parent].priority) {
        ;
        [this.items[i], this.items[parent]] = [this.items[parent], this.items[i]];
        i = parent;
      } else {
        break;
      }
    }
  }
  sinkDown(i) {
    const n = this.items.length;
    while (true) {
      let smallest = i;
      const left = 2 * i + 1;
      const right = 2 * i + 2;
      if (left < n && this.items[left].priority < this.items[smallest].priority) {
        smallest = left;
      }
      if (right < n && this.items[right].priority < this.items[smallest].priority) {
        smallest = right;
      }
      if (smallest !== i) {
        ;
        [this.items[i], this.items[smallest]] = [this.items[smallest], this.items[i]];
        i = smallest;
      } else {
        break;
      }
    }
  }
};
function heuristic(a, b) {
  const absX = Math.abs(a.x - b.x);
  const absY = Math.abs(a.y - b.y);
  if (absX === 0 || absY === 0) {
    return absX + absY;
  }
  return absX + absY + 1;
}
var MOVE_DIRS = [
  { x: 1, y: 0 },
  { x: -1, y: 0 },
  { x: 0, y: 1 },
  { x: 0, y: -1 }
];
function isFreeInGrid(grid, c) {
  if (c.x < 0 || c.y < 0) return false;
  return !grid.has(gridKey(c));
}
function getPath(grid, from, to) {
  const pq = new MinHeap();
  pq.push({ coord: from, priority: 0 });
  const costSoFar = /* @__PURE__ */ new Map();
  costSoFar.set(gridKey(from), 0);
  const cameFrom = /* @__PURE__ */ new Map();
  cameFrom.set(gridKey(from), null);
  while (pq.length > 0) {
    const current = pq.pop().coord;
    if (gridCoordEquals(current, to)) {
      const path = [];
      let c = current;
      while (c !== null) {
        path.unshift(c);
        c = cameFrom.get(gridKey(c)) ?? null;
      }
      return path;
    }
    const currentCost = costSoFar.get(gridKey(current));
    for (const dir of MOVE_DIRS) {
      const next = { x: current.x + dir.x, y: current.y + dir.y };
      if (!isFreeInGrid(grid, next) && !gridCoordEquals(next, to)) {
        continue;
      }
      const newCost = currentCost + 1;
      const nextKey = gridKey(next);
      const existingCost = costSoFar.get(nextKey);
      if (existingCost === void 0 || newCost < existingCost) {
        costSoFar.set(nextKey, newCost);
        const priority = newCost + heuristic(next, to);
        pq.push({ coord: next, priority });
        cameFrom.set(nextKey, current);
      }
    }
  }
  return null;
}
function mergePath(path) {
  if (path.length <= 2) return path;
  const toRemove = /* @__PURE__ */ new Set();
  let step0 = path[0];
  let step1 = path[1];
  for (let idx = 2; idx < path.length; idx++) {
    const step2 = path[idx];
    const prevDx = step1.x - step0.x;
    const prevDy = step1.y - step0.y;
    const dx = step2.x - step1.x;
    const dy = step2.y - step1.y;
    if (prevDx === dx && prevDy === dy) {
      toRemove.add(idx - 1);
    }
    step0 = step1;
    step1 = step2;
  }
  return path.filter((_, i) => !toRemove.has(i));
}

// src/ascii/edge-routing.ts
function getOpposite(d) {
  if (d === Up) return Down;
  if (d === Down) return Up;
  if (d === Left) return Right;
  if (d === Right) return Left;
  if (d === UpperRight) return LowerLeft;
  if (d === UpperLeft) return LowerRight;
  if (d === LowerRight) return UpperLeft;
  if (d === LowerLeft) return UpperRight;
  return Middle;
}
function dirEquals(a, b) {
  return a.x === b.x && a.y === b.y;
}
function determineDirection(from, to) {
  if (from.x === to.x) {
    return from.y < to.y ? Down : Up;
  } else if (from.y === to.y) {
    return from.x < to.x ? Right : Left;
  } else if (from.x < to.x) {
    return from.y < to.y ? LowerRight : UpperRight;
  } else {
    return from.y < to.y ? LowerLeft : UpperLeft;
  }
}
function selfReferenceDirection(graphDirection) {
  if (graphDirection === "LR") return [Right, Down, Down, Right];
  return [Down, Right, Right, Down];
}
function determineStartAndEndDir(edge, graphDirection) {
  if (edge.from === edge.to) return selfReferenceDirection(graphDirection);
  const d = determineDirection(edge.from.gridCoord, edge.to.gridCoord);
  let preferredDir;
  let preferredOppositeDir;
  let alternativeDir;
  let alternativeOppositeDir;
  const isBackwards = graphDirection === "LR" ? dirEquals(d, Left) || dirEquals(d, UpperLeft) || dirEquals(d, LowerLeft) : dirEquals(d, Up) || dirEquals(d, UpperLeft) || dirEquals(d, UpperRight);
  if (dirEquals(d, LowerRight)) {
    if (graphDirection === "LR") {
      preferredDir = Down;
      preferredOppositeDir = Left;
      alternativeDir = Right;
      alternativeOppositeDir = Up;
    } else {
      preferredDir = Right;
      preferredOppositeDir = Up;
      alternativeDir = Down;
      alternativeOppositeDir = Left;
    }
  } else if (dirEquals(d, UpperRight)) {
    if (graphDirection === "LR") {
      preferredDir = Up;
      preferredOppositeDir = Left;
      alternativeDir = Right;
      alternativeOppositeDir = Down;
    } else {
      preferredDir = Right;
      preferredOppositeDir = Down;
      alternativeDir = Up;
      alternativeOppositeDir = Left;
    }
  } else if (dirEquals(d, LowerLeft)) {
    if (graphDirection === "LR") {
      preferredDir = Down;
      preferredOppositeDir = Down;
      alternativeDir = Left;
      alternativeOppositeDir = Up;
    } else {
      preferredDir = Left;
      preferredOppositeDir = Up;
      alternativeDir = Down;
      alternativeOppositeDir = Right;
    }
  } else if (dirEquals(d, UpperLeft)) {
    if (graphDirection === "LR") {
      preferredDir = Down;
      preferredOppositeDir = Down;
      alternativeDir = Left;
      alternativeOppositeDir = Down;
    } else {
      preferredDir = Right;
      preferredOppositeDir = Right;
      alternativeDir = Up;
      alternativeOppositeDir = Right;
    }
  } else if (isBackwards) {
    if (graphDirection === "LR" && dirEquals(d, Left)) {
      preferredDir = Down;
      preferredOppositeDir = Down;
      alternativeDir = Left;
      alternativeOppositeDir = Right;
    } else if (graphDirection === "TD" && dirEquals(d, Up)) {
      preferredDir = Right;
      preferredOppositeDir = Right;
      alternativeDir = Up;
      alternativeOppositeDir = Down;
    } else {
      preferredDir = d;
      preferredOppositeDir = getOpposite(d);
      alternativeDir = d;
      alternativeOppositeDir = getOpposite(d);
    }
  } else {
    preferredDir = d;
    preferredOppositeDir = getOpposite(d);
    alternativeDir = d;
    alternativeOppositeDir = getOpposite(d);
  }
  return [preferredDir, preferredOppositeDir, alternativeDir, alternativeOppositeDir];
}
function determinePath(graph, edge) {
  const sourceSg = getNodeSubgraph(graph, edge.from);
  const targetSg = getNodeSubgraph(graph, edge.to);
  const effectiveDir = sourceSg && sourceSg === targetSg && sourceSg.direction ? sourceSg.direction : graph.config.graphDirection;
  const [preferredDir, preferredOppositeDir, alternativeDir, alternativeOppositeDir] = determineStartAndEndDir(edge, effectiveDir);
  const prefFrom = gridCoordDirection(edge.from.gridCoord, preferredDir);
  const prefTo = gridCoordDirection(edge.to.gridCoord, preferredOppositeDir);
  let preferredPath = getPath(graph.grid, prefFrom, prefTo);
  const altFrom = gridCoordDirection(edge.from.gridCoord, alternativeDir);
  const altTo = gridCoordDirection(edge.to.gridCoord, alternativeOppositeDir);
  let alternativePath = getPath(graph.grid, altFrom, altTo);
  if (preferredPath !== null && alternativePath !== null) {
    preferredPath = mergePath(preferredPath);
    alternativePath = mergePath(alternativePath);
    if (preferredPath.length <= alternativePath.length) {
      edge.startDir = preferredDir;
      edge.endDir = preferredOppositeDir;
      edge.path = preferredPath;
    } else {
      edge.startDir = alternativeDir;
      edge.endDir = alternativeOppositeDir;
      edge.path = alternativePath;
    }
    return;
  }
  if (preferredPath !== null) {
    edge.startDir = preferredDir;
    edge.endDir = preferredOppositeDir;
    edge.path = mergePath(preferredPath);
    return;
  }
  if (alternativePath !== null) {
    edge.startDir = alternativeDir;
    edge.endDir = alternativeOppositeDir;
    edge.path = mergePath(alternativePath);
    return;
  }
  edge.startDir = preferredDir;
  edge.endDir = preferredOppositeDir;
  edge.path = [prefFrom, prefTo];
}
function determineLabelLine(graph, edge) {
  if (edge.text.length === 0) return;
  const lenLabel = edge.text.length;
  const pathLen = edge.path.length;
  const isVerticalFlow = graph.config.graphDirection === "TD";
  const segments = [];
  for (let i = 1; i < pathLen; i++) {
    const p1 = edge.path[i - 1];
    const p2 = edge.path[i];
    const line = [p1, p2];
    const width = calculateLineWidth(graph, line);
    const isVertical = p1.x === p2.x;
    segments.push({ line, width, index: i, isVertical });
  }
  const suitableSegments = segments.filter((s) => s.width >= lenLabel && s.index > 1);
  let largestLine;
  if (suitableSegments.length > 0) {
    suitableSegments.sort((a, b) => b.index - a.index);
    largestLine = suitableSegments[0].line;
  } else {
    const fallbackSegments = segments.filter((s) => s.width >= lenLabel);
    if (fallbackSegments.length > 0) {
      fallbackSegments.sort((a, b) => b.index - a.index);
      largestLine = fallbackSegments[0].line;
    } else {
      segments.sort((a, b) => b.width - a.width);
      largestLine = segments[0]?.line ?? [edge.path[0], edge.path[1]];
    }
  }
  const minX = Math.min(largestLine[0].x, largestLine[1].x);
  const maxX = Math.max(largestLine[0].x, largestLine[1].x);
  const middleX = minX + Math.floor((maxX - minX) / 2);
  const current = graph.columnWidth.get(middleX) ?? 0;
  graph.columnWidth.set(middleX, Math.max(current, lenLabel + 2));
  edge.labelLine = [largestLine[0], largestLine[1]];
}
function calculateLineWidth(graph, line) {
  let total = 0;
  const startX = Math.min(line[0].x, line[1].x);
  const endX = Math.max(line[0].x, line[1].x);
  for (let x = startX; x <= endX; x++) {
    total += graph.columnWidth.get(x) ?? 0;
  }
  return total;
}

// src/ascii/edge-bundling.ts
function analyzeEdgeBundles(graph) {
  if (graph.config.graphDirection !== "TD") {
    return [];
  }
  const bundles = [];
  const bundledEdges = /* @__PURE__ */ new Set();
  const edgesByTarget = /* @__PURE__ */ new Map();
  for (const edge of graph.edges) {
    if (edge.from === edge.to) continue;
    const existing = edgesByTarget.get(edge.to) ?? [];
    existing.push(edge);
    edgesByTarget.set(edge.to, existing);
  }
  for (const [target, edges] of edgesByTarget) {
    if (edges.length < 2) continue;
    if (!canBundle(edges, graph)) continue;
    if (edges.some((e) => bundledEdges.has(e))) continue;
    const bundle = {
      type: "fan-in",
      edges: [...edges],
      sharedNode: target,
      otherNodes: edges.map((e) => e.from),
      junctionPoint: null,
      sharedPath: [],
      junctionDir: Middle,
      sharedNodeDir: Middle
    };
    for (const edge of edges) {
      edge.bundle = bundle;
      bundledEdges.add(edge);
    }
    bundles.push(bundle);
  }
  const edgesBySource = /* @__PURE__ */ new Map();
  for (const edge of graph.edges) {
    if (edge.from === edge.to) continue;
    if (bundledEdges.has(edge)) continue;
    const existing = edgesBySource.get(edge.from) ?? [];
    existing.push(edge);
    edgesBySource.set(edge.from, existing);
  }
  for (const [source, edges] of edgesBySource) {
    if (edges.length < 2) continue;
    if (!canBundle(edges, graph)) continue;
    const bundle = {
      type: "fan-out",
      edges: [...edges],
      sharedNode: source,
      otherNodes: edges.map((e) => e.to),
      junctionPoint: null,
      sharedPath: [],
      junctionDir: Middle,
      sharedNodeDir: Middle
    };
    for (const edge of edges) {
      edge.bundle = bundle;
      bundledEdges.add(edge);
    }
    bundles.push(bundle);
  }
  return bundles;
}
function canBundle(edges, graph) {
  if (edges.length < 2) return false;
  const firstStyle = edges[0].style;
  const firstFromSg = getNodeSubgraph(graph, edges[0].from);
  const firstToSg = getNodeSubgraph(graph, edges[0].to);
  for (const edge of edges) {
    if (edge.style !== firstStyle) return false;
    if (edge.text.length > 0) return false;
    const fromSg = getNodeSubgraph(graph, edge.from);
    const toSg = getNodeSubgraph(graph, edge.to);
    if (fromSg !== firstFromSg || toSg !== firstToSg) return false;
    if (fromSg !== toSg) return false;
  }
  return true;
}
function calculateJunctionPoint(graph, bundle) {
  const dir = graph.config.graphDirection;
  const sharedCoord = bundle.sharedNode.gridCoord;
  const otherCoords = bundle.otherNodes.map((n) => n.gridCoord);
  if (bundle.type === "fan-in") {
    const minX = Math.min(...otherCoords.map((c) => c.x));
    const maxX = Math.max(...otherCoords.map((c) => c.x));
    const minY = Math.min(...otherCoords.map((c) => c.y));
    const maxY = Math.max(...otherCoords.map((c) => c.y));
    if (dir === "TD") {
      const junctionY = sharedCoord.y - 1;
      const centerX = Math.floor((minX + maxX) / 2) + 1;
      const junctionX = sharedCoord.x + 1;
      return { x: junctionX, y: junctionY };
    } else {
      const junctionX = sharedCoord.x - 1;
      const junctionY = sharedCoord.y + 1;
      return { x: junctionX, y: junctionY };
    }
  } else {
    const minX = Math.min(...otherCoords.map((c) => c.x));
    const maxX = Math.max(...otherCoords.map((c) => c.x));
    const minY = Math.min(...otherCoords.map((c) => c.y));
    const maxY = Math.max(...otherCoords.map((c) => c.y));
    if (dir === "TD") {
      const junctionY = sharedCoord.y + 3;
      const junctionX = sharedCoord.x + 1;
      return { x: junctionX, y: junctionY };
    } else {
      const junctionX = sharedCoord.x + 3;
      const junctionY = sharedCoord.y + 1;
      return { x: junctionX, y: junctionY };
    }
  }
}
function routeBundledEdges(graph, bundle) {
  const dir = graph.config.graphDirection;
  bundle.junctionPoint = calculateJunctionPoint(graph, bundle);
  const junction = bundle.junctionPoint;
  if (bundle.type === "fan-in") {
    bundle.junctionDir = dir === "TD" ? Up : Left;
    bundle.sharedNodeDir = dir === "TD" ? Down : Right;
    const targetCoord = bundle.sharedNode.gridCoord;
    const targetEntry = dir === "TD" ? { x: targetCoord.x + 1, y: targetCoord.y } : { x: targetCoord.x, y: targetCoord.y + 1 };
    const sharedPath = getPath(graph.grid, junction, targetEntry);
    bundle.sharedPath = sharedPath ? mergePath(sharedPath) : [junction, targetEntry];
    for (const edge of bundle.edges) {
      const sourceCoord = edge.from.gridCoord;
      const sourceExit = dir === "TD" ? { x: sourceCoord.x + 1, y: sourceCoord.y + 2 } : { x: sourceCoord.x + 2, y: sourceCoord.y + 1 };
      const pathToJunction = getPath(graph.grid, sourceExit, junction);
      edge.pathToJunction = pathToJunction ? mergePath(pathToJunction) : [sourceExit, junction];
      edge.startDir = dir === "TD" ? Down : Right;
      edge.endDir = dir === "TD" ? Up : Left;
      edge.path = [...edge.pathToJunction, ...bundle.sharedPath.slice(1)];
    }
  } else {
    bundle.junctionDir = dir === "TD" ? Down : Right;
    bundle.sharedNodeDir = dir === "TD" ? Up : Left;
    const sourceCoord = bundle.sharedNode.gridCoord;
    const sourceExit = dir === "TD" ? { x: sourceCoord.x + 1, y: sourceCoord.y + 2 } : { x: sourceCoord.x + 2, y: sourceCoord.y + 1 };
    const sharedPath = getPath(graph.grid, sourceExit, junction);
    bundle.sharedPath = sharedPath ? mergePath(sharedPath) : [sourceExit, junction];
    for (const edge of bundle.edges) {
      const targetCoord = edge.to.gridCoord;
      const targetEntry = dir === "TD" ? { x: targetCoord.x + 1, y: targetCoord.y } : { x: targetCoord.x, y: targetCoord.y + 1 };
      const pathToJunction = getPath(graph.grid, junction, targetEntry);
      edge.pathToJunction = pathToJunction ? mergePath(pathToJunction) : [junction, targetEntry];
      edge.startDir = dir === "TD" ? Down : Right;
      edge.endDir = dir === "TD" ? Up : Left;
      edge.path = [...bundle.sharedPath, ...edge.pathToJunction.slice(1)];
    }
  }
}
function processBundles(graph) {
  for (const bundle of graph.bundles) {
    routeBundledEdges(graph, bundle);
  }
}

// src/ascii/multiline-utils.ts
function splitLines(label) {
  return label.split("\n");
}
function maxLineWidth(label) {
  const lines = splitLines(label);
  return Math.max(...lines.map((l) => l.length), 0);
}
function lineCount(label) {
  return splitLines(label).length;
}

// src/ascii/shapes/corners.ts
var SHAPE_CORNERS = {
  // Standard rectangular shapes
  rectangle: {
    unicode: { tl: "\u250C", tr: "\u2510", bl: "\u2514", br: "\u2518" },
    ascii: { tl: "+", tr: "+", bl: "+", br: "+" }
  },
  rounded: {
    unicode: { tl: "\u256D", tr: "\u256E", bl: "\u2570", br: "\u256F" },
    ascii: { tl: ".", tr: ".", bl: "'", br: "'" }
  },
  // Circular shapes - use circle markers at corners
  circle: {
    unicode: { tl: "\u25EF", tr: "\u25EF", bl: "\u25EF", br: "\u25EF" },
    ascii: { tl: "o", tr: "o", bl: "o", br: "o" }
  },
  doublecircle: {
    unicode: { tl: "\u25CE", tr: "\u25CE", bl: "\u25CE", br: "\u25CE" },
    ascii: { tl: "@", tr: "@", bl: "@", br: "@" }
  },
  // Diamond - decision nodes
  diamond: {
    unicode: { tl: "\u25C7", tr: "\u25C7", bl: "\u25C7", br: "\u25C7" },
    ascii: { tl: "<", tr: ">", bl: "<", br: ">" }
  },
  // Hexagon - process nodes (crop corners — monospace-safe, distinct from rectangle)
  hexagon: {
    unicode: { tl: "\u231C", tr: "\u231D", bl: "\u231E", br: "\u231F" },
    ascii: { tl: "*", tr: "*", bl: "*", br: "*" }
  },
  // Stadium/pill shape
  stadium: {
    unicode: { tl: "(", tr: ")", bl: "(", br: ")" },
    ascii: { tl: "(", tr: ")", bl: "(", br: ")" }
  },
  // Subroutine - double vertical bars
  subroutine: {
    unicode: { tl: "\u255F", tr: "\u2562", bl: "\u255F", br: "\u2562" },
    ascii: { tl: "|", tr: "|", bl: "|", br: "|" }
  },
  // Cylinder/database
  cylinder: {
    unicode: { tl: "\u256D", tr: "\u256E", bl: "\u2570", br: "\u256F" },
    ascii: { tl: ".", tr: ".", bl: "'", br: "'" }
  },
  // Asymmetric/flag - pointer on left side
  asymmetric: {
    unicode: { tl: "\u25B7", tr: "\u2510", bl: "\u25B7", br: "\u2518" },
    ascii: { tl: ">", tr: "+", bl: ">", br: "+" }
  },
  // Trapezoid - wider at bottom (top corners slope inward)
  trapezoid: {
    unicode: { tl: "/", tr: "\\", bl: "\u2514", br: "\u2518" },
    ascii: { tl: "/", tr: "\\", bl: "+", br: "+" }
  },
  // Trapezoid-alt - wider at top (bottom corners slope inward)
  "trapezoid-alt": {
    unicode: { tl: "\u250C", tr: "\u2510", bl: "\\", br: "/" },
    ascii: { tl: "+", tr: "+", bl: "\\", br: "/" }
  },
  // State diagram pseudostates (special handling, not corner-based)
  "state-start": {
    unicode: { tl: "\u25CF", tr: "\u25CF", bl: "\u25CF", br: "\u25CF" },
    ascii: { tl: "*", tr: "*", bl: "*", br: "*" }
  },
  "state-end": {
    unicode: { tl: "\u25C9", tr: "\u25C9", bl: "\u25C9", br: "\u25C9" },
    ascii: { tl: "@", tr: "@", bl: "@", br: "@" }
  }
};
function getCorners(shape, useAscii) {
  const corners = SHAPE_CORNERS[shape] ?? SHAPE_CORNERS.rectangle;
  return useAscii ? corners.ascii : corners.unicode;
}

// src/ascii/shapes/rectangle.ts
function getBoxDimensions(label, options) {
  const lines = splitLines(label);
  const maxLineWidth3 = Math.max(...lines.map((l) => l.length), 0);
  const lineCount3 = lines.length;
  const innerWidth = 2 * options.padding + maxLineWidth3;
  const width = innerWidth + 2;
  const rawInnerHeight = lineCount3 + 2 * options.padding;
  const innerHeight = rawInnerHeight % 2 === 0 ? rawInnerHeight + 1 : rawInnerHeight;
  const height = innerHeight + 2;
  return {
    width,
    height,
    labelArea: {
      x: 1 + options.padding,
      y: 1 + options.padding,
      width: maxLineWidth3,
      height: lineCount3
    },
    // Grid layout: [border=1, content, border=1]
    gridColumns: [1, innerWidth, 1],
    gridRows: [1, innerHeight, 1]
  };
}
function renderBox(label, dimensions, corners, useAscii) {
  const { width, height } = dimensions;
  const canvas = mkCanvas(width - 1, height - 1);
  const from = { x: 0, y: 0 };
  const to = { x: width - 1, y: height - 1 };
  const hLine = useAscii ? "-" : "\u2500";
  const vLine = useAscii ? "|" : "\u2502";
  for (let x = from.x + 1; x < to.x; x++) {
    canvas[x][from.y] = hLine;
    canvas[x][to.y] = hLine;
  }
  for (let y = from.y + 1; y < to.y; y++) {
    canvas[from.x][y] = vLine;
    canvas[to.x][y] = vLine;
  }
  canvas[from.x][from.y] = corners.tl;
  canvas[to.x][from.y] = corners.tr;
  canvas[from.x][to.y] = corners.bl;
  canvas[to.x][to.y] = corners.br;
  const lines = splitLines(label);
  const w = width - 1;
  const h = height - 1;
  const centerY = Math.floor(h / 2);
  const startY = centerY - Math.floor((lines.length - 1) / 2);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const textX = Math.floor(w / 2) - Math.ceil(line.length / 2) + 1;
    for (let j = 0; j < line.length; j++) {
      const x = textX + j;
      const y = startY + i;
      if (x >= 0 && x < canvas.length && y >= 0 && y < canvas[0].length) {
        canvas[x][y] = line[j];
      }
    }
  }
  return canvas;
}
function getBoxAttachmentPoint(dir, dimensions, baseCoord) {
  const { width, height } = dimensions;
  const centerX = baseCoord.x + Math.floor(width / 2);
  const centerY = baseCoord.y + Math.floor(height / 2);
  if (dirEquals(dir, Up)) return { x: centerX, y: baseCoord.y };
  if (dirEquals(dir, Down)) return { x: centerX, y: baseCoord.y + height - 1 };
  if (dirEquals(dir, Left)) return { x: baseCoord.x, y: centerY };
  if (dirEquals(dir, Right)) return { x: baseCoord.x + width - 1, y: centerY };
  if (dirEquals(dir, UpperLeft)) return { x: baseCoord.x, y: baseCoord.y };
  if (dirEquals(dir, UpperRight)) return { x: baseCoord.x + width - 1, y: baseCoord.y };
  if (dirEquals(dir, LowerLeft)) return { x: baseCoord.x, y: baseCoord.y + height - 1 };
  if (dirEquals(dir, LowerRight)) return { x: baseCoord.x + width - 1, y: baseCoord.y + height - 1 };
  return { x: centerX, y: centerY };
}
var rectangleRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("rectangle", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/diamond.ts
var diamondRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("diamond", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/circle.ts
var circleRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("circle", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/state.ts
var stateStartRenderer = {
  getDimensions(_label, _options) {
    const width = 5;
    const height = 3;
    return {
      width,
      height,
      labelArea: { x: 2, y: 1, width: 1, height: 1 },
      gridColumns: [1, 3, 1],
      gridRows: [1, 1, 1]
    };
  },
  render(_label, dimensions, options) {
    const { width, height } = dimensions;
    const canvas = mkCanvas(width - 1, height - 1);
    const centerX = Math.floor(width / 2);
    if (!options.useAscii) {
      canvas[0][0] = "\u256D";
      canvas[1][0] = "\u2500";
      canvas[2][0] = "\u2500";
      canvas[3][0] = "\u2500";
      canvas[4][0] = "\u256E";
      canvas[0][1] = "\u2502";
      canvas[centerX][1] = "\u25CF";
      canvas[4][1] = "\u2502";
      canvas[0][2] = "\u2570";
      canvas[1][2] = "\u2500";
      canvas[2][2] = "\u2500";
      canvas[3][2] = "\u2500";
      canvas[4][2] = "\u256F";
    } else {
      canvas[0][0] = ".";
      canvas[1][0] = "-";
      canvas[2][0] = "-";
      canvas[3][0] = "-";
      canvas[4][0] = ".";
      canvas[0][1] = "|";
      canvas[centerX][1] = "*";
      canvas[4][1] = "|";
      canvas[0][2] = "'";
      canvas[1][2] = "-";
      canvas[2][2] = "-";
      canvas[3][2] = "-";
      canvas[4][2] = "'";
    }
    return canvas;
  },
  getAttachmentPoint(dir, dimensions, baseCoord) {
    const { width, height } = dimensions;
    const centerX = baseCoord.x + Math.floor(width / 2);
    const centerY = baseCoord.y + Math.floor(height / 2);
    if (dirEquals(dir, Up)) return { x: centerX, y: baseCoord.y };
    if (dirEquals(dir, Down)) return { x: centerX, y: baseCoord.y + height - 1 };
    if (dirEquals(dir, Left)) return { x: baseCoord.x, y: centerY };
    if (dirEquals(dir, Right)) return { x: baseCoord.x + width - 1, y: centerY };
    return { x: centerX, y: centerY };
  }
};
var stateEndRenderer = {
  getDimensions(_label, _options) {
    const width = 5;
    const height = 3;
    return {
      width,
      height,
      labelArea: { x: 2, y: 1, width: 1, height: 1 },
      gridColumns: [1, 3, 1],
      gridRows: [1, 1, 1]
    };
  },
  render(_label, dimensions, options) {
    const { width, height } = dimensions;
    const canvas = mkCanvas(width - 1, height - 1);
    const centerX = Math.floor(width / 2);
    if (!options.useAscii) {
      canvas[0][0] = "\u2554";
      canvas[1][0] = "\u2550";
      canvas[2][0] = "\u2550";
      canvas[3][0] = "\u2550";
      canvas[4][0] = "\u2557";
      canvas[0][1] = "\u2551";
      canvas[centerX][1] = "\u25CE";
      canvas[4][1] = "\u2551";
      canvas[0][2] = "\u255A";
      canvas[1][2] = "\u2550";
      canvas[2][2] = "\u2550";
      canvas[3][2] = "\u2550";
      canvas[4][2] = "\u255D";
    } else {
      canvas[0][0] = "#";
      canvas[1][0] = "=";
      canvas[2][0] = "=";
      canvas[3][0] = "=";
      canvas[4][0] = "#";
      canvas[0][1] = "#";
      canvas[centerX][1] = "*";
      canvas[4][1] = "#";
      canvas[0][2] = "#";
      canvas[1][2] = "=";
      canvas[2][2] = "=";
      canvas[3][2] = "=";
      canvas[4][2] = "#";
    }
    return canvas;
  },
  getAttachmentPoint(dir, dimensions, baseCoord) {
    const { width, height } = dimensions;
    const centerX = baseCoord.x + Math.floor(width / 2);
    const centerY = baseCoord.y + Math.floor(height / 2);
    if (dirEquals(dir, Up)) return { x: centerX, y: baseCoord.y };
    if (dirEquals(dir, Down)) return { x: centerX, y: baseCoord.y + height - 1 };
    if (dirEquals(dir, Left)) return { x: baseCoord.x, y: centerY };
    if (dirEquals(dir, Right)) return { x: baseCoord.x + width - 1, y: centerY };
    return { x: centerX, y: centerY };
  }
};

// src/ascii/shapes/rounded.ts
var roundedRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("rounded", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/stadium.ts
var stadiumRenderer = {
  getDimensions(label, options) {
    const lines = splitLines(label);
    const maxLineWidth3 = Math.max(...lines.map((l) => l.length), 0);
    const lineCount3 = lines.length;
    const innerWidth = 2 * options.padding + maxLineWidth3;
    const width = innerWidth + 4;
    const innerHeight = lineCount3 + 2 * options.padding;
    const height = Math.max(innerHeight + 2, 3);
    return {
      width,
      height,
      labelArea: {
        x: 2 + options.padding,
        y: 1 + options.padding,
        width: maxLineWidth3,
        height: lineCount3
      },
      gridColumns: [2, innerWidth, 2],
      gridRows: [1, innerHeight, 1]
    };
  },
  render(label, dimensions, options) {
    const { width, height } = dimensions;
    const canvas = mkCanvas(width - 1, height - 1);
    const centerY = Math.floor(height / 2);
    const hChar = options.useAscii ? "-" : "\u2500";
    if (height === 3) {
      canvas[0][centerY] = "(";
      canvas[width - 1][centerY] = ")";
    } else if (!options.useAscii) {
      canvas[0][0] = "\u256D";
      for (let x = 1; x < width - 1; x++) canvas[x][0] = hChar;
      canvas[width - 1][0] = "\u256E";
      for (let y = 1; y < height - 1; y++) {
        canvas[0][y] = "\u2502";
        canvas[width - 1][y] = "\u2502";
      }
      canvas[0][height - 1] = "\u2570";
      for (let x = 1; x < width - 1; x++) canvas[x][height - 1] = hChar;
      canvas[width - 1][height - 1] = "\u256F";
    } else {
      for (let y = 0; y < height; y++) {
        canvas[0][y] = "(";
        canvas[width - 1][y] = ")";
      }
      for (let x = 1; x < width - 1; x++) {
        canvas[x][0] = hChar;
        canvas[x][height - 1] = hChar;
      }
    }
    const lines = splitLines(label);
    const startY = centerY - Math.floor((lines.length - 1) / 2);
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const textX = Math.floor(width / 2) - Math.floor(line.length / 2);
      for (let j = 0; j < line.length; j++) {
        const x = textX + j;
        const y = startY + i;
        if (x > 0 && x < width - 1 && y >= 0 && y < height) {
          canvas[x][y] = line[j];
        }
      }
    }
    return canvas;
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/hexagon.ts
var hexagonRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("hexagon", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/special.ts
var subroutineRenderer = {
  getDimensions(label, options) {
    const lines = splitLines(label);
    const maxLineWidth3 = Math.max(...lines.map((l) => l.length), 0);
    const lineCount3 = lines.length;
    const innerWidth = 2 * options.padding + maxLineWidth3;
    const width = innerWidth + 4;
    const innerHeight = lineCount3 + 2 * options.padding;
    const height = innerHeight + 2;
    return {
      width,
      height,
      labelArea: {
        x: 2 + options.padding,
        y: 1 + options.padding,
        width: maxLineWidth3,
        height: lineCount3
      },
      gridColumns: [2, innerWidth, 2],
      gridRows: [1, innerHeight, 1]
    };
  },
  render(label, dimensions, options) {
    const { width, height } = dimensions;
    const canvas = mkCanvas(width - 1, height - 1);
    const hChar = options.useAscii ? "-" : "\u2500";
    const vChar = options.useAscii ? "|" : "\u2502";
    canvas[0][0] = options.useAscii ? "+" : "\u250C";
    canvas[1][0] = options.useAscii ? "+" : "\u252C";
    for (let x = 2; x < width - 2; x++) canvas[x][0] = hChar;
    canvas[width - 2][0] = options.useAscii ? "+" : "\u252C";
    canvas[width - 1][0] = options.useAscii ? "+" : "\u2510";
    for (let y = 1; y < height - 1; y++) {
      canvas[0][y] = vChar;
      canvas[1][y] = vChar;
      canvas[width - 2][y] = vChar;
      canvas[width - 1][y] = vChar;
    }
    canvas[0][height - 1] = options.useAscii ? "+" : "\u2514";
    canvas[1][height - 1] = options.useAscii ? "+" : "\u2534";
    for (let x = 2; x < width - 2; x++) canvas[x][height - 1] = hChar;
    canvas[width - 2][height - 1] = options.useAscii ? "+" : "\u2534";
    canvas[width - 1][height - 1] = options.useAscii ? "+" : "\u2518";
    const lines = splitLines(label);
    const centerY = Math.floor(height / 2);
    const startY = centerY - Math.floor((lines.length - 1) / 2);
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const textX = Math.floor(width / 2) - Math.floor(line.length / 2);
      for (let j = 0; j < line.length; j++) {
        const x = textX + j;
        const y = startY + i;
        if (x > 1 && x < width - 2 && y > 0 && y < height - 1) {
          canvas[x][y] = line[j];
        }
      }
    }
    return canvas;
  },
  getAttachmentPoint: getBoxAttachmentPoint
};
var doublecircleRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("doublecircle", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};
var cylinderRenderer = {
  getDimensions(label, options) {
    const lines = splitLines(label);
    const maxLineWidth3 = Math.max(...lines.map((l) => l.length), 0);
    const lineCount3 = lines.length;
    const innerWidth = 2 * options.padding + maxLineWidth3;
    const width = innerWidth + 2;
    const innerHeight = lineCount3 + 2 * options.padding + 2;
    const height = innerHeight + 2;
    return {
      width,
      height,
      labelArea: {
        x: 1 + options.padding,
        y: 2 + options.padding,
        width: maxLineWidth3,
        height: lineCount3
      },
      gridColumns: [1, innerWidth, 1],
      gridRows: [2, innerHeight - 2, 2]
    };
  },
  render(label, dimensions, options) {
    const { width, height } = dimensions;
    const canvas = mkCanvas(width - 1, height - 1);
    const hChar = options.useAscii ? "-" : "\u2500";
    const vChar = options.useAscii ? "|" : "\u2502";
    canvas[0][0] = options.useAscii ? "." : "\u256D";
    for (let x = 1; x < width - 1; x++) canvas[x][0] = hChar;
    canvas[width - 1][0] = options.useAscii ? "." : "\u256E";
    canvas[0][1] = vChar;
    for (let x = 1; x < width - 1; x++) canvas[x][1] = hChar;
    canvas[width - 1][1] = vChar;
    for (let y = 2; y < height - 2; y++) {
      canvas[0][y] = vChar;
      canvas[width - 1][y] = vChar;
    }
    canvas[0][height - 2] = vChar;
    for (let x = 1; x < width - 1; x++) canvas[x][height - 2] = hChar;
    canvas[width - 1][height - 2] = vChar;
    canvas[0][height - 1] = options.useAscii ? "'" : "\u2570";
    for (let x = 1; x < width - 1; x++) canvas[x][height - 1] = hChar;
    canvas[width - 1][height - 1] = options.useAscii ? "'" : "\u256F";
    const lines = splitLines(label);
    const centerY = Math.floor(height / 2);
    const startY = centerY - Math.floor((lines.length - 1) / 2);
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const textX = Math.floor(width / 2) - Math.floor(line.length / 2);
      for (let j = 0; j < line.length; j++) {
        const x = textX + j;
        const y = startY + i;
        if (x > 0 && x < width - 1 && y > 1 && y < height - 2) {
          canvas[x][y] = line[j];
        }
      }
    }
    return canvas;
  },
  getAttachmentPoint: getBoxAttachmentPoint
};
var asymmetricRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("asymmetric", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};
var trapezoidRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("trapezoid", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};
var trapezoidAltRenderer = {
  getDimensions: getBoxDimensions,
  render(label, dimensions, options) {
    const corners = getCorners("trapezoid-alt", options.useAscii);
    return renderBox(label, dimensions, corners, options.useAscii);
  },
  getAttachmentPoint: getBoxAttachmentPoint
};

// src/ascii/shapes/index.ts
var shapeRegistry = /* @__PURE__ */ new Map([
  // Core shapes
  ["rectangle", rectangleRenderer],
  ["rounded", roundedRenderer],
  ["diamond", diamondRenderer],
  ["stadium", stadiumRenderer],
  ["circle", circleRenderer],
  // Batch 1 additions
  ["subroutine", subroutineRenderer],
  ["doublecircle", doublecircleRenderer],
  ["hexagon", hexagonRenderer],
  // Batch 2 additions
  ["cylinder", cylinderRenderer],
  ["asymmetric", asymmetricRenderer],
  ["trapezoid", trapezoidRenderer],
  ["trapezoid-alt", trapezoidAltRenderer],
  // State diagram pseudo-states
  ["state-start", stateStartRenderer],
  ["state-end", stateEndRenderer]
]);
function getShapeRenderer(shape) {
  return shapeRegistry.get(shape) ?? rectangleRenderer;
}
function getShapeDimensions(shape, label, options) {
  const renderer = getShapeRenderer(shape);
  return renderer.getDimensions(label, options);
}
function getShapeAttachmentPoint(shape, dir, dimensions, baseCoord) {
  const renderer = getShapeRenderer(shape);
  return renderer.getAttachmentPoint(dir, dimensions, baseCoord);
}

// src/ascii/draw.ts
function drawNode(node, graph) {
  return drawBoxWithGridDimensions(node, graph);
}
function drawBoxWithGridDimensions(node, graph) {
  const gc = node.gridCoord;
  const useAscii = graph.config.useAscii;
  let w = 0;
  for (let i = 0; i < 2; i++) {
    w += graph.columnWidth.get(gc.x + i) ?? 0;
  }
  let h = 0;
  for (let i = 0; i < 2; i++) {
    h += graph.rowHeight.get(gc.y + i) ?? 0;
  }
  const from = { x: 0, y: 0 };
  const to = { x: w, y: h };
  const box = mkCanvas(Math.max(from.x, to.x), Math.max(from.y, to.y));
  const corners = getCorners(node.shape, useAscii);
  const isDoubleBox = node.shape === "state-end";
  const hChar = useAscii ? isDoubleBox ? "=" : "-" : isDoubleBox ? "\u2550" : "\u2500";
  const vChar = useAscii ? isDoubleBox ? "\u2016" : "|" : isDoubleBox ? "\u2551" : "\u2502";
  const doubleCorners = useAscii ? { tl: "#", tr: "#", bl: "#", br: "#" } : { tl: "\u2554", tr: "\u2557", bl: "\u255A", br: "\u255D" };
  const effectiveCorners = isDoubleBox ? doubleCorners : corners;
  for (let x = from.x + 1; x < to.x; x++) box[x][from.y] = hChar;
  for (let x = from.x + 1; x < to.x; x++) box[x][to.y] = hChar;
  for (let y = from.y + 1; y < to.y; y++) box[from.x][y] = vChar;
  for (let y = from.y + 1; y < to.y; y++) box[to.x][y] = vChar;
  box[from.x][from.y] = effectiveCorners.tl;
  box[to.x][from.y] = effectiveCorners.tr;
  box[from.x][to.y] = effectiveCorners.bl;
  box[to.x][to.y] = effectiveCorners.br;
  const label = node.displayLabel;
  const lines = splitLines(label);
  const textCenterY = from.y + Math.floor(h / 2);
  const startY = textCenterY - Math.floor((lines.length - 1) / 2);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const textX = from.x + Math.floor(w / 2) - Math.ceil(line.length / 2) + 1;
    for (let j = 0; j < line.length; j++) {
      if (textX + j >= 0 && textX + j < box.length && startY + i >= 0 && startY + i < box[0].length) {
        box[textX + j][startY + i] = line[j];
      }
    }
  }
  return box;
}
function drawBox(node, graph) {
  return drawNode(node, graph);
}
function drawMultiBox(sections, useAscii, padding = 1) {
  let maxTextWidth = 0;
  for (const section of sections) {
    for (const line of section) {
      maxTextWidth = Math.max(maxTextWidth, line.length);
    }
  }
  const innerWidth = maxTextWidth + 2 * padding;
  const boxWidth = innerWidth + 2;
  let totalLines = 0;
  for (const section of sections) {
    totalLines += Math.max(section.length, 1);
  }
  const numDividers = sections.length - 1;
  const boxHeight = totalLines + numDividers + 2;
  const hLine = useAscii ? "-" : "\u2500";
  const vLine = useAscii ? "|" : "\u2502";
  const tl = useAscii ? "+" : "\u250C";
  const tr = useAscii ? "+" : "\u2510";
  const bl = useAscii ? "+" : "\u2514";
  const br = useAscii ? "+" : "\u2518";
  const divL = useAscii ? "+" : "\u251C";
  const divR = useAscii ? "+" : "\u2524";
  const canvas = mkCanvas(boxWidth - 1, boxHeight - 1);
  canvas[0][0] = tl;
  for (let x = 1; x < boxWidth - 1; x++) canvas[x][0] = hLine;
  canvas[boxWidth - 1][0] = tr;
  canvas[0][boxHeight - 1] = bl;
  for (let x = 1; x < boxWidth - 1; x++) canvas[x][boxHeight - 1] = hLine;
  canvas[boxWidth - 1][boxHeight - 1] = br;
  for (let y = 1; y < boxHeight - 1; y++) {
    canvas[0][y] = vLine;
    canvas[boxWidth - 1][y] = vLine;
  }
  let row = 1;
  for (let s = 0; s < sections.length; s++) {
    const section = sections[s];
    const lines = section.length > 0 ? section : [""];
    for (const line of lines) {
      const startX = 1 + padding;
      for (let i = 0; i < line.length; i++) {
        canvas[startX + i][row] = line[i];
      }
      row++;
    }
    if (s < sections.length - 1) {
      canvas[0][row] = divL;
      for (let x = 1; x < boxWidth - 1; x++) canvas[x][row] = hLine;
      canvas[boxWidth - 1][row] = divR;
      row++;
    }
  }
  return canvas;
}
var LINE_CHARS = {
  solid: {
    h: { unicode: "\u2500", ascii: "-" },
    v: { unicode: "\u2502", ascii: "|" }
  },
  dotted: {
    h: { unicode: "\u2504", ascii: "." },
    v: { unicode: "\u2506", ascii: ":" }
  },
  thick: {
    h: { unicode: "\u2501", ascii: "=" },
    v: { unicode: "\u2503", ascii: "\u2016" }
  }
};
function drawLine(canvas, from, to, offsetFrom, offsetTo, useAscii, style = "solid") {
  const dir = determineDirection(from, to);
  const drawnCoords = [];
  const chars = LINE_CHARS[style];
  const hChar = useAscii ? chars.h.ascii : chars.h.unicode;
  const vChar = useAscii ? chars.v.ascii : chars.v.unicode;
  if (dirEquals(dir, Up)) {
    for (let y = from.y - offsetFrom; y >= to.y - offsetTo; y--) {
      drawnCoords.push({ x: from.x, y });
      canvas[from.x][y] = vChar;
    }
  } else if (dirEquals(dir, Down)) {
    for (let y = from.y + offsetFrom; y <= to.y + offsetTo; y++) {
      drawnCoords.push({ x: from.x, y });
      canvas[from.x][y] = vChar;
    }
  } else if (dirEquals(dir, Left)) {
    for (let x = from.x - offsetFrom; x >= to.x - offsetTo; x--) {
      drawnCoords.push({ x, y: from.y });
      canvas[x][from.y] = hChar;
    }
  } else if (dirEquals(dir, Right)) {
    for (let x = from.x + offsetFrom; x <= to.x + offsetTo; x++) {
      drawnCoords.push({ x, y: from.y });
      canvas[x][from.y] = hChar;
    }
  } else if (dirEquals(dir, UpperLeft)) {
    for (let x = from.x - offsetFrom; x >= to.x; x--) {
      drawnCoords.push({ x, y: from.y });
      canvas[x][from.y] = hChar;
    }
    for (let y = from.y - 1; y >= to.y - offsetTo; y--) {
      drawnCoords.push({ x: to.x, y });
      canvas[to.x][y] = vChar;
    }
  } else if (dirEquals(dir, UpperRight)) {
    for (let x = from.x + offsetFrom; x <= to.x; x++) {
      drawnCoords.push({ x, y: from.y });
      canvas[x][from.y] = hChar;
    }
    for (let y = from.y - 1; y >= to.y - offsetTo; y--) {
      drawnCoords.push({ x: to.x, y });
      canvas[to.x][y] = vChar;
    }
  } else if (dirEquals(dir, LowerLeft)) {
    for (let x = from.x - offsetFrom; x >= to.x; x--) {
      drawnCoords.push({ x, y: from.y });
      canvas[x][from.y] = hChar;
    }
    for (let y = from.y + 1; y <= to.y + offsetTo; y++) {
      drawnCoords.push({ x: to.x, y });
      canvas[to.x][y] = vChar;
    }
  } else if (dirEquals(dir, LowerRight)) {
    const dx = to.x - from.x;
    if (dx <= 1) {
      for (let y = from.y + offsetFrom; y <= to.y + offsetTo; y++) {
        drawnCoords.push({ x: from.x, y });
        canvas[from.x][y] = vChar;
      }
    } else {
      for (let x = from.x + offsetFrom; x <= to.x; x++) {
        drawnCoords.push({ x, y: from.y });
        canvas[x][from.y] = hChar;
      }
      for (let y = from.y + 1; y <= to.y + offsetTo; y++) {
        drawnCoords.push({ x: to.x, y });
        canvas[to.x][y] = vChar;
      }
    }
  }
  return drawnCoords;
}
function drawArrow(graph, edge) {
  if (edge.path.length === 0) {
    const empty = copyCanvas(graph.canvas);
    return [empty, empty, empty, empty, empty, empty];
  }
  const labelCanvas = drawArrowLabel(graph, edge);
  const [pathCanvas, linesDrawn, lineDirs] = drawPath(graph, edge.path, edge.style);
  const boxStartCanvas = drawBoxStart(graph, edge.path, linesDrawn[0], edge.from.shape);
  let arrowHeadEndCanvas;
  if (edge.hasArrowEnd) {
    arrowHeadEndCanvas = drawArrowHead(
      graph,
      linesDrawn[linesDrawn.length - 1],
      lineDirs[lineDirs.length - 1]
    );
  } else {
    arrowHeadEndCanvas = copyCanvas(graph.canvas);
  }
  let arrowHeadStartCanvas;
  if (edge.hasArrowStart && linesDrawn.length > 0) {
    const firstLine = linesDrawn[0];
    const firstPoint = firstLine[0];
    const startDir = reverseDirection(lineDirs[0]);
    const arrowPos = { x: firstPoint.x, y: firstPoint.y };
    if (dirEquals(lineDirs[0], Right)) arrowPos.x = firstPoint.x - 1;
    else if (dirEquals(lineDirs[0], Left)) arrowPos.x = firstPoint.x + 1;
    else if (dirEquals(lineDirs[0], Down)) arrowPos.y = firstPoint.y - 1;
    else if (dirEquals(lineDirs[0], Up)) arrowPos.y = firstPoint.y + 1;
    const syntheticLine = [firstPoint, arrowPos];
    arrowHeadStartCanvas = drawArrowHead(graph, syntheticLine, startDir);
  } else {
    arrowHeadStartCanvas = copyCanvas(graph.canvas);
  }
  const cornersCanvas = drawCorners(graph, edge.path);
  return [pathCanvas, boxStartCanvas, arrowHeadEndCanvas, arrowHeadStartCanvas, cornersCanvas, labelCanvas];
}
function reverseDirection(dir) {
  if (dirEquals(dir, Up)) return Down;
  if (dirEquals(dir, Down)) return Up;
  if (dirEquals(dir, Left)) return Right;
  if (dirEquals(dir, Right)) return Left;
  if (dirEquals(dir, UpperLeft)) return LowerRight;
  if (dirEquals(dir, UpperRight)) return LowerLeft;
  if (dirEquals(dir, LowerLeft)) return UpperRight;
  if (dirEquals(dir, LowerRight)) return UpperLeft;
  return Middle;
}
function drawPath(graph, path, style = "solid") {
  const canvas = copyCanvas(graph.canvas);
  let previousCoord = path[0];
  const linesDrawn = [];
  const lineDirs = [];
  for (let i = 1; i < path.length; i++) {
    const nextCoord = path[i];
    const prevDC = gridToDrawingCoord(graph, previousCoord);
    const nextDC = gridToDrawingCoord(graph, nextCoord);
    if (drawingCoordEquals(prevDC, nextDC)) {
      previousCoord = nextCoord;
      continue;
    }
    const dir = determineDirection(previousCoord, nextCoord);
    const segment = drawLine(canvas, prevDC, nextDC, 1, -1, graph.config.useAscii, style);
    if (segment.length === 0) segment.push(prevDC);
    linesDrawn.push(segment);
    lineDirs.push(dir);
    previousCoord = nextCoord;
  }
  return [canvas, linesDrawn, lineDirs];
}
function drawBoxStart(graph, path, firstLine, sourceShape) {
  const canvas = copyCanvas(graph.canvas);
  if (graph.config.useAscii) return canvas;
  if (sourceShape === "state-start" || sourceShape === "state-end") {
    return canvas;
  }
  const from = firstLine[0];
  const dir = determineDirection(path[0], path[1]);
  if (dirEquals(dir, Up)) canvas[from.x][from.y + 1] = "\u2534";
  else if (dirEquals(dir, Down)) canvas[from.x][from.y - 1] = "\u252C";
  else if (dirEquals(dir, Left)) canvas[from.x + 1][from.y] = "\u2524";
  else if (dirEquals(dir, Right)) canvas[from.x - 1][from.y] = "\u251C";
  return canvas;
}
function drawArrowHead(graph, lastLine, fallbackDir) {
  const canvas = copyCanvas(graph.canvas);
  if (lastLine.length === 0) return canvas;
  const from = lastLine[0];
  const lastPos = lastLine[lastLine.length - 1];
  let dir = determineDirection(from, lastPos);
  if (lastLine.length === 1 || dirEquals(dir, Middle)) dir = fallbackDir;
  let char;
  if (!graph.config.useAscii) {
    if (dirEquals(dir, Up)) char = "\u25B2";
    else if (dirEquals(dir, Down)) char = "\u25BC";
    else if (dirEquals(dir, Left)) char = "\u25C4";
    else if (dirEquals(dir, Right)) char = "\u25BA";
    else if (dirEquals(dir, UpperRight)) char = "\u25E5";
    else if (dirEquals(dir, UpperLeft)) char = "\u25E4";
    else if (dirEquals(dir, LowerRight)) char = "\u25E2";
    else if (dirEquals(dir, LowerLeft)) char = "\u25E3";
    else {
      if (dirEquals(fallbackDir, Up)) char = "\u25B2";
      else if (dirEquals(fallbackDir, Down)) char = "\u25BC";
      else if (dirEquals(fallbackDir, Left)) char = "\u25C4";
      else if (dirEquals(fallbackDir, Right)) char = "\u25BA";
      else if (dirEquals(fallbackDir, UpperRight)) char = "\u25E5";
      else if (dirEquals(fallbackDir, UpperLeft)) char = "\u25E4";
      else if (dirEquals(fallbackDir, LowerRight)) char = "\u25E2";
      else if (dirEquals(fallbackDir, LowerLeft)) char = "\u25E3";
      else char = "\u25CF";
    }
  } else {
    if (dirEquals(dir, Up)) char = "^";
    else if (dirEquals(dir, Down)) char = "v";
    else if (dirEquals(dir, Left)) char = "<";
    else if (dirEquals(dir, Right)) char = ">";
    else {
      if (dirEquals(fallbackDir, Up)) char = "^";
      else if (dirEquals(fallbackDir, Down)) char = "v";
      else if (dirEquals(fallbackDir, Left)) char = "<";
      else if (dirEquals(fallbackDir, Right)) char = ">";
      else char = "*";
    }
  }
  canvas[lastPos.x][lastPos.y] = char;
  return canvas;
}
function drawCorners(graph, path) {
  const canvas = copyCanvas(graph.canvas);
  for (let idx = 1; idx < path.length - 1; idx++) {
    const coord = path[idx];
    const dc = gridToDrawingCoord(graph, coord);
    const prevDir = determineDirection(path[idx - 1], coord);
    const nextDir = determineDirection(coord, path[idx + 1]);
    let corner;
    if (!graph.config.useAscii) {
      if (dirEquals(prevDir, Right) && dirEquals(nextDir, Down) || dirEquals(prevDir, Up) && dirEquals(nextDir, Left)) {
        corner = "\u2510";
      } else if (dirEquals(prevDir, Right) && dirEquals(nextDir, Up) || dirEquals(prevDir, Down) && dirEquals(nextDir, Left)) {
        corner = "\u2518";
      } else if (dirEquals(prevDir, Left) && dirEquals(nextDir, Down) || dirEquals(prevDir, Up) && dirEquals(nextDir, Right)) {
        corner = "\u250C";
      } else if (dirEquals(prevDir, Left) && dirEquals(nextDir, Up) || dirEquals(prevDir, Down) && dirEquals(nextDir, Right)) {
        corner = "\u2514";
      } else {
        corner = "+";
      }
    } else {
      corner = "+";
    }
    canvas[dc.x][dc.y] = corner;
  }
  return canvas;
}
function drawArrowLabel(graph, edge) {
  const canvas = copyCanvas(graph.canvas);
  if (edge.text.length === 0) return canvas;
  const drawingLine = lineToDrawing(graph, edge.labelLine);
  let isUpwardEdge;
  if (edge.path.length >= 2) {
    const startY = edge.path[0].y;
    const endY = edge.path[edge.path.length - 1].y;
    if (endY < startY) {
      isUpwardEdge = true;
    } else if (endY > startY) {
      isUpwardEdge = false;
    }
  }
  drawTextOnLine(canvas, drawingLine, edge.text, isUpwardEdge);
  return canvas;
}
function drawTextOnLine(canvas, line, label, isUpwardEdge) {
  if (line.length < 2) return;
  const minX = Math.min(line[0].x, line[1].x);
  const maxX = Math.max(line[0].x, line[1].x);
  const minY = Math.min(line[0].y, line[1].y);
  const maxY = Math.max(line[0].y, line[1].y);
  const middleX = minX + Math.floor((maxX - minX) / 2);
  let middleY = minY + Math.floor((maxY - minY) / 2);
  if (isUpwardEdge !== void 0 && minX === maxX) {
    const segmentHeight = maxY - minY;
    const offset = Math.max(1, Math.floor(segmentHeight / 4));
    if (isUpwardEdge) {
      middleY = middleY + offset;
    } else {
      middleY = middleY - offset;
    }
  }
  const lines = splitLines(label);
  const startY = middleY - Math.floor((lines.length - 1) / 2);
  for (let i = 0; i < lines.length; i++) {
    const lineText = lines[i];
    const startX = middleX - Math.floor(lineText.length / 2);
    drawText(canvas, { x: startX, y: startY + i }, lineText);
  }
}
function getNodeAttachmentPoint(graph, node, dir) {
  const gc = node.gridCoord;
  let w = 0;
  for (let i = 0; i < 2; i++) {
    w += graph.columnWidth.get(gc.x + i) ?? 0;
  }
  let h = 0;
  for (let i = 0; i < 2; i++) {
    h += graph.rowHeight.get(gc.y + i) ?? 0;
  }
  const gridDimensions = {
    width: w + 1,
    height: h + 1,
    labelArea: { x: 0, y: 0, width: 0, height: 0 },
    gridColumns: [0, 0, 0],
    gridRows: [0, 0, 0]
  };
  const baseCoord = node.drawingCoord;
  return getShapeAttachmentPoint(node.shape, dir, gridDimensions, baseCoord);
}
function drawBundledEdgeSegment(graph, edge, bundle) {
  const empty = copyCanvas(graph.canvas);
  if (!edge.pathToJunction || edge.pathToJunction.length === 0) {
    return [empty, empty, empty, empty, empty, empty];
  }
  const pathCanvas = copyCanvas(graph.canvas);
  const useAscii = graph.config.useAscii;
  const drawingPath = edge.pathToJunction.map((gc, idx) => {
    if (bundle.type === "fan-in" && idx === 0) {
      return getNodeAttachmentPoint(graph, edge.from, edge.startDir);
    }
    if (bundle.type === "fan-out" && idx === edge.pathToJunction.length - 1) {
      return getNodeAttachmentPoint(graph, edge.to, edge.endDir);
    }
    return gridToDrawingCoord(graph, gc);
  });
  for (let i = 1; i < drawingPath.length; i++) {
    const from = drawingPath[i - 1];
    const to = drawingPath[i];
    if (!drawingCoordEquals(from, to)) {
      drawLine(pathCanvas, from, to, 1, -1, useAscii, edge.style);
    }
  }
  const cornersCanvas = copyCanvas(graph.canvas);
  for (let idx = 1; idx < edge.pathToJunction.length - 1; idx++) {
    const coord = edge.pathToJunction[idx];
    const dc = gridToDrawingCoord(graph, coord);
    const prevDir = determineDirection(edge.pathToJunction[idx - 1], coord);
    const nextDir = determineDirection(coord, edge.pathToJunction[idx + 1]);
    let corner;
    if (!useAscii) {
      if (dirEquals(prevDir, Right) && dirEquals(nextDir, Down) || dirEquals(prevDir, Up) && dirEquals(nextDir, Left)) {
        corner = "\u2510";
      } else if (dirEquals(prevDir, Right) && dirEquals(nextDir, Up) || dirEquals(prevDir, Down) && dirEquals(nextDir, Left)) {
        corner = "\u2518";
      } else if (dirEquals(prevDir, Left) && dirEquals(nextDir, Down) || dirEquals(prevDir, Up) && dirEquals(nextDir, Right)) {
        corner = "\u250C";
      } else if (dirEquals(prevDir, Left) && dirEquals(nextDir, Up) || dirEquals(prevDir, Down) && dirEquals(nextDir, Right)) {
        corner = "\u2514";
      } else {
        corner = "+";
      }
    } else {
      corner = "+";
    }
    cornersCanvas[dc.x][dc.y] = corner;
  }
  const boxStartCanvas = copyCanvas(graph.canvas);
  if (bundle.type === "fan-in" && edge.pathToJunction.length >= 2) {
    const firstPoint = drawingPath[0];
    const dir = determineDirection(edge.pathToJunction[0], edge.pathToJunction[1]);
    if (!useAscii) {
      if (dirEquals(dir, Up)) boxStartCanvas[firstPoint.x][firstPoint.y] = "\u2534";
      else if (dirEquals(dir, Down)) boxStartCanvas[firstPoint.x][firstPoint.y] = "\u252C";
      else if (dirEquals(dir, Left)) boxStartCanvas[firstPoint.x][firstPoint.y] = "\u2524";
      else if (dirEquals(dir, Right)) boxStartCanvas[firstPoint.x][firstPoint.y] = "\u251C";
    }
  }
  const labelCanvas = copyCanvas(graph.canvas);
  return [pathCanvas, boxStartCanvas, empty, empty, cornersCanvas, labelCanvas];
}
function drawBundleSharedPath(graph, bundle) {
  const pathCanvas = copyCanvas(graph.canvas);
  const cornersCanvas = copyCanvas(graph.canvas);
  if (bundle.sharedPath.length < 2) {
    return [pathCanvas, cornersCanvas];
  }
  const useAscii = graph.config.useAscii;
  const style = bundle.edges[0]?.style ?? "solid";
  const graphDir = graph.config.graphDirection;
  const drawingPath = bundle.sharedPath.map((gc, idx) => {
    if (bundle.type === "fan-in" && idx === bundle.sharedPath.length - 1) {
      const entryDir = graphDir === "TD" ? Up : Left;
      return getNodeAttachmentPoint(graph, bundle.sharedNode, entryDir);
    }
    if (bundle.type === "fan-out" && idx === 0) {
      const exitDir = graphDir === "TD" ? Down : Right;
      return getNodeAttachmentPoint(graph, bundle.sharedNode, exitDir);
    }
    return gridToDrawingCoord(graph, gc);
  });
  for (let i = 1; i < drawingPath.length; i++) {
    const from = drawingPath[i - 1];
    const to = drawingPath[i];
    if (!drawingCoordEquals(from, to)) {
      drawLine(pathCanvas, from, to, 1, -1, useAscii, style);
    }
  }
  for (let idx = 1; idx < bundle.sharedPath.length - 1; idx++) {
    const coord = bundle.sharedPath[idx];
    const dc = gridToDrawingCoord(graph, coord);
    const prevDir = determineDirection(bundle.sharedPath[idx - 1], coord);
    const nextDir = determineDirection(coord, bundle.sharedPath[idx + 1]);
    let corner;
    if (!useAscii) {
      if (dirEquals(prevDir, Right) && dirEquals(nextDir, Down) || dirEquals(prevDir, Up) && dirEquals(nextDir, Left)) {
        corner = "\u2510";
      } else if (dirEquals(prevDir, Right) && dirEquals(nextDir, Up) || dirEquals(prevDir, Down) && dirEquals(nextDir, Left)) {
        corner = "\u2518";
      } else if (dirEquals(prevDir, Left) && dirEquals(nextDir, Down) || dirEquals(prevDir, Up) && dirEquals(nextDir, Right)) {
        corner = "\u250C";
      } else if (dirEquals(prevDir, Left) && dirEquals(nextDir, Up) || dirEquals(prevDir, Down) && dirEquals(nextDir, Right)) {
        corner = "\u2514";
      } else {
        corner = "+";
      }
    } else {
      corner = "+";
    }
    cornersCanvas[dc.x][dc.y] = corner;
  }
  return [pathCanvas, cornersCanvas];
}
function drawBundleArrowhead(graph, bundle) {
  const canvas = copyCanvas(graph.canvas);
  if (bundle.sharedPath.length < 2) return canvas;
  const lastIdx = bundle.sharedPath.length - 1;
  const secondLast = bundle.sharedPath[lastIdx - 1];
  const last = bundle.sharedPath[lastIdx];
  const dir = determineDirection(secondLast, last);
  const graphDir = graph.config.graphDirection;
  const entryDir = graphDir === "TD" ? Up : Left;
  const dc = getNodeAttachmentPoint(graph, bundle.sharedNode, entryDir);
  if (graphDir === "TD") dc.y -= 1;
  else dc.x -= 1;
  let char;
  if (!graph.config.useAscii) {
    if (dirEquals(dir, Up)) char = "\u25B2";
    else if (dirEquals(dir, Down)) char = "\u25BC";
    else if (dirEquals(dir, Left)) char = "\u25C4";
    else if (dirEquals(dir, Right)) char = "\u25BA";
    else char = "\u25BC";
  } else {
    if (dirEquals(dir, Up)) char = "^";
    else if (dirEquals(dir, Down)) char = "v";
    else if (dirEquals(dir, Left)) char = "<";
    else if (dirEquals(dir, Right)) char = ">";
    else char = "v";
  }
  canvas[dc.x][dc.y] = char;
  return canvas;
}
function drawBundledEdgeArrowhead(graph, edge) {
  const canvas = copyCanvas(graph.canvas);
  if (!edge.pathToJunction || edge.pathToJunction.length < 2) return canvas;
  const lastIdx = edge.pathToJunction.length - 1;
  const secondLast = edge.pathToJunction[lastIdx - 1];
  const last = edge.pathToJunction[lastIdx];
  const dir = determineDirection(secondLast, last);
  const graphDir = graph.config.graphDirection;
  const entryDir = graphDir === "TD" ? Up : Left;
  const dc = getNodeAttachmentPoint(graph, edge.to, entryDir);
  if (graphDir === "TD") dc.y -= 1;
  else dc.x -= 1;
  let char;
  if (!graph.config.useAscii) {
    if (dirEquals(dir, Up)) char = "\u25B2";
    else if (dirEquals(dir, Down)) char = "\u25BC";
    else if (dirEquals(dir, Left)) char = "\u25C4";
    else if (dirEquals(dir, Right)) char = "\u25BA";
    else char = "\u25BC";
  } else {
    if (dirEquals(dir, Up)) char = "^";
    else if (dirEquals(dir, Down)) char = "v";
    else if (dirEquals(dir, Left)) char = "<";
    else if (dirEquals(dir, Right)) char = ">";
    else char = "v";
  }
  canvas[dc.x][dc.y] = char;
  return canvas;
}
function drawJunctionCharacter(graph, bundle) {
  const canvas = copyCanvas(graph.canvas);
  if (!bundle.junctionPoint) return canvas;
  const dc = gridToDrawingCoord(graph, bundle.junctionPoint);
  const useAscii = graph.config.useAscii;
  let hasUp = false;
  let hasDown = false;
  let hasLeft = false;
  let hasRight = false;
  if (bundle.sharedPath.length >= 2) {
    const junctionIdx = bundle.type === "fan-in" ? 0 : bundle.sharedPath.length - 1;
    const adjacentIdx = bundle.type === "fan-in" ? 1 : bundle.sharedPath.length - 2;
    const sharedDir = determineDirection(
      bundle.sharedPath[junctionIdx],
      bundle.sharedPath[adjacentIdx]
    );
    if (dirEquals(sharedDir, Down)) hasDown = true;
    else if (dirEquals(sharedDir, Up)) hasUp = true;
    else if (dirEquals(sharedDir, Right)) hasRight = true;
    else if (dirEquals(sharedDir, Left)) hasLeft = true;
  }
  for (const edge of bundle.edges) {
    if (edge.pathToJunction && edge.pathToJunction.length >= 2) {
      const junctionIdx = bundle.type === "fan-in" ? edge.pathToJunction.length - 1 : 0;
      const adjacentIdx = bundle.type === "fan-in" ? edge.pathToJunction.length - 2 : 1;
      const arrivalDir = determineDirection(
        edge.pathToJunction[adjacentIdx],
        edge.pathToJunction[junctionIdx]
      );
      if (dirEquals(arrivalDir, Down)) hasUp = true;
      else if (dirEquals(arrivalDir, Up)) hasDown = true;
      else if (dirEquals(arrivalDir, Right)) hasLeft = true;
      else if (dirEquals(arrivalDir, Left)) hasRight = true;
    }
  }
  let char;
  if (!useAscii) {
    if (hasUp && hasDown && hasLeft && hasRight) {
      char = "\u253C";
    } else if (hasDown && hasLeft && hasRight && !hasUp) {
      char = "\u252C";
    } else if (hasUp && hasLeft && hasRight && !hasDown) {
      char = "\u2534";
    } else if (hasUp && hasDown && hasRight && !hasLeft) {
      char = "\u251C";
    } else if (hasUp && hasDown && hasLeft && !hasRight) {
      char = "\u2524";
    } else if (hasLeft && hasRight) {
      char = "\u2500";
    } else if (hasUp && hasDown) {
      char = "\u2502";
    } else if (hasDown && hasRight) {
      char = "\u250C";
    } else if (hasDown && hasLeft) {
      char = "\u2510";
    } else if (hasUp && hasRight) {
      char = "\u2514";
    } else if (hasUp && hasLeft) {
      char = "\u2518";
    } else {
      char = "\u253C";
    }
  } else {
    char = "+";
  }
  canvas[dc.x][dc.y] = char;
  return canvas;
}
function drawSubgraphBox(sg, graph) {
  const width = sg.maxX - sg.minX;
  const height = sg.maxY - sg.minY;
  if (width <= 0 || height <= 0) return mkCanvas(0, 0);
  const from = { x: 0, y: 0 };
  const to = { x: width, y: height };
  const canvas = mkCanvas(width, height);
  if (!graph.config.useAscii) {
    for (let x = from.x + 1; x < to.x; x++) canvas[x][from.y] = "\u2500";
    for (let x = from.x + 1; x < to.x; x++) canvas[x][to.y] = "\u2500";
    for (let y = from.y + 1; y < to.y; y++) canvas[from.x][y] = "\u2502";
    for (let y = from.y + 1; y < to.y; y++) canvas[to.x][y] = "\u2502";
    canvas[from.x][from.y] = "\u250C";
    canvas[to.x][from.y] = "\u2510";
    canvas[from.x][to.y] = "\u2514";
    canvas[to.x][to.y] = "\u2518";
  } else {
    for (let x = from.x + 1; x < to.x; x++) canvas[x][from.y] = "-";
    for (let x = from.x + 1; x < to.x; x++) canvas[x][to.y] = "-";
    for (let y = from.y + 1; y < to.y; y++) canvas[from.x][y] = "|";
    for (let y = from.y + 1; y < to.y; y++) canvas[to.x][y] = "|";
    canvas[from.x][from.y] = "+";
    canvas[to.x][from.y] = "+";
    canvas[from.x][to.y] = "+";
    canvas[to.x][to.y] = "+";
  }
  return canvas;
}
function drawSubgraphLabel(sg, graph) {
  const width = sg.maxX - sg.minX;
  const height = sg.maxY - sg.minY;
  if (width <= 0 || height <= 0) return [mkCanvas(0, 0), { x: 0, y: 0 }];
  const canvas = mkCanvas(width, height);
  const lines = splitLines(sg.name);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const labelY = 1 + i;
    let labelX = Math.floor(width / 2) - Math.floor(line.length / 2);
    if (labelX < 1) labelX = 1;
    for (let j = 0; j < line.length; j++) {
      if (labelX + j < width && labelY < height) {
        canvas[labelX + j][labelY] = line[j];
      }
    }
  }
  return [canvas, { x: sg.minX, y: sg.minY }];
}
function sortSubgraphsByDepth(subgraphs) {
  function getDepth(sg) {
    return sg.parent === null ? 0 : 1 + getDepth(sg.parent);
  }
  const sorted = [...subgraphs];
  sorted.sort((a, b) => getDepth(a) - getDepth(b));
  return sorted;
}
function fillRolesFromCanvas(roleCanvas, canvas, offset, role) {
  for (let x = 0; x < canvas.length; x++) {
    for (let y = 0; y < (canvas[0]?.length ?? 0); y++) {
      const char = canvas[x]?.[y];
      if (char && char !== " ") {
        const rx = x + offset.x;
        const ry = y + offset.y;
        if (rx >= 0 && ry >= 0) {
          setRole(roleCanvas, rx, ry, role);
        }
      }
    }
  }
}
function fillRolesFromCanvases(roleCanvas, canvases, offset, role) {
  for (const canvas of canvases) {
    fillRolesFromCanvas(roleCanvas, canvas, offset, role);
  }
}
function fillRolesForNodeBox(roleCanvas, canvas, offset) {
  const isBorderChar = (c) => /^[┌┐└┘├┤┬┴┼│─╭╮╰╯+\-|.':]$/.test(c);
  for (let x = 0; x < canvas.length; x++) {
    for (let y = 0; y < (canvas[0]?.length ?? 0); y++) {
      const char = canvas[x]?.[y];
      if (char && char !== " ") {
        const rx = x + offset.x;
        const ry = y + offset.y;
        if (rx >= 0 && ry >= 0) {
          setRole(roleCanvas, rx, ry, isBorderChar(char) ? "border" : "text");
        }
      }
    }
  }
}
function drawGraph(graph) {
  const useAscii = graph.config.useAscii;
  const zero = { x: 0, y: 0 };
  const sortedSgs = sortSubgraphsByDepth(graph.subgraphs);
  for (const sg of sortedSgs) {
    const sgCanvas = drawSubgraphBox(sg, graph);
    const offset = { x: sg.minX, y: sg.minY };
    graph.canvas = mergeCanvases(graph.canvas, offset, useAscii, sgCanvas);
    fillRolesFromCanvas(graph.roleCanvas, sgCanvas, offset, "border");
  }
  for (const node of graph.nodes) {
    if (!node.drawn && node.drawingCoord && node.drawing) {
      graph.canvas = mergeCanvases(graph.canvas, node.drawingCoord, useAscii, node.drawing);
      fillRolesForNodeBox(graph.roleCanvas, node.drawing, node.drawingCoord);
      node.drawn = true;
    }
  }
  const lineCanvases = [];
  const cornerCanvases = [];
  const arrowHeadEndCanvases = [];
  const arrowHeadStartCanvases = [];
  const boxStartCanvases = [];
  const labelCanvases = [];
  const junctionCanvases = [];
  const processedBundles = /* @__PURE__ */ new Set();
  for (const edge of graph.edges) {
    if (edge.bundle && edge.pathToJunction) {
      const bundle = edge.bundle;
      const [pathC, boxStartC, , , cornersC, labelC] = drawBundledEdgeSegment(graph, edge, bundle);
      lineCanvases.push(pathC);
      cornerCanvases.push(cornersC);
      boxStartCanvases.push(boxStartC);
      labelCanvases.push(labelC);
      if (!processedBundles.has(bundle)) {
        processedBundles.add(bundle);
        const [sharedPathC, sharedCornersC] = drawBundleSharedPath(graph, bundle);
        lineCanvases.push(sharedPathC);
        cornerCanvases.push(sharedCornersC);
        if (bundle.type === "fan-in") {
          const arrowHeadC = drawBundleArrowhead(graph, bundle);
          arrowHeadEndCanvases.push(arrowHeadC);
        }
        const junctionC = drawJunctionCharacter(graph, bundle);
        junctionCanvases.push(junctionC);
      }
      if (bundle.type === "fan-out" && edge.hasArrowEnd) {
        const arrowHeadC = drawBundledEdgeArrowhead(graph, edge);
        arrowHeadEndCanvases.push(arrowHeadC);
      }
    } else {
      const [pathC, boxStartC, arrowHeadEndC, arrowHeadStartC, cornersC, labelC] = drawArrow(graph, edge);
      lineCanvases.push(pathC);
      cornerCanvases.push(cornersC);
      arrowHeadEndCanvases.push(arrowHeadEndC);
      arrowHeadStartCanvases.push(arrowHeadStartC);
      boxStartCanvases.push(boxStartC);
      labelCanvases.push(labelC);
    }
  }
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...lineCanvases);
  fillRolesFromCanvases(graph.roleCanvas, lineCanvases, zero, "line");
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...cornerCanvases);
  fillRolesFromCanvases(graph.roleCanvas, cornerCanvases, zero, "corner");
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...junctionCanvases);
  fillRolesFromCanvases(graph.roleCanvas, junctionCanvases, zero, "junction");
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...arrowHeadEndCanvases);
  fillRolesFromCanvases(graph.roleCanvas, arrowHeadEndCanvases, zero, "arrow");
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...boxStartCanvases);
  fillRolesFromCanvases(graph.roleCanvas, boxStartCanvases, zero, "junction");
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...arrowHeadStartCanvases);
  fillRolesFromCanvases(graph.roleCanvas, arrowHeadStartCanvases, zero, "arrow");
  graph.canvas = mergeCanvases(graph.canvas, zero, useAscii, ...labelCanvases);
  fillRolesFromCanvases(graph.roleCanvas, labelCanvases, zero, "text");
  for (const sg of graph.subgraphs) {
    if (sg.nodes.length === 0) continue;
    const [labelCanvas, offset] = drawSubgraphLabel(sg, graph);
    graph.canvas = mergeCanvases(graph.canvas, offset, useAscii, labelCanvas);
    fillRolesFromCanvas(graph.roleCanvas, labelCanvas, offset, "text");
  }
  return graph.canvas;
}

// src/ascii/grid.ts
function gridToDrawingCoord(graph, c, dir) {
  const target = dir ? { x: c.x + dir.x, y: c.y + dir.y } : c;
  let x = 0;
  for (let col = 0; col < target.x; col++) {
    x += graph.columnWidth.get(col) ?? 0;
  }
  let y = 0;
  for (let row = 0; row < target.y; row++) {
    y += graph.rowHeight.get(row) ?? 0;
  }
  const colW = graph.columnWidth.get(target.x) ?? 0;
  const rowH = graph.rowHeight.get(target.y) ?? 0;
  return {
    x: x + Math.floor(colW / 2) + graph.offsetX,
    y: y + Math.floor(rowH / 2) + graph.offsetY
  };
}
function lineToDrawing(graph, line) {
  return line.map((c) => gridToDrawingCoord(graph, c));
}
function reserveSpotInGrid(graph, node, requested, effectiveDir) {
  const dir = effectiveDir ?? getEffectiveDirection2(graph, node);
  if (graph.grid.has(gridKey(requested))) {
    if (dir === "LR") {
      return reserveSpotInGrid(graph, node, { x: requested.x, y: requested.y + 4 }, dir);
    } else {
      return reserveSpotInGrid(graph, node, { x: requested.x + 4, y: requested.y }, dir);
    }
  }
  for (let dx = 0; dx < 3; dx++) {
    for (let dy = 0; dy < 3; dy++) {
      const reserved = { x: requested.x + dx, y: requested.y + dy };
      graph.grid.set(gridKey(reserved), node);
    }
  }
  node.gridCoord = requested;
  return requested;
}
function setColumnWidth(graph, node) {
  const gc = node.gridCoord;
  const padding = graph.config.boxBorderPadding;
  const shapeDims = getShapeDimensions(node.shape, node.displayLabel, {
    useAscii: graph.config.useAscii,
    padding
  });
  const colWidths = shapeDims.gridColumns;
  const rowHeights = shapeDims.gridRows;
  for (let idx = 0; idx < colWidths.length; idx++) {
    const xCoord = gc.x + idx;
    const current = graph.columnWidth.get(xCoord) ?? 0;
    graph.columnWidth.set(xCoord, Math.max(current, colWidths[idx]));
  }
  for (let idx = 0; idx < rowHeights.length; idx++) {
    const yCoord = gc.y + idx;
    const current = graph.rowHeight.get(yCoord) ?? 0;
    graph.rowHeight.set(yCoord, Math.max(current, rowHeights[idx]));
  }
  if (gc.x > 0) {
    const current = graph.columnWidth.get(gc.x - 1) ?? 0;
    graph.columnWidth.set(gc.x - 1, Math.max(current, graph.config.paddingX));
  }
  if (gc.y > 0) {
    let basePadding = graph.config.paddingY;
    if (hasIncomingEdgeFromOutsideSubgraph(graph, node)) {
      const subgraphOverhead = 4;
      basePadding += subgraphOverhead;
    }
    const current = graph.rowHeight.get(gc.y - 1) ?? 0;
    graph.rowHeight.set(gc.y - 1, Math.max(current, basePadding));
  }
}
function increaseGridSizeForPath(graph, path) {
  for (const c of path) {
    if (!graph.columnWidth.has(c.x)) {
      graph.columnWidth.set(c.x, Math.floor(graph.config.paddingX / 2));
    }
    if (!graph.rowHeight.has(c.y)) {
      graph.rowHeight.set(c.y, Math.floor(graph.config.paddingY / 2));
    }
  }
}
function isNodeInAnySubgraph(graph, node) {
  return graph.subgraphs.some((sg) => sg.nodes.includes(node));
}
function getNodeSubgraph(graph, node) {
  let innermost = null;
  for (const sg of graph.subgraphs) {
    if (sg.nodes.includes(node)) {
      if (!innermost || isAncestorOrSelf2(innermost, sg)) {
        innermost = sg;
      }
    }
  }
  return innermost;
}
function isAncestorOrSelf2(candidate, target) {
  let current = target;
  while (current !== null) {
    if (current === candidate) return true;
    current = current.parent;
  }
  return false;
}
function getEffectiveDirection2(graph, node) {
  const sg = getNodeSubgraph(graph, node);
  if (sg?.direction) {
    return sg.direction;
  }
  return graph.config.graphDirection;
}
function hasIncomingEdgeFromOutsideSubgraph(graph, node) {
  const nodeSg = getNodeSubgraph(graph, node);
  if (!nodeSg) return false;
  let hasExternalEdge = false;
  for (const edge of graph.edges) {
    if (edge.to === node) {
      const sourceSg = getNodeSubgraph(graph, edge.from);
      if (sourceSg !== nodeSg) {
        hasExternalEdge = true;
        break;
      }
    }
  }
  if (!hasExternalEdge) return false;
  for (const otherNode of nodeSg.nodes) {
    if (otherNode === node || !otherNode.gridCoord) continue;
    let otherHasExternal = false;
    for (const edge of graph.edges) {
      if (edge.to === otherNode) {
        const sourceSg = getNodeSubgraph(graph, edge.from);
        if (sourceSg !== nodeSg) {
          otherHasExternal = true;
          break;
        }
      }
    }
    if (otherHasExternal && otherNode.gridCoord.y < node.gridCoord.y) {
      return false;
    }
  }
  return true;
}
function calculateSubgraphBoundingBox(graph, sg) {
  if (sg.nodes.length === 0) return;
  let minX = 1e6;
  let minY = 1e6;
  let maxX = -1e6;
  let maxY = -1e6;
  for (const child of sg.children) {
    calculateSubgraphBoundingBox(graph, child);
    if (child.nodes.length > 0) {
      minX = Math.min(minX, child.minX);
      minY = Math.min(minY, child.minY);
      maxX = Math.max(maxX, child.maxX);
      maxY = Math.max(maxY, child.maxY);
    }
  }
  for (const node of sg.nodes) {
    if (!node.drawingCoord || !node.drawing) continue;
    const nodeMinX = node.drawingCoord.x;
    const nodeMinY = node.drawingCoord.y;
    const nodeMaxX = nodeMinX + node.drawing.length - 1;
    const nodeMaxY = nodeMinY + node.drawing[0].length - 1;
    minX = Math.min(minX, nodeMinX);
    minY = Math.min(minY, nodeMinY);
    maxX = Math.max(maxX, nodeMaxX);
    maxY = Math.max(maxY, nodeMaxY);
  }
  const subgraphPadding = 2;
  const subgraphLabelSpace = 2;
  sg.minX = minX - subgraphPadding;
  sg.minY = minY - subgraphPadding - subgraphLabelSpace;
  sg.maxX = maxX + subgraphPadding;
  sg.maxY = maxY + subgraphPadding;
}
function ensureSubgraphSpacing(graph) {
  const minSpacing = 1;
  const rootSubgraphs = graph.subgraphs.filter((sg) => sg.parent === null && sg.nodes.length > 0);
  for (let i = 0; i < rootSubgraphs.length; i++) {
    for (let j = i + 1; j < rootSubgraphs.length; j++) {
      const sg1 = rootSubgraphs[i];
      const sg2 = rootSubgraphs[j];
      if (sg1.minX < sg2.maxX && sg1.maxX > sg2.minX) {
        if (sg1.maxY >= sg2.minY - minSpacing && sg1.minY < sg2.minY) {
          sg2.minY = sg1.maxY + minSpacing + 1;
        } else if (sg2.maxY >= sg1.minY - minSpacing && sg2.minY < sg1.minY) {
          sg1.minY = sg2.maxY + minSpacing + 1;
        }
      }
      if (sg1.minY < sg2.maxY && sg1.maxY > sg2.minY) {
        if (sg1.maxX >= sg2.minX - minSpacing && sg1.minX < sg2.minX) {
          sg2.minX = sg1.maxX + minSpacing + 1;
        } else if (sg2.maxX >= sg1.minX - minSpacing && sg2.minX < sg1.minX) {
          sg1.minX = sg2.maxX + minSpacing + 1;
        }
      }
    }
  }
}
function calculateSubgraphBoundingBoxes(graph) {
  for (const sg of graph.subgraphs) {
    calculateSubgraphBoundingBox(graph, sg);
  }
  ensureSubgraphSpacing(graph);
}
function offsetDrawingForSubgraphs(graph) {
  if (graph.subgraphs.length === 0) return;
  let minX = 0;
  let minY = 0;
  for (const sg of graph.subgraphs) {
    minX = Math.min(minX, sg.minX);
    minY = Math.min(minY, sg.minY);
  }
  const offsetX = -minX;
  const offsetY = -minY;
  if (offsetX === 0 && offsetY === 0) return;
  graph.offsetX = offsetX;
  graph.offsetY = offsetY;
  for (const sg of graph.subgraphs) {
    sg.minX += offsetX;
    sg.minY += offsetY;
    sg.maxX += offsetX;
    sg.maxY += offsetY;
  }
  for (const node of graph.nodes) {
    if (node.drawingCoord) {
      node.drawingCoord.x += offsetX;
      node.drawingCoord.y += offsetY;
    }
  }
}
function createMapping(graph) {
  const dir = graph.config.graphDirection;
  const highestPositionPerLevel = new Array(100).fill(0);
  const nodesFound = /* @__PURE__ */ new Set();
  const initialRoots = [];
  for (const node of graph.nodes) {
    if (!nodesFound.has(node.name)) {
      initialRoots.push(node);
    }
    nodesFound.add(node.name);
    for (const child of getChildren(graph, node)) {
      nodesFound.add(child.name);
    }
  }
  const rootNodes = initialRoots.filter((node) => {
    const nodeSg = getNodeSubgraph(graph, node);
    if (!nodeSg) return true;
    for (const edge of graph.edges) {
      if (edge.to === node) {
        const sourceSg = getNodeSubgraph(graph, edge.from);
        if (sourceSg !== nodeSg) {
          return false;
        }
      }
    }
    return true;
  });
  let hasExternalRoots = false;
  let hasSubgraphRootsWithEdges = false;
  for (const node of rootNodes) {
    if (isNodeInAnySubgraph(graph, node)) {
      if (getChildren(graph, node).length > 0) hasSubgraphRootsWithEdges = true;
    } else {
      hasExternalRoots = true;
    }
  }
  const shouldSeparate = dir === "LR" && hasExternalRoots && hasSubgraphRootsWithEdges;
  let externalRootNodes;
  let subgraphRootNodes = [];
  if (shouldSeparate) {
    externalRootNodes = rootNodes.filter((n) => !isNodeInAnySubgraph(graph, n));
    subgraphRootNodes = rootNodes.filter((n) => isNodeInAnySubgraph(graph, n));
  } else {
    externalRootNodes = rootNodes;
  }
  for (const node of externalRootNodes) {
    const requested = dir === "LR" ? { x: 0, y: highestPositionPerLevel[0] } : { x: highestPositionPerLevel[0], y: 0 };
    reserveSpotInGrid(graph, graph.nodes[node.index], requested);
    highestPositionPerLevel[0] = highestPositionPerLevel[0] + 4;
  }
  if (shouldSeparate && subgraphRootNodes.length > 0) {
    const subgraphLevel = 4;
    for (const node of subgraphRootNodes) {
      const requested = dir === "LR" ? { x: subgraphLevel, y: highestPositionPerLevel[subgraphLevel] } : { x: highestPositionPerLevel[subgraphLevel], y: subgraphLevel };
      reserveSpotInGrid(graph, graph.nodes[node.index], requested);
      highestPositionPerLevel[subgraphLevel] = highestPositionPerLevel[subgraphLevel] + 4;
    }
  }
  let placedCount = externalRootNodes.length + subgraphRootNodes.length;
  while (placedCount < graph.nodes.length) {
    const prevCount = placedCount;
    for (const node of graph.nodes) {
      if (node.gridCoord === null) continue;
      const gc = node.gridCoord;
      for (const child of getChildren(graph, node)) {
        if (child.gridCoord !== null) continue;
        const parentSg = getNodeSubgraph(graph, node);
        const childSg = getNodeSubgraph(graph, child);
        const edgeDir = parentSg && parentSg === childSg && parentSg.direction ? parentSg.direction : graph.config.graphDirection;
        const childLevel = edgeDir === "LR" ? gc.x + 4 : gc.y + 4;
        let highestPosition;
        if (edgeDir !== graph.config.graphDirection) {
          highestPosition = edgeDir === "LR" ? gc.y : gc.x;
        } else {
          highestPosition = highestPositionPerLevel[childLevel];
        }
        const requested = edgeDir === "LR" ? { x: childLevel, y: highestPosition } : { x: highestPosition, y: childLevel };
        reserveSpotInGrid(graph, graph.nodes[child.index], requested, edgeDir);
        if (edgeDir === graph.config.graphDirection) {
          highestPositionPerLevel[childLevel] = highestPosition + 4;
        }
        placedCount++;
      }
    }
    if (placedCount === prevCount) break;
  }
  for (const node of graph.nodes) {
    setColumnWidth(graph, node);
  }
  graph.bundles = analyzeEdgeBundles(graph);
  processBundles(graph);
  for (const edge of graph.edges) {
    if (edge.bundle && edge.path.length > 0) {
      increaseGridSizeForPath(graph, edge.path);
      determineLabelLine(graph, edge);
      continue;
    }
    determinePath(graph, edge);
    increaseGridSizeForPath(graph, edge.path);
    determineLabelLine(graph, edge);
  }
  for (const node of graph.nodes) {
    node.drawingCoord = gridToDrawingCoord(graph, node.gridCoord);
    node.drawing = drawBox(node, graph);
  }
  setCanvasSizeToGrid(graph.canvas, graph.columnWidth, graph.rowHeight);
  setRoleCanvasSizeToGrid(graph.roleCanvas, graph.columnWidth, graph.rowHeight);
  calculateSubgraphBoundingBoxes(graph);
  offsetDrawingForSubgraphs(graph);
}
function getEdgesFromNode(graph, node) {
  return graph.edges.filter((e) => e.from.name === node.name);
}
function getChildren(graph, node) {
  return getEdgesFromNode(graph, node).map((e) => e.to);
}

// src/sequence/parser.ts
function parseSequenceDiagram(lines) {
  const diagram = {
    actors: [],
    messages: [],
    blocks: [],
    notes: []
  };
  const actorIds = /* @__PURE__ */ new Set();
  const blockStack = [];
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    const actorMatch = line.match(/^(participant|actor)\s+(\S+?)(?:\s+as\s+(.+))?$/);
    if (actorMatch) {
      const type = actorMatch[1];
      const id = actorMatch[2];
      const rawLabel = actorMatch[3]?.trim() ?? id;
      const label = normalizeBrTags(rawLabel);
      if (!actorIds.has(id)) {
        actorIds.add(id);
        diagram.actors.push({ id, label, type });
      }
      continue;
    }
    const noteMatch = line.match(/^Note\s+(left of|right of|over)\s+([^:]+):\s*(.+)$/i);
    if (noteMatch) {
      const posStr = noteMatch[1].toLowerCase();
      const actorsStr = noteMatch[2].trim();
      const text = normalizeBrTags(noteMatch[3].trim());
      const noteActorIds = actorsStr.split(",").map((s) => s.trim());
      for (const aid of noteActorIds) {
        ensureActor(diagram, actorIds, aid);
      }
      let position = "over";
      if (posStr === "left of") position = "left";
      else if (posStr === "right of") position = "right";
      diagram.notes.push({
        actorIds: noteActorIds,
        text,
        position,
        afterIndex: diagram.messages.length - 1
      });
      continue;
    }
    const blockMatch = line.match(/^(loop|alt|opt|par|critical|break|rect)\s*(.*)$/);
    if (blockMatch) {
      const blockType = blockMatch[1];
      const rawBlockLabel = blockMatch[2]?.trim() ?? "";
      const label = normalizeBrTags(rawBlockLabel);
      blockStack.push({
        type: blockType,
        label,
        startIndex: diagram.messages.length,
        dividers: []
      });
      continue;
    }
    const dividerMatch = line.match(/^(else|and)\s*(.*)$/);
    if (dividerMatch && blockStack.length > 0) {
      const rawDividerLabel = dividerMatch[2]?.trim() ?? "";
      const label = normalizeBrTags(rawDividerLabel);
      blockStack[blockStack.length - 1].dividers.push({
        index: diagram.messages.length,
        label
      });
      continue;
    }
    if (line === "end" && blockStack.length > 0) {
      const completed = blockStack.pop();
      diagram.blocks.push({
        type: completed.type,
        label: completed.label,
        startIndex: completed.startIndex,
        endIndex: Math.max(diagram.messages.length - 1, completed.startIndex),
        dividers: completed.dividers
      });
      continue;
    }
    const msgMatch = line.match(
      /^(\S+?)\s*(--?>?>|--?[)x]|--?>>|--?>)\s*([+-]?)(\S+?)\s*:\s*(.+)$/
    );
    if (msgMatch) {
      const from = msgMatch[1];
      const arrow = msgMatch[2];
      const activationMark = msgMatch[3];
      const to = msgMatch[4];
      const label = normalizeBrTags(msgMatch[5].trim());
      ensureActor(diagram, actorIds, from);
      ensureActor(diagram, actorIds, to);
      const lineStyle = arrow.startsWith("--") ? "dashed" : "solid";
      const arrowHead = arrow.includes(">>") || arrow.includes("x") ? "filled" : "open";
      const msg = {
        from,
        to,
        label,
        lineStyle,
        arrowHead
      };
      if (activationMark === "+") msg.activate = true;
      if (activationMark === "-") msg.deactivate = true;
      diagram.messages.push(msg);
      continue;
    }
    const simpleMsgMatch = line.match(
      /^(\S+?)\s*(->>|-->>|-\)|--\)|-x|--x|->|-->)\s*([+-]?)(\S+?)\s*:\s*(.+)$/
    );
    if (simpleMsgMatch) {
      const from = simpleMsgMatch[1];
      const arrow = simpleMsgMatch[2];
      const activationMark = simpleMsgMatch[3];
      const to = simpleMsgMatch[4];
      const label = normalizeBrTags(simpleMsgMatch[5].trim());
      ensureActor(diagram, actorIds, from);
      ensureActor(diagram, actorIds, to);
      const lineStyle = arrow.startsWith("--") ? "dashed" : "solid";
      const arrowHead = arrow.includes(">>") || arrow.includes("x") ? "filled" : "open";
      const msg = { from, to, label, lineStyle, arrowHead };
      if (activationMark === "+") msg.activate = true;
      if (activationMark === "-") msg.deactivate = true;
      diagram.messages.push(msg);
      continue;
    }
  }
  return diagram;
}
function ensureActor(diagram, actorIds, id) {
  if (!actorIds.has(id)) {
    actorIds.add(id);
    diagram.actors.push({ id, label: id, type: "participant" });
  }
}

// src/ascii/sequence.ts
function renderSequenceAscii(text, config, colorMode, theme) {
  const lines = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("%%"));
  const diagram = parseSequenceDiagram(lines);
  if (diagram.actors.length === 0) return "";
  const useAscii = config.useAscii;
  const H = useAscii ? "-" : "\u2500";
  const V = useAscii ? "|" : "\u2502";
  const TL = useAscii ? "+" : "\u250C";
  const TR = useAscii ? "+" : "\u2510";
  const BL = useAscii ? "+" : "\u2514";
  const BR = useAscii ? "+" : "\u2518";
  const JT = useAscii ? "+" : "\u252C";
  const JB = useAscii ? "+" : "\u2534";
  const JL = useAscii ? "+" : "\u251C";
  const JR = useAscii ? "+" : "\u2524";
  const actorIdx = /* @__PURE__ */ new Map();
  diagram.actors.forEach((a, i) => actorIdx.set(a.id, i));
  const boxPad = 1;
  const actorBoxWidths = diagram.actors.map((a) => maxLineWidth(a.label) + 2 * boxPad + 2);
  const halfBox = actorBoxWidths.map((w) => Math.ceil(w / 2));
  const actorBoxHeights = diagram.actors.map((a) => lineCount(a.label) + 2);
  const actorBoxH = Math.max(...actorBoxHeights, 3);
  const adjMaxWidth = new Array(Math.max(diagram.actors.length - 1, 0)).fill(0);
  for (const msg of diagram.messages) {
    const fi = actorIdx.get(msg.from);
    const ti = actorIdx.get(msg.to);
    if (fi === ti) continue;
    const lo = Math.min(fi, ti);
    const hi = Math.max(fi, ti);
    const needed = maxLineWidth(msg.label) + 4;
    const numGaps = hi - lo;
    const perGap = Math.ceil(needed / numGaps);
    for (let g = lo; g < hi; g++) {
      adjMaxWidth[g] = Math.max(adjMaxWidth[g], perGap);
    }
  }
  const llX = [halfBox[0]];
  for (let i = 1; i < diagram.actors.length; i++) {
    const gap = Math.max(
      halfBox[i - 1] + halfBox[i] + 2,
      adjMaxWidth[i - 1] + 2,
      10
    );
    llX[i] = llX[i - 1] + gap;
  }
  const msgArrowY = [];
  const msgLabelY = [];
  const blockStartY = /* @__PURE__ */ new Map();
  const blockEndY = /* @__PURE__ */ new Map();
  const divYMap = /* @__PURE__ */ new Map();
  const notePositions = [];
  let curY = actorBoxH;
  for (let m = 0; m < diagram.messages.length; m++) {
    for (let b = 0; b < diagram.blocks.length; b++) {
      if (diagram.blocks[b].startIndex === m) {
        curY += 2;
        blockStartY.set(b, curY - 1);
      }
    }
    for (let b = 0; b < diagram.blocks.length; b++) {
      for (let d = 0; d < diagram.blocks[b].dividers.length; d++) {
        if (diagram.blocks[b].dividers[d].index === m) {
          curY += 1;
          divYMap.set(`${b}:${d}`, curY);
          curY += 1;
        }
      }
    }
    curY += 1;
    const msg = diagram.messages[m];
    const isSelf = msg.from === msg.to;
    const msgLineCount = lineCount(msg.label);
    if (isSelf) {
      msgLabelY[m] = curY + 1;
      msgArrowY[m] = curY;
      curY += 2 + msgLineCount;
    } else {
      msgLabelY[m] = curY;
      msgArrowY[m] = curY + msgLineCount;
      curY += msgLineCount + 1;
    }
    for (let n = 0; n < diagram.notes.length; n++) {
      if (diagram.notes[n].afterIndex === m) {
        curY += 1;
        const note = diagram.notes[n];
        const nLines = splitLines(note.text);
        const nWidth = Math.max(...nLines.map((l) => l.length)) + 4;
        const nHeight = nLines.length + 2;
        const aIdx = actorIdx.get(note.actorIds[0]) ?? 0;
        let nx;
        if (note.position === "left") {
          nx = llX[aIdx] - nWidth - 1;
        } else if (note.position === "right") {
          nx = llX[aIdx] + 2;
        } else {
          if (note.actorIds.length >= 2) {
            const aIdx2 = actorIdx.get(note.actorIds[1]) ?? aIdx;
            nx = Math.floor((llX[aIdx] + llX[aIdx2]) / 2) - Math.floor(nWidth / 2);
          } else {
            nx = llX[aIdx] - Math.floor(nWidth / 2);
          }
        }
        nx = Math.max(0, nx);
        notePositions.push({ x: nx, y: curY, width: nWidth, height: nHeight, lines: nLines });
        curY += nHeight;
      }
    }
    for (let b = 0; b < diagram.blocks.length; b++) {
      if (diagram.blocks[b].endIndex === m) {
        curY += 1;
        blockEndY.set(b, curY);
        curY += 1;
      }
    }
  }
  curY += 1;
  const footerY = curY;
  const totalH = footerY + actorBoxH;
  const lastLL = llX[llX.length - 1] ?? 0;
  const lastHalf = halfBox[halfBox.length - 1] ?? 0;
  let totalW = lastLL + lastHalf + 2;
  for (let m = 0; m < diagram.messages.length; m++) {
    const msg = diagram.messages[m];
    if (msg.from === msg.to) {
      const fi = actorIdx.get(msg.from);
      const selfRight = llX[fi] + 6 + 2 + msg.label.length;
      totalW = Math.max(totalW, selfRight + 1);
    }
  }
  for (const np of notePositions) {
    totalW = Math.max(totalW, np.x + np.width + 1);
  }
  const canvas = mkCanvas(totalW, totalH - 1);
  const rc = mkRoleCanvas(totalW, totalH - 1);
  function setC(x, y, ch, role) {
    if (x >= 0 && x < canvas.length && y >= 0 && y < (canvas[0]?.length ?? 0)) {
      canvas[x][y] = ch;
      setRole(rc, x, y, role);
    }
  }
  function drawActorBox(cx, topY, label) {
    const lines2 = splitLines(label);
    const maxW = maxLineWidth(label);
    const w = maxW + 2 * boxPad + 2;
    const h = lines2.length + 2;
    const left = cx - Math.floor(w / 2);
    setC(left, topY, TL, "border");
    for (let x = 1; x < w - 1; x++) setC(left + x, topY, H, "border");
    setC(left + w - 1, topY, TR, "border");
    for (let i = 0; i < lines2.length; i++) {
      const row = topY + 1 + i;
      setC(left, row, V, "border");
      setC(left + w - 1, row, V, "border");
      const line = lines2[i];
      const ls = left + 1 + boxPad + Math.floor((maxW - line.length) / 2);
      for (let j = 0; j < line.length; j++) {
        setC(ls + j, row, line[j], "text");
      }
    }
    const bottomY = topY + h - 1;
    setC(left, bottomY, BL, "border");
    for (let x = 1; x < w - 1; x++) setC(left + x, bottomY, H, "border");
    setC(left + w - 1, bottomY, BR, "border");
  }
  for (let i = 0; i < diagram.actors.length; i++) {
    const x = llX[i];
    for (let y = actorBoxH; y <= footerY; y++) {
      setC(x, y, V, "line");
    }
  }
  for (let i = 0; i < diagram.actors.length; i++) {
    const actor = diagram.actors[i];
    drawActorBox(llX[i], 0, actor.label);
    drawActorBox(llX[i], footerY, actor.label);
    if (!useAscii) {
      setC(llX[i], actorBoxH - 1, JT, "junction");
      setC(llX[i], footerY, JB, "junction");
    }
  }
  for (let m = 0; m < diagram.messages.length; m++) {
    const msg = diagram.messages[m];
    const fi = actorIdx.get(msg.from);
    const ti = actorIdx.get(msg.to);
    const fromX = llX[fi];
    const toX = llX[ti];
    const isSelf = fi === ti;
    const isDashed = msg.lineStyle === "dashed";
    const isFilled = msg.arrowHead === "filled";
    const lineChar = isDashed ? useAscii ? "." : "\u254C" : H;
    if (isSelf) {
      const y0 = msgArrowY[m];
      const loopW = Math.max(4, 4);
      setC(fromX, y0, JL, "junction");
      for (let x = fromX + 1; x < fromX + loopW; x++) setC(x, y0, lineChar, "line");
      setC(fromX + loopW, y0, useAscii ? "+" : "\u2510", "corner");
      setC(fromX + loopW, y0 + 1, V, "line");
      const labelX = fromX + loopW + 2;
      for (let i = 0; i < msg.label.length; i++) {
        if (labelX + i < totalW) setC(labelX + i, y0 + 1, msg.label[i], "text");
      }
      const arrowChar = isFilled ? useAscii ? "<" : "\u25C0" : useAscii ? "<" : "\u25C1";
      setC(fromX, y0 + 2, arrowChar, "arrow");
      for (let x = fromX + 1; x < fromX + loopW; x++) setC(x, y0 + 2, lineChar, "line");
      setC(fromX + loopW, y0 + 2, useAscii ? "+" : "\u2518", "corner");
    } else {
      const labelY = msgLabelY[m];
      const arrowY = msgArrowY[m];
      const leftToRight = fromX < toX;
      const midX = Math.floor((fromX + toX) / 2);
      const msgLines = splitLines(msg.label);
      for (let lineIdx = 0; lineIdx < msgLines.length; lineIdx++) {
        const line = msgLines[lineIdx];
        const labelStart = midX - Math.floor(line.length / 2);
        const y = labelY + lineIdx;
        for (let i = 0; i < line.length; i++) {
          const lx = labelStart + i;
          if (lx >= 0 && lx < totalW) setC(lx, y, line[i], "text");
        }
      }
      if (leftToRight) {
        for (let x = fromX + 1; x < toX; x++) setC(x, arrowY, lineChar, "line");
        const ah = isFilled ? useAscii ? ">" : "\u25B6" : useAscii ? ">" : "\u25B7";
        setC(toX, arrowY, ah, "arrow");
      } else {
        for (let x = toX + 1; x < fromX; x++) setC(x, arrowY, lineChar, "line");
        const ah = isFilled ? useAscii ? "<" : "\u25C0" : useAscii ? "<" : "\u25C1";
        setC(toX, arrowY, ah, "arrow");
      }
    }
  }
  for (let b = 0; b < diagram.blocks.length; b++) {
    const block = diagram.blocks[b];
    const topY = blockStartY.get(b);
    const botY = blockEndY.get(b);
    if (topY === void 0 || botY === void 0) continue;
    let minLX = totalW;
    let maxLX = 0;
    for (let m = block.startIndex; m <= block.endIndex; m++) {
      if (m >= diagram.messages.length) break;
      const msg = diagram.messages[m];
      const f = actorIdx.get(msg.from) ?? 0;
      const t = actorIdx.get(msg.to) ?? 0;
      minLX = Math.min(minLX, llX[Math.min(f, t)]);
      maxLX = Math.max(maxLX, llX[Math.max(f, t)]);
    }
    const bLeft = Math.max(0, minLX - 4);
    const bRight = Math.min(totalW - 1, maxLX + 4);
    setC(bLeft, topY, TL, "border");
    for (let x = bLeft + 1; x < bRight; x++) setC(x, topY, H, "border");
    setC(bRight, topY, TR, "border");
    const hdrLabel = block.label ? `${block.type} [${block.label}]` : block.type;
    const hdrLines = splitLines(hdrLabel);
    for (let lineIdx = 0; lineIdx < hdrLines.length && topY + lineIdx < botY; lineIdx++) {
      const line = hdrLines[lineIdx];
      for (let i = 0; i < line.length && bLeft + 1 + i < bRight; i++) {
        setC(bLeft + 1 + i, topY + lineIdx, line[i], "text");
      }
    }
    setC(bLeft, botY, BL, "border");
    for (let x = bLeft + 1; x < bRight; x++) setC(x, botY, H, "border");
    setC(bRight, botY, BR, "border");
    for (let y = topY + 1; y < botY; y++) {
      setC(bLeft, y, V, "border");
      setC(bRight, y, V, "border");
    }
    for (let d = 0; d < block.dividers.length; d++) {
      const dY = divYMap.get(`${b}:${d}`);
      if (dY === void 0) continue;
      const dashChar = isDashedH();
      setC(bLeft, dY, JL, "junction");
      for (let x = bLeft + 1; x < bRight; x++) setC(x, dY, dashChar, "line");
      setC(bRight, dY, JR, "junction");
      const dLabel = block.dividers[d].label;
      if (dLabel) {
        const dStr = `[${dLabel}]`;
        for (let i = 0; i < dStr.length && bLeft + 1 + i < bRight; i++) {
          setC(bLeft + 1 + i, dY, dStr[i], "text");
        }
      }
    }
  }
  for (const np of notePositions) {
    increaseSize(canvas, np.x + np.width, np.y + np.height);
    increaseRoleCanvasSize(rc, np.x + np.width, np.y + np.height);
    setC(np.x, np.y, TL, "border");
    for (let x = 1; x < np.width - 1; x++) setC(np.x + x, np.y, H, "border");
    setC(np.x + np.width - 1, np.y, TR, "border");
    for (let l = 0; l < np.lines.length; l++) {
      const ly = np.y + 1 + l;
      setC(np.x, ly, V, "border");
      setC(np.x + np.width - 1, ly, V, "border");
      for (let i = 0; i < np.lines[l].length; i++) {
        setC(np.x + 2 + i, ly, np.lines[l][i], "text");
      }
    }
    const by = np.y + np.height - 1;
    setC(np.x, by, BL, "border");
    for (let x = 1; x < np.width - 1; x++) setC(np.x + x, by, H, "border");
    setC(np.x + np.width - 1, by, BR, "border");
  }
  return canvasToString(canvas, { roleCanvas: rc, colorMode, theme });
  function isDashedH() {
    return useAscii ? "-" : "\u254C";
  }
}

// src/class/parser.ts
function parseClassDiagram(lines) {
  const diagram = {
    classes: [],
    relationships: [],
    namespaces: []
  };
  const classMap = /* @__PURE__ */ new Map();
  let currentNamespace = null;
  let currentClass = null;
  let braceDepth = 0;
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    if (currentClass && braceDepth > 0) {
      if (line === "}") {
        braceDepth--;
        if (braceDepth === 0) {
          currentClass = null;
        }
        continue;
      }
      const annotMatch = line.match(/^<<(\w+)>>$/);
      if (annotMatch) {
        currentClass.annotation = annotMatch[1];
        continue;
      }
      const member = parseMember(line);
      if (member) {
        if (member.isMethod) {
          currentClass.methods.push(member.member);
        } else {
          currentClass.attributes.push(member.member);
        }
      }
      continue;
    }
    const nsMatch = line.match(/^namespace\s+(\S+)\s*\{$/);
    if (nsMatch) {
      currentNamespace = { name: nsMatch[1], classIds: [] };
      continue;
    }
    if (line === "}" && currentNamespace) {
      diagram.namespaces.push(currentNamespace);
      currentNamespace = null;
      continue;
    }
    const classBlockMatch = line.match(/^class\s+(\S+?)(?:\s*~(\w+)~)?\s*\{$/);
    if (classBlockMatch) {
      const id = classBlockMatch[1];
      const generic = classBlockMatch[2];
      const cls = ensureClass(classMap, id);
      if (generic) {
        cls.label = `${id}<${generic}>`;
      }
      currentClass = cls;
      braceDepth = 1;
      if (currentNamespace) {
        currentNamespace.classIds.push(id);
      }
      continue;
    }
    const classOnlyMatch = line.match(/^class\s+(\S+?)(?:\s*~(\w+)~)?\s*$/);
    if (classOnlyMatch) {
      const id = classOnlyMatch[1];
      const generic = classOnlyMatch[2];
      const cls = ensureClass(classMap, id);
      if (generic) {
        cls.label = `${id}<${generic}>`;
      }
      if (currentNamespace) {
        currentNamespace.classIds.push(id);
      }
      continue;
    }
    const inlineAnnotMatch = line.match(/^class\s+(\S+?)\s*\{\s*<<(\w+)>>\s*\}$/);
    if (inlineAnnotMatch) {
      const cls = ensureClass(classMap, inlineAnnotMatch[1]);
      cls.annotation = inlineAnnotMatch[2];
      continue;
    }
    const inlineAttrMatch = line.match(/^(\S+?)\s*:\s*(.+)$/);
    if (inlineAttrMatch) {
      const rest = inlineAttrMatch[2];
      if (!rest.match(/<\|--|--|\*--|o--|-->|\.\.>|\.\.\|>/)) {
        const cls = ensureClass(classMap, inlineAttrMatch[1]);
        const member = parseMember(rest);
        if (member) {
          if (member.isMethod) {
            cls.methods.push(member.member);
          } else {
            cls.attributes.push(member.member);
          }
        }
        continue;
      }
    }
    const rel = parseRelationship(line);
    if (rel) {
      ensureClass(classMap, rel.from);
      ensureClass(classMap, rel.to);
      diagram.relationships.push(rel);
      continue;
    }
  }
  diagram.classes = [...classMap.values()];
  return diagram;
}
function ensureClass(classMap, id) {
  let cls = classMap.get(id);
  if (!cls) {
    cls = { id, label: id, attributes: [], methods: [] };
    classMap.set(id, cls);
  }
  return cls;
}
function parseMember(line) {
  const trimmed = line.trim().replace(/;$/, "");
  if (!trimmed) return null;
  let visibility = "";
  let rest = trimmed;
  if (/^[+\-#~]/.test(rest)) {
    visibility = rest[0];
    rest = rest.slice(1).trim();
  }
  const methodMatch = rest.match(/^(.+?)\(([^)]*)\)(?:\s*(.+))?$/);
  if (methodMatch) {
    const name2 = methodMatch[1].trim();
    const params = methodMatch[2]?.trim() || void 0;
    const type2 = methodMatch[3]?.trim();
    const isStatic2 = name2.endsWith("$") || rest.includes("$");
    const isAbstract2 = name2.endsWith("*") || rest.includes("*");
    return {
      member: {
        visibility,
        name: name2.replace(/[$*]$/, ""),
        type: type2 || void 0,
        isStatic: isStatic2,
        isAbstract: isAbstract2,
        isMethod: true,
        params
      },
      isMethod: true
    };
  }
  const parts = rest.split(/\s+/);
  let name;
  let type;
  if (parts.length >= 2) {
    type = parts[0];
    name = parts.slice(1).join(" ");
  } else {
    name = parts[0] ?? rest;
  }
  const isStatic = name.endsWith("$");
  const isAbstract = name.endsWith("*");
  return {
    member: {
      visibility,
      name: name.replace(/[$*]$/, ""),
      type: type || void 0,
      isStatic,
      isAbstract,
      isMethod: false
    },
    isMethod: false
  };
}
function parseRelationship(line) {
  const match = line.match(
    /^(\S+?)\s+(?:"([^"]*?)"\s+)?(<\|--|<\|\.\.|\*--|o--|-->|--\*|--o|--\|>|\.\.>|\.\.\|>|<--|<\.\.?|--)\s+(?:"([^"]*?)"\s+)?(\S+?)(?:\s*:\s*(.+))?$/
  );
  if (!match) return null;
  const from = match[1];
  const rawFromCardinality = match[2];
  const fromCardinality = rawFromCardinality ? normalizeBrTags(rawFromCardinality) : void 0;
  const arrow = match[3].trim();
  const rawToCardinality = match[4];
  const toCardinality = rawToCardinality ? normalizeBrTags(rawToCardinality) : void 0;
  const to = match[5];
  const rawLabel = match[6]?.trim();
  const label = rawLabel ? normalizeBrTags(rawLabel) : void 0;
  const parsed = parseArrow(arrow);
  if (!parsed) return null;
  return { from, to, type: parsed.type, markerAt: parsed.markerAt, label, fromCardinality, toCardinality };
}
function parseArrow(arrow) {
  const a = arrow.trim();
  switch (a) {
    case "<|--":
      return { type: "inheritance", markerAt: "from" };
    case "--|>":
      return { type: "inheritance", markerAt: "to" };
    case "<|..":
      return { type: "realization", markerAt: "from" };
    case "..|>":
      return { type: "realization", markerAt: "to" };
    case "*--":
      return { type: "composition", markerAt: "from" };
    case "--*":
      return { type: "composition", markerAt: "to" };
    case "o--":
      return { type: "aggregation", markerAt: "from" };
    case "--o":
      return { type: "aggregation", markerAt: "to" };
    case "-->":
      return { type: "association", markerAt: "to" };
    case "<--":
      return { type: "association", markerAt: "from" };
    case "..>":
      return { type: "dependency", markerAt: "to" };
    case "<..":
      return { type: "dependency", markerAt: "from" };
    case "--":
      return { type: "association", markerAt: "to" };
    default:
      return null;
  }
}

// src/ascii/class-diagram.ts
function classifyBoxChar(ch) {
  if (/^[┌┐└┘├┤┬┴┼│─╭╮╰╯+\-|]$/.test(ch)) return "border";
  return "text";
}
function formatMember(m) {
  const vis = m.visibility || "";
  const type = m.type ? `: ${m.type}` : "";
  return `${vis}${m.name}${type}`;
}
function buildClassSections(cls) {
  const header = [];
  if (cls.annotation) header.push(`<<${cls.annotation}>>`);
  const nameLines = splitLines(cls.label);
  header.push(...nameLines);
  const attrs = cls.attributes.map(formatMember);
  const methods = cls.methods.map(formatMember);
  if (attrs.length === 0 && methods.length === 0) return [header];
  if (methods.length === 0) return [header, attrs];
  return [header, attrs, methods];
}
function getRelMarker(type, markerAt) {
  const dashed = type === "dependency" || type === "realization";
  return { type, markerAt, dashed };
}
function getMarkerShape(type, useAscii, direction) {
  switch (type) {
    case "inheritance":
    case "realization":
      if (direction === "down") {
        return useAscii ? "^" : "\u25B3";
      } else if (direction === "up") {
        return useAscii ? "v" : "\u25BD";
      } else if (direction === "left") {
        return useAscii ? ">" : "\u25C1";
      } else {
        return useAscii ? "<" : "\u25B7";
      }
    case "composition":
      return useAscii ? "*" : "\u25C6";
    case "aggregation":
      return useAscii ? "o" : "\u25C7";
    case "association":
    case "dependency":
      if (direction === "down") {
        return useAscii ? "v" : "\u25BC";
      } else if (direction === "up") {
        return useAscii ? "^" : "\u25B2";
      } else if (direction === "left") {
        return useAscii ? "<" : "\u25C0";
      } else {
        return useAscii ? ">" : "\u25B6";
      }
  }
}
function renderClassAscii(text, config, colorMode, theme) {
  const lines = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("%%"));
  const diagram = parseClassDiagram(lines);
  if (diagram.classes.length === 0) return "";
  const useAscii = config.useAscii;
  const hGap = 4;
  const vGap = 3;
  const classSections = /* @__PURE__ */ new Map();
  const classBoxW = /* @__PURE__ */ new Map();
  const classBoxH = /* @__PURE__ */ new Map();
  for (const cls of diagram.classes) {
    const sections = buildClassSections(cls);
    classSections.set(cls.id, sections);
    let maxTextW = 0;
    for (const section of sections) {
      for (const line of section) maxTextW = Math.max(maxTextW, line.length);
    }
    const boxW = maxTextW + 4;
    let totalLines = 0;
    for (const section of sections) totalLines += Math.max(section.length, 1);
    const boxH = totalLines + (sections.length - 1) + 2;
    classBoxW.set(cls.id, boxW);
    classBoxH.set(cls.id, boxH);
  }
  const classById = /* @__PURE__ */ new Map();
  for (const cls of diagram.classes) classById.set(cls.id, cls);
  const parents = /* @__PURE__ */ new Map();
  const children = /* @__PURE__ */ new Map();
  for (const rel of diagram.relationships) {
    const isHierarchical = rel.type === "inheritance" || rel.type === "realization";
    const parentId = isHierarchical && rel.markerAt === "to" ? rel.to : rel.from;
    const childId = isHierarchical && rel.markerAt === "to" ? rel.from : rel.to;
    if (!parents.has(childId)) parents.set(childId, /* @__PURE__ */ new Set());
    parents.get(childId).add(parentId);
    if (!children.has(parentId)) children.set(parentId, /* @__PURE__ */ new Set());
    children.get(parentId).add(childId);
  }
  const level = /* @__PURE__ */ new Map();
  const roots = diagram.classes.filter((c) => !parents.has(c.id) || parents.get(c.id).size === 0);
  const queue = roots.map((c) => c.id);
  for (const id of queue) level.set(id, 0);
  const levelCap = diagram.classes.length - 1;
  let qi = 0;
  while (qi < queue.length) {
    const id = queue[qi++];
    const childSet = children.get(id);
    if (!childSet) continue;
    for (const childId of childSet) {
      const newLevel = (level.get(id) ?? 0) + 1;
      if (newLevel > levelCap) continue;
      if (!level.has(childId) || level.get(childId) < newLevel) {
        level.set(childId, newLevel);
        queue.push(childId);
      }
    }
  }
  for (const cls of diagram.classes) {
    if (!level.has(cls.id)) level.set(cls.id, 0);
  }
  const maxLevel = Math.max(...[...level.values()], 0);
  const levelGroups = Array.from({ length: maxLevel + 1 }, () => []);
  for (const cls of diagram.classes) {
    levelGroups[level.get(cls.id)].push(cls.id);
  }
  const placed = /* @__PURE__ */ new Map();
  let currentY = 0;
  for (let lv = 0; lv <= maxLevel; lv++) {
    const group = levelGroups[lv];
    if (group.length === 0) continue;
    let currentX = 0;
    let maxH = 0;
    for (const id of group) {
      const cls = classById.get(id);
      const w = classBoxW.get(id);
      const h = classBoxH.get(id);
      placed.set(id, {
        cls,
        sections: classSections.get(id),
        x: currentX,
        y: currentY,
        width: w,
        height: h
      });
      currentX += w + hGap;
      maxH = Math.max(maxH, h);
    }
    currentY += maxH + vGap;
  }
  let totalW = 0;
  let totalH = 0;
  for (const p of placed.values()) {
    totalW = Math.max(totalW, p.x + p.width);
    totalH = Math.max(totalH, p.y + p.height);
  }
  totalW += 4;
  totalH += 2;
  const canvas = mkCanvas(totalW - 1, totalH - 1);
  const rc = mkRoleCanvas(totalW - 1, totalH - 1);
  function setC(x, y, ch, role) {
    if (x >= 0 && x < canvas.length && y >= 0 && y < (canvas[0]?.length ?? 0)) {
      canvas[x][y] = ch;
      setRole(rc, x, y, role);
    }
  }
  for (const p of placed.values()) {
    const boxCanvas = drawMultiBox(p.sections, useAscii);
    for (let bx = 0; bx < boxCanvas.length; bx++) {
      for (let by = 0; by < boxCanvas[0].length; by++) {
        const ch = boxCanvas[bx][by];
        if (ch !== " ") {
          const cx = p.x + bx;
          const cy = p.y + by;
          if (cx < totalW && cy < totalH) {
            setC(cx, cy, ch, classifyBoxChar(ch));
          }
        }
      }
    }
  }
  const boxOccupancy = [];
  for (const p of placed.values()) {
    boxOccupancy.push({
      x1: p.x,
      x2: p.x + p.width - 1,
      y1: p.y,
      y2: p.y + p.height - 1
    });
  }
  function isInsideBox(x, y, excludeIds) {
    for (const [id, p] of placed.entries()) {
      if (excludeIds?.has(id)) continue;
      if (x >= p.x && x <= p.x + p.width - 1 && y >= p.y && y <= p.y + p.height - 1) {
        return true;
      }
    }
    return false;
  }
  function findClearColumn(startX, y1, y2, excludeIds) {
    let clear = true;
    for (let y = Math.min(y1, y2); y <= Math.max(y1, y2); y++) {
      if (isInsideBox(startX, y, excludeIds)) {
        clear = false;
        break;
      }
    }
    if (clear) return startX;
    for (let offset = 1; offset < totalW + 10; offset++) {
      const rightX = startX + offset;
      clear = true;
      for (let y = Math.min(y1, y2); y <= Math.max(y1, y2); y++) {
        if (isInsideBox(rightX, y, excludeIds)) {
          clear = false;
          break;
        }
      }
      if (clear) return rightX;
      const leftX = startX - offset;
      if (leftX >= 0) {
        clear = true;
        for (let y = Math.min(y1, y2); y <= Math.max(y1, y2); y++) {
          if (isInsideBox(leftX, y, excludeIds)) {
            clear = false;
            break;
          }
        }
        if (clear) return leftX;
      }
    }
    return totalW + 2;
  }
  const H = useAscii ? "-" : "\u2500";
  const V = useAscii ? "|" : "\u2502";
  const dashH = useAscii ? "." : "\u254C";
  const dashV = useAscii ? ":" : "\u250A";
  for (const rel of diagram.relationships) {
    const fromP = placed.get(rel.from);
    const toP = placed.get(rel.to);
    if (!fromP || !toP) continue;
    const marker = getRelMarker(rel.type, rel.markerAt);
    const lineH = marker.dashed ? dashH : H;
    const lineV = marker.dashed ? dashV : V;
    const excludeIds = /* @__PURE__ */ new Set([rel.from, rel.to]);
    const fromCX = fromP.x + Math.floor(fromP.width / 2);
    const fromBY = fromP.y + fromP.height - 1;
    const toCX = toP.x + Math.floor(toP.width / 2);
    const toTY = toP.y;
    if (fromBY < toTY) {
      const routeX = findClearColumn(fromCX, fromBY + 1, toTY - 1, excludeIds);
      const needsDetour = routeX !== fromCX;
      if (routeX >= totalW) {
        increaseSize(canvas, routeX + 2, totalH);
      }
      if (needsDetour) {
        const exitY = fromBY + 1;
        const entryY = toTY - 1;
        const lx1 = Math.min(fromCX, routeX);
        const rx1 = Math.max(fromCX, routeX);
        for (let x = lx1; x <= rx1; x++) {
          setC(x, exitY, lineH, "line");
        }
        if (!useAscii && exitY < (canvas[0]?.length ?? 0)) {
          if (fromCX < routeX) {
            setC(fromCX, exitY, "\u2514", "corner");
            setC(routeX, exitY, "\u2510", "corner");
          } else {
            setC(fromCX, exitY, "\u2518", "corner");
            setC(routeX, exitY, "\u250C", "corner");
          }
        }
        for (let y = exitY + 1; y <= entryY; y++) {
          setC(routeX, y, lineV, "line");
        }
        if (routeX !== toCX) {
          const lx2 = Math.min(routeX, toCX);
          const rx2 = Math.max(routeX, toCX);
          for (let x = lx2; x <= rx2; x++) {
            setC(x, entryY, lineH, "line");
          }
          if (!useAscii && entryY < (canvas[0]?.length ?? 0)) {
            if (routeX < toCX) {
              setC(routeX, entryY, "\u2514", "corner");
              setC(toCX, entryY, "\u2510", "corner");
            } else {
              setC(routeX, entryY, "\u2518", "corner");
              setC(toCX, entryY, "\u250C", "corner");
            }
          }
        }
        if (marker.markerAt === "to") {
          const markerChar = getMarkerShape(marker.type, useAscii, "down");
          setC(toCX, entryY, markerChar, "arrow");
        }
        if (marker.markerAt === "from") {
          const markerChar = getMarkerShape(marker.type, useAscii, "down");
          setC(fromCX, fromBY + 1, markerChar, "arrow");
        }
      } else {
        const midY = fromBY + Math.floor((toTY - fromBY) / 2);
        for (let y = fromBY + 1; y <= midY; y++) {
          setC(fromCX, y, lineV, "line");
        }
        if (fromCX !== toCX && midY < (canvas[0]?.length ?? 0)) {
          const lx = Math.min(fromCX, toCX);
          const rx = Math.max(fromCX, toCX);
          for (let x = lx; x <= rx; x++) {
            setC(x, midY, lineH, "line");
          }
          if (!useAscii) {
            setC(fromCX, midY, fromCX < toCX ? "\u2514" : "\u2518", "corner");
            setC(toCX, midY, fromCX < toCX ? "\u2510" : "\u250C", "corner");
          }
        }
        for (let y = midY + 1; y < toTY; y++) {
          setC(toCX, y, lineV, "line");
        }
        if (marker.markerAt === "to") {
          setC(toCX, toTY - 1, getMarkerShape(marker.type, useAscii, "down"), "arrow");
        }
        if (marker.markerAt === "from") {
          setC(fromCX, fromBY + 1, getMarkerShape(marker.type, useAscii, "down"), "arrow");
        }
      }
    } else if (toP.y + toP.height - 1 < fromP.y) {
      const fromTY = fromP.y;
      const toBY = toP.y + toP.height - 1;
      const midY = toBY + Math.floor((fromTY - toBY) / 2);
      for (let y = fromTY - 1; y >= midY; y--) {
        setC(fromCX, y, lineV, "line");
      }
      if (fromCX !== toCX) {
        const lx = Math.min(fromCX, toCX);
        const rx = Math.max(fromCX, toCX);
        for (let x = lx; x <= rx; x++) {
          setC(x, midY, lineH, "line");
        }
        if (!useAscii && midY >= 0 && midY < totalH) {
          setC(fromCX, midY, fromCX < toCX ? "\u250C" : "\u2510", "corner");
          setC(toCX, midY, fromCX < toCX ? "\u2518" : "\u2514", "corner");
        }
      }
      for (let y = midY - 1; y > toBY; y--) {
        setC(toCX, y, lineV, "line");
      }
      if (marker.markerAt === "from") {
        const markerChar = getMarkerShape(marker.type, useAscii, "up");
        const my = fromTY - 1;
        for (let i = 0; i < markerChar.length; i++) {
          setC(fromCX - Math.floor(markerChar.length / 2) + i, my, markerChar[i], "arrow");
        }
      }
      if (marker.markerAt === "to") {
        const isHierarchical = marker.type === "inheritance" || marker.type === "realization";
        const markerDir = isHierarchical ? "down" : "up";
        const markerChar = getMarkerShape(marker.type, useAscii, markerDir);
        const my = toBY + 1;
        for (let i = 0; i < markerChar.length; i++) {
          setC(toCX - Math.floor(markerChar.length / 2) + i, my, markerChar[i], "arrow");
        }
      }
    } else {
      const detourY = Math.max(fromBY, toP.y + toP.height - 1) + 2;
      increaseSize(canvas, totalW, detourY + 1);
      increaseRoleCanvasSize(rc, totalW, detourY + 1);
      for (let y = fromBY + 1; y <= detourY; y++) {
        setC(fromCX, y, lineV, "line");
      }
      const lx = Math.min(fromCX, toCX);
      const rx = Math.max(fromCX, toCX);
      for (let x = lx; x <= rx; x++) {
        setC(x, detourY, lineH, "line");
      }
      for (let y = detourY - 1; y >= toP.y + toP.height; y--) {
        setC(toCX, y, lineV, "line");
      }
      if (marker.markerAt === "from") {
        const markerChar = getMarkerShape(marker.type, useAscii, "down");
        const my = fromBY + 1;
        for (let i = 0; i < markerChar.length; i++) {
          setC(fromCX - Math.floor(markerChar.length / 2) + i, my, markerChar[i], "arrow");
        }
      }
      if (marker.markerAt === "to") {
        const markerChar = getMarkerShape(marker.type, useAscii, "up");
        const my = toP.y + toP.height;
        for (let i = 0; i < markerChar.length; i++) {
          setC(toCX - Math.floor(markerChar.length / 2) + i, my, markerChar[i], "arrow");
        }
      }
    }
    if (rel.label) {
      const lines2 = splitLines(rel.label);
      const maxLabelWidth = Math.max(...lines2.map((l) => l.length)) + 2;
      let baseMidY;
      let idealMidX;
      if (fromBY < toTY) {
        baseMidY = Math.floor((fromBY + 1 + toTY - 1) / 2);
        idealMidX = Math.floor((fromCX + toCX) / 2);
      } else if (toP.y + toP.height - 1 < fromP.y) {
        const toBY = toP.y + toP.height - 1;
        baseMidY = Math.floor((toBY + 1 + fromP.y - 1) / 2);
        idealMidX = Math.floor((fromCX + toCX) / 2);
      } else {
        baseMidY = Math.max(fromBY, toP.y + toP.height - 1) + 2;
        idealMidX = Math.floor((fromCX + toCX) / 2);
      }
      let labelY = baseMidY;
      const halfHeight = Math.floor(lines2.length / 2);
      let labelInBox = false;
      for (let i = 0; i < lines2.length; i++) {
        const y = labelY - halfHeight + i;
        const idealLabelStart = idealMidX - Math.floor(maxLabelWidth / 2);
        const labelStart = Math.max(0, idealLabelStart);
        for (let x = labelStart; x < labelStart + maxLabelWidth; x++) {
          if (isInsideBox(x, y, excludeIds)) {
            labelInBox = true;
            break;
          }
        }
        if (labelInBox) break;
      }
      if (labelInBox) {
        const gapTop = fromBY + 1;
        const gapBottom = toTY - 1;
        for (let y = gapTop; y <= gapBottom; y++) {
          let clearRow = true;
          const idealLabelStart = idealMidX - Math.floor(maxLabelWidth / 2);
          const labelStart = Math.max(0, idealLabelStart);
          for (let x = labelStart; x < labelStart + maxLabelWidth; x++) {
            if (isInsideBox(x, y, excludeIds)) {
              clearRow = false;
              break;
            }
          }
          if (clearRow) {
            labelY = y;
            break;
          }
        }
      }
      const startY = labelY - halfHeight;
      for (let lineIdx = 0; lineIdx < lines2.length; lineIdx++) {
        const paddedLine = ` ${lines2[lineIdx]} `;
        const idealLabelStart = idealMidX - Math.floor(paddedLine.length / 2);
        const labelStart = Math.max(0, idealLabelStart);
        const y = startY + lineIdx;
        const labelEnd = labelStart + paddedLine.length;
        if (labelEnd > 0 && y >= 0) {
          increaseSize(canvas, Math.max(labelEnd, 1), Math.max(y + 1, 1));
          increaseRoleCanvasSize(rc, Math.max(labelEnd, 1), Math.max(y + 1, 1));
        }
        for (let i = 0; i < paddedLine.length; i++) {
          const lx = labelStart + i;
          if (lx >= 0 && y >= 0) {
            setC(lx, y, paddedLine[i], "text");
          }
        }
      }
    }
  }
  return canvasToString(canvas, { roleCanvas: rc, colorMode, theme });
}

// src/er/parser.ts
function parseErDiagram(lines) {
  const diagram = {
    entities: [],
    relationships: []
  };
  const entityMap = /* @__PURE__ */ new Map();
  let currentEntity = null;
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    if (currentEntity) {
      if (line === "}") {
        currentEntity = null;
        continue;
      }
      const attr = parseAttribute(line);
      if (attr) {
        currentEntity.attributes.push(attr);
      }
      continue;
    }
    const entityBlockMatch = line.match(/^(\S+)\s*\{$/);
    if (entityBlockMatch) {
      const id = entityBlockMatch[1];
      const entity = ensureEntity(entityMap, id);
      currentEntity = entity;
      continue;
    }
    const rel = parseRelationshipLine(line);
    if (rel) {
      ensureEntity(entityMap, rel.entity1);
      ensureEntity(entityMap, rel.entity2);
      diagram.relationships.push(rel);
      continue;
    }
  }
  diagram.entities = [...entityMap.values()];
  return diagram;
}
function ensureEntity(entityMap, id) {
  let entity = entityMap.get(id);
  if (!entity) {
    entity = { id, label: id, attributes: [] };
    entityMap.set(id, entity);
  }
  return entity;
}
function parseAttribute(line) {
  const match = line.match(/^(\S+)\s+(\S+)(?:\s+(.+))?$/);
  if (!match) return null;
  const type = match[1];
  const name = match[2];
  const rest = match[3]?.trim() ?? "";
  const keys = [];
  let comment;
  const commentMatch = rest.match(/"([^"]*)"/);
  if (commentMatch) {
    comment = normalizeBrTags(commentMatch[1]);
  }
  const restWithoutComment = rest.replace(/"[^"]*"/, "").trim();
  for (const part of restWithoutComment.split(/\s+/)) {
    const upper = part.toUpperCase();
    if (upper === "PK" || upper === "FK" || upper === "UK") {
      keys.push(upper);
    }
  }
  return { type, name, keys, comment };
}
function parseRelationshipLine(line) {
  const match = line.match(/^(\S+)\s+([|o}{]+(?:--|\.\.)[|o}{]+)\s+(\S+)\s*:\s*(.+)$/);
  if (!match) return null;
  const entity1 = match[1];
  const cardinalityStr = match[2];
  const entity2 = match[3];
  const rawLabel = match[4].trim().replace(/^["']|["']$/g, "");
  const label = normalizeBrTags(rawLabel);
  const lineMatch = cardinalityStr.match(/^([|o}{]+)(--|\.\.?)([|o}{]+)$/);
  if (!lineMatch) return null;
  const leftStr = lineMatch[1];
  const lineStyle = lineMatch[2];
  const rightStr = lineMatch[3];
  const cardinality1 = parseCardinality(leftStr);
  const cardinality2 = parseCardinality(rightStr);
  const identifying = lineStyle === "--";
  if (!cardinality1 || !cardinality2) return null;
  return { entity1, entity2, cardinality1, cardinality2, label, identifying };
}
function parseCardinality(str) {
  const sorted = str.split("").sort().join("");
  if (sorted === "||") return "one";
  if (sorted === "o|") return "zero-one";
  if (sorted === "|}" || sorted === "{|") return "many";
  if (sorted === "{o" || sorted === "o{") return "zero-many";
  return null;
}

// src/ascii/er-diagram.ts
function classifyBoxChar2(ch) {
  if (/^[┌┐└┘├┤┬┴┼│─╭╮╰╯+\-|]$/.test(ch)) return "border";
  return "text";
}
function formatAttribute(attr) {
  const keyStr = attr.keys.length > 0 ? attr.keys.join(",") + " " : "   ";
  return `${keyStr}${attr.type} ${attr.name}`;
}
function buildEntitySections(entity) {
  const header = splitLines(entity.label);
  const attrs = entity.attributes.map(formatAttribute);
  if (attrs.length === 0) return [header];
  return [header, attrs];
}
function getCrowsFootChars(card, useAscii, isRight = false) {
  if (useAscii) {
    switch (card) {
      case "one":
        return "|";
      case "zero-one":
        return "o|";
      case "many":
        return isRight ? "<" : ">";
      case "zero-many":
        return isRight ? "o<" : ">o";
    }
  } else {
    switch (card) {
      case "one":
        return "\u2502";
      case "zero-one":
        return "\u25CB\u2502";
      case "many":
        return isRight ? "\u255F" : "\u2562";
      case "zero-many":
        return isRight ? "\u25CB\u255F" : "\u2562\u25CB";
    }
  }
}
function findConnectedComponents(diagram) {
  const visited = /* @__PURE__ */ new Set();
  const components = [];
  const neighbors = /* @__PURE__ */ new Map();
  for (const ent of diagram.entities) {
    neighbors.set(ent.id, /* @__PURE__ */ new Set());
  }
  for (const rel of diagram.relationships) {
    neighbors.get(rel.entity1)?.add(rel.entity2);
    neighbors.get(rel.entity2)?.add(rel.entity1);
  }
  function dfs(startId, component) {
    const stack = [startId];
    while (stack.length > 0) {
      const nodeId = stack.pop();
      if (visited.has(nodeId)) continue;
      visited.add(nodeId);
      component.add(nodeId);
      for (const neighbor of neighbors.get(nodeId) ?? []) {
        if (!visited.has(neighbor)) {
          stack.push(neighbor);
        }
      }
    }
  }
  for (const ent of diagram.entities) {
    if (!visited.has(ent.id)) {
      const component = /* @__PURE__ */ new Set();
      dfs(ent.id, component);
      if (component.size > 0) {
        components.push(component);
      }
    }
  }
  return components;
}
function renderErAscii(text, config, colorMode, theme) {
  const lines = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("%%"));
  const diagram = parseErDiagram(lines);
  if (diagram.entities.length === 0) return "";
  const useAscii = config.useAscii;
  const hGap = 6;
  const vGap = 4;
  const componentGap = 6;
  const entitySections = /* @__PURE__ */ new Map();
  const entityBoxW = /* @__PURE__ */ new Map();
  const entityBoxH = /* @__PURE__ */ new Map();
  const entityById = /* @__PURE__ */ new Map();
  for (const ent of diagram.entities) {
    entityById.set(ent.id, ent);
    const sections = buildEntitySections(ent);
    entitySections.set(ent.id, sections);
    let maxTextW = 0;
    for (const section of sections) {
      for (const line of section) maxTextW = Math.max(maxTextW, line.length);
    }
    const boxW = maxTextW + 4;
    let totalLines = 0;
    for (const section of sections) totalLines += Math.max(section.length, 1);
    const boxH = totalLines + (sections.length - 1) + 2;
    entityBoxW.set(ent.id, boxW);
    entityBoxH.set(ent.id, boxH);
  }
  const components = findConnectedComponents(diagram);
  const placed = /* @__PURE__ */ new Map();
  let currentY = 0;
  for (const component of components) {
    const componentEntities = diagram.entities.filter((e) => component.has(e.id));
    const maxPerRow = Math.max(2, Math.ceil(Math.sqrt(componentEntities.length)));
    let currentX = 0;
    let maxRowH = 0;
    let colCount = 0;
    const componentStartY = currentY;
    for (const ent of componentEntities) {
      const w = entityBoxW.get(ent.id);
      const h = entityBoxH.get(ent.id);
      if (colCount >= maxPerRow) {
        currentY += maxRowH + vGap;
        currentX = 0;
        maxRowH = 0;
        colCount = 0;
      }
      placed.set(ent.id, {
        entity: ent,
        sections: entitySections.get(ent.id),
        x: currentX,
        y: currentY,
        width: w,
        height: h
      });
      currentX += w + hGap;
      maxRowH = Math.max(maxRowH, h);
      colCount++;
    }
    currentY += maxRowH + componentGap;
  }
  let totalW = 0;
  let totalH = 0;
  for (const p of placed.values()) {
    totalW = Math.max(totalW, p.x + p.width);
    totalH = Math.max(totalH, p.y + p.height);
  }
  totalW += 4;
  totalH += 2;
  const canvas = mkCanvas(totalW - 1, totalH - 1);
  const rc = mkRoleCanvas(totalW - 1, totalH - 1);
  function setC(x, y, ch, role) {
    if (x >= 0 && x < canvas.length && y >= 0 && y < (canvas[0]?.length ?? 0)) {
      canvas[x][y] = ch;
      setRole(rc, x, y, role);
    }
  }
  for (const p of placed.values()) {
    const boxCanvas = drawMultiBox(p.sections, useAscii);
    for (let bx = 0; bx < boxCanvas.length; bx++) {
      for (let by = 0; by < boxCanvas[0].length; by++) {
        const ch = boxCanvas[bx][by];
        if (ch !== " ") {
          const cx = p.x + bx;
          const cy = p.y + by;
          if (cx < totalW && cy < totalH) {
            setC(cx, cy, ch, classifyBoxChar2(ch));
          }
        }
      }
    }
  }
  const H = useAscii ? "-" : "\u2500";
  const V = useAscii ? "|" : "\u2502";
  const dashH = useAscii ? "." : "\u254C";
  const dashV = useAscii ? ":" : "\u250A";
  for (const rel of diagram.relationships) {
    const e1 = placed.get(rel.entity1);
    const e2 = placed.get(rel.entity2);
    if (!e1 || !e2) continue;
    const lineH = rel.identifying ? H : dashH;
    const lineV = rel.identifying ? V : dashV;
    const e1CX = e1.x + Math.floor(e1.width / 2);
    const e1CY = e1.y + Math.floor(e1.height / 2);
    const e2CX = e2.x + Math.floor(e2.width / 2);
    const e2CY = e2.y + Math.floor(e2.height / 2);
    const sameRow = Math.abs(e1CY - e2CY) < Math.max(e1.height, e2.height);
    if (sameRow) {
      const [left, right] = e1CX < e2CX ? [e1, e2] : [e2, e1];
      const [leftCard, rightCard] = e1CX < e2CX ? [rel.cardinality1, rel.cardinality2] : [rel.cardinality2, rel.cardinality1];
      const startX = left.x + left.width;
      const endX = right.x - 1;
      const lineY = left.y + Math.floor(left.height / 2);
      for (let x = startX; x <= endX; x++) {
        setC(x, lineY, lineH, "line");
      }
      const leftChars = getCrowsFootChars(leftCard, useAscii, false);
      for (let i = 0; i < leftChars.length; i++) {
        setC(startX + i, lineY, leftChars[i], "arrow");
      }
      const rightChars = getCrowsFootChars(rightCard, useAscii, true);
      for (let i = 0; i < rightChars.length; i++) {
        setC(endX - rightChars.length + 1 + i, lineY, rightChars[i], "arrow");
      }
      if (rel.label) {
        const lines2 = splitLines(rel.label);
        const gapMid = Math.floor((startX + endX) / 2);
        for (let lineIdx = 0; lineIdx < lines2.length; lineIdx++) {
          const line = lines2[lineIdx];
          const labelStart = Math.max(startX, gapMid - Math.floor(line.length / 2));
          const labelY = lineY + 1 + lineIdx;
          increaseSize(canvas, Math.max(labelStart + line.length, 1), Math.max(labelY + 1, 1));
          increaseRoleCanvasSize(rc, Math.max(labelStart + line.length, 1), Math.max(labelY + 1, 1));
          for (let i = 0; i < line.length; i++) {
            const lx = labelStart + i;
            if (lx >= startX && lx <= endX) {
              setC(lx, labelY, line[i], "text");
            }
          }
        }
      }
    } else {
      const [upper, lower] = e1CY < e2CY ? [e1, e2] : [e2, e1];
      const [upperCard, lowerCard] = e1CY < e2CY ? [rel.cardinality1, rel.cardinality2] : [rel.cardinality2, rel.cardinality1];
      const startY = upper.y + upper.height;
      const endY = lower.y - 1;
      const lineX = upper.x + Math.floor(upper.width / 2);
      for (let y = startY; y <= endY; y++) {
        setC(lineX, y, lineV, "line");
      }
      const lowerCX = lower.x + Math.floor(lower.width / 2);
      if (lineX !== lowerCX) {
        const midY = Math.floor((startY + endY) / 2);
        const lx = Math.min(lineX, lowerCX);
        const rx = Math.max(lineX, lowerCX);
        for (let x = lx; x <= rx; x++) {
          setC(x, midY, lineH, "line");
        }
        for (let y = midY + 1; y <= endY; y++) {
          setC(lowerCX, y, lineV, "line");
        }
      }
      const upperChars = getCrowsFootChars(upperCard, useAscii, false);
      for (let i = 0; i < upperChars.length; i++) {
        setC(lineX - Math.floor(upperChars.length / 2) + i, startY, upperChars[i], "arrow");
      }
      const targetX = lineX !== lowerCX ? lowerCX : lineX;
      const lowerChars = getCrowsFootChars(lowerCard, useAscii, true);
      for (let i = 0; i < lowerChars.length; i++) {
        setC(targetX - Math.floor(lowerChars.length / 2) + i, endY, lowerChars[i], "arrow");
      }
      if (rel.label) {
        const lines2 = splitLines(rel.label);
        const midY = Math.floor((startY + endY) / 2);
        const startLabelY = midY - Math.floor((lines2.length - 1) / 2);
        for (let lineIdx = 0; lineIdx < lines2.length; lineIdx++) {
          const line = lines2[lineIdx];
          const labelX = lineX + 2;
          const y = startLabelY + lineIdx;
          if (y >= 0) {
            for (let i = 0; i < line.length; i++) {
              const lx = labelX + i;
              if (lx >= 0) {
                increaseSize(canvas, lx + 1, y + 1);
                increaseRoleCanvasSize(rc, lx + 1, y + 1);
                setC(lx, y, line[i], "text");
              }
            }
          }
        }
      }
    }
  }
  return canvasToString(canvas, { roleCanvas: rc, colorMode, theme });
}

// src/xychart/parser.ts
function parseXYChart(lines) {
  const xAxis = {};
  const yAxis = {};
  const series = [];
  let title;
  let horizontal = false;
  for (const line of lines) {
    if (/^xychart(-beta)?\b/i.test(line)) {
      if (/\bhorizontal\b/i.test(line)) horizontal = true;
      continue;
    }
    const titleMatch = line.match(/^title\s+"([^"]+)"/);
    if (titleMatch) {
      title = titleMatch[1];
      continue;
    }
    const xCatMatch = line.match(/^x-axis\s+(?:"([^"]*)"\s*)?\[([^\]]+)\]/);
    if (xCatMatch) {
      if (xCatMatch[1]) xAxis.title = xCatMatch[1];
      xAxis.categories = xCatMatch[2].split(",").map((s) => s.trim());
      continue;
    }
    const xRangeMatch = line.match(/^x-axis\s+(?:"([^"]*)"\s+)?(-?\d+(?:\.\d+)?)\s*-->\s*(-?\d+(?:\.\d+)?)/);
    if (xRangeMatch) {
      if (xRangeMatch[1]) xAxis.title = xRangeMatch[1];
      xAxis.range = { min: parseFloat(xRangeMatch[2]), max: parseFloat(xRangeMatch[3]) };
      continue;
    }
    const yRangeMatch = line.match(/^y-axis\s+(?:"([^"]*)"\s+)?(-?\d+(?:\.\d+)?)\s*-->\s*(-?\d+(?:\.\d+)?)/);
    if (yRangeMatch) {
      if (yRangeMatch[1]) yAxis.title = yRangeMatch[1];
      yAxis.range = { min: parseFloat(yRangeMatch[2]), max: parseFloat(yRangeMatch[3]) };
      continue;
    }
    const yTitleOnly = line.match(/^y-axis\s+"([^"]+)"\s*$/);
    if (yTitleOnly) {
      yAxis.title = yTitleOnly[1];
      continue;
    }
    const barMatch = line.match(/^bar\s+\[([^\]]+)\]/);
    if (barMatch) {
      series.push({ type: "bar", data: parseNumericArray(barMatch[1]) });
      continue;
    }
    const lineMatch = line.match(/^line\s+\[([^\]]+)\]/);
    if (lineMatch) {
      series.push({ type: "line", data: parseNumericArray(lineMatch[1]) });
      continue;
    }
  }
  if (!yAxis.range && series.length > 0) {
    const allValues = series.flatMap((s) => s.data);
    let min = Math.min(...allValues);
    let max = Math.max(...allValues);
    const span = max - min || 1;
    min = min - span * 0.1;
    max = max + span * 0.1;
    if (min > 0 && min < span * 0.5) min = 0;
    yAxis.range = { min, max };
  }
  if (!yAxis.range) {
    yAxis.range = { min: 0, max: 100 };
  }
  return { title, horizontal, xAxis, yAxis, series };
}
function parseNumericArray(str) {
  return str.split(",").map((s) => parseFloat(s.trim()));
}

// src/xychart/colors.ts
var CHART_ACCENT_FALLBACK = "#3b82f6";
function hexToHsl(hex) {
  const h = hex.replace("#", "");
  const ri = parseInt(h.substring(0, 2), 16) / 255;
  const gi = parseInt(h.substring(2, 4), 16) / 255;
  const bi = parseInt(h.substring(4, 6), 16) / 255;
  const max = Math.max(ri, gi, bi);
  const min = Math.min(ri, gi, bi);
  const l = (max + min) / 2;
  if (max === min) return [0, 0, l * 100];
  const d = max - min;
  const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
  let hue;
  if (max === ri) hue = ((gi - bi) / d + (gi < bi ? 6 : 0)) / 6;
  else if (max === gi) hue = ((bi - ri) / d + 2) / 6;
  else hue = ((ri - gi) / d + 4) / 6;
  return [hue * 360, s * 100, l * 100];
}
function hslToHex(h, s, l) {
  const si = s / 100;
  const li = l / 100;
  const c = (1 - Math.abs(2 * li - 1)) * si;
  const x = c * (1 - Math.abs(h / 60 % 2 - 1));
  const m = li - c / 2;
  let r2, g, b;
  if (h < 60) {
    r2 = c;
    g = x;
    b = 0;
  } else if (h < 120) {
    r2 = x;
    g = c;
    b = 0;
  } else if (h < 180) {
    r2 = 0;
    g = c;
    b = x;
  } else if (h < 240) {
    r2 = 0;
    g = x;
    b = c;
  } else if (h < 300) {
    r2 = x;
    g = 0;
    b = c;
  } else {
    r2 = c;
    g = 0;
    b = x;
  }
  const toHex = (v) => Math.round((v + m) * 255).toString(16).padStart(2, "0");
  return `#${toHex(r2)}${toHex(g)}${toHex(b)}`;
}
function isValidHex(color) {
  return /^#[0-9a-fA-F]{6}$/.test(color);
}
function isDarkBackground(bgHex) {
  return hexToHsl(bgHex)[2] < 50;
}
function getSeriesColor(index, accentColor, bgColor) {
  if (index === 0) return accentColor;
  const safeAccent = isValidHex(accentColor) ? accentColor : CHART_ACCENT_FALLBACK;
  const safeBg = bgColor && isValidHex(bgColor) ? bgColor : void 0;
  const [h, s] = hexToHsl(safeAccent);
  const chartS = Math.max(55, Math.min(85, s));
  const tier = Math.ceil(index / 2);
  const oddIndex = index % 2 === 1;
  const dark = safeBg && isDarkBackground(safeBg) ? !oddIndex : oddIndex;
  const l = dark ? Math.max(25, 48 - tier * 13) : Math.min(78, 55 + tier * 11);
  const hShift = (dark ? -8 : 12) * tier;
  const newH = ((h + hShift) % 360 + 360) % 360;
  return hslToHex(newH, chartS, l);
}

// src/ascii/xychart.ts
var PLOT_WIDTH = 60;
var PLOT_HEIGHT = 20;
var UNI = {
  hLine: "\u2500",
  vLine: "\u2502",
  origin: "\u253C",
  yTick: "\u2524",
  xTick: "\u252C",
  bar: "\u2588",
  grid: "\xB7",
  cornerTL: "\u256D",
  // top-left: down+right
  cornerTR: "\u256E",
  // top-right: down+left
  cornerBL: "\u2570",
  // bottom-left: up+right
  cornerBR: "\u256F"
  // bottom-right: up+left
};
var ASC = {
  hLine: "-",
  vLine: "|",
  origin: "+",
  yTick: "+",
  xTick: "+",
  bar: "#",
  grid: ".",
  cornerTL: "+",
  cornerTR: "+",
  cornerBL: "+",
  cornerBR: "+"
};
function getSeriesColors(total, theme) {
  const accent = theme.accent ?? CHART_ACCENT_FALLBACK;
  if (total <= 1) return [accent];
  return Array.from({ length: total }, (_, i) => getSeriesColor(i, accent, theme.bg));
}
function roleToHex(role, theme) {
  switch (role) {
    case "text":
      return theme.fg;
    case "border":
      return theme.border;
    case "line":
      return theme.line;
    case "arrow":
      return theme.arrow;
    case "corner":
      return theme.corner ?? theme.line;
    case "junction":
      return theme.junction ?? theme.border;
    default:
      return theme.fg;
  }
}
function renderXYChartAscii(text, config, colorMode, theme) {
  const lines = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("%%"));
  const chart = parseXYChart(lines);
  const ch = config.useAscii ? ASC : UNI;
  if (chart.horizontal) {
    return renderHorizontal(chart, ch, colorMode, theme);
  }
  return renderVertical(chart, ch, colorMode, theme);
}
function renderVertical(chart, ch, colorMode, theme) {
  const dataCount = getDataCount(chart);
  if (dataCount === 0) return "";
  const yRange = chart.yAxis.range;
  const yTicks = niceTickValues(yRange.min, yRange.max);
  const yLabels = yTicks.map((v) => formatTickValue(v));
  const yGutter = Math.max(...yLabels.map((l) => l.length)) + 1;
  const plotW = Math.max(PLOT_WIDTH, dataCount * 6);
  const plotH = PLOT_HEIGHT;
  const bandW = Math.floor(plotW / dataCount);
  const catLabels = getCategoryLabels(chart, dataCount);
  const hasTitle = !!chart.title;
  const hasXTitle = !!chart.xAxis.title;
  const hasLegend = chart.series.length > 1;
  const titleRow = hasTitle ? 0 : -1;
  const plotTop = (hasTitle ? 2 : 0) + (hasLegend ? 1 : 0);
  const plotLeft = yGutter + 1;
  const totalW = plotLeft + bandW * dataCount + 2;
  const xAxisRow = plotTop + plotH;
  const xLabelRow = xAxisRow + 1;
  const xTitleRow = hasXTitle ? xLabelRow + 1 : -1;
  const totalH = xLabelRow + 1 + (hasXTitle ? 1 : 0) + (hasLegend && !hasTitle ? 0 : 0);
  const canvas = createCanvas(totalW, totalH);
  const roles = createRoleCanvas(totalW, totalH);
  const hexColors = createHexCanvas(totalW, totalH);
  const seriesColors = getSeriesColors(chart.series.length, theme);
  const valueToRow = (v) => {
    const t = (v - yRange.min) / (yRange.max - yRange.min || 1);
    return Math.round(t * (plotH - 1));
  };
  const bandCenter = (i) => plotLeft + Math.floor(bandW * (i + 0.5));
  if (hasTitle && titleRow >= 0) {
    writeText(canvas, roles, titleRow, Math.floor(totalW / 2 - chart.title.length / 2), chart.title, "text");
  }
  if (hasLegend) {
    const legendRow = hasTitle ? 1 : 0;
    drawLegend(canvas, roles, hexColors, chart, legendRow, totalW, ch, seriesColors);
  }
  for (let row = 0; row < plotH; row++) {
    const displayRow = plotTop + (plotH - 1 - row);
    set(canvas, roles, displayRow, plotLeft - 1, ch.vLine, "border");
  }
  set(canvas, roles, xAxisRow, plotLeft - 1, ch.origin, "border");
  for (const tick of yTicks) {
    const row = valueToRow(tick);
    if (row < 0 || row >= plotH) continue;
    const displayRow = plotTop + (plotH - 1 - row);
    const label = formatTickValue(tick);
    set(canvas, roles, displayRow, plotLeft - 1, row === 0 ? ch.origin : ch.yTick, "border");
    const labelStart = yGutter - label.length;
    writeText(canvas, roles, displayRow, Math.max(0, labelStart), label, "text");
  }
  for (let c = plotLeft; c < plotLeft + bandW * dataCount; c++) {
    set(canvas, roles, xAxisRow, c, ch.hLine, "border");
  }
  for (let i = 0; i < dataCount; i++) {
    const cx = bandCenter(i);
    set(canvas, roles, xAxisRow, cx, ch.xTick, "border");
    const label = catLabels[i];
    const labelStart = cx - Math.floor(label.length / 2);
    writeText(canvas, roles, xLabelRow, Math.max(0, labelStart), label, "text");
  }
  if (hasXTitle && xTitleRow >= 0) {
    const title = chart.xAxis.title;
    writeText(canvas, roles, xTitleRow, Math.floor(totalW / 2 - title.length / 2), title, "text");
  }
  for (const tick of yTicks) {
    const row = valueToRow(tick);
    if (row < 0 || row >= plotH) continue;
    const displayRow = plotTop + (plotH - 1 - row);
    for (let c = plotLeft; c < plotLeft + bandW * dataCount; c++) {
      if (get(canvas, displayRow, c) === " ") {
        set(canvas, roles, displayRow, c, ch.grid, "line");
      }
    }
  }
  const barEntries = [];
  for (let si = 0; si < chart.series.length; si++) {
    if (chart.series[si].type === "bar") barEntries.push({ data: chart.series[si].data, globalIdx: si });
  }
  if (barEntries.length > 0) {
    const barCount = barEntries.length;
    const usable = Math.max(1, bandW - 2);
    const singleBarW = Math.max(1, Math.min(Math.floor(usable / barCount), 8));
    const groupW = singleBarW * barCount + (barCount - 1);
    const baseRow = valueToRow(Math.max(0, yRange.min));
    for (let bIdx = 0; bIdx < barEntries.length; bIdx++) {
      const entry = barEntries[bIdx];
      const hexColor = seriesColors[entry.globalIdx];
      for (let i = 0; i < entry.data.length; i++) {
        const cx = bandCenter(i);
        const groupLeft = cx - Math.floor(groupW / 2);
        const bx = groupLeft + bIdx * (singleBarW + 1);
        const valRow = valueToRow(entry.data[i]);
        const fromRow = Math.min(baseRow, valRow);
        const toRow = Math.max(baseRow, valRow);
        for (let row = fromRow; row <= toRow; row++) {
          const displayRow = plotTop + (plotH - 1 - row);
          for (let c = bx; c < bx + singleBarW; c++) {
            set(canvas, roles, displayRow, c, ch.bar, "arrow", hexColors, hexColor);
          }
        }
      }
    }
  }
  const lineEntries = [];
  for (let si = 0; si < chart.series.length; si++) {
    if (chart.series[si].type === "line") lineEntries.push({ data: chart.series[si].data, globalIdx: si });
  }
  for (const entry of lineEntries) {
    if (entry.data.length === 0) continue;
    const hexColor = seriesColors[entry.globalIdx];
    drawStaircaseLine(canvas, roles, entry.data, bandCenter, valueToRow, plotTop, plotH, plotLeft, bandW * dataCount, ch, hexColors, hexColor);
  }
  return canvasToString2(canvas, roles, hexColors, colorMode, theme);
}
function renderHorizontal(chart, ch, colorMode, theme) {
  const dataCount = getDataCount(chart);
  if (dataCount === 0) return "";
  const yRange = chart.yAxis.range;
  const valueTicks = niceTickValues(yRange.min, yRange.max);
  const catLabels = getCategoryLabels(chart, dataCount);
  const catGutter = Math.max(...catLabels.map((l) => l.length)) + 1;
  const plotW = Math.max(PLOT_WIDTH, 40);
  const bandH = Math.max(2, Math.floor(PLOT_HEIGHT / dataCount));
  const plotH = bandH * dataCount;
  const hasTitle = !!chart.title;
  const hasYTitle = !!chart.yAxis.title;
  const hasLegend = chart.series.length > 1;
  const plotTop = (hasTitle ? 2 : 0) + (hasLegend ? 1 : 0);
  const plotLeft = catGutter + 1;
  const totalW = plotLeft + plotW + 2;
  const totalH = plotTop + plotH + 2 + (hasYTitle ? 1 : 0);
  const xAxisRow = plotTop + plotH;
  const canvas = createCanvas(totalW, totalH);
  const roles = createRoleCanvas(totalW, totalH);
  const hexColors = createHexCanvas(totalW, totalH);
  const seriesColors = getSeriesColors(chart.series.length, theme);
  const valueToCol = (v) => {
    const t = (v - yRange.min) / (yRange.max - yRange.min || 1);
    return plotLeft + Math.round(t * (plotW - 1));
  };
  const bandMid = (i) => plotTop + Math.floor(bandH * (i + 0.5));
  if (hasTitle) {
    writeText(canvas, roles, 0, Math.floor(totalW / 2 - chart.title.length / 2), chart.title, "text");
  }
  if (hasLegend) {
    const legendRow = hasTitle ? 1 : 0;
    drawLegend(canvas, roles, hexColors, chart, legendRow, totalW, ch, seriesColors);
  }
  for (let r2 = plotTop; r2 < plotTop + plotH; r2++) {
    set(canvas, roles, r2, plotLeft - 1, ch.vLine, "border");
  }
  set(canvas, roles, xAxisRow, plotLeft - 1, ch.origin, "border");
  for (let i = 0; i < dataCount; i++) {
    const my = bandMid(i);
    const label = catLabels[i];
    const labelStart = catGutter - label.length;
    writeText(canvas, roles, my, Math.max(0, labelStart), label, "text");
  }
  for (let c = plotLeft; c < plotLeft + plotW; c++) {
    set(canvas, roles, xAxisRow, c, ch.hLine, "border");
  }
  for (const tick of valueTicks) {
    const cx = valueToCol(tick);
    if (cx < plotLeft || cx >= plotLeft + plotW) continue;
    set(canvas, roles, xAxisRow, cx, ch.xTick, "border");
    const label = formatTickValue(tick);
    writeText(canvas, roles, xAxisRow + 1, cx - Math.floor(label.length / 2), label, "text");
  }
  if (hasYTitle) {
    const title = chart.yAxis.title;
    writeText(canvas, roles, totalH - 1, Math.floor(totalW / 2 - title.length / 2), title, "text");
  }
  for (const tick of valueTicks) {
    const cx = valueToCol(tick);
    if (cx < plotLeft || cx >= plotLeft + plotW) continue;
    for (let r2 = plotTop; r2 < plotTop + plotH; r2++) {
      if (get(canvas, r2, cx) === " ") {
        set(canvas, roles, r2, cx, ch.grid, "line");
      }
    }
  }
  const barEntries = [];
  for (let si = 0; si < chart.series.length; si++) {
    if (chart.series[si].type === "bar") barEntries.push({ data: chart.series[si].data, globalIdx: si });
  }
  if (barEntries.length > 0) {
    const barCount = barEntries.length;
    const singleBarH = 1;
    const groupH = singleBarH * barCount + (barCount - 1);
    const baseCol = valueToCol(Math.max(0, yRange.min));
    for (let bIdx = 0; bIdx < barEntries.length; bIdx++) {
      const entry = barEntries[bIdx];
      const hexColor = seriesColors[entry.globalIdx];
      for (let i = 0; i < entry.data.length; i++) {
        const my = bandMid(i);
        const groupTop = my - Math.floor(groupH / 2);
        const by = groupTop + bIdx * (singleBarH + 1);
        const valCol = valueToCol(entry.data[i]);
        const fromCol = Math.min(baseCol, valCol);
        const toCol = Math.max(baseCol, valCol);
        for (let r2 = by; r2 < by + singleBarH; r2++) {
          for (let c = fromCol; c <= toCol; c++) {
            set(canvas, roles, r2, c, ch.bar, "arrow", hexColors, hexColor);
          }
        }
      }
    }
  }
  const lineEntries = [];
  for (let si = 0; si < chart.series.length; si++) {
    if (chart.series[si].type === "line") lineEntries.push({ data: chart.series[si].data, globalIdx: si });
  }
  for (const entry of lineEntries) {
    if (entry.data.length === 0) continue;
    const hexColor = seriesColors[entry.globalIdx];
    drawHorizontalStaircaseLine(canvas, roles, entry.data, bandMid, valueToCol, plotTop, plotH, plotLeft, plotW, ch, hexColors, hexColor);
  }
  return canvasToString2(canvas, roles, hexColors, colorMode, theme);
}
function drawStaircaseLine(canvas, roles, data, bandCenter, valueToRow, plotTop, plotH, plotLeft, plotTotalW, ch, hexCanvas, hexColor) {
  if (data.length === 0) return;
  const points = data.map((v, i) => ({
    col: bandCenter(i),
    row: valueToRow(v)
  }));
  const drawAt = (col, row, char) => {
    const displayRow = plotTop + (plotH - 1 - row);
    if (displayRow >= 0 && col >= plotLeft && col < plotLeft + plotTotalW) {
      set(canvas, roles, displayRow, col, char, "arrow", hexCanvas, hexColor);
    }
  };
  if (points.length === 1) {
    drawAt(points[0].col, points[0].row, ch.hLine);
    return;
  }
  for (let i = 0; i < points.length - 1; i++) {
    const p1 = points[i];
    const p2 = points[i + 1];
    if (p1.row === p2.row) {
      for (let c = p1.col; c <= p2.col; c++) {
        drawAt(c, p1.row, ch.hLine);
      }
      continue;
    }
    const midCol = Math.round((p1.col + p2.col) / 2);
    const goingUp = p2.row > p1.row;
    for (let c = p1.col; c < midCol; c++) {
      drawAt(c, p1.row, ch.hLine);
    }
    if (goingUp) {
      drawAt(midCol, p1.row, ch.cornerBR);
    } else {
      drawAt(midCol, p1.row, ch.cornerTR);
    }
    const minRow = Math.min(p1.row, p2.row);
    const maxRow = Math.max(p1.row, p2.row);
    for (let row = minRow + 1; row < maxRow; row++) {
      drawAt(midCol, row, ch.vLine);
    }
    if (goingUp) {
      drawAt(midCol, p2.row, ch.cornerTL);
    } else {
      drawAt(midCol, p2.row, ch.cornerBL);
    }
    for (let c = midCol + 1; c <= p2.col; c++) {
      drawAt(c, p2.row, ch.hLine);
    }
    if (i === 0) {
      const leadStart = Math.max(plotLeft, p1.col - Math.floor((p2.col - p1.col) / 4));
      for (let c = leadStart; c < p1.col; c++) {
        drawAt(c, p1.row, ch.hLine);
      }
    }
    if (i === points.length - 2) {
      const trailEnd = Math.min(plotLeft + plotTotalW - 1, p2.col + Math.floor((p2.col - p1.col) / 4));
      for (let c = p2.col + 1; c <= trailEnd; c++) {
        drawAt(c, p2.row, ch.hLine);
      }
    }
  }
}
function drawHorizontalStaircaseLine(canvas, roles, data, bandMid, valueToCol, plotTop, plotH, plotLeft, plotW, ch, hexCanvas, hexColor) {
  if (data.length === 0) return;
  const points = data.map((v, i) => ({
    row: bandMid(i),
    col: valueToCol(v)
  }));
  const drawAt = (row, col, char) => {
    if (row >= plotTop && row < plotTop + plotH && col >= plotLeft && col < plotLeft + plotW) {
      set(canvas, roles, row, col, char, "arrow", hexCanvas, hexColor);
    }
  };
  if (points.length === 1) {
    drawAt(points[0].row, points[0].col, ch.vLine);
    return;
  }
  for (let i = 0; i < points.length - 1; i++) {
    const p1 = points[i];
    const p2 = points[i + 1];
    if (p1.col === p2.col) {
      for (let r2 = p1.row; r2 <= p2.row; r2++) {
        drawAt(r2, p1.col, ch.vLine);
      }
      continue;
    }
    const midRow = Math.round((p1.row + p2.row) / 2);
    const goingRight = p2.col > p1.col;
    for (let r2 = p1.row; r2 < midRow; r2++) {
      drawAt(r2, p1.col, ch.vLine);
    }
    if (goingRight) {
      drawAt(midRow, p1.col, ch.cornerBL);
    } else {
      drawAt(midRow, p1.col, ch.cornerBR);
    }
    const minCol = Math.min(p1.col, p2.col);
    const maxCol = Math.max(p1.col, p2.col);
    for (let c = minCol + 1; c < maxCol; c++) {
      drawAt(midRow, c, ch.hLine);
    }
    if (goingRight) {
      drawAt(midRow, p2.col, ch.cornerTR);
    } else {
      drawAt(midRow, p2.col, ch.cornerTL);
    }
    for (let r2 = midRow + 1; r2 <= p2.row; r2++) {
      drawAt(r2, p2.col, ch.vLine);
    }
  }
}
function drawLegend(canvas, roles, hexCanvas, chart, row, totalW, ch, seriesColors) {
  const items = [];
  let barIdx = 0, lineIdx = 0;
  for (let si = 0; si < chart.series.length; si++) {
    const s = chart.series[si];
    if (s.type === "bar") {
      items.push({ symbol: ch.bar, label: `Bar ${barIdx + 1}`, globalIdx: si });
      barIdx++;
    } else {
      items.push({ symbol: ch.hLine, label: `Line ${lineIdx + 1}`, globalIdx: si });
      lineIdx++;
    }
  }
  let totalLen = 0;
  for (let i = 0; i < items.length; i++) {
    if (i > 0) totalLen += 2;
    totalLen += 1 + 1 + items[i].label.length;
  }
  const startCol = Math.max(0, Math.floor(totalW / 2 - totalLen / 2));
  let col = startCol;
  for (let i = 0; i < items.length; i++) {
    if (i > 0) col += 2;
    const item = items[i];
    set(canvas, roles, row, col, item.symbol, "arrow", hexCanvas, seriesColors[item.globalIdx]);
    col += 1;
    col += 1;
    writeText(canvas, roles, row, col, item.label, "text");
    col += item.label.length;
  }
}
function createCanvas(width, height) {
  return Array.from({ length: width }, () => Array.from({ length: height }, () => " "));
}
function createRoleCanvas(width, height) {
  return Array.from({ length: width }, () => Array.from({ length: height }).fill(null));
}
function createHexCanvas(width, height) {
  return Array.from({ length: width }, () => Array.from({ length: height }).fill(null));
}
function set(canvas, roles, row, col, char, role, hexCanvas, hex) {
  if (col >= 0 && col < canvas.length && row >= 0 && row < canvas[0].length) {
    canvas[col][row] = char;
    roles[col][row] = role;
    if (hexCanvas && hex) hexCanvas[col][row] = hex;
  }
}
function get(canvas, row, col) {
  if (col >= 0 && col < canvas.length && row >= 0 && row < canvas[0].length) {
    return canvas[col][row];
  }
  return " ";
}
function writeText(canvas, roles, row, startCol, text, role) {
  for (let i = 0; i < text.length; i++) {
    set(canvas, roles, row, startCol + i, text[i], role);
  }
}
function canvasToString2(canvas, roles, hexCanvas, colorMode, theme) {
  if (canvas.length === 0) return "";
  const height = canvas[0].length;
  const width = canvas.length;
  const lines = [];
  for (let row = 0; row < height; row++) {
    const chars = [];
    const rowRoles = [];
    const rowHex = [];
    for (let col = 0; col < width; col++) {
      chars.push(canvas[col][row]);
      rowRoles.push(roles[col][row]);
      rowHex.push(hexCanvas[col][row]);
    }
    let end = chars.length - 1;
    while (end >= 0 && chars[end] === " ") end--;
    if (end < 0) {
      lines.push("");
    } else {
      lines.push(colorizeRow(
        chars.slice(0, end + 1),
        rowRoles.slice(0, end + 1),
        rowHex.slice(0, end + 1),
        theme,
        colorMode
      ));
    }
  }
  while (lines.length > 0 && lines[lines.length - 1] === "") {
    lines.pop();
  }
  return lines.join("\n");
}
function colorizeRow(chars, roles, hexOverrides, theme, mode) {
  if (mode === "none") return chars.join("");
  let result = "";
  let currentColor = null;
  let buffer = "";
  for (let i = 0; i < chars.length; i++) {
    const char = chars[i];
    if (char === " ") {
      if (buffer.length > 0) {
        result += currentColor ? colorizeText(buffer, currentColor, mode) : buffer;
        buffer = "";
        currentColor = null;
      }
      result += " ";
      continue;
    }
    const hexOvr = hexOverrides[i] ?? null;
    const roleVal = roles[i] ?? null;
    const color = hexOvr ?? (roleVal ? roleToHex(roleVal, theme) : null);
    if (color === currentColor) {
      buffer += char;
    } else {
      if (buffer.length > 0) {
        result += currentColor ? colorizeText(buffer, currentColor, mode) : buffer;
      }
      buffer = char;
      currentColor = color;
    }
  }
  if (buffer.length > 0) {
    result += currentColor ? colorizeText(buffer, currentColor, mode) : buffer;
  }
  return result;
}
function getDataCount(chart) {
  if (chart.xAxis.categories) return chart.xAxis.categories.length;
  for (const s of chart.series) {
    if (s.data.length > 0) return s.data.length;
  }
  return 0;
}
function getCategoryLabels(chart, count) {
  if (chart.xAxis.categories) return chart.xAxis.categories;
  if (chart.xAxis.range) {
    const { min, max } = chart.xAxis.range;
    const step = count > 1 ? (max - min) / (count - 1) : 0;
    return Array.from({ length: count }, (_, i) => formatTickValue(min + step * i));
  }
  return Array.from({ length: count }, (_, i) => String(i + 1));
}
function niceTickValues(min, max) {
  const range = max - min;
  if (range <= 0) return [min];
  const rawInterval = range / 6;
  const magnitude = Math.pow(10, Math.floor(Math.log10(rawInterval)));
  const residual = rawInterval / magnitude;
  let niceInterval;
  if (residual <= 1.5) niceInterval = magnitude;
  else if (residual <= 3) niceInterval = 2 * magnitude;
  else if (residual <= 7) niceInterval = 5 * magnitude;
  else niceInterval = 10 * magnitude;
  const start = Math.ceil(min / niceInterval) * niceInterval;
  const ticks = [];
  for (let v = start; v <= max + niceInterval * 1e-3; v += niceInterval) {
    ticks.push(Math.round(v * 1e10) / 1e10);
  }
  return ticks;
}
function formatTickValue(v) {
  if (Number.isInteger(v)) return String(v);
  return v.toFixed(Math.abs(v) < 10 ? 1 : 0);
}

// src/ascii/index.ts
function detectDiagramType(text) {
  const firstLine = text.trim().split("\n")[0]?.trim().toLowerCase() ?? "";
  if (/^xychart(-beta)?\b/.test(firstLine)) return "xychart";
  if (/^sequencediagram\s*$/.test(firstLine)) return "sequence";
  if (/^classdiagram\s*$/.test(firstLine)) return "class";
  if (/^erdiagram\s*$/.test(firstLine)) return "er";
  return "flowchart";
}
function renderMermaidASCII(text, options = {}) {
  const config = {
    useAscii: options.useAscii ?? false,
    paddingX: options.paddingX ?? 5,
    paddingY: options.paddingY ?? 5,
    boxBorderPadding: options.boxBorderPadding ?? 1,
    graphDirection: "TD"
    // default, overridden for flowcharts below
  };
  const colorMode = options.colorMode === "auto" || options.colorMode === void 0 ? detectColorMode() : options.colorMode;
  const theme = { ...DEFAULT_ASCII_THEME, ...options.theme };
  const diagramType = detectDiagramType(text);
  switch (diagramType) {
    case "xychart":
      return renderXYChartAscii(text, config, colorMode, theme);
    case "sequence":
      return renderSequenceAscii(text, config, colorMode, theme);
    case "class":
      return renderClassAscii(text, config, colorMode, theme);
    case "er":
      return renderErAscii(text, config, colorMode, theme);
    case "flowchart":
    default: {
      const parsed = parseMermaid(text);
      if (parsed.direction === "LR" || parsed.direction === "RL") {
        config.graphDirection = "LR";
      } else {
        config.graphDirection = "TD";
      }
      const graph = convertToAsciiGraph(parsed, config);
      createMapping(graph);
      drawGraph(graph);
      if (parsed.direction === "BT") {
        flipCanvasVertically(graph.canvas);
        flipRoleCanvasVertically(graph.roleCanvas);
      }
      return canvasToString(graph.canvas, {
        roleCanvas: graph.roleCanvas,
        colorMode,
        theme
      });
    }
  }
}
var renderMermaidAscii = renderMermaidASCII;

// src/index.ts
import { decodeXML } from "entities";

// src/styles.ts
function estimateTextWidth(text, fontSize, fontWeight) {
  return measureTextWidth(text, fontSize, fontWeight);
}
function estimateMonoTextWidth(text, fontSize) {
  return text.length * fontSize * 0.6;
}
var MONO_FONT = "'JetBrains Mono'";
var MONO_FONT_STACK = `${MONO_FONT}, 'SF Mono', 'Fira Code', ui-monospace, monospace`;
var FONT_SIZES = {
  /** Node label text */
  nodeLabel: 13,
  /** Edge label text */
  edgeLabel: 11,
  /** Subgraph header text */
  groupHeader: 12
};
var FONT_WEIGHTS = {
  nodeLabel: 500,
  edgeLabel: 400,
  groupHeader: 600
};
var NODE_PADDING = {
  /** Horizontal padding inside rectangles/rounded/stadium (increased from 16 for better label fit) */
  horizontal: 20,
  /** Vertical padding inside rectangles/rounded/stadium */
  vertical: 10,
  /** Extra padding for diamond shapes (they need more space due to rotation) */
  diamondExtra: 24
};
var STROKE_WIDTHS = {
  outerBox: 1,
  innerBox: 0.75,
  /** Edge connector stroke (increased from 0.75 for better visibility) */
  connector: 1
};
var TEXT_BASELINE_SHIFT = "0.35em";
var ARROW_HEAD = {
  width: 8,
  height: 5
};

// src/elk-instance.ts
import ELKBundled from "elkjs/lib/elk.bundled.js";
var elk = null;
var rawWorker = null;
function ensureElk() {
  if (elk) return;
  const pending = [];
  const origSetTimeout = globalThis.setTimeout;
  globalThis.setTimeout = (fn, delay) => {
    if (delay === 0) {
      pending.push(fn);
      return 0;
    }
    return origSetTimeout(fn, delay);
  };
  const g = globalThis;
  const hadSelf = "self" in g;
  const origSelf = g.self;
  if (hadSelf && typeof g.document === "undefined") {
    delete g.self;
  }
  elk = new ELKBundled();
  if (hadSelf) g.self = origSelf;
  globalThis.setTimeout = origSetTimeout;
  pending.forEach((fn) => fn());
  rawWorker = elk.worker.worker;
}
function elkLayoutSync(graph) {
  ensureElk();
  let result;
  let error;
  const origOnmessage = rawWorker.onmessage;
  rawWorker.onmessage = (answer) => {
    if (answer.data.error) {
      error = answer.data.error;
    } else {
      result = answer.data.data;
    }
  };
  rawWorker.dispatcher.saveDispatch({ data: { id: 0, cmd: "layout", graph } });
  rawWorker.onmessage = origOnmessage;
  if (error) throw error;
  if (!result) throw new Error("ELK layout did not return synchronously");
  return result;
}

// src/shape-clipping.ts
function clipEdgeToShape(points, node, isStart) {
  if (points.length < 2) return points;
  if (node.shape === "rectangle" || node.shape === "rounded" || node.shape === "stadium") {
    return points;
  }
  const result = [...points];
  if (node.shape === "diamond") {
    if (isStart) {
      result[0] = clipToDiamond(points[0], points[1], node);
    } else {
      const lastIdx = points.length - 1;
      result[lastIdx] = clipToDiamond(points[lastIdx], points[lastIdx - 1], node);
    }
  }
  return result;
}
function clipToDiamond(endpoint, adjacent, node) {
  const cx = node.x + node.width / 2;
  const cy = node.y + node.height / 2;
  const halfW = node.width / 2;
  const halfH = node.height / 2;
  const top = { x: cx, y: node.y };
  const right = { x: node.x + node.width, y: cy };
  const bottom = { x: cx, y: node.y + node.height };
  const left = { x: node.x, y: cy };
  const dx = endpoint.x - adjacent.x;
  const dy = endpoint.y - adjacent.y;
  const isVertical = Math.abs(dx) < Math.abs(dy);
  if (isVertical) {
    const rayX = endpoint.x;
    if (dy > 0) {
      if (rayX <= cx) {
        return intersectVerticalRayWithEdge(rayX, left, top) ?? top;
      } else {
        return intersectVerticalRayWithEdge(rayX, top, right) ?? top;
      }
    } else {
      if (rayX <= cx) {
        return intersectVerticalRayWithEdge(rayX, bottom, left) ?? bottom;
      } else {
        return intersectVerticalRayWithEdge(rayX, right, bottom) ?? bottom;
      }
    }
  } else {
    const rayY = endpoint.y;
    if (dx > 0) {
      if (rayY <= cy) {
        return intersectHorizontalRayWithEdge(rayY, top, left) ?? left;
      } else {
        return intersectHorizontalRayWithEdge(rayY, left, bottom) ?? left;
      }
    } else {
      if (rayY <= cy) {
        return intersectHorizontalRayWithEdge(rayY, top, right) ?? right;
      } else {
        return intersectHorizontalRayWithEdge(rayY, right, bottom) ?? right;
      }
    }
  }
}
function intersectHorizontalRayWithEdge(rayY, p1, p2) {
  const dy = p2.y - p1.y;
  if (Math.abs(dy) < 1e-3) {
    return null;
  }
  const t = (rayY - p1.y) / dy;
  if (t < 0 || t > 1) {
    return null;
  }
  const x = p1.x + t * (p2.x - p1.x);
  return { x, y: rayY };
}
function intersectVerticalRayWithEdge(rayX, p1, p2) {
  const dx = p2.x - p1.x;
  if (Math.abs(dx) < 1e-3) {
    return null;
  }
  const t = (rayX - p1.x) / dx;
  if (t < 0 || t > 1) {
    return null;
  }
  const y = p1.y + t * (p2.y - p1.y);
  return { x: rayX, y };
}

// src/layout-engine.ts
var DEFAULTS2 = {
  font: "Inter",
  padding: 40,
  nodeSpacing: 28,
  layerSpacing: 48,
  mergeEdges: true,
  thoroughness: 3
};
function directionToElk(dir) {
  switch (dir) {
    case "LR":
      return "RIGHT";
    case "RL":
      return "LEFT";
    case "BT":
      return "UP";
    case "TD":
    case "TB":
    default:
      return "DOWN";
  }
}
function estimateNodeSize(id, label, shape) {
  const metrics = measureMultilineText(label, FONT_SIZES.nodeLabel, FONT_WEIGHTS.nodeLabel);
  let width = metrics.width + NODE_PADDING.horizontal * 2;
  let height = metrics.height + NODE_PADDING.vertical * 2;
  if (shape === "diamond") {
    const side = Math.max(width, height) + NODE_PADDING.diamondExtra;
    width = side;
    height = side;
  }
  if (shape === "circle" || shape === "doublecircle") {
    const diameter = Math.ceil(Math.sqrt(width * width + height * height)) + 8;
    width = shape === "doublecircle" ? diameter + 12 : diameter;
    height = width;
  }
  if (shape === "hexagon") {
    width += NODE_PADDING.horizontal;
  }
  if (shape === "trapezoid" || shape === "trapezoid-alt") {
    width += NODE_PADDING.horizontal;
  }
  if (shape === "asymmetric") {
    width += 12;
  }
  if (shape === "cylinder") {
    height += 14;
  }
  if (shape === "state-start" || shape === "state-end") {
    return { width: 28, height: 28 };
  }
  width = Math.max(width, 60);
  height = Math.max(height, 36);
  return { width, height };
}
function mermaidToElk(graph, opts) {
  const subgraphNodeIds = /* @__PURE__ */ new Set();
  const subgraphIds = /* @__PURE__ */ new Set();
  for (const sg of graph.subgraphs) {
    subgraphIds.add(sg.id);
    collectSubgraphNodeIds(sg, subgraphNodeIds, subgraphIds);
  }
  const nodeToSubgraph = buildNodeToSubgraphMap(graph.subgraphs);
  const edgesBySubgraph = /* @__PURE__ */ new Map();
  edgesBySubgraph.set(null, []);
  const crossHierarchyEdges = [];
  for (let i = 0; i < graph.edges.length; i++) {
    const edge = graph.edges[i];
    const sourceSubgraph = nodeToSubgraph.get(edge.source);
    const targetSubgraph = nodeToSubgraph.get(edge.target);
    if (sourceSubgraph && sourceSubgraph === targetSubgraph) {
      if (!edgesBySubgraph.has(sourceSubgraph)) {
        edgesBySubgraph.set(sourceSubgraph, []);
      }
      edgesBySubgraph.get(sourceSubgraph).push({ index: i, edge });
    } else if (!sourceSubgraph && !targetSubgraph) {
      edgesBySubgraph.get(null).push({ index: i, edge });
    } else {
      crossHierarchyEdges.push({ index: i, edge, sourceSubgraph, targetSubgraph });
    }
  }
  const hasDirectionOverride = graph.subgraphs.some((sg) => sg.direction !== void 0);
  const elkGraph = {
    id: "root",
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": directionToElk(graph.direction),
      "elk.spacing.nodeNode": String(opts.nodeSpacing),
      "elk.layered.spacing.nodeNodeBetweenLayers": String(opts.layerSpacing),
      "elk.spacing.edgeEdge": "12",
      "elk.layered.spacing.edgeEdgeBetweenLayers": "12",
      "elk.layered.spacing.edgeNodeBetweenLayers": "12",
      "elk.padding": `[top=${opts.padding},left=${opts.padding},bottom=${opts.padding},right=${opts.padding}]`,
      "elk.edgeRouting": "ORTHOGONAL",
      "elk.layered.nodePlacement.bk.fixedAlignment": "BALANCED",
      "elk.contentAlignment": "H_CENTER V_CENTER",
      "elk.layered.thoroughness": String(DEFAULTS2.thoroughness),
      "elk.layered.highDegreeNodes.treatment": "true",
      "elk.layered.highDegreeNodes.threshold": "8",
      "elk.layered.compaction.postCompaction.strategy": "LEFT_RIGHT_CONSTRAINT_LOCKING",
      "elk.layered.considerModelOrder.strategy": "NODES_AND_EDGES",
      "elk.layered.wrapping.strategy": "OFF",
      // Use SEPARATE when subgraphs have direction overrides (enables proper direction handling)
      // Use INCLUDE_CHILDREN otherwise (simpler cross-hierarchy edge routing)
      "elk.hierarchyHandling": hasDirectionOverride ? "SEPARATE" : "INCLUDE_CHILDREN"
    },
    children: [],
    edges: []
  };
  const subgraphPorts = /* @__PURE__ */ new Map();
  if (hasDirectionOverride) {
    for (const { index, edge, sourceSubgraph, targetSubgraph } of crossHierarchyEdges) {
      if (sourceSubgraph) {
        const portId = `${sourceSubgraph}_out_${index}`;
        if (!subgraphPorts.has(sourceSubgraph)) {
          subgraphPorts.set(sourceSubgraph, []);
        }
        subgraphPorts.get(sourceSubgraph).push({
          portId,
          edgeIndex: index,
          direction: "outgoing",
          internalNodeId: edge.source
        });
      }
      if (targetSubgraph) {
        const portId = `${targetSubgraph}_in_${index}`;
        if (!subgraphPorts.has(targetSubgraph)) {
          subgraphPorts.set(targetSubgraph, []);
        }
        subgraphPorts.get(targetSubgraph).push({
          portId,
          edgeIndex: index,
          direction: "incoming",
          internalNodeId: edge.target
        });
      }
    }
  }
  for (const [id, node] of graph.nodes) {
    if (!subgraphNodeIds.has(id) && !subgraphIds.has(id)) {
      const size = estimateNodeSize(id, node.label, node.shape);
      elkGraph.children.push({
        id,
        width: size.width,
        height: size.height,
        labels: [{ text: node.label }]
      });
    }
  }
  for (const sg of graph.subgraphs) {
    elkGraph.children.push(subgraphToElk(sg, graph, opts, edgesBySubgraph, subgraphPorts));
  }
  for (const { index, edge } of edgesBySubgraph.get(null)) {
    const elkEdge = {
      id: `e${index}`,
      sources: [edge.source],
      targets: [edge.target]
    };
    if (edge.label) {
      const metrics = measureMultilineText(edge.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
      elkEdge.labels = [{
        text: edge.label,
        width: metrics.width + 8,
        height: metrics.height + 6,
        layoutOptions: {
          "elk.edgeLabels.inline": "true",
          "elk.edgeLabels.placement": "CENTER"
        }
      }];
    }
    elkGraph.edges.push(elkEdge);
  }
  for (const { index, edge, sourceSubgraph, targetSubgraph } of crossHierarchyEdges) {
    const elkEdge = {
      id: `e${index}`,
      sources: hasDirectionOverride && sourceSubgraph ? [`${sourceSubgraph}_out_${index}`] : [edge.source],
      targets: hasDirectionOverride && targetSubgraph ? [`${targetSubgraph}_in_${index}`] : [edge.target]
    };
    if (edge.label) {
      const metrics = measureMultilineText(edge.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
      elkEdge.labels = [{
        text: edge.label,
        width: metrics.width + 8,
        height: metrics.height + 6,
        layoutOptions: {
          "elk.edgeLabels.inline": "true",
          "elk.edgeLabels.placement": "CENTER"
        }
      }];
    }
    elkGraph.edges.push(elkEdge);
  }
  return elkGraph;
}
function subgraphToElk(sg, graph, opts, edgesBySubgraph, subgraphPorts) {
  const layoutOptions = {
    "elk.algorithm": "layered",
    "elk.padding": "[top=44,left=16,bottom=16,right=16]",
    // Top = headerHeight(28) + gap(16) to match bottom padding
    "elk.edgeRouting": "ORTHOGONAL",
    "elk.contentAlignment": "H_CENTER V_CENTER",
    "elk.spacing.edgeEdge": "12",
    "elk.layered.spacing.edgeEdgeBetweenLayers": "12",
    "elk.layered.spacing.edgeNodeBetweenLayers": "12",
    "elk.layered.nodePlacement.bk.fixedAlignment": "BALANCED",
    "elk.layered.spacing.nodeNodeBetweenLayers": String(opts.layerSpacing),
    "elk.spacing.nodeNode": String(opts.nodeSpacing)
  };
  if (sg.direction) {
    layoutOptions["elk.direction"] = directionToElk(sg.direction);
  }
  const elkNode = {
    id: sg.id,
    layoutOptions,
    labels: sg.label ? [{ text: sg.label }] : void 0,
    children: [],
    edges: []
  };
  const ports = subgraphPorts.get(sg.id) ?? [];
  if (ports.length > 0) {
    elkNode.ports = ports.map((p) => ({
      id: p.portId
      // Port side is determined by ELK based on edge direction
    }));
  }
  for (const nodeId of sg.nodeIds) {
    const node = graph.nodes.get(nodeId);
    if (node) {
      const size = estimateNodeSize(nodeId, node.label, node.shape);
      elkNode.children.push({
        id: nodeId,
        width: size.width,
        height: size.height,
        labels: [{ text: node.label }]
      });
    }
  }
  for (const child of sg.children) {
    elkNode.children.push(subgraphToElk(child, graph, opts, edgesBySubgraph, subgraphPorts));
  }
  const internalEdges = edgesBySubgraph.get(sg.id) ?? [];
  for (const { index, edge } of internalEdges) {
    const elkEdge = {
      id: `e${index}`,
      sources: [edge.source],
      targets: [edge.target]
    };
    if (edge.label) {
      const metrics = measureMultilineText(edge.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
      elkEdge.labels = [{
        text: edge.label,
        width: metrics.width + 8,
        height: metrics.height + 6,
        layoutOptions: {
          "elk.edgeLabels.inline": "true",
          "elk.edgeLabels.placement": "CENTER"
        }
      }];
    }
    elkNode.edges.push(elkEdge);
  }
  for (const port of ports) {
    const internalEdgeId = `e${port.edgeIndex}_internal`;
    const elkEdge = port.direction === "incoming" ? { id: internalEdgeId, sources: [port.portId], targets: [port.internalNodeId] } : { id: internalEdgeId, sources: [port.internalNodeId], targets: [port.portId] };
    elkNode.edges.push(elkEdge);
  }
  return elkNode;
}
function collectSubgraphNodeIds(sg, nodeIds, subgraphIds) {
  for (const id of sg.nodeIds) {
    nodeIds.add(id);
  }
  for (const child of sg.children) {
    subgraphIds.add(child.id);
    collectSubgraphNodeIds(child, nodeIds, subgraphIds);
  }
}
function buildNodeToSubgraphMap(subgraphs) {
  const map = /* @__PURE__ */ new Map();
  function traverse(sg) {
    for (const nodeId of sg.nodeIds) {
      map.set(nodeId, sg.id);
    }
    for (const child of sg.children) {
      traverse(child);
    }
  }
  for (const sg of subgraphs) {
    traverse(sg);
  }
  return map;
}
function flattenGroupBounds(groups) {
  const bounds = [];
  for (const g of groups) {
    bounds.push({ x: g.x, y: g.y, right: g.x + g.width, bottom: g.y + g.height });
    bounds.push(...flattenGroupBounds(g.children));
  }
  return bounds;
}
function elkToPositioned(elkResult, graph, mergeEdges = false) {
  const nodes = [];
  const edges = [];
  const groups = [];
  const subgraphIds = /* @__PURE__ */ new Set();
  for (const sg of graph.subgraphs) {
    collectAllSubgraphIds(sg, subgraphIds);
  }
  extractNodesAndGroups(elkResult, graph, subgraphIds, nodes, groups, 0, 0);
  const allBounds = flattenGroupBounds(groups);
  const margins = allBounds.length > 0 ? {
    leftX: Math.min(...allBounds.map((b) => b.x)) - 20,
    rightX: Math.max(...allBounds.map((b) => b.right)) + 20
  } : void 0;
  extractEdgesRecursively(elkResult, graph, edges, 0, 0, margins);
  alignLayerNodes(nodes, edges, graph.direction);
  if (mergeEdges) {
    bundleEdgePaths(edges, nodes, groups, graph.direction);
  }
  const nodeMap = new Map(nodes.map((n) => [n.id, n]));
  for (const edge of edges) {
    const sourceNode = nodeMap.get(edge.source);
    const targetNode = nodeMap.get(edge.target);
    if (sourceNode) {
      edge.points = clipEdgeToShape(edge.points, sourceNode, true);
    }
    if (targetNode) {
      edge.points = clipEdgeToShape(edge.points, targetNode, false);
    }
  }
  let width = elkResult.width ?? 800;
  let height = elkResult.height ?? 600;
  const arrowMargin = ARROW_HEAD.width;
  const padding = DEFAULTS2.padding;
  for (const edge of edges) {
    for (const p of edge.points) {
      width = Math.max(width, p.x + arrowMargin + padding);
      height = Math.max(height, p.y + arrowMargin + padding);
    }
    if (edge.labelPosition) {
      width = Math.max(width, edge.labelPosition.x + 60 + padding);
      height = Math.max(height, edge.labelPosition.y + 20 + padding);
    }
  }
  return {
    width,
    height,
    nodes,
    edges,
    groups
  };
}
function extractNodesAndGroups(elkNode, graph, subgraphIds, nodes, groups, offsetX, offsetY) {
  if (!elkNode.children) return;
  for (const child of elkNode.children) {
    const x = (child.x ?? 0) + offsetX;
    const y = (child.y ?? 0) + offsetY;
    const width = child.width ?? 0;
    const height = child.height ?? 0;
    if (subgraphIds.has(child.id)) {
      const childGroups = [];
      extractNodesAndGroups(child, graph, subgraphIds, nodes, childGroups, x, y);
      const mermaidSg = findSubgraph(graph.subgraphs, child.id);
      groups.push({
        id: child.id,
        label: mermaidSg?.label ?? "",
        x,
        y,
        width,
        height,
        children: childGroups
      });
    } else {
      const mNode = graph.nodes.get(child.id);
      if (mNode) {
        const inlineStyle = resolveNodeStyle(child.id, graph);
        nodes.push({
          id: child.id,
          label: mNode.label,
          shape: mNode.shape,
          x,
          y,
          width,
          height,
          inlineStyle
        });
      }
      if (child.children && child.children.length > 0) {
        extractNodesAndGroups(child, graph, subgraphIds, nodes, groups, x, y);
      }
    }
  }
}
function calculatePathMidpoint(points) {
  if (points.length === 0) return { x: 0, y: 0 };
  if (points.length === 1) return points[0];
  let totalLength = 0;
  for (let i = 1; i < points.length; i++) {
    const dx = points[i].x - points[i - 1].x;
    const dy = points[i].y - points[i - 1].y;
    totalLength += Math.sqrt(dx * dx + dy * dy);
  }
  let remaining = totalLength / 2;
  for (let i = 1; i < points.length; i++) {
    const dx = points[i].x - points[i - 1].x;
    const dy = points[i].y - points[i - 1].y;
    const segLen = Math.sqrt(dx * dx + dy * dy);
    if (remaining <= segLen) {
      const t = remaining / segLen;
      return {
        x: points[i - 1].x + t * dx,
        y: points[i - 1].y + t * dy
      };
    }
    remaining -= segLen;
  }
  return points[points.length - 1];
}
function extractEdgesRecursively(elkNode, graph, edges, offsetX, offsetY, margins) {
  const segments = /* @__PURE__ */ new Map();
  collectEdgeSegments(elkNode, segments, 0, 0);
  let marginEdgeIndex = 0;
  for (const [edgeIndex, seg] of segments) {
    const originalEdge = graph.edges[edgeIndex];
    if (!originalEdge) continue;
    const allPoints = [];
    if (seg.outgoing && seg.outgoing.points.length > 0) {
      allPoints.push(...seg.outgoing.points);
    }
    if (seg.external && seg.external.points.length > 0) {
      if (allPoints.length > 0) {
        allPoints.push(...seg.external.points.slice(1));
      } else {
        allPoints.push(...seg.external.points);
      }
    }
    if (seg.incoming && seg.incoming.points.length > 0) {
      if (allPoints.length > 0) {
        allPoints.push(...seg.incoming.points.slice(1));
      } else {
        allPoints.push(...seg.incoming.points);
      }
    }
    let labelPosition;
    if (originalEdge.label && allPoints.length >= 2) {
      const elkLabelPos = seg.external?.labelPosition;
      labelPosition = elkLabelPos ?? calculatePathMidpoint(allPoints);
    }
    const orthogonalPoints = orthogonalizeEdgePoints(allPoints, margins, marginEdgeIndex);
    if (orthogonalPoints !== allPoints) {
      marginEdgeIndex++;
    }
    if (originalEdge.label && orthogonalPoints !== allPoints && orthogonalPoints.length >= 2) {
      labelPosition = calculatePathMidpoint(orthogonalPoints);
    }
    edges.push({
      source: originalEdge.source,
      target: originalEdge.target,
      label: originalEdge.label,
      style: originalEdge.style,
      hasArrowStart: originalEdge.hasArrowStart,
      hasArrowEnd: originalEdge.hasArrowEnd,
      points: orthogonalPoints,
      labelPosition,
      inlineStyle: resolveEdgeStyle(edgeIndex, graph)
    });
  }
}
function orthogonalizeEdgePoints(points, margins, edgeIndex = 0) {
  if (points.length < 2) return points;
  let needsWork = false;
  for (let i = 1; i < points.length; i++) {
    const dx = Math.abs(points[i].x - points[i - 1].x);
    const dy = Math.abs(points[i].y - points[i - 1].y);
    if (dx > 1 && dy > 1) {
      needsWork = true;
      break;
    }
  }
  if (!needsWork) return points;
  const EDGE_SPACING = 12;
  const result = [points[0]];
  for (let i = 1; i < points.length; i++) {
    const prev = result[result.length - 1];
    const curr = points[i];
    const dx = Math.abs(curr.x - prev.x);
    const dy = Math.abs(curr.y - prev.y);
    if (dx > 1 && dy > 1) {
      if (margins) {
        const useRight = edgeIndex % 2 === 0;
        const offset = Math.floor(edgeIndex / 2) * EDGE_SPACING;
        const marginX = useRight ? margins.rightX + offset : margins.leftX - offset;
        result.push({ x: marginX, y: prev.y });
        result.push({ x: marginX, y: curr.y });
      } else {
        const midY = (prev.y + curr.y) / 2;
        result.push({ x: prev.x, y: midY });
        result.push({ x: curr.x, y: midY });
      }
    }
    result.push(curr);
  }
  return result;
}
function collectEdgeSegments(elkNode, segments, offsetX, offsetY) {
  if (elkNode.edges) {
    for (const elkEdge of elkNode.edges) {
      const isInternal = elkEdge.id.endsWith("_internal");
      const edgeIndex = parseInt(elkEdge.id.substring(1), 10);
      if (isNaN(edgeIndex)) continue;
      const points = [];
      if (elkEdge.sections && elkEdge.sections.length > 0) {
        const section = elkEdge.sections[0];
        points.push({
          x: section.startPoint.x + offsetX,
          y: section.startPoint.y + offsetY
        });
        if (section.bendPoints) {
          for (const bp of section.bendPoints) {
            points.push({ x: bp.x + offsetX, y: bp.y + offsetY });
          }
        }
        points.push({
          x: section.endPoint.x + offsetX,
          y: section.endPoint.y + offsetY
        });
      }
      let labelPosition;
      if (elkEdge.labels && elkEdge.labels.length > 0) {
        const label = elkEdge.labels[0];
        if (label.x != null && label.y != null) {
          labelPosition = {
            x: label.x + (label.width ?? 0) / 2 + offsetX,
            y: label.y + (label.height ?? 0) / 2 + offsetY
          };
        }
      }
      if (!segments.has(edgeIndex)) {
        segments.set(edgeIndex, {});
      }
      const seg = segments.get(edgeIndex);
      if (isInternal) {
        const source = elkEdge.sources?.[0] ?? "";
        const target = elkEdge.targets?.[0] ?? "";
        const sourceIsPort = source.includes("_in_") || source.includes("_out_");
        const targetIsPort = target.includes("_in_") || target.includes("_out_");
        if (sourceIsPort) {
          seg.incoming = { edgeIndex, isInternal, points, labelPosition };
        } else if (targetIsPort) {
          seg.outgoing = { edgeIndex, isInternal, points, labelPosition };
        }
      } else {
        seg.external = { edgeIndex, isInternal, points, labelPosition };
      }
    }
  }
  if (elkNode.children) {
    for (const child of elkNode.children) {
      collectEdgeSegments(child, segments, offsetX + (child.x ?? 0), offsetY + (child.y ?? 0));
    }
  }
}
function findSubgraph(subgraphs, id) {
  for (const sg of subgraphs) {
    if (sg.id === id) return sg;
    const found = findSubgraph(sg.children, id);
    if (found) return found;
  }
  return void 0;
}
function collectAllSubgraphIds(sg, out) {
  out.add(sg.id);
  for (const child of sg.children) {
    collectAllSubgraphIds(child, out);
  }
}
function resolveNodeStyle(nodeId, graph) {
  let result;
  const className = graph.classAssignments.get(nodeId);
  if (className) {
    const classDef = graph.classDefs.get(className);
    if (classDef) {
      result = { ...classDef };
    }
  }
  const nodeStyle = graph.nodeStyles.get(nodeId);
  if (nodeStyle) {
    result = result ? { ...result, ...nodeStyle } : { ...nodeStyle };
  }
  return result;
}
function resolveEdgeStyle(edgeIndex, graph) {
  let result;
  const defaultStyle = graph.linkStyles.get("default");
  if (defaultStyle) {
    result = { ...defaultStyle };
  }
  const indexStyle = graph.linkStyles.get(edgeIndex);
  if (indexStyle) {
    result = result ? { ...result, ...indexStyle } : { ...indexStyle };
  }
  return result;
}
function alignLayerNodes(nodes, edges, direction) {
  if (nodes.length === 0) return;
  const isHorizontal = direction === "LR" || direction === "RL";
  const connectedPairs = /* @__PURE__ */ new Set();
  for (const edge of edges) {
    connectedPairs.add(`${edge.source}:${edge.target}`);
    connectedPairs.add(`${edge.target}:${edge.source}`);
  }
  const THRESHOLD = DEFAULTS2.layerSpacing * 0.6;
  const sorted = [...nodes].sort(
    (a, b) => isHorizontal ? a.x - b.x : a.y - b.y
  );
  const layers = [];
  let currentLayer = [sorted[0]];
  for (let i = 1; i < sorted.length; i++) {
    const pos = isHorizontal ? sorted[i].x : sorted[i].y;
    const prevPos = isHorizontal ? sorted[i - 1].x : sorted[i - 1].y;
    const gap = pos - prevPos;
    const hasEdgeToLayer = currentLayer.some(
      (n) => connectedPairs.has(`${n.id}:${sorted[i].id}`)
    );
    if (gap <= THRESHOLD && !hasEdgeToLayer) {
      currentLayer.push(sorted[i]);
    } else {
      layers.push(currentLayer);
      currentLayer = [sorted[i]];
    }
  }
  layers.push(currentLayer);
  const deltas = /* @__PURE__ */ new Map();
  for (const layer of layers) {
    if (layer.length <= 1) continue;
    const positions = layer.map((n) => isHorizontal ? n.x : n.y);
    const min = Math.min(...positions);
    const max = Math.max(...positions);
    if (max - min <= 1) continue;
    const target = (min + max) / 2;
    for (const node of layer) {
      const oldPos = isHorizontal ? node.x : node.y;
      const delta = target - oldPos;
      if (Math.abs(delta) > 0.5) {
        if (isHorizontal) {
          node.x = target;
        } else {
          node.y = target;
        }
        deltas.set(node.id, delta);
      }
    }
  }
  if (deltas.size === 0) return;
  const nodeMap = new Map(nodes.map((n) => [n.id, n]));
  for (const edge of edges) {
    if (edge.points.length < 2) continue;
    const srcDelta = deltas.get(edge.source);
    const tgtDelta = deltas.get(edge.target);
    if (srcDelta != null) {
      const first = edge.points[0];
      if (isHorizontal) {
        first.x += srcDelta;
        if (edge.points.length > 1 && edge.points[1].x === first.x - srcDelta) {
          edge.points[1].x += srcDelta;
        }
      } else {
        first.y += srcDelta;
        if (edge.points.length > 1 && edge.points[1].y === first.y - srcDelta) {
          edge.points[1].y += srcDelta;
        }
      }
    }
    if (tgtDelta != null) {
      const last = edge.points[edge.points.length - 1];
      if (isHorizontal) {
        last.x += tgtDelta;
        if (edge.points.length > 1) {
          const prev = edge.points[edge.points.length - 2];
          if (prev.x === last.x - tgtDelta) prev.x += tgtDelta;
        }
      } else {
        last.y += tgtDelta;
        if (edge.points.length > 1) {
          const prev = edge.points[edge.points.length - 2];
          if (prev.y === last.y - tgtDelta) prev.y += tgtDelta;
        }
      }
    }
  }
}
function findGroupsContainingPoint(x, y, groups) {
  const result = [];
  for (const g of groups) {
    if (x >= g.x && x <= g.x + g.width && y >= g.y && y <= g.y + g.height) {
      result.push(g);
      result.push(...findGroupsContainingPoint(x, y, g.children));
    }
  }
  return result;
}
function adjustJunctionForGroups(junctionMain, refX, refY, groups, direction) {
  const GAP = 12;
  const isLR = direction === "LR";
  const isRL = direction === "RL";
  const isBT = direction === "BT";
  const isHorizontal = isLR || isRL;
  const refGroupIds = new Set(findGroupsContainingPoint(refX, refY, groups).map((g) => g.id));
  const probeX = isHorizontal ? junctionMain : refX;
  const probeY = isHorizontal ? refY : junctionMain;
  const junctionGroups = findGroupsContainingPoint(probeX, probeY, groups);
  const crossingGroup = junctionGroups.find((g) => !refGroupIds.has(g.id));
  if (!crossingGroup) return junctionMain;
  if (isLR) return crossingGroup.x - GAP;
  if (isRL) return crossingGroup.x + crossingGroup.width + GAP;
  if (isBT) return crossingGroup.y + crossingGroup.height + GAP;
  return crossingGroup.y - GAP;
}
function bundleEdgePaths(edges, nodes, groups, direction) {
  const nodeMap = new Map(nodes.map((n) => [n.id, n]));
  const processed = /* @__PURE__ */ new Set();
  const isLR = direction === "LR";
  const isRL = direction === "RL";
  const isBT = direction === "BT";
  const isHorizontal = isLR || isRL;
  const fanOutGroups = /* @__PURE__ */ new Map();
  for (const edge of edges) {
    if (edge.source === edge.target) continue;
    if (!fanOutGroups.has(edge.source)) fanOutGroups.set(edge.source, []);
    fanOutGroups.get(edge.source).push(edge);
  }
  for (const [sourceId, group] of fanOutGroups) {
    if (group.length < 2) continue;
    const style = group[0].style;
    if (group.some((e) => e.label || e.style !== style)) continue;
    const source = nodeMap.get(sourceId);
    if (!source) continue;
    const forward = group.filter((e) => {
      const t = nodeMap.get(e.target);
      if (!t) return false;
      if (isLR) return t.x > source.x + source.width;
      if (isRL) return t.x + t.width < source.x;
      if (isBT) return t.y + t.height < source.y;
      return t.y > source.y + source.height;
    });
    if (forward.length < 2) continue;
    const targets = forward.map((e) => ({ edge: e, node: nodeMap.get(e.target) }));
    const srcCX = source.x + source.width / 2;
    const srcCY = source.y + source.height / 2;
    if (isHorizontal) {
      const exitX = isLR ? source.x + source.width : source.x;
      const exitY = srcCY;
      const nearestX = isLR ? Math.min(...targets.map((t) => t.node.x)) : Math.max(...targets.map((t) => t.node.x + t.node.width));
      let junctionX = exitX + (nearestX - exitX) / 2;
      junctionX = adjustJunctionForGroups(junctionX, srcCX, srcCY, groups, direction);
      for (const { edge, node: target } of targets) {
        const entryX = isLR ? target.x : target.x + target.width;
        const entryY = target.y + target.height / 2;
        edge.points = [
          { x: exitX, y: exitY },
          { x: junctionX, y: exitY },
          { x: junctionX, y: entryY },
          { x: entryX, y: entryY }
        ];
        processed.add(edge);
      }
    } else {
      const exitX = srcCX;
      const exitY = isBT ? source.y : source.y + source.height;
      const nearestY = isBT ? Math.max(...targets.map((t) => t.node.y + t.node.height)) : Math.min(...targets.map((t) => t.node.y));
      let junctionY = exitY + (nearestY - exitY) / 2;
      junctionY = adjustJunctionForGroups(junctionY, srcCX, srcCY, groups, direction);
      for (const { edge, node: target } of targets) {
        const entryX = target.x + target.width / 2;
        const entryY = isBT ? target.y + target.height : target.y;
        edge.points = [
          { x: exitX, y: exitY },
          { x: exitX, y: junctionY },
          { x: entryX, y: junctionY },
          { x: entryX, y: entryY }
        ];
        processed.add(edge);
      }
    }
  }
  const fanInGroups = /* @__PURE__ */ new Map();
  for (const edge of edges) {
    if (processed.has(edge) || edge.source === edge.target) continue;
    if (!fanInGroups.has(edge.target)) fanInGroups.set(edge.target, []);
    fanInGroups.get(edge.target).push(edge);
  }
  for (const [targetId, group] of fanInGroups) {
    if (group.length < 2) continue;
    const style = group[0].style;
    if (group.some((e) => e.label || e.style !== style)) continue;
    const target = nodeMap.get(targetId);
    if (!target) continue;
    const forward = group.filter((e) => {
      const s = nodeMap.get(e.source);
      if (!s) return false;
      if (isLR) return s.x + s.width < target.x;
      if (isRL) return s.x > target.x + target.width;
      if (isBT) return s.y > target.y + target.height;
      return s.y + s.height < target.y;
    });
    if (forward.length < 2) continue;
    const sources = forward.map((e) => ({ edge: e, node: nodeMap.get(e.source) }));
    const tgtCX = target.x + target.width / 2;
    const tgtCY = target.y + target.height / 2;
    if (isHorizontal) {
      const entryX = isLR ? target.x : target.x + target.width;
      const entryY = tgtCY;
      const farthestX = isLR ? Math.max(...sources.map((s) => s.node.x + s.node.width)) : Math.min(...sources.map((s) => s.node.x));
      let junctionX = farthestX + (entryX - farthestX) / 2;
      junctionX = adjustJunctionForGroups(junctionX, tgtCX, tgtCY, groups, direction);
      for (const { edge, node: src } of sources) {
        const exitX = isLR ? src.x + src.width : src.x;
        const exitY = src.y + src.height / 2;
        edge.points = [
          { x: exitX, y: exitY },
          { x: junctionX, y: exitY },
          { x: junctionX, y: entryY },
          { x: entryX, y: entryY }
        ];
      }
    } else {
      const entryX = tgtCX;
      const entryY = isBT ? target.y + target.height : target.y;
      const farthestY = isBT ? Math.min(...sources.map((s) => s.node.y)) : Math.max(...sources.map((s) => s.node.y + s.node.height));
      let junctionY = farthestY + (entryY - farthestY) / 2;
      junctionY = adjustJunctionForGroups(junctionY, tgtCX, tgtCY, groups, direction);
      for (const { edge, node: src } of sources) {
        const exitX = src.x + src.width / 2;
        const exitY = isBT ? src.y : src.y + src.height;
        edge.points = [
          { x: exitX, y: exitY },
          { x: exitX, y: junctionY },
          { x: entryX, y: junctionY },
          { x: entryX, y: entryY }
        ];
      }
    }
  }
}
function layoutGraphSync(graph, options = {}) {
  const opts = { ...DEFAULTS2, ...options };
  const elkGraph = mermaidToElk(graph, opts);
  const result = elkLayoutSync(elkGraph);
  return elkToPositioned(result, graph, DEFAULTS2.mergeEdges);
}

// src/renderer.ts
function renderSvg(graph, colors, font = "Inter", transparent = false) {
  const parts = [];
  parts.push(svgOpenTag(graph.width, graph.height, colors, transparent));
  parts.push(buildStyleBlock(font, false));
  parts.push("<defs>");
  parts.push(arrowMarkerDefs());
  const customStrokeColors = /* @__PURE__ */ new Set();
  for (const edge of graph.edges) {
    if (edge.inlineStyle?.stroke) {
      customStrokeColors.add(edge.inlineStyle.stroke);
    }
  }
  for (const color of customStrokeColors) {
    parts.push(arrowMarkerDefsForColor(color));
  }
  parts.push("</defs>");
  for (const group of graph.groups) {
    parts.push(renderGroup(group, font));
  }
  for (const edge of graph.edges) {
    parts.push(renderEdge(edge));
  }
  for (const edge of graph.edges) {
    if (edge.label) {
      parts.push(renderEdgeLabel(edge, font));
    }
  }
  for (const node of graph.nodes) {
    parts.push(renderNode(node, font));
  }
  parts.push("</svg>");
  return parts.join("\n");
}
function arrowMarkerDefs() {
  const w = ARROW_HEAD.width;
  const h = ARROW_HEAD.height;
  const arrowStyle = 'fill="var(--_arrow)" stroke="var(--_arrow)" stroke-width="0.75" stroke-linejoin="round"';
  const refX = w - 1;
  return (
    // Forward arrow (marker-end) — orient="auto" ensures arrow points along line direction
    `  <marker id="arrowhead" markerWidth="${w}" markerHeight="${h}" refX="${refX}" refY="${h / 2}" orient="auto">
    <polygon points="0 0, ${w} ${h / 2}, 0 ${h}" ${arrowStyle} />
  </marker>
  <marker id="arrowhead-start" markerWidth="${w}" markerHeight="${h}" refX="1" refY="${h / 2}" orient="auto-start-reverse">
    <polygon points="${w} 0, 0 ${h / 2}, ${w} ${h}" ${arrowStyle} />
  </marker>`
  );
}
function arrowMarkerDefsForColor(color) {
  const w = ARROW_HEAD.width;
  const h = ARROW_HEAD.height;
  const escaped = escapeAttr(color);
  const arrowStyle = `fill="${escaped}" stroke="${escaped}" stroke-width="0.75" stroke-linejoin="round"`;
  const refX = w - 1;
  const suffix = markerSuffix(color);
  return `  <marker id="arrowhead-${suffix}" markerWidth="${w}" markerHeight="${h}" refX="${refX}" refY="${h / 2}" orient="auto">
    <polygon points="0 0, ${w} ${h / 2}, 0 ${h}" ${arrowStyle} />
  </marker>
  <marker id="arrowhead-start-${suffix}" markerWidth="${w}" markerHeight="${h}" refX="1" refY="${h / 2}" orient="auto-start-reverse">
    <polygon points="${w} 0, 0 ${h / 2}, ${w} ${h}" ${arrowStyle} />
  </marker>`;
}
function markerSuffix(color) {
  return color.replace(/[^a-zA-Z0-9]/g, (ch) => ch.charCodeAt(0).toString(16));
}
function renderGroup(group, font) {
  const headerHeight = FONT_SIZES.groupHeader + 16;
  const parts = [];
  parts.push(
    `<g class="subgraph" data-id="${escapeAttr(group.id)}" data-label="${escapeAttr(group.label)}">`
  );
  parts.push(
    `  <rect x="${group.x}" y="${group.y}" width="${group.width}" height="${group.height}" rx="0" ry="0" fill="var(--_group-fill)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  parts.push(
    `  <rect x="${group.x}" y="${group.y}" width="${group.width}" height="${headerHeight}" rx="0" ry="0" fill="var(--_group-hdr)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  parts.push(
    "  " + renderMultilineText(
      group.label,
      group.x + 12,
      group.y + headerHeight / 2,
      FONT_SIZES.groupHeader,
      `font-size="${FONT_SIZES.groupHeader}" font-weight="${FONT_WEIGHTS.groupHeader}" fill="var(--_text-sec)"`
    )
  );
  for (const child of group.children) {
    parts.push(renderGroup(child, font));
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderEdge(edge) {
  if (edge.points.length < 2) return "";
  const pathData = pointsToPolylinePath(edge.points);
  const dashArray = edge.style === "dotted" ? ' stroke-dasharray="4 4"' : "";
  const baseStrokeWidth = edge.style === "thick" ? STROKE_WIDTHS.connector * 2 : STROKE_WIDTHS.connector;
  const strokeColor = escapeAttr(edge.inlineStyle?.stroke ?? "var(--_line)");
  const strokeWidth = escapeAttr(edge.inlineStyle?.["stroke-width"] ?? String(baseStrokeWidth));
  const suffix = edge.inlineStyle?.stroke ? `-${markerSuffix(edge.inlineStyle.stroke)}` : "";
  let markers = "";
  if (edge.hasArrowEnd) markers += ` marker-end="url(#arrowhead${suffix})"`;
  if (edge.hasArrowStart) markers += ` marker-start="url(#arrowhead-start${suffix})"`;
  const dataAttrs = [
    'class="edge"',
    `data-from="${escapeAttr(edge.source)}"`,
    `data-to="${escapeAttr(edge.target)}"`,
    `data-style="${edge.style}"`,
    `data-arrow-start="${edge.hasArrowStart}"`,
    `data-arrow-end="${edge.hasArrowEnd}"`
  ];
  if (edge.label) {
    dataAttrs.push(`data-label="${escapeAttr(edge.label)}"`);
  }
  return `<polyline ${dataAttrs.join(" ")} points="${pathData}" fill="none" stroke="${strokeColor}" stroke-width="${strokeWidth}"${dashArray}${markers} />`;
}
function pointsToPolylinePath(points) {
  return points.map((p) => `${p.x},${p.y}`).join(" ");
}
function renderEdgeLabel(edge, font) {
  const mid = edge.labelPosition ?? edgeMidpoint(edge.points);
  const label = edge.label;
  const padding = 8;
  const metrics = measureMultilineText(label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
  const content = renderMultilineTextWithBackground(
    label,
    mid.x,
    mid.y,
    metrics.width,
    metrics.height,
    FONT_SIZES.edgeLabel,
    padding,
    // Use --_text-sec for better contrast (was --_text-muted)
    `text-anchor="middle" font-size="${FONT_SIZES.edgeLabel}" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-sec)"`,
    // Increased stroke width from 0.5 to 1 for better label separation from edges
    `rx="2" ry="2" fill="var(--bg)" stroke="var(--_inner-stroke)" stroke-width="1"`
  );
  return `<g class="edge-label" data-from="${escapeAttr(edge.source)}" data-to="${escapeAttr(edge.target)}" data-label="${escapeAttr(label)}">
  ${content.replace(/\n/g, "\n  ")}
</g>`;
}
function edgeMidpoint(points) {
  if (points.length === 0) return { x: 0, y: 0 };
  if (points.length === 1) return points[0];
  let totalLength = 0;
  for (let i = 1; i < points.length; i++) {
    totalLength += dist(points[i - 1], points[i]);
  }
  let remaining = totalLength / 2;
  for (let i = 1; i < points.length; i++) {
    const segLen = dist(points[i - 1], points[i]);
    if (remaining <= segLen) {
      const t = remaining / segLen;
      return {
        x: points[i - 1].x + t * (points[i].x - points[i - 1].x),
        y: points[i - 1].y + t * (points[i].y - points[i - 1].y)
      };
    }
    remaining -= segLen;
  }
  return points[points.length - 1];
}
function dist(a, b) {
  return Math.sqrt((b.x - a.x) ** 2 + (b.y - a.y) ** 2);
}
function renderNode(node, font) {
  const shape = renderNodeShape(node);
  const label = renderNodeLabel(node, font);
  const parts = [];
  parts.push(
    `<g class="node" data-id="${escapeAttr(node.id)}" data-label="${escapeAttr(node.label)}" data-shape="${node.shape}">`
  );
  parts.push(`  ${shape.replace(/\n/g, "\n  ")}`);
  if (label) {
    parts.push(`  ${label.replace(/\n/g, "\n  ")}`);
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderNodeShape(node) {
  const { x, y, width, height, shape, inlineStyle } = node;
  const fill = escapeAttr(inlineStyle?.fill ?? "var(--_node-fill)");
  const stroke = escapeAttr(inlineStyle?.stroke ?? "var(--_node-stroke)");
  const sw = escapeAttr(inlineStyle?.["stroke-width"] ?? String(STROKE_WIDTHS.innerBox));
  switch (shape) {
    case "diamond":
      return renderDiamond(x, y, width, height, fill, stroke, sw);
    case "rounded":
      return renderRoundedRect(x, y, width, height, fill, stroke, sw);
    case "stadium":
      return renderStadium(x, y, width, height, fill, stroke, sw);
    case "circle":
      return renderCircle(x, y, width, height, fill, stroke, sw);
    case "subroutine":
      return renderSubroutine(x, y, width, height, fill, stroke, sw);
    case "doublecircle":
      return renderDoubleCircle(x, y, width, height, fill, stroke, sw);
    case "hexagon":
      return renderHexagon(x, y, width, height, fill, stroke, sw);
    case "cylinder":
      return renderCylinder(x, y, width, height, fill, stroke, sw);
    case "asymmetric":
      return renderAsymmetric(x, y, width, height, fill, stroke, sw);
    case "trapezoid":
      return renderTrapezoid(x, y, width, height, fill, stroke, sw);
    case "trapezoid-alt":
      return renderTrapezoidAlt(x, y, width, height, fill, stroke, sw);
    case "state-start":
      return renderStateStart(x, y, width, height);
    case "state-end":
      return renderStateEnd(x, y, width, height);
    case "rectangle":
    default:
      return renderRect(x, y, width, height, fill, stroke, sw);
  }
}
function renderRect(x, y, w, h, fill, stroke, sw) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="0" ry="0" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderRoundedRect(x, y, w, h, fill, stroke, sw) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="6" ry="6" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderStadium(x, y, w, h, fill, stroke, sw) {
  const r2 = h / 2;
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r2}" ry="${r2}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderCircle(x, y, w, h, fill, stroke, sw) {
  const cx = x + w / 2;
  const cy = y + h / 2;
  const r2 = Math.min(w, h) / 2;
  return `<circle cx="${cx}" cy="${cy}" r="${r2}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderDiamond(x, y, w, h, fill, stroke, sw) {
  const cx = x + w / 2;
  const cy = y + h / 2;
  const hw = w / 2;
  const hh = h / 2;
  const points = [
    `${cx},${cy - hh}`,
    // top
    `${cx + hw},${cy}`,
    // right
    `${cx},${cy + hh}`,
    // bottom
    `${cx - hw},${cy}`
    // left
  ].join(" ");
  return `<polygon points="${points}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderSubroutine(x, y, w, h, fill, stroke, sw) {
  const inset = 8;
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="0" ry="0" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />
<line x1="${x + inset}" y1="${y}" x2="${x + inset}" y2="${y + h}" stroke="${stroke}" stroke-width="${sw}" />
<line x1="${x + w - inset}" y1="${y}" x2="${x + w - inset}" y2="${y + h}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderDoubleCircle(x, y, w, h, fill, stroke, sw) {
  const cx = x + w / 2;
  const cy = y + h / 2;
  const outerR = Math.min(w, h) / 2;
  const innerR = outerR - 5;
  return `<circle cx="${cx}" cy="${cy}" r="${outerR}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />
<circle cx="${cx}" cy="${cy}" r="${innerR}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderHexagon(x, y, w, h, fill, stroke, sw) {
  const inset = h / 4;
  const points = [
    `${x + inset},${y}`,
    // top-left
    `${x + w - inset},${y}`,
    // top-right
    `${x + w},${y + h / 2}`,
    // mid-right
    `${x + w - inset},${y + h}`,
    // bottom-right
    `${x + inset},${y + h}`,
    // bottom-left
    `${x},${y + h / 2}`
    // mid-left
  ].join(" ");
  return `<polygon points="${points}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderCylinder(x, y, w, h, fill, stroke, sw) {
  const ry = 7;
  const cx = x + w / 2;
  const bodyTop = y + ry;
  const bodyH = h - 2 * ry;
  return (
    // Body rectangle (no top border — covered by top ellipse)
    `<rect x="${x}" y="${bodyTop}" width="${w}" height="${bodyH}" fill="${fill}" stroke="none" />
<line x1="${x}" y1="${bodyTop}" x2="${x}" y2="${bodyTop + bodyH}" stroke="${stroke}" stroke-width="${sw}" />
<line x1="${x + w}" y1="${bodyTop}" x2="${x + w}" y2="${bodyTop + bodyH}" stroke="${stroke}" stroke-width="${sw}" />
<ellipse cx="${cx}" cy="${y + h - ry}" rx="${w / 2}" ry="${ry}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />
<ellipse cx="${cx}" cy="${bodyTop}" rx="${w / 2}" ry="${ry}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`
  );
}
function renderAsymmetric(x, y, w, h, fill, stroke, sw) {
  const indent = 12;
  const points = [
    `${x + indent},${y}`,
    // top-left (indented)
    `${x + w},${y}`,
    // top-right
    `${x + w},${y + h}`,
    // bottom-right
    `${x + indent},${y + h}`,
    // bottom-left (indented)
    `${x},${y + h / 2}`
    // left point
  ].join(" ");
  return `<polygon points="${points}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderTrapezoid(x, y, w, h, fill, stroke, sw) {
  const inset = w * 0.15;
  const points = [
    `${x + inset},${y}`,
    // top-left (indented)
    `${x + w - inset},${y}`,
    // top-right (indented)
    `${x + w},${y + h}`,
    // bottom-right (full width)
    `${x},${y + h}`
    // bottom-left (full width)
  ].join(" ");
  return `<polygon points="${points}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderTrapezoidAlt(x, y, w, h, fill, stroke, sw) {
  const inset = w * 0.15;
  const points = [
    `${x},${y}`,
    // top-left (full width)
    `${x + w},${y}`,
    // top-right (full width)
    `${x + w - inset},${y + h}`,
    // bottom-right (indented)
    `${x + inset},${y + h}`
    // bottom-left (indented)
  ].join(" ");
  return `<polygon points="${points}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" />`;
}
function renderStateStart(x, y, w, h) {
  const cx = x + w / 2;
  const cy = y + h / 2;
  const r2 = Math.min(w, h) / 2 - 2;
  return `<circle cx="${cx}" cy="${cy}" r="${r2}" fill="var(--_text)" stroke="none" />`;
}
function renderStateEnd(x, y, w, h) {
  const cx = x + w / 2;
  const cy = y + h / 2;
  const outerR = Math.min(w, h) / 2 - 2;
  const innerR = outerR - 4;
  return `<circle cx="${cx}" cy="${cy}" r="${outerR}" fill="none" stroke="var(--_text)" stroke-width="${STROKE_WIDTHS.innerBox * 2}" />
<circle cx="${cx}" cy="${cy}" r="${innerR}" fill="var(--_text)" stroke="none" />`;
}
function renderNodeLabel(node, font) {
  if (node.shape === "state-start" || node.shape === "state-end") {
    if (!node.label) return "";
  }
  const cx = node.x + node.width / 2;
  const cy = node.y + node.height / 2;
  const textColor = escapeAttr(node.inlineStyle?.color ?? "var(--_text)");
  return renderMultilineText(
    node.label,
    cx,
    cy,
    FONT_SIZES.nodeLabel,
    `text-anchor="middle" font-size="${FONT_SIZES.nodeLabel}" font-weight="${FONT_WEIGHTS.nodeLabel}" fill="${textColor}"`
  );
}
function escapeAttr(value) {
  return value.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// src/sequence/layout.ts
var SEQ = {
  /** Padding around the entire diagram */
  padding: 30,
  /** Minimum gap between actor centers */
  actorGap: 140,
  /** Actor box height */
  actorHeight: 40,
  /** Horizontal padding inside actor boxes */
  actorPadX: 16,
  /** Vertical space between actor boxes and first message */
  headerGap: 20,
  /** Vertical space per message row */
  messageRowHeight: 40,
  /** Extra vertical space for self-messages (they loop back) */
  selfMessageHeight: 30,
  /** Activation box width (narrow rectangle on lifeline) */
  activationWidth: 10,
  /** Block padding (loop/alt borders) */
  blockPadX: 10,
  blockPadTop: 40,
  blockPadBottom: 8,
  /** Extra vertical space before the first message in a block (room for the header label) */
  blockHeaderExtra: 28,
  /** Extra vertical space before a message at a divider boundary (room for else/and label) */
  dividerExtra: 24,
  /** Note dimensions */
  noteWidth: 60,
  notePadX: 12,
  notePadY: 6,
  noteGap: 10
};
function layoutSequenceDiagram(diagram, _options = {}) {
  if (diagram.actors.length === 0) {
    return { width: 0, height: 0, actors: [], lifelines: [], messages: [], activations: [], blocks: [], notes: [] };
  }
  const actorWidths = diagram.actors.map((a) => {
    const textW = estimateTextWidth(a.label, FONT_SIZES.nodeLabel, FONT_WEIGHTS.nodeLabel);
    return Math.max(textW + SEQ.actorPadX * 2, 80);
  });
  const actorCenterX = [];
  let currentX = SEQ.padding + actorWidths[0] / 2;
  for (let i = 0; i < diagram.actors.length; i++) {
    if (i > 0) {
      const minGap = Math.max(SEQ.actorGap, (actorWidths[i - 1] + actorWidths[i]) / 2 + 40);
      currentX += minGap;
    }
    actorCenterX.push(currentX);
  }
  const actorIndex = /* @__PURE__ */ new Map();
  for (let i = 0; i < diagram.actors.length; i++) {
    actorIndex.set(diagram.actors[i].id, i);
  }
  const actorY = SEQ.padding;
  const actors = diagram.actors.map((a, i) => ({
    id: a.id,
    label: a.label,
    type: a.type,
    x: actorCenterX[i],
    y: actorY,
    width: actorWidths[i],
    height: SEQ.actorHeight
  }));
  let messageY = actorY + SEQ.actorHeight + SEQ.headerGap;
  const messages = [];
  const extraSpaceBefore = /* @__PURE__ */ new Map();
  for (const block of diagram.blocks) {
    const prev = extraSpaceBefore.get(block.startIndex) ?? 0;
    extraSpaceBefore.set(block.startIndex, Math.max(prev, SEQ.blockHeaderExtra));
    for (const div of block.dividers) {
      const prevDiv = extraSpaceBefore.get(div.index) ?? 0;
      extraSpaceBefore.set(div.index, Math.max(prevDiv, SEQ.dividerExtra));
    }
  }
  const notesByAfterIndex = /* @__PURE__ */ new Map();
  for (const note of diagram.notes) {
    const list = notesByAfterIndex.get(note.afterIndex) ?? [];
    list.push(note);
    notesByAfterIndex.set(note.afterIndex, list);
  }
  const positionedNotes = [];
  const activationStacks = /* @__PURE__ */ new Map();
  const activations = [];
  const nestingOffset = 4;
  for (let msgIdx = 0; msgIdx < diagram.messages.length; msgIdx++) {
    const msg = diagram.messages[msgIdx];
    const fromIdx = actorIndex.get(msg.from) ?? 0;
    const toIdx = actorIndex.get(msg.to) ?? 0;
    const isSelf = msg.from === msg.to;
    const extra = extraSpaceBefore.get(msgIdx) ?? 0;
    if (extra > 0) messageY += extra;
    const x1 = actorCenterX[fromIdx];
    const x2 = actorCenterX[toIdx];
    messages.push({
      from: msg.from,
      to: msg.to,
      label: msg.label,
      lineStyle: msg.lineStyle,
      arrowHead: msg.arrowHead,
      x1,
      x2,
      y: messageY,
      isSelf
    });
    if (msg.activate) {
      if (!activationStacks.has(msg.to)) {
        activationStacks.set(msg.to, []);
      }
      const stack = activationStacks.get(msg.to);
      const depth = stack.length;
      stack.push({ startY: messageY, depth });
    }
    if (msg.deactivate) {
      const stack = activationStacks.get(msg.from);
      if (stack && stack.length > 0) {
        const { startY, depth } = stack.pop();
        const idx = actorIndex.get(msg.from) ?? 0;
        const xOffset = depth * nestingOffset;
        activations.push({
          actorId: msg.from,
          x: actorCenterX[idx] - SEQ.activationWidth / 2 + xOffset,
          topY: startY,
          bottomY: messageY,
          width: SEQ.activationWidth
        });
      }
    }
    messageY += isSelf ? SEQ.selfMessageHeight + SEQ.messageRowHeight : SEQ.messageRowHeight;
    const notesForMsg = notesByAfterIndex.get(msgIdx);
    if (notesForMsg && notesForMsg.length > 0) {
      const selfLoopExtra = isSelf ? SEQ.selfMessageHeight : 0;
      let noteY = messages[msgIdx].y + selfLoopExtra + 8;
      for (const note of notesForMsg) {
        const noteW = Math.max(
          SEQ.noteWidth,
          estimateTextWidth(note.text, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel) + SEQ.notePadX * 2
        );
        const noteH = FONT_SIZES.edgeLabel + SEQ.notePadY * 2;
        const firstActorIdx = actorIndex.get(note.actorIds[0] ?? "") ?? 0;
        let noteX;
        if (note.position === "left") {
          noteX = actorCenterX[firstActorIdx] - actorWidths[firstActorIdx] / 2 - noteW - SEQ.noteGap;
        } else if (note.position === "right") {
          noteX = actorCenterX[firstActorIdx] + actorWidths[firstActorIdx] / 2 + SEQ.noteGap;
        } else {
          if (note.actorIds.length > 1) {
            const lastActorIdx = actorIndex.get(note.actorIds[note.actorIds.length - 1] ?? "") ?? firstActorIdx;
            noteX = (actorCenterX[firstActorIdx] + actorCenterX[lastActorIdx]) / 2 - noteW / 2;
          } else {
            noteX = actorCenterX[firstActorIdx] - noteW / 2;
          }
        }
        positionedNotes.push({
          text: note.text,
          x: noteX,
          y: noteY,
          width: noteW,
          height: noteH,
          position: note.position,
          actors: note.actorIds
        });
        noteY += noteH + 4;
      }
      messageY = Math.max(messageY, noteY + SEQ.messageRowHeight / 2);
    }
  }
  for (const [actorId, stack] of activationStacks) {
    for (const { startY, depth } of stack) {
      const idx = actorIndex.get(actorId) ?? 0;
      const xOffset = depth * nestingOffset;
      activations.push({
        actorId,
        x: actorCenterX[idx] - SEQ.activationWidth / 2 + xOffset,
        topY: startY,
        bottomY: messageY - SEQ.messageRowHeight / 2,
        width: SEQ.activationWidth
      });
    }
  }
  const blocks = diagram.blocks.map((block) => {
    const startMsg = messages[block.startIndex];
    const endMsg = messages[block.endIndex];
    const blockTop = (startMsg?.y ?? messageY) - SEQ.blockPadTop;
    const blockBottom = (endMsg?.y ?? messageY) + SEQ.blockPadBottom + 12;
    const involvedActors = /* @__PURE__ */ new Set();
    for (let mi = block.startIndex; mi <= block.endIndex; mi++) {
      const m = diagram.messages[mi];
      if (m) {
        involvedActors.add(actorIndex.get(m.from) ?? 0);
        involvedActors.add(actorIndex.get(m.to) ?? 0);
      }
    }
    if (involvedActors.size === 0) {
      for (let ai = 0; ai < diagram.actors.length; ai++) involvedActors.add(ai);
    }
    const minIdx = Math.min(...involvedActors);
    const maxIdx = Math.max(...involvedActors);
    const blockLeft = actorCenterX[minIdx] - actorWidths[minIdx] / 2 - SEQ.blockPadX;
    const blockRight = actorCenterX[maxIdx] + actorWidths[maxIdx] / 2 + SEQ.blockPadX;
    const dividers = block.dividers.map((d) => {
      const msg = messages[d.index];
      const msgY = msg?.y ?? messageY;
      let offset = 28;
      if (d.label && msg?.label) {
        const divLabelText = `[${d.label}]`;
        const divLabelW = estimateTextWidth(divLabelText, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
        const divLabelLeft = blockLeft + 8;
        const divLabelRight = divLabelLeft + divLabelW;
        const msgLabelW = estimateTextWidth(msg.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
        const msgLabelLeft = msg.isSelf ? msg.x1 + 36 : (msg.x1 + msg.x2) / 2 - msgLabelW / 2;
        const msgLabelRight = msgLabelLeft + msgLabelW;
        if (divLabelRight > msgLabelLeft && divLabelLeft < msgLabelRight) {
          offset = 36;
        }
      }
      return { y: msgY - offset, label: d.label };
    });
    return {
      type: block.type,
      label: block.label,
      x: blockLeft,
      y: blockTop,
      width: blockRight - blockLeft,
      height: blockBottom - blockTop,
      dividers
    };
  });
  const notes = positionedNotes;
  const diagramBottom = messageY + SEQ.padding;
  let globalMinX = SEQ.padding;
  let globalMaxX = 0;
  for (const a of actors) {
    globalMinX = Math.min(globalMinX, a.x - a.width / 2);
    globalMaxX = Math.max(globalMaxX, a.x + a.width / 2);
  }
  for (const b of blocks) {
    globalMinX = Math.min(globalMinX, b.x);
    globalMaxX = Math.max(globalMaxX, b.x + b.width);
  }
  for (const n of notes) {
    globalMinX = Math.min(globalMinX, n.x);
    globalMaxX = Math.max(globalMaxX, n.x + n.width);
  }
  for (const m of messages) {
    if (m.isSelf && m.label) {
      const loopW = 30;
      const labelPadding = 8;
      const labelLeft = m.x1 + loopW + labelPadding;
      const labelWidth = estimateTextWidth(m.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
      globalMaxX = Math.max(globalMaxX, labelLeft + labelWidth + 8);
    }
  }
  const shiftX = globalMinX < SEQ.padding ? SEQ.padding - globalMinX : 0;
  if (shiftX > 0) {
    for (const a of actors) a.x += shiftX;
    for (const m of messages) {
      m.x1 += shiftX;
      m.x2 += shiftX;
    }
    for (const act of activations) act.x += shiftX;
    for (const b of blocks) {
      b.x += shiftX;
    }
    for (const n of notes) n.x += shiftX;
    for (let i = 0; i < actorCenterX.length; i++) actorCenterX[i] += shiftX;
  }
  const lifelines = diagram.actors.map((a, i) => ({
    actorId: a.id,
    x: actorCenterX[i],
    topY: actorY + SEQ.actorHeight,
    bottomY: diagramBottom - SEQ.padding
  }));
  const diagramWidth = globalMaxX + shiftX + SEQ.padding;
  const diagramHeight = diagramBottom;
  return {
    width: Math.max(diagramWidth, 200),
    height: Math.max(diagramHeight, 100),
    actors,
    lifelines,
    messages,
    activations,
    blocks,
    notes
  };
}

// src/sequence/renderer.ts
function renderSequenceSvg(diagram, colors, font = "Inter", transparent = false) {
  const parts = [];
  parts.push(svgOpenTag(diagram.width, diagram.height, colors, transparent));
  parts.push(buildStyleBlock(font, false));
  parts.push("<defs>");
  parts.push(arrowMarkerDefs2());
  parts.push("</defs>");
  for (const block of diagram.blocks) {
    parts.push(renderBlock(block));
  }
  for (const lifeline of diagram.lifelines) {
    parts.push(renderLifeline(lifeline));
  }
  for (const activation of diagram.activations) {
    parts.push(renderActivation(activation));
  }
  for (const message of diagram.messages) {
    parts.push(renderMessage(message));
  }
  for (const note of diagram.notes) {
    parts.push(renderNote(note));
  }
  for (const actor of diagram.actors) {
    parts.push(renderActor(actor));
  }
  parts.push("</svg>");
  return parts.join("\n");
}
function arrowMarkerDefs2() {
  const w = ARROW_HEAD.width;
  const h = ARROW_HEAD.height;
  return `  <marker id="seq-arrow" markerWidth="${w}" markerHeight="${h}" refX="${w}" refY="${h / 2}" orient="auto-start-reverse">
    <polygon points="0 0, ${w} ${h / 2}, 0 ${h}" fill="var(--_arrow)" />
  </marker>
  <marker id="seq-arrow-open" markerWidth="${w}" markerHeight="${h}" refX="${w}" refY="${h / 2}" orient="auto-start-reverse">
    <polyline points="0 0, ${w} ${h / 2}, 0 ${h}" fill="none" stroke="var(--_arrow)" stroke-width="1" />
  </marker>`;
}
function renderActor(actor) {
  const { id, x, y, width, height, label, type } = actor;
  const parts = [];
  parts.push(
    `<g class="actor" data-id="${escapeAttr2(id)}" data-label="${escapeAttr2(label)}" data-type="${type}">`
  );
  if (type === "actor") {
    const s = height / 24 * 0.9;
    const tx = x - 12 * s;
    const ty = y + (height - 24 * s) / 2;
    const sw = STROKE_WIDTHS.outerBox / s;
    const iconStroke = "var(--_line)";
    parts.push(
      `  <g transform="translate(${tx},${ty}) scale(${s})">
    <path d="M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" fill="none" stroke="${iconStroke}" stroke-width="${sw}" />
    <path d="M15 10C15 11.6569 13.6569 13 12 13C10.3431 13 9 11.6569 9 10C9 8.34315 10.3431 7 12 7C13.6569 7 15 8.34315 15 10Z" fill="none" stroke="${iconStroke}" stroke-width="${sw}" />
    <path d="M5.62842 18.3563C7.08963 17.0398 9.39997 16 12 16C14.6 16 16.9104 17.0398 18.3716 18.3563" fill="none" stroke="${iconStroke}" stroke-width="${sw}" />
  </g>`
    );
    parts.push(
      "  " + renderMultilineText(
        label,
        x,
        y + height + 14,
        FONT_SIZES.nodeLabel,
        `font-size="${FONT_SIZES.nodeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.nodeLabel}" fill="var(--_text)"`
      )
    );
  } else {
    const boxX = x - width / 2;
    parts.push(
      `  <rect x="${boxX}" y="${y}" width="${width}" height="${height}" rx="4" ry="4" fill="var(--_node-fill)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
    );
    parts.push(
      "  " + renderMultilineText(
        label,
        x,
        y + height / 2,
        FONT_SIZES.nodeLabel,
        `font-size="${FONT_SIZES.nodeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.nodeLabel}" fill="var(--_text)"`
      )
    );
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderLifeline(lifeline) {
  return `<line class="lifeline" data-actor="${escapeAttr2(lifeline.actorId)}" x1="${lifeline.x}" y1="${lifeline.topY}" x2="${lifeline.x}" y2="${lifeline.bottomY}" stroke="var(--_line)" stroke-width="0.75" stroke-dasharray="6 4" />`;
}
function renderActivation(activation) {
  return `<rect class="activation" data-actor="${escapeAttr2(activation.actorId)}" x="${activation.x}" y="${activation.topY}" width="${activation.width}" height="${activation.bottomY - activation.topY}" fill="var(--_node-fill)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.innerBox}" />`;
}
function renderMessage(msg) {
  const parts = [];
  const dashArray = msg.lineStyle === "dashed" ? ' stroke-dasharray="6 4"' : "";
  const markerId = msg.arrowHead === "filled" ? "seq-arrow" : "seq-arrow-open";
  parts.push(
    `<g class="message" data-from="${escapeAttr2(msg.from)}" data-to="${escapeAttr2(msg.to)}" data-label="${escapeAttr2(msg.label)}" data-line-style="${msg.lineStyle}" data-arrow-head="${msg.arrowHead}" data-self="${msg.isSelf}">`
  );
  if (msg.isSelf) {
    const loopW = 30;
    const loopH = 20;
    const labelPadding = 8;
    parts.push(
      `  <polyline points="${msg.x1},${msg.y} ${msg.x1 + loopW},${msg.y} ${msg.x1 + loopW},${msg.y + loopH} ${msg.x2},${msg.y + loopH}" fill="none" stroke="var(--_line)" stroke-width="${STROKE_WIDTHS.connector}"${dashArray} marker-end="url(#${markerId})" />`
    );
    parts.push(
      "  " + renderMultilineText(
        msg.label,
        msg.x1 + loopW + labelPadding,
        msg.y + loopH / 2,
        FONT_SIZES.edgeLabel,
        `font-size="${FONT_SIZES.edgeLabel}" text-anchor="start" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
      )
    );
  } else {
    parts.push(
      `  <line x1="${msg.x1}" y1="${msg.y}" x2="${msg.x2}" y2="${msg.y}" stroke="var(--_line)" stroke-width="${STROKE_WIDTHS.connector}"${dashArray} marker-end="url(#${markerId})" />`
    );
    const midX = (msg.x1 + msg.x2) / 2;
    parts.push(
      "  " + renderMultilineText(
        msg.label,
        midX,
        msg.y - 10,
        FONT_SIZES.edgeLabel,
        `font-size="${FONT_SIZES.edgeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
      )
    );
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderBlock(block) {
  const parts = [];
  const labelAttr = block.label ? ` data-label="${escapeAttr2(block.label)}"` : "";
  parts.push(
    `<g class="block" data-type="${escapeAttr2(block.type)}"${labelAttr}>`
  );
  parts.push(
    `  <rect x="${block.x}" y="${block.y}" width="${block.width}" height="${block.height}" rx="0" ry="0" fill="none" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  const labelText = `${block.type}${block.label ? ` [${block.label}]` : ""}`;
  const firstLine = labelText.split("\n")[0];
  const tabWidth = estimateTextWidth(firstLine, FONT_SIZES.edgeLabel, FONT_WEIGHTS.groupHeader) + 16;
  const tabHeight = 18;
  parts.push(
    `  <rect x="${block.x}" y="${block.y}" width="${tabWidth}" height="${tabHeight}" fill="var(--_group-hdr)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  parts.push(
    "  " + renderMultilineText(
      labelText,
      block.x + 6,
      block.y + tabHeight / 2,
      FONT_SIZES.edgeLabel,
      `font-size="${FONT_SIZES.edgeLabel}" font-weight="${FONT_WEIGHTS.groupHeader}" fill="var(--_text-sec)"`
    )
  );
  for (const divider of block.dividers) {
    parts.push(
      `  <line x1="${block.x}" y1="${divider.y}" x2="${block.x + block.width}" y2="${divider.y}" stroke="var(--_line)" stroke-width="0.75" stroke-dasharray="6 4" />`
    );
    if (divider.label) {
      parts.push(
        "  " + renderMultilineText(
          `[${divider.label}]`,
          block.x + 8,
          divider.y + 14,
          FONT_SIZES.edgeLabel,
          `font-size="${FONT_SIZES.edgeLabel}" text-anchor="start" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
        )
      );
    }
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderNote(note) {
  const foldSize = 6;
  const { x, y, width: w, height: h } = note;
  const actorsAttr = note.actors && note.actors.length > 0 ? ` data-actors="${note.actors.map(escapeAttr2).join(",")}"` : "";
  const positionAttr = note.position ? ` data-position="${escapeAttr2(note.position)}"` : "";
  const bodyPoints = [
    `${x},${y}`,
    `${x + w - foldSize},${y}`,
    `${x + w},${y + foldSize}`,
    `${x + w},${y + h}`,
    `${x},${y + h}`
  ].join(" ");
  return `<g class="note"${positionAttr}${actorsAttr}>
  <polygon points="${bodyPoints}" fill="var(--bg)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.innerBox}" />
  <polygon points="${x + w - foldSize},${y} ${x + w},${y + foldSize} ${x + w - foldSize},${y + foldSize}" fill="var(--_inner-stroke)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.innerBox}" />
  ${renderMultilineText(
    note.text,
    x + w / 2,
    y + h / 2,
    FONT_SIZES.edgeLabel,
    `font-size="${FONT_SIZES.edgeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
  )}
</g>`;
}
function escapeAttr2(value) {
  return value.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// src/class/layout.ts
var CLS = {
  padding: 40,
  boxPadX: 8,
  headerBaseHeight: 32,
  annotationHeight: 16,
  memberRowHeight: 20,
  sectionPadY: 8,
  emptySectionHeight: 8,
  minWidth: 120,
  memberFontSize: 11,
  memberFontWeight: 400,
  nodeSpacing: 40,
  layerSpacing: 60
};
function buildClassElkGraph(diagram, _options) {
  const classSizes = /* @__PURE__ */ new Map();
  for (const cls of diagram.classes) {
    const headerHeight = cls.annotation ? CLS.headerBaseHeight + CLS.annotationHeight : CLS.headerBaseHeight;
    const attrHeight = cls.attributes.length > 0 ? cls.attributes.length * CLS.memberRowHeight + CLS.sectionPadY : CLS.emptySectionHeight;
    const methodHeight = cls.methods.length > 0 ? cls.methods.length * CLS.memberRowHeight + CLS.sectionPadY : CLS.emptySectionHeight;
    const headerTextW = estimateTextWidth(cls.label, FONT_SIZES.nodeLabel, FONT_WEIGHTS.nodeLabel);
    const maxAttrW = maxMemberWidth(cls.attributes);
    const maxMethodW = maxMemberWidth(cls.methods);
    const width = Math.max(CLS.minWidth, headerTextW + CLS.boxPadX * 2, maxAttrW + CLS.boxPadX * 2, maxMethodW + CLS.boxPadX * 2);
    const height = headerHeight + attrHeight + methodHeight;
    classSizes.set(cls.id, { width, height, headerHeight, attrHeight, methodHeight });
  }
  const elkGraph = {
    id: "root",
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": "DOWN",
      "elk.spacing.nodeNode": String(CLS.nodeSpacing),
      "elk.layered.spacing.nodeNodeBetweenLayers": String(CLS.layerSpacing),
      "elk.padding": `[top=${CLS.padding},left=${CLS.padding},bottom=${CLS.padding},right=${CLS.padding}]`,
      "elk.edgeRouting": "ORTHOGONAL",
      "elk.edgeLabels.placement": "CENTER"
    },
    children: [],
    edges: []
  };
  for (const cls of diagram.classes) {
    const size = classSizes.get(cls.id);
    elkGraph.children.push({ id: cls.id, width: size.width, height: size.height });
  }
  for (let i = 0; i < diagram.relationships.length; i++) {
    const rel = diagram.relationships[i];
    const edge = { id: `e${i}`, sources: [rel.from], targets: [rel.to] };
    if (rel.label) {
      const metrics = measureMultilineText(rel.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
      edge.labels = [{ text: rel.label, width: metrics.width + 8, height: metrics.height + 6 }];
    }
    elkGraph.edges.push(edge);
  }
  return { elkGraph, classSizes };
}
function extractClassLayout(result, diagram, classSizes) {
  const classLookup = /* @__PURE__ */ new Map();
  for (const cls of diagram.classes) classLookup.set(cls.id, cls);
  const positionedClasses = [];
  for (const child of result.children ?? []) {
    const cls = classLookup.get(child.id);
    if (cls) {
      const size = classSizes.get(cls.id);
      positionedClasses.push({
        id: cls.id,
        label: cls.label,
        annotation: cls.annotation,
        attributes: cls.attributes,
        methods: cls.methods,
        x: child.x ?? 0,
        y: child.y ?? 0,
        width: child.width ?? size.width,
        height: child.height ?? size.height,
        headerHeight: size.headerHeight,
        attrHeight: size.attrHeight,
        methodHeight: size.methodHeight
      });
    }
  }
  const relationships = [];
  for (let i = 0; i < (result.edges?.length ?? 0); i++) {
    const elkEdge = result.edges[i];
    const rel = diagram.relationships[i];
    const points = [];
    if (elkEdge.sections && elkEdge.sections.length > 0) {
      const section = elkEdge.sections[0];
      points.push({ x: section.startPoint.x, y: section.startPoint.y });
      if (section.bendPoints) {
        for (const bp of section.bendPoints) {
          points.push({ x: bp.x, y: bp.y });
        }
      }
      points.push({ x: section.endPoint.x, y: section.endPoint.y });
    }
    let labelPosition;
    if (elkEdge.labels && elkEdge.labels.length > 0) {
      const label = elkEdge.labels[0];
      if (label.x != null && label.y != null) {
        labelPosition = {
          x: label.x + (label.width ?? 0) / 2,
          y: label.y + (label.height ?? 0) / 2
        };
      }
    }
    relationships.push({
      from: rel.from,
      to: rel.to,
      type: rel.type,
      markerAt: rel.markerAt,
      label: rel.label,
      fromCardinality: rel.fromCardinality,
      toCardinality: rel.toCardinality,
      points,
      labelPosition
    });
  }
  return {
    width: result.width ?? 600,
    height: result.height ?? 400,
    classes: positionedClasses,
    relationships
  };
}
function layoutClassDiagramSync(diagram, options = {}) {
  if (diagram.classes.length === 0) {
    return { width: 0, height: 0, classes: [], relationships: [] };
  }
  const { elkGraph, classSizes } = buildClassElkGraph(diagram, options);
  const result = elkLayoutSync(elkGraph);
  return extractClassLayout(result, diagram, classSizes);
}
function maxMemberWidth(members) {
  if (members.length === 0) return 0;
  let maxW = 0;
  for (const m of members) {
    const text = memberToString(m);
    const w = estimateMonoTextWidth(text, CLS.memberFontSize);
    if (w > maxW) maxW = w;
  }
  return maxW;
}
function memberToString(m) {
  const vis = m.visibility ? `${m.visibility} ` : "";
  const name = m.isMethod ? `${m.name}(${m.params || ""})` : m.name;
  const type = m.type ? `: ${m.type}` : "";
  return `${vis}${name}${type}`;
}

// src/class/renderer.ts
var CLS_FONT = {
  memberSize: 11,
  memberWeight: 400,
  annotationSize: 10,
  annotationWeight: 500
};
function renderClassSvg(diagram, colors, font = "Inter", transparent = false) {
  const parts = [];
  parts.push(svgOpenTag(diagram.width, diagram.height, colors, transparent));
  parts.push(buildStyleBlock(font, true));
  parts.push("<defs>");
  parts.push(relationshipMarkerDefs());
  parts.push("</defs>");
  for (const rel of diagram.relationships) {
    parts.push(renderRelationship(rel));
  }
  for (const cls of diagram.classes) {
    parts.push(renderClassBox(cls));
  }
  for (const rel of diagram.relationships) {
    parts.push(renderRelationshipLabels(rel));
  }
  parts.push("</svg>");
  return parts.join("\n");
}
function relationshipMarkerDefs() {
  return (
    // Hollow triangle (inheritance, realization) — points at target
    `  <marker id="cls-inherit" markerWidth="12" markerHeight="10" refX="12" refY="5" orient="auto-start-reverse">
    <polygon points="0 0, 12 5, 0 10" fill="var(--bg)" stroke="var(--_arrow)" stroke-width="1.5" />
  </marker>
  <marker id="cls-composition" markerWidth="12" markerHeight="10" refX="0" refY="5" orient="auto-start-reverse">
    <polygon points="6 0, 12 5, 6 10, 0 5" fill="var(--_arrow)" stroke="var(--_arrow)" stroke-width="1" />
  </marker>
  <marker id="cls-aggregation" markerWidth="12" markerHeight="10" refX="0" refY="5" orient="auto-start-reverse">
    <polygon points="6 0, 12 5, 6 10, 0 5" fill="var(--bg)" stroke="var(--_arrow)" stroke-width="1.5" />
  </marker>
  <marker id="cls-arrow" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto-start-reverse">
    <polyline points="0 0, 8 3, 0 6" fill="none" stroke="var(--_arrow)" stroke-width="1.5" />
  </marker>`
  );
}
function renderClassBox(cls) {
  const { x, y, width, height, headerHeight, attrHeight, methodHeight } = cls;
  const parts = [];
  const annotationAttr = cls.annotation ? ` data-annotation="${escapeAttr3(cls.annotation)}"` : "";
  parts.push(
    `<g class="class-node" data-id="${escapeAttr3(cls.id)}" data-label="${escapeAttr3(cls.label)}"${annotationAttr}>`
  );
  parts.push(
    `  <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="0" ry="0" fill="var(--_node-fill)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  parts.push(
    `  <rect x="${x}" y="${y}" width="${width}" height="${headerHeight}" rx="0" ry="0" fill="var(--_group-hdr)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  let nameY = y + headerHeight / 2;
  if (cls.annotation) {
    const annotY = y + 12;
    parts.push(
      `  <text x="${x + width / 2}" y="${annotY}" text-anchor="middle" dy="${TEXT_BASELINE_SHIFT}" font-size="${CLS_FONT.annotationSize}" font-weight="${CLS_FONT.annotationWeight}" font-style="italic" fill="var(--_text-muted)">&lt;&lt;${escapeXml3(cls.annotation)}&gt;&gt;</text>`
    );
    nameY = y + headerHeight / 2 + 6;
  }
  parts.push(
    "  " + renderMultilineText(
      cls.label,
      x + width / 2,
      nameY,
      FONT_SIZES.nodeLabel,
      `text-anchor="middle" font-size="${FONT_SIZES.nodeLabel}" font-weight="700" fill="var(--_text)"`
    )
  );
  const attrTop = y + headerHeight;
  parts.push(
    `  <line x1="${x}" y1="${attrTop}" x2="${x + width}" y2="${attrTop}" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.innerBox}" />`
  );
  const memberRowH = 20;
  for (let i = 0; i < cls.attributes.length; i++) {
    const member = cls.attributes[i];
    const memberY = attrTop + 4 + i * memberRowH + memberRowH / 2;
    parts.push("  " + renderMember(member, x + CLS.boxPadX, memberY));
  }
  const methodTop = attrTop + attrHeight;
  parts.push(
    `  <line x1="${x}" y1="${methodTop}" x2="${x + width}" y2="${methodTop}" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.innerBox}" />`
  );
  for (let i = 0; i < cls.methods.length; i++) {
    const member = cls.methods[i];
    const memberY = methodTop + 4 + i * memberRowH + memberRowH / 2;
    parts.push("  " + renderMember(member, x + CLS.boxPadX, memberY));
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderMember(member, x, y) {
  const fontStyle = member.isAbstract ? ' font-style="italic"' : "";
  const decoration = member.isStatic ? ' text-decoration="underline"' : "";
  const spans = [];
  if (member.visibility) {
    spans.push(`<tspan fill="var(--_text-faint)">${escapeXml3(member.visibility)} </tspan>`);
  }
  const displayName = member.isMethod ? `${member.name}(${member.params || ""})` : member.name;
  spans.push(`<tspan fill="var(--_text-sec)">${escapeXml3(displayName)}</tspan>`);
  if (member.type) {
    spans.push(`<tspan fill="var(--_text-faint)">: </tspan>`);
    spans.push(`<tspan fill="var(--_text-muted)">${escapeXml3(member.type)}</tspan>`);
  }
  return `<text x="${x}" y="${y}" class="mono" dy="${TEXT_BASELINE_SHIFT}" font-size="${CLS_FONT.memberSize}" font-weight="${CLS_FONT.memberWeight}"${fontStyle}${decoration}>${spans.join("")}</text>`;
}
function renderRelationship(rel) {
  if (rel.points.length < 2) return "";
  const pathData = rel.points.map((p) => `${p.x},${p.y}`).join(" ");
  const isDashed = rel.type === "dependency" || rel.type === "realization";
  const dashArray = isDashed ? ' stroke-dasharray="6 4"' : "";
  const markers = getRelationshipMarkers(rel.type, rel.markerAt);
  const dataAttrs = [
    'class="class-relationship"',
    `data-from="${escapeAttr3(rel.from)}"`,
    `data-to="${escapeAttr3(rel.to)}"`,
    `data-type="${rel.type}"`,
    `data-marker-at="${rel.markerAt}"`
  ];
  if (rel.label) {
    dataAttrs.push(`data-label="${escapeAttr3(rel.label)}"`);
  }
  if (rel.fromCardinality) {
    dataAttrs.push(`data-from-cardinality="${escapeAttr3(rel.fromCardinality)}"`);
  }
  if (rel.toCardinality) {
    dataAttrs.push(`data-to-cardinality="${escapeAttr3(rel.toCardinality)}"`);
  }
  return `<polyline ${dataAttrs.join(" ")} points="${pathData}" fill="none" stroke="var(--_line)" stroke-width="${STROKE_WIDTHS.connector}"${dashArray}${markers} />`;
}
function getRelationshipMarkers(type, markerAt) {
  const markerId = getMarkerDefId(type);
  if (!markerId) return "";
  if (markerAt === "from") {
    return ` marker-start="url(#${markerId})"`;
  } else {
    return ` marker-end="url(#${markerId})"`;
  }
}
function getMarkerDefId(type) {
  switch (type) {
    case "inheritance":
    case "realization":
      return "cls-inherit";
    case "composition":
      return "cls-composition";
    case "aggregation":
      return "cls-aggregation";
    case "association":
    case "dependency":
      return "cls-arrow";
    default:
      return null;
  }
}
function renderRelationshipLabels(rel) {
  if (!rel.label && !rel.fromCardinality && !rel.toCardinality) return "";
  if (rel.points.length < 2) return "";
  const parts = [];
  if (rel.label) {
    const pos = rel.labelPosition ?? midpoint(rel.points);
    parts.push(
      renderMultilineText(
        rel.label,
        pos.x,
        pos.y - 8,
        FONT_SIZES.edgeLabel,
        `font-size="${FONT_SIZES.edgeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
      )
    );
  }
  if (rel.fromCardinality) {
    const p = rel.points[0];
    const next = rel.points[1];
    const offset = cardinalityOffset(p, next);
    parts.push(
      renderMultilineText(
        rel.fromCardinality,
        p.x + offset.x,
        p.y + offset.y,
        FONT_SIZES.edgeLabel,
        `font-size="${FONT_SIZES.edgeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
      )
    );
  }
  if (rel.toCardinality) {
    const p = rel.points[rel.points.length - 1];
    const prev = rel.points[rel.points.length - 2];
    const offset = cardinalityOffset(p, prev);
    parts.push(
      renderMultilineText(
        rel.toCardinality,
        p.x + offset.x,
        p.y + offset.y,
        FONT_SIZES.edgeLabel,
        `font-size="${FONT_SIZES.edgeLabel}" text-anchor="middle" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
      )
    );
  }
  return parts.join("\n");
}
function midpoint(points) {
  if (points.length === 0) return { x: 0, y: 0 };
  const mid = Math.floor(points.length / 2);
  return points[mid];
}
function cardinalityOffset(from, to) {
  const dx = to.x - from.x;
  const dy = to.y - from.y;
  if (Math.abs(dx) > Math.abs(dy)) {
    return { x: dx > 0 ? 14 : -14, y: -10 };
  }
  return { x: -14, y: dy > 0 ? 14 : -14 };
}
var escapeXml3 = escapeXml;
function escapeAttr3(value) {
  return value.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// src/er/layout.ts
var ER = {
  padding: 40,
  boxPadX: 14,
  headerHeight: 34,
  rowHeight: 22,
  minWidth: 140,
  attrFontSize: 11,
  attrFontWeight: 400,
  nodeSpacing: 70,
  layerSpacing: 90
};
function buildErElkGraph(diagram, _options) {
  const entitySizes = /* @__PURE__ */ new Map();
  for (const entity of diagram.entities) {
    const headerTextW = estimateTextWidth(entity.label, FONT_SIZES.nodeLabel, FONT_WEIGHTS.nodeLabel);
    let maxAttrW = 0;
    for (const attr of entity.attributes) {
      const attrText = `${attr.type}  ${attr.name}${attr.keys.length > 0 ? "  " + attr.keys.join(",") : ""}`;
      const w = estimateMonoTextWidth(attrText, ER.attrFontSize);
      if (w > maxAttrW) maxAttrW = w;
    }
    const width = Math.max(ER.minWidth, headerTextW + ER.boxPadX * 2, maxAttrW + ER.boxPadX * 2);
    const height = ER.headerHeight + Math.max(entity.attributes.length, 1) * ER.rowHeight;
    entitySizes.set(entity.id, { width, height });
  }
  const elkGraph = {
    id: "root",
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": "RIGHT",
      "elk.spacing.nodeNode": String(ER.nodeSpacing),
      "elk.layered.spacing.nodeNodeBetweenLayers": String(ER.layerSpacing),
      "elk.padding": `[top=${ER.padding},left=${ER.padding},bottom=${ER.padding},right=${ER.padding}]`,
      "elk.edgeRouting": "ORTHOGONAL",
      "elk.edgeLabels.placement": "CENTER"
    },
    children: [],
    edges: []
  };
  for (const entity of diagram.entities) {
    const size = entitySizes.get(entity.id);
    elkGraph.children.push({ id: entity.id, width: size.width, height: size.height });
  }
  for (let i = 0; i < diagram.relationships.length; i++) {
    const rel = diagram.relationships[i];
    const metrics = measureMultilineText(rel.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
    const edge = { id: `e${i}`, sources: [rel.entity1], targets: [rel.entity2] };
    if (rel.label) {
      edge.labels = [{ text: rel.label, width: metrics.width + 8, height: metrics.height + 6 }];
    }
    elkGraph.edges.push(edge);
  }
  return { elkGraph, entitySizes };
}
function extractErLayout(result, diagram, entitySizes) {
  const entityLookup = /* @__PURE__ */ new Map();
  for (const entity of diagram.entities) entityLookup.set(entity.id, entity);
  const positionedEntities = [];
  for (const child of result.children ?? []) {
    const entity = entityLookup.get(child.id);
    if (entity) {
      positionedEntities.push({
        id: entity.id,
        label: entity.label,
        attributes: entity.attributes,
        x: child.x ?? 0,
        y: child.y ?? 0,
        width: child.width ?? entitySizes.get(entity.id).width,
        height: child.height ?? entitySizes.get(entity.id).height,
        headerHeight: ER.headerHeight,
        rowHeight: ER.rowHeight
      });
    }
  }
  const relationships = [];
  for (let i = 0; i < (result.edges?.length ?? 0); i++) {
    const elkEdge = result.edges[i];
    const rel = diagram.relationships[i];
    const points = [];
    if (elkEdge.sections && elkEdge.sections.length > 0) {
      const section = elkEdge.sections[0];
      points.push({ x: section.startPoint.x, y: section.startPoint.y });
      if (section.bendPoints) {
        for (const bp of section.bendPoints) {
          points.push({ x: bp.x, y: bp.y });
        }
      }
      points.push({ x: section.endPoint.x, y: section.endPoint.y });
    }
    relationships.push({
      entity1: rel.entity1,
      entity2: rel.entity2,
      cardinality1: rel.cardinality1,
      cardinality2: rel.cardinality2,
      label: rel.label,
      identifying: rel.identifying,
      points
    });
  }
  return {
    width: result.width ?? 600,
    height: result.height ?? 400,
    entities: positionedEntities,
    relationships
  };
}
function layoutErDiagramSync(diagram, options = {}) {
  if (diagram.entities.length === 0) {
    return { width: 0, height: 0, entities: [], relationships: [] };
  }
  const { elkGraph, entitySizes } = buildErElkGraph(diagram, options);
  const result = elkLayoutSync(elkGraph);
  return extractErLayout(result, diagram, entitySizes);
}

// src/er/renderer.ts
var ER_FONT = {
  attrSize: 11,
  attrWeight: 400,
  keySize: 9,
  keyWeight: 600
};
function renderErSvg(diagram, colors, font = "Inter", transparent = false) {
  const parts = [];
  parts.push(svgOpenTag(diagram.width, diagram.height, colors, transparent));
  parts.push(buildStyleBlock(font, true));
  parts.push("<defs>");
  parts.push("</defs>");
  for (const rel of diagram.relationships) {
    parts.push(renderRelationshipLine(rel));
  }
  for (const entity of diagram.entities) {
    parts.push(renderEntityBox(entity));
  }
  for (const rel of diagram.relationships) {
    parts.push(renderCardinality(rel));
  }
  for (const rel of diagram.relationships) {
    parts.push(renderRelationshipLabel(rel));
  }
  parts.push("</svg>");
  return parts.join("\n");
}
function renderEntityBox(entity) {
  const { id, x, y, width, height, headerHeight, rowHeight, label, attributes } = entity;
  const parts = [];
  parts.push(
    `<g class="entity" data-id="${escapeAttr4(id)}" data-label="${escapeAttr4(label)}">`
  );
  parts.push(
    `  <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="0" ry="0" fill="var(--_node-fill)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  parts.push(
    `  <rect x="${x}" y="${y}" width="${width}" height="${headerHeight}" rx="0" ry="0" fill="var(--_group-hdr)" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.outerBox}" />`
  );
  parts.push(
    "  " + renderMultilineText(
      label,
      x + width / 2,
      y + headerHeight / 2,
      FONT_SIZES.nodeLabel,
      `text-anchor="middle" font-size="${FONT_SIZES.nodeLabel}" font-weight="700" fill="var(--_text)"`
    )
  );
  const attrTop = y + headerHeight;
  parts.push(
    `  <line x1="${x}" y1="${attrTop}" x2="${x + width}" y2="${attrTop}" stroke="var(--_node-stroke)" stroke-width="${STROKE_WIDTHS.innerBox}" />`
  );
  for (let i = 0; i < attributes.length; i++) {
    const attr = attributes[i];
    const rowY = attrTop + i * rowHeight + rowHeight / 2;
    parts.push("  " + renderAttribute(attr, x, rowY, width).replace(/\n/g, "\n  "));
  }
  if (attributes.length === 0) {
    parts.push(
      `  <text x="${x + width / 2}" y="${attrTop + rowHeight / 2}" text-anchor="middle" dy="${TEXT_BASELINE_SHIFT}" font-size="${ER_FONT.attrSize}" fill="var(--_text-faint)" font-style="italic">(no attributes)</text>`
    );
  }
  parts.push("</g>");
  return parts.join("\n");
}
function renderAttribute(attr, boxX, y, boxWidth) {
  const parts = [];
  const hasComment = attr.comment && attr.comment.length > 0;
  if (hasComment) {
    const tooltipText = attr.comment.replace(/<br\s*\/?>/gi, "\n");
    parts.push(`<g><title>${escapeXml4(tooltipText)}</title>`);
  }
  let keyWidth = 0;
  if (attr.keys.length > 0) {
    const keyText = attr.keys.join(",");
    keyWidth = estimateTextWidth(keyText, ER_FONT.keySize, ER_FONT.keyWeight) + 8;
    parts.push(
      `<rect x="${boxX + 6}" y="${y - 7}" width="${keyWidth}" height="14" rx="2" ry="2" fill="var(--_key-badge)" />`
    );
    parts.push(
      `<text x="${boxX + 6 + keyWidth / 2}" y="${y}" text-anchor="middle" dy="${TEXT_BASELINE_SHIFT}" font-size="${ER_FONT.keySize}" font-weight="${ER_FONT.keyWeight}" fill="var(--_text-sec)">${attr.keys.join(",")}</text>`
    );
  }
  const typeX = boxX + 8 + (keyWidth > 0 ? keyWidth + 6 : 0);
  parts.push(
    `<text x="${typeX}" y="${y}" class="mono" dy="${TEXT_BASELINE_SHIFT}" font-size="${ER_FONT.attrSize}" font-weight="${ER_FONT.attrWeight}"><tspan fill="var(--_text-muted)">${escapeXml4(attr.type)}</tspan></text>`
  );
  const nameX = boxX + boxWidth - 8;
  parts.push(
    `<text x="${nameX}" y="${y}" class="mono" text-anchor="end" dy="${TEXT_BASELINE_SHIFT}" font-size="${ER_FONT.attrSize}" font-weight="${ER_FONT.attrWeight}"><tspan fill="var(--_text-sec)">${escapeXml4(attr.name)}</tspan></text>`
  );
  if (hasComment) {
    parts.push("</g>");
  }
  return parts.join("\n");
}
function renderRelationshipLine(rel) {
  if (rel.points.length < 2) return "";
  const pathData = rel.points.map((p) => `${p.x},${p.y}`).join(" ");
  const dashArray = !rel.identifying ? ' stroke-dasharray="6 4"' : "";
  const labelAttr = rel.label ? ` data-label="${escapeAttr4(rel.label)}"` : "";
  const dataAttrs = [
    'class="er-relationship"',
    `data-entity1="${escapeAttr4(rel.entity1)}"`,
    `data-entity2="${escapeAttr4(rel.entity2)}"`,
    `data-cardinality1="${rel.cardinality1}"`,
    `data-cardinality2="${rel.cardinality2}"`,
    `data-identifying="${rel.identifying}"`
  ];
  return `<polyline ${dataAttrs.join(" ")}${labelAttr} points="${pathData}" fill="none" stroke="var(--_line)" stroke-width="${STROKE_WIDTHS.connector}"${dashArray} />`;
}
function renderRelationshipLabel(rel) {
  if (!rel.label || rel.points.length < 2) return "";
  const mid = midpoint2(rel.points);
  const metrics = measureMultilineText(rel.label, FONT_SIZES.edgeLabel, FONT_WEIGHTS.edgeLabel);
  const bgW = metrics.width + 8;
  const bgH = metrics.height + 6;
  return `<rect x="${mid.x - bgW / 2}" y="${mid.y - bgH / 2}" width="${bgW}" height="${bgH}" rx="2" ry="2" fill="var(--bg)" stroke="var(--_inner-stroke)" stroke-width="0.5" />
${renderMultilineText(
    rel.label,
    mid.x,
    mid.y,
    FONT_SIZES.edgeLabel,
    `text-anchor="middle" font-size="${FONT_SIZES.edgeLabel}" font-weight="${FONT_WEIGHTS.edgeLabel}" fill="var(--_text-muted)"`
  )}`;
}
function renderCardinality(rel) {
  if (rel.points.length < 2) return "";
  const parts = [];
  const p1 = rel.points[0];
  const p2 = rel.points[1];
  parts.push(renderCrowsFoot(p1, p2, rel.cardinality1));
  const pN = rel.points[rel.points.length - 1];
  const pN1 = rel.points[rel.points.length - 2];
  parts.push(renderCrowsFoot(pN, pN1, rel.cardinality2));
  return parts.join("\n");
}
function renderCrowsFoot(point, toward, cardinality) {
  const parts = [];
  const sw = STROKE_WIDTHS.connector + 0.25;
  const dx = point.x - toward.x;
  const dy = point.y - toward.y;
  const len = Math.sqrt(dx * dx + dy * dy);
  if (len === 0) return "";
  const ux = dx / len;
  const uy = dy / len;
  const px = -uy;
  const py = ux;
  const tipX = point.x - ux * 4;
  const tipY = point.y - uy * 4;
  const backX = point.x - ux * 16;
  const backY = point.y - uy * 16;
  const hasOneLine = cardinality === "one" || cardinality === "zero-one";
  const hasCrowsFoot = cardinality === "many" || cardinality === "zero-many";
  const hasCircle = cardinality === "zero-one" || cardinality === "zero-many";
  if (hasOneLine) {
    const halfW = 6;
    parts.push(
      `<line x1="${tipX + px * halfW}" y1="${tipY + py * halfW}" x2="${tipX - px * halfW}" y2="${tipY - py * halfW}" stroke="var(--_line)" stroke-width="${sw}" />`
    );
    const line2X = tipX - ux * 4;
    const line2Y = tipY - uy * 4;
    parts.push(
      `<line x1="${line2X + px * halfW}" y1="${line2Y + py * halfW}" x2="${line2X - px * halfW}" y2="${line2Y - py * halfW}" stroke="var(--_line)" stroke-width="${sw}" />`
    );
  }
  if (hasCrowsFoot) {
    const fanW = 7;
    const cfTipX = tipX;
    const cfTipY = tipY;
    parts.push(
      // Top fan line
      `<line x1="${cfTipX + px * fanW}" y1="${cfTipY + py * fanW}" x2="${backX}" y2="${backY}" stroke="var(--_line)" stroke-width="${sw}" />`
    );
    parts.push(
      // Center line
      `<line x1="${cfTipX}" y1="${cfTipY}" x2="${backX}" y2="${backY}" stroke="var(--_line)" stroke-width="${sw}" />`
    );
    parts.push(
      // Bottom fan line
      `<line x1="${cfTipX - px * fanW}" y1="${cfTipY - py * fanW}" x2="${backX}" y2="${backY}" stroke="var(--_line)" stroke-width="${sw}" />`
    );
  }
  if (hasCircle) {
    const circleOffset = hasCrowsFoot ? 20 : 12;
    const circleX = point.x - ux * circleOffset;
    const circleY = point.y - uy * circleOffset;
    parts.push(
      `<circle cx="${circleX}" cy="${circleY}" r="4" fill="var(--bg)" stroke="var(--_line)" stroke-width="${sw}" />`
    );
  }
  return parts.join("\n");
}
function midpoint2(points) {
  if (points.length === 0) return { x: 0, y: 0 };
  if (points.length === 1) return points[0];
  let totalLen = 0;
  for (let i = 1; i < points.length; i++) {
    const dx = points[i].x - points[i - 1].x;
    const dy = points[i].y - points[i - 1].y;
    totalLen += Math.sqrt(dx * dx + dy * dy);
  }
  if (totalLen === 0) return points[0];
  const halfLen = totalLen / 2;
  let walked = 0;
  for (let i = 1; i < points.length; i++) {
    const dx = points[i].x - points[i - 1].x;
    const dy = points[i].y - points[i - 1].y;
    const segLen = Math.sqrt(dx * dx + dy * dy);
    if (walked + segLen >= halfLen) {
      const t = segLen > 0 ? (halfLen - walked) / segLen : 0;
      return {
        x: points[i - 1].x + dx * t,
        y: points[i - 1].y + dy * t
      };
    }
    walked += segLen;
  }
  return points[points.length - 1];
}
var escapeXml4 = escapeXml;
function escapeAttr4(value) {
  return value.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// src/xychart/layout.ts
var XY = {
  plotWidth: 600,
  plotHeight: 340,
  padding: 22,
  titleFontSize: 18,
  titleFontWeight: 600,
  titleHeight: 42,
  axisLabelFontSize: 14,
  axisLabelFontWeight: 400,
  axisTitleFontSize: 15,
  axisTitleFontWeight: 500,
  xLabelHeight: 38,
  yLabelWidth: 58,
  yLabelGap: 18,
  axisTitlePad: 30,
  tickLength: 4,
  barPadRatio: 0.2,
  barGroupGap: 0,
  maxBarWidth: 40,
  legendFontSize: 14,
  legendFontWeight: 400,
  legendHeight: 28,
  legendSwatchW: 14,
  legendSwatchH: 14,
  legendGap: 6,
  legendItemGap: 16
};
function layoutXYChart(chart, _options = {}) {
  if (chart.horizontal) return layoutHorizontal(chart);
  return layoutVertical(chart);
}
function layoutVertical(chart) {
  const hasTitle = !!chart.title;
  const hasXTitle = !!chart.xAxis.title;
  const hasYTitle = !!chart.yAxis.title;
  const hasLegend = chart.series.length > 1;
  const yRange = chart.yAxis.range;
  const yTicks = niceTickValues2(yRange.min, yRange.max);
  const maxYLabelWidth = Math.max(
    ...yTicks.map((v) => estimateTextWidth(formatTickValue2(v), XY.axisLabelFontSize, XY.axisLabelFontWeight)),
    XY.yLabelWidth
  );
  const top = XY.padding + (hasTitle ? XY.titleHeight : 0) + (hasLegend ? XY.legendHeight : 0);
  const bottom = XY.padding + XY.xLabelHeight + (hasXTitle ? XY.axisTitlePad : 0);
  const left = XY.padding + maxYLabelWidth + XY.yLabelGap + (hasYTitle ? XY.axisTitlePad : 0);
  const right = XY.padding;
  const plotW = XY.plotWidth;
  const plotH = XY.plotHeight;
  const totalW = left + plotW + right;
  const totalH = top + plotH + bottom;
  const plotArea = { x: left, y: top, width: plotW, height: plotH };
  const dataCount = getDataCount2(chart);
  const xScale = (i) => left + (i + 0.5) * (plotW / dataCount);
  const bandWidth = plotW / dataCount;
  const yScale = (v) => {
    const t = (v - yRange.min) / (yRange.max - yRange.min || 1);
    return top + plotH - t * plotH;
  };
  const xTicks = buildXTicks(chart, xScale, top + plotH, bandWidth);
  const yAxisTicks = yTicks.map((v) => ({
    label: formatTickValue2(v),
    x: left,
    y: yScale(v),
    tx: left - XY.tickLength,
    ty: yScale(v),
    labelX: left - XY.yLabelGap,
    labelY: yScale(v),
    textAnchor: "end"
  }));
  const gridLines = yTicks.map((v) => ({
    x1: left,
    y1: yScale(v),
    x2: left + plotW,
    y2: yScale(v)
  }));
  const catLabels = getCategoryLabels2(chart, dataCount);
  const colorMap = chart.series.map((_, i) => i);
  const bars = layoutBars(chart, xScale, yScale, bandWidth, yRange.min, catLabels, colorMap);
  const lines = layoutLines(chart, xScale, yScale, catLabels, colorMap);
  const legendY = XY.padding + (hasTitle ? XY.titleHeight : 0) + XY.legendHeight / 2;
  const legend = hasLegend ? buildLegendItems(chart, totalW / 2, legendY, colorMap) : [];
  const xAxisLine = { x1: left, y1: top + plotH, x2: left + plotW, y2: top + plotH };
  const yAxisLine = { x1: left, y1: top, x2: left, y2: top + plotH };
  const xAxisObj = {
    ticks: xTicks,
    line: xAxisLine,
    ...hasXTitle ? { title: { text: chart.xAxis.title, x: left + plotW / 2, y: totalH - XY.padding } } : {}
  };
  const yAxisObj = {
    ticks: yAxisTicks,
    line: yAxisLine,
    ...hasYTitle ? { title: { text: chart.yAxis.title, x: XY.padding + 4, y: top + plotH / 2, rotate: -90 } } : {}
  };
  const titleObj = hasTitle ? { text: chart.title, x: totalW / 2, y: XY.padding + XY.titleFontSize } : void 0;
  return { width: totalW, height: totalH, title: titleObj, xAxis: xAxisObj, yAxis: yAxisObj, plotArea, bars, lines, gridLines, legend };
}
function layoutHorizontal(chart) {
  const hasTitle = !!chart.title;
  const hasXTitle = !!chart.xAxis.title;
  const hasYTitle = !!chart.yAxis.title;
  const hasLegend = chart.series.length > 1;
  const yRange = chart.yAxis.range;
  const valueTicks = niceTickValues2(yRange.min, yRange.max);
  const dataCount = getDataCount2(chart);
  const catLabels = getCategoryLabels2(chart, dataCount);
  const maxCatLabelWidth = Math.max(
    ...catLabels.map((l) => estimateTextWidth(l, XY.axisLabelFontSize, XY.axisLabelFontWeight)),
    40
  );
  const top = XY.padding + (hasTitle ? XY.titleHeight : 0) + (hasLegend ? XY.legendHeight : 0);
  const bottom = XY.padding + XY.xLabelHeight + (hasYTitle ? XY.axisTitlePad : 0);
  const left = XY.padding + maxCatLabelWidth + XY.yLabelGap + (hasXTitle ? XY.axisTitlePad : 0);
  const right = XY.padding;
  const plotW = XY.plotWidth;
  const plotH = XY.plotHeight;
  const totalW = left + plotW + right;
  const totalH = top + plotH + bottom;
  const plotArea = { x: left, y: top, width: plotW, height: plotH };
  const valueScale = (v) => {
    const t = (v - yRange.min) / (yRange.max - yRange.min || 1);
    return left + t * plotW;
  };
  const bandHeight = plotH / dataCount;
  const catScale = (i) => top + (i + 0.5) * bandHeight;
  const xTicks = valueTicks.map((v) => ({
    label: formatTickValue2(v),
    x: valueScale(v),
    y: top + plotH,
    tx: valueScale(v),
    ty: top + plotH + XY.tickLength,
    labelX: valueScale(v),
    labelY: top + plotH + 18,
    textAnchor: "middle"
  }));
  const yTicks = catLabels.map((label, i) => ({
    label,
    x: left,
    y: catScale(i),
    tx: left - XY.tickLength,
    ty: catScale(i),
    labelX: left - XY.yLabelGap,
    labelY: catScale(i),
    textAnchor: "end"
  }));
  const gridLines = valueTicks.map((v) => ({
    x1: valueScale(v),
    y1: top,
    x2: valueScale(v),
    y2: top + plotH
  }));
  const colorMap = chart.series.map((_, i) => i);
  const barSeries = chart.series.filter((s) => s.type === "bar");
  const barCount = barSeries.length;
  const bars = [];
  if (barCount > 0) {
    const usable = bandHeight * (1 - XY.barPadRatio);
    const rawBarH = barCount > 1 ? (usable - (barCount - 1) * XY.barGroupGap) / barCount : usable;
    const singleBarH = Math.min(rawBarH, XY.maxBarWidth);
    const groupH = barCount > 1 ? singleBarH * barCount + XY.barGroupGap * (barCount - 1) : singleBarH;
    let bIdx = 0;
    let seriesArrayIdx = 0;
    for (const s of chart.series) {
      if (s.type !== "bar") {
        seriesArrayIdx++;
        continue;
      }
      for (let i = 0; i < s.data.length; i++) {
        const cy = catScale(i);
        const groupTop = cy - groupH / 2;
        const by = groupTop + bIdx * (singleBarH + XY.barGroupGap);
        const valX = valueScale(Math.max(s.data[i], yRange.min));
        const baseX = valueScale(Math.max(0, yRange.min));
        bars.push({
          x: Math.min(baseX, valX),
          y: by,
          width: Math.abs(valX - baseX),
          height: singleBarH,
          value: s.data[i],
          label: catLabels[i],
          seriesIndex: bIdx,
          colorIndex: colorMap[seriesArrayIdx]
        });
      }
      bIdx++;
      seriesArrayIdx++;
    }
  }
  const lines = [];
  let lineIdx = 0;
  let lineSeriesIdx = 0;
  for (const s of chart.series) {
    if (s.type !== "line") {
      lineSeriesIdx++;
      continue;
    }
    const points = s.data.map((v, i) => ({ x: valueScale(v), y: catScale(i), value: v, label: catLabels[i] }));
    lines.push({ points, seriesIndex: lineIdx, colorIndex: colorMap[lineSeriesIdx] });
    lineIdx++;
    lineSeriesIdx++;
  }
  const xAxisLine = { x1: left, y1: top + plotH, x2: left + plotW, y2: top + plotH };
  const yAxisLine = { x1: left, y1: top, x2: left, y2: top + plotH };
  const xAxisObj = {
    ticks: xTicks,
    line: xAxisLine,
    ...hasYTitle ? { title: { text: chart.yAxis.title, x: left + plotW / 2, y: totalH - XY.padding } } : {}
  };
  const yAxisObj = {
    ticks: yTicks,
    line: yAxisLine,
    ...hasXTitle ? { title: { text: chart.xAxis.title, x: XY.padding + 4, y: top + plotH / 2, rotate: -90 } } : {}
  };
  const titleObj = hasTitle ? { text: chart.title, x: totalW / 2, y: XY.padding + XY.titleFontSize } : void 0;
  const legendY = XY.padding + (hasTitle ? XY.titleHeight : 0) + XY.legendHeight / 2;
  const legend = hasLegend ? buildLegendItems(chart, totalW / 2, legendY, colorMap) : [];
  return { width: totalW, height: totalH, horizontal: true, title: titleObj, xAxis: xAxisObj, yAxis: yAxisObj, plotArea, bars, lines, gridLines, legend };
}
function getDataCount2(chart) {
  if (chart.xAxis.categories) return chart.xAxis.categories.length;
  for (const s of chart.series) {
    if (s.data.length > 0) return s.data.length;
  }
  return 1;
}
function getCategoryLabels2(chart, count) {
  if (chart.xAxis.categories) return chart.xAxis.categories;
  if (chart.xAxis.range) {
    const { min, max } = chart.xAxis.range;
    const step = count > 1 ? (max - min) / (count - 1) : 0;
    return Array.from({ length: count }, (_, i) => formatTickValue2(min + step * i));
  }
  return Array.from({ length: count }, (_, i) => String(i + 1));
}
function buildXTicks(chart, xScale, axisY, _bandWidth) {
  const count = getDataCount2(chart);
  const labels = getCategoryLabels2(chart, count);
  return labels.map((label, i) => ({
    label,
    x: xScale(i),
    y: axisY,
    tx: xScale(i),
    ty: axisY + XY.tickLength,
    labelX: xScale(i),
    labelY: axisY + 18,
    textAnchor: "middle"
  }));
}
function layoutBars(chart, xScale, yScale, bandWidth, yMin, catLabels, colorMap) {
  const barSeries = chart.series.filter((s) => s.type === "bar");
  const barCount = barSeries.length;
  if (barCount === 0) return [];
  const usable = bandWidth * (1 - XY.barPadRatio);
  const rawBarW = barCount > 1 ? (usable - (barCount - 1) * XY.barGroupGap) / barCount : usable;
  const singleBarW = Math.min(rawBarW, XY.maxBarWidth);
  const groupW = barCount > 1 ? singleBarW * barCount + XY.barGroupGap * (barCount - 1) : singleBarW;
  const bars = [];
  let bIdx = 0;
  let seriesArrayIdx = 0;
  for (const s of chart.series) {
    if (s.type !== "bar") {
      seriesArrayIdx++;
      continue;
    }
    for (let i = 0; i < s.data.length; i++) {
      const cx = xScale(i);
      const groupLeft = cx - groupW / 2;
      const bx = groupLeft + bIdx * (singleBarW + XY.barGroupGap);
      const valY = yScale(s.data[i]);
      const baseY = yScale(Math.max(0, yMin));
      bars.push({
        x: bx,
        y: Math.min(valY, baseY),
        width: singleBarW,
        height: Math.abs(baseY - valY),
        value: s.data[i],
        label: catLabels[i],
        seriesIndex: bIdx,
        colorIndex: colorMap[seriesArrayIdx]
      });
    }
    bIdx++;
    seriesArrayIdx++;
  }
  return bars;
}
function layoutLines(chart, xScale, yScale, catLabels, colorMap) {
  const lines = [];
  let lineIdx = 0;
  let seriesArrayIdx = 0;
  for (const s of chart.series) {
    if (s.type !== "line") {
      seriesArrayIdx++;
      continue;
    }
    const points = s.data.map((v, i) => ({ x: xScale(i), y: yScale(v), value: v, label: catLabels[i] }));
    lines.push({ points, seriesIndex: lineIdx, colorIndex: colorMap[seriesArrayIdx] });
    lineIdx++;
    seriesArrayIdx++;
  }
  return lines;
}
function niceTickValues2(min, max) {
  const range = max - min;
  if (range <= 0) return [min];
  const rawInterval = range / 6;
  const magnitude = Math.pow(10, Math.floor(Math.log10(rawInterval)));
  const residual = rawInterval / magnitude;
  let niceInterval;
  if (residual <= 1.5) niceInterval = magnitude;
  else if (residual <= 3) niceInterval = 2 * magnitude;
  else if (residual <= 7) niceInterval = 5 * magnitude;
  else niceInterval = 10 * magnitude;
  const start = Math.ceil(min / niceInterval) * niceInterval;
  const ticks = [];
  for (let v = start; v <= max + niceInterval * 1e-3; v += niceInterval) {
    ticks.push(Math.round(v * 1e10) / 1e10);
  }
  return ticks;
}
function formatTickValue2(v) {
  if (Number.isInteger(v)) return String(v);
  return v.toFixed(Math.abs(v) < 10 ? 1 : 0);
}
function buildLegendItems(chart, centerX, y, colorMap) {
  const items = [];
  let barIdx = 0, lineIdx = 0;
  for (let si = 0; si < chart.series.length; si++) {
    const s = chart.series[si];
    const label = s.type === "bar" ? `Bar ${barIdx + 1}` : `Line ${lineIdx + 1}`;
    items.push({ label, x: 0, y, type: s.type, seriesIndex: s.type === "bar" ? barIdx : lineIdx, colorIndex: colorMap[si] });
    if (s.type === "bar") barIdx++;
    else lineIdx++;
  }
  const itemWidths = items.map((item) => {
    const textW = estimateTextWidth(item.label, XY.legendFontSize, XY.legendFontWeight);
    return XY.legendSwatchW + XY.legendGap + textW;
  });
  const totalWidth = itemWidths.reduce((a, b) => a + b, 0) + (items.length - 1) * XY.legendItemGap;
  let x = centerX - totalWidth / 2;
  for (let i = 0; i < items.length; i++) {
    items[i].x = x;
    x += itemWidths[i] + XY.legendItemGap;
  }
  return items;
}

// src/xychart/renderer.ts
var CHART_FONT = {
  titleSize: 18,
  titleWeight: 600,
  axisTitleSize: 15,
  axisTitleWeight: 500,
  labelSize: 14,
  labelWeight: 400,
  legendSize: 14,
  legendWeight: 400,
  dotRadius: 5,
  lineWidth: 2.5,
  barRadius: 8
};
var TIP = {
  fontSize: 15,
  fontWeight: 500,
  height: 32,
  padX: 14,
  offsetY: 12,
  rx: 8,
  minY: 4,
  pointerSize: 6
};
function renderXYChartSvg(chart, colors, font = "Inter", transparent = false, interactive = false) {
  const parts = [];
  const maxColorIdx = Math.max(0, ...chart.bars.map((b) => b.colorIndex), ...chart.lines.map((l) => l.colorIndex));
  const svgTag = svgOpenTag(chart.width, chart.height, colors, transparent).replace("<svg ", `<svg data-xychart-colors="${maxColorIdx}" `);
  parts.push(svgTag);
  parts.push(buildStyleBlock(font, false));
  const maxLinePoints = Math.max(...chart.lines.map((l) => l.points.length), 0);
  const sparse = maxLinePoints > 0 && maxLinePoints <= 12;
  const { style: chartCss, defs: chartDefs } = chartStyles(chart, interactive, sparse, colors.accent, colors.bg);
  parts.push(chartCss);
  if (chartDefs) parts.push(chartDefs);
  const { plotArea } = chart;
  const xTicks = chart.xAxis.ticks.map((t) => t.x);
  const yVals = chart.horizontal ? chart.yAxis.ticks.map((t) => t.y) : chart.gridLines.map((g) => g.y1);
  const xBase = xTicks.length > 1 ? Math.abs(xTicks[1] - xTicks[0]) : plotArea.width / 6;
  const yBase = yVals.length > 1 ? Math.abs(yVals[1] - yVals[0]) : plotArea.height / 6;
  const xGap = xBase / Math.max(1, Math.round(xBase / 20));
  const yGap = yBase / Math.max(1, Math.round(yBase / 20));
  const xAnchor = xTicks[0] ?? plotArea.x;
  const yAnchor = yVals[0] ?? plotArea.y;
  const xStart = xAnchor - Math.ceil((xAnchor - plotArea.x) / xGap) * xGap;
  const yStart = yAnchor - Math.ceil((yAnchor - plotArea.y) / yGap) * yGap;
  for (let y = yStart; y <= plotArea.y + plotArea.height + 0.5; y += yGap) {
    for (let x = xStart; x <= plotArea.x + plotArea.width + 0.5; x += xGap) {
      parts.push(`<circle cx="${r(x)}" cy="${r(y)}" r="1.5" class="xychart-grid"/>`);
    }
  }
  const barOverlay = [];
  for (const bar of chart.bars) {
    const dataAttrs = ` data-value="${bar.value}"${bar.label ? ` data-label="${escapeXml5(bar.label)}"` : ""}`;
    const barPath = chart.horizontal ? roundedRightBarPath(bar.x, bar.y, bar.width, bar.height, CHART_FONT.barRadius) : roundedTopBarPath(bar.x, bar.y, bar.width, bar.height, CHART_FONT.barRadius);
    parts.push(
      `<path d="${barPath}" class="xychart-bar xychart-color-${bar.colorIndex}"${dataAttrs}/>`
    );
    if (interactive) {
      const tipText = formatTipValue(bar.value);
      const tipTitle = bar.label ? `${bar.label}: ${tipText}` : tipText;
      const tip = tooltipAbove(bar.x + bar.width / 2, bar.y, tipText);
      barOverlay.push(
        `<g class="xychart-bar-group"><rect x="${r(bar.x)}" y="${r(bar.y)}" width="${r(bar.width)}" height="${r(bar.height)}" fill="transparent"/><title>${escapeXml5(tipTitle)}</title>` + tip + `</g>`
      );
    }
  }
  for (const line of chart.lines) {
    if (line.points.length === 0) continue;
    const d = smoothCurvePath(line.points);
    parts.push(`<path d="${d}" class="xychart-line-shadow xychart-color-${line.colorIndex}" transform="translate(0,2)"/>`);
    parts.push(`<path d="${d}" class="xychart-line xychart-color-${line.colorIndex}"/>`);
  }
  const dotOverlay = [];
  if (interactive || sparse) {
    const lineLegendLabels = /* @__PURE__ */ new Map();
    for (const item of chart.legend) {
      if (item.type === "line") lineLegendLabels.set(item.seriesIndex, item.label);
    }
    const columns = /* @__PURE__ */ new Map();
    for (const line of chart.lines) {
      for (const p of line.points) {
        const key = r(p.x);
        if (!columns.has(key)) columns.set(key, []);
        columns.get(key).push({ x: p.x, y: p.y, value: p.value, label: p.label, seriesIndex: line.seriesIndex, colorIndex: line.colorIndex });
      }
    }
    for (const entries of columns.values()) {
      const cx = entries[0].x;
      const label = entries[0].label || "";
      if (interactive && entries.length > 1) {
        const topY = Math.min(...entries.map((e) => e.y));
        const botY = Math.max(...entries.map((e) => e.y));
        const hitPad = CHART_FONT.dotRadius * 3;
        const hitArea = `<rect x="${r(cx - hitPad)}" y="${r(topY - hitPad)}" width="${r(hitPad * 2)}" height="${r(botY - topY + hitPad * 2)}" fill="transparent" class="xychart-hit"/>`;
        const tipEntries = entries.map((e) => ({
          text: formatTipValue(e.value),
          legendLabel: lineLegendLabels.get(e.seriesIndex) || `Line ${e.seriesIndex + 1}`
        }));
        const tip = multiTooltipAbove(cx, topY - CHART_FONT.dotRadius, label, tipEntries);
        const valStrs = tipEntries.map((e) => e.text);
        const titleText = label ? `${label}: ${valStrs.join(" \xB7 ")}` : valStrs.join(" \xB7 ");
        let group = `<g class="xychart-dot-group">${hitArea}`;
        for (const e of entries) {
          const dataAttrs = ` data-value="${e.value}"${e.label ? ` data-label="${escapeXml5(e.label)}"` : ""}`;
          group += `<circle cx="${r(e.x)}" cy="${r(e.y)}" r="${CHART_FONT.dotRadius}" class="xychart-dot xychart-color-${e.colorIndex}"${dataAttrs}/>`;
        }
        group += `<title>${escapeXml5(titleText)}</title>${tip}</g>`;
        dotOverlay.push(group);
      } else if (interactive) {
        const e = entries[0];
        const dataAttrs = ` data-value="${e.value}"${e.label ? ` data-label="${escapeXml5(e.label)}"` : ""}`;
        const tipText = formatTipValue(e.value);
        const tipTitle = e.label ? `${e.label}: ${tipText}` : tipText;
        const tip = tooltipAbove(cx, e.y - CHART_FONT.dotRadius, tipText);
        const hitArea = sparse ? `<circle cx="${r(cx)}" cy="${r(e.y)}" r="${CHART_FONT.dotRadius * 3}" fill="transparent" class="xychart-hit"/>` : "";
        dotOverlay.push(
          `<g class="xychart-dot-group">${hitArea}<circle cx="${r(e.x)}" cy="${r(e.y)}" r="${CHART_FONT.dotRadius}" class="xychart-dot xychart-color-${e.colorIndex}"${dataAttrs}/><title>${escapeXml5(tipTitle)}</title>${tip}</g>`
        );
      } else {
        for (const e of entries) {
          const dataAttrs = ` data-value="${e.value}"${e.label ? ` data-label="${escapeXml5(e.label)}"` : ""}`;
          parts.push(
            `<circle cx="${r(e.x)}" cy="${r(e.y)}" r="${CHART_FONT.dotRadius}" class="xychart-dot xychart-color-${e.colorIndex}"${dataAttrs}/>`
          );
        }
      }
    }
  }
  for (const tick of chart.xAxis.ticks) {
    parts.push(
      `<text x="${tick.labelX}" y="${tick.labelY}" text-anchor="${tick.textAnchor}" font-size="${CHART_FONT.labelSize}" font-weight="${CHART_FONT.labelWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-label">${escapeXml5(tick.label)}</text>`
    );
  }
  for (const tick of chart.yAxis.ticks) {
    parts.push(
      `<text x="${tick.labelX}" y="${tick.labelY}" text-anchor="${tick.textAnchor}" font-size="${CHART_FONT.labelSize}" font-weight="${CHART_FONT.labelWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-label">${escapeXml5(tick.label)}</text>`
    );
  }
  if (chart.xAxis.title) {
    const t = chart.xAxis.title;
    const transform = t.rotate ? ` transform="rotate(${t.rotate},${t.x},${t.y})"` : "";
    parts.push(
      `<text x="${t.x}" y="${t.y}" text-anchor="middle"${transform} font-size="${CHART_FONT.axisTitleSize}" font-weight="${CHART_FONT.axisTitleWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-axis-title">${escapeXml5(t.text)}</text>`
    );
  }
  if (chart.yAxis.title) {
    const t = chart.yAxis.title;
    const transform = t.rotate ? ` transform="rotate(${t.rotate},${t.x},${t.y})"` : "";
    parts.push(
      `<text x="${t.x}" y="${t.y}" text-anchor="middle"${transform} font-size="${CHART_FONT.axisTitleSize}" font-weight="${CHART_FONT.axisTitleWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-axis-title">${escapeXml5(t.text)}</text>`
    );
  }
  if (chart.title) {
    parts.push(
      `<text x="${chart.title.x}" y="${chart.title.y}" text-anchor="middle" font-size="${CHART_FONT.titleSize}" font-weight="${CHART_FONT.titleWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-title">${escapeXml5(chart.title.text)}</text>`
    );
  }
  for (const item of chart.legend) {
    const swatchW = 14, swatchH = 14;
    const gap = 6;
    if (item.type === "bar") {
      parts.push(
        `<rect x="${item.x}" y="${item.y - swatchH / 2}" width="${swatchW}" height="${swatchH}" rx="3" class="xychart-bar xychart-color-${item.colorIndex}"/>`
      );
    } else {
      const ly = item.y;
      parts.push(
        `<line x1="${item.x}" y1="${ly}" x2="${item.x + swatchW}" y2="${ly}" stroke-width="${CHART_FONT.lineWidth}" stroke-linecap="round" class="xychart-legend-line xychart-color-${item.colorIndex}"/>`
      );
    }
    parts.push(
      `<text x="${item.x + swatchW + gap}" y="${item.y}" text-anchor="start" font-size="${CHART_FONT.legendSize}" font-weight="${CHART_FONT.legendWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-label">${escapeXml5(item.label)}</text>`
    );
  }
  for (const g of barOverlay) parts.push(g);
  for (const g of dotOverlay) parts.push(g);
  parts.push("</svg>");
  return parts.join("\n");
}
function chartStyles(chart, interactive, sparse, themeAccent, bgColor) {
  const accentHex = themeAccent ?? CHART_ACCENT_FALLBACK;
  const colorIndices = /* @__PURE__ */ new Set();
  for (const b of chart.bars) colorIndices.add(b.colorIndex);
  for (const l of chart.lines) colorIndices.add(l.colorIndex);
  const colorVarDefs = [];
  for (const idx of [...colorIndices].sort((a, b) => a - b)) {
    const value = idx === 0 ? `var(--accent, ${CHART_ACCENT_FALLBACK})` : getSeriesColor(idx, accentHex, bgColor);
    colorVarDefs.push(`    --xychart-color-${idx}: ${value};`);
    colorVarDefs.push(`    --xychart-bar-fill-${idx}: color-mix(in srgb, var(--bg) 75%, var(--xychart-color-${idx}) 25%);`);
  }
  const seriesRules = [];
  for (const idx of [...colorIndices].sort((a, b) => a - b)) {
    const color = `var(--xychart-color-${idx})`;
    seriesRules.push(`  .xychart-bar.xychart-color-${idx} { stroke: ${color}; fill: var(--xychart-bar-fill-${idx}); }`);
    seriesRules.push(`  path.xychart-color-${idx}, line.xychart-color-${idx} { stroke: ${color}; }`);
    seriesRules.push(`  circle.xychart-color-${idx} { fill: ${color}; }`);
  }
  const tipRules = interactive ? `
  .xychart-tip { opacity: 0; pointer-events: none; }
  .xychart-tip-bg { fill: var(--_text); filter: drop-shadow(0 1px 3px color-mix(in srgb, var(--fg) 20%, transparent)); }
  .xychart-tip-text { fill: var(--bg); font-size: ${TIP.fontSize}px; font-weight: ${TIP.fontWeight}; }
  .xychart-tip-ptr { fill: var(--_text); }
  .xychart-bar-group:hover .xychart-tip,
  .xychart-dot-group:hover .xychart-tip { opacity: 1; }` : "";
  const colorVarsBlock = colorVarDefs.length > 0 ? `
  svg {
${colorVarDefs.join("\n")}
  }` : "";
  const style = `<style>
  .xychart-grid { fill: var(--_inner-stroke); stroke: none; opacity: 0.65; }
  .xychart-bar { stroke-width: 1.5; }
  .xychart-line { fill: none; stroke-width: ${CHART_FONT.lineWidth}; stroke-linecap: round; stroke-linejoin: round; }
  .xychart-line-shadow { fill: none; stroke-width: 5; stroke-linecap: round; stroke-linejoin: round; opacity: 0.12; }
  .xychart-dot { stroke: var(--bg); stroke-width: 2; }
  .xychart-label { fill: var(--_text-muted); }
  .xychart-axis-title { fill: var(--_text-sec); }
  .xychart-title { fill: var(--_text); }${colorVarsBlock}
${seriesRules.join("\n")}${tipRules}
</style>`;
  return { style, defs: "" };
}
function roundedTopBarPath(x, y, w, h, radius) {
  const rr = Math.min(radius, w / 2, h / 2);
  if (rr <= 0) {
    return `M${r(x)},${r(y)} h${r(w)} v${r(h)} h${r(-w)} Z`;
  }
  return [
    `M${r(x)},${r(y + rr)}`,
    // start below top-left
    `Q${r(x)},${r(y)} ${r(x + rr)},${r(y)}`,
    // top-left
    `L${r(x + w - rr)},${r(y)}`,
    // top edge
    `Q${r(x + w)},${r(y)} ${r(x + w)},${r(y + rr)}`,
    // top-right
    `L${r(x + w)},${r(y + h - rr)}`,
    // right edge
    `Q${r(x + w)},${r(y + h)} ${r(x + w - rr)},${r(y + h)}`,
    // bottom-right
    `L${r(x + rr)},${r(y + h)}`,
    // bottom edge
    `Q${r(x)},${r(y + h)} ${r(x)},${r(y + h - rr)}`,
    // bottom-left
    "Z"
  ].join(" ");
}
function roundedRightBarPath(x, y, w, h, radius) {
  const rr = Math.min(radius, w / 2, h / 2);
  if (rr <= 0) {
    return `M${r(x)},${r(y)} h${r(w)} v${r(h)} h${r(-w)} Z`;
  }
  return [
    `M${r(x + rr)},${r(y)}`,
    // start after top-left
    `L${r(x + w - rr)},${r(y)}`,
    // top edge
    `Q${r(x + w)},${r(y)} ${r(x + w)},${r(y + rr)}`,
    // top-right
    `L${r(x + w)},${r(y + h - rr)}`,
    // right edge
    `Q${r(x + w)},${r(y + h)} ${r(x + w - rr)},${r(y + h)}`,
    // bottom-right
    `L${r(x + rr)},${r(y + h)}`,
    // bottom edge
    `Q${r(x)},${r(y + h)} ${r(x)},${r(y + h - rr)}`,
    // bottom-left
    `L${r(x)},${r(y + rr)}`,
    // left edge
    `Q${r(x)},${r(y)} ${r(x + rr)},${r(y)}`,
    // top-left
    "Z"
  ].join(" ");
}
function smoothCurvePath(points) {
  if (points.length === 0) return "";
  if (points.length === 1) return `M${r(points[0].x)},${r(points[0].y)}`;
  if (points.length === 2) {
    return `M${r(points[0].x)},${r(points[0].y)} L${r(points[1].x)},${r(points[1].y)}`;
  }
  const n = points.length;
  const h = [];
  const delta = [];
  for (let i = 0; i < n - 1; i++) {
    h.push(points[i + 1].x - points[i].x);
    delta.push(h[i] === 0 ? 0 : (points[i + 1].y - points[i].y) / h[i]);
  }
  const c = new Array(n).fill(0);
  if (n > 2) {
    const cp = new Array(n).fill(0);
    const dp = new Array(n).fill(0);
    for (let i = 1; i < n - 1; i++) {
      const diag = 2 * (h[i - 1] + h[i]);
      const rhs = 3 * (delta[i] - delta[i - 1]);
      if (i === 1) {
        cp[i] = h[i] / diag;
        dp[i] = rhs / diag;
      } else {
        const w = diag - h[i - 1] * cp[i - 1];
        cp[i] = h[i] / w;
        dp[i] = (rhs - h[i - 1] * dp[i - 1]) / w;
      }
    }
    for (let i = n - 2; i >= 1; i--) {
      c[i] = dp[i] - cp[i] * c[i + 1];
    }
  }
  const slopes = new Array(n).fill(0);
  for (let i = 0; i < n - 1; i++) {
    slopes[i] = delta[i] - h[i] * (2 * c[i] + c[i + 1]) / 3;
  }
  slopes[n - 1] = delta[n - 2] + h[n - 2] * c[n - 2] / 3;
  let path = `M${r(points[0].x)},${r(points[0].y)}`;
  for (let i = 0; i < n - 1; i++) {
    const seg = h[i] / 3;
    const cp1x = points[i].x + seg;
    const cp1y = points[i].y + slopes[i] * seg;
    const cp2x = points[i + 1].x - seg;
    const cp2y = points[i + 1].y - slopes[i + 1] * seg;
    path += ` C${r(cp1x)},${r(cp1y)} ${r(cp2x)},${r(cp2y)} ${r(points[i + 1].x)},${r(points[i + 1].y)}`;
  }
  return path;
}
function multiTooltipAbove(cx, topY, label, entries) {
  const lineH = 20;
  const padY = 6;
  const labelGap = 10;
  const headingW = estimateTextWidth(label, TIP.fontSize, 600);
  const maxRowW = Math.max(...entries.map((e) => {
    const legendW = estimateTextWidth(e.legendLabel, TIP.fontSize, TIP.fontWeight);
    const valW = estimateTextWidth(e.text, TIP.fontSize, TIP.fontWeight);
    return legendW + labelGap + valW;
  }));
  const bgW = Math.max(headingW, maxRowW) + TIP.padX * 2;
  const bgH = padY + lineH + entries.length * lineH + padY;
  const tipY = Math.max(TIP.minY, topY - TIP.offsetY - bgH - TIP.pointerSize);
  const bgX = cx - bgW / 2;
  const ptrX = cx;
  const ptrY = tipY + bgH;
  const ps = TIP.pointerSize;
  const pointer = `<polygon points="${r(ptrX - ps)},${r(ptrY)} ${r(ptrX + ps)},${r(ptrY)} ${r(ptrX)},${r(ptrY + ps)}" class="xychart-tip xychart-tip-ptr"/>`;
  let svg = `<rect x="${r(bgX)}" y="${r(tipY)}" width="${r(bgW)}" height="${bgH}" rx="${TIP.rx}" class="xychart-tip xychart-tip-bg"/>`;
  svg += pointer;
  let textY = tipY + padY + lineH / 2;
  svg += `<text x="${r(cx)}" y="${r(textY)}" text-anchor="middle" font-weight="600" font-size="${TIP.fontSize}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-tip xychart-tip-text">${escapeXml5(label)}</text>`;
  const rowLeft = bgX + TIP.padX;
  const rowRight = bgX + bgW - TIP.padX;
  for (const entry of entries) {
    textY += lineH;
    svg += `<text x="${r(rowLeft)}" y="${r(textY)}" text-anchor="start" font-size="${TIP.fontSize}" font-weight="${TIP.fontWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-tip xychart-tip-text">${escapeXml5(entry.legendLabel)}</text>`;
    svg += `<text x="${r(rowRight)}" y="${r(textY)}" text-anchor="end" font-size="${TIP.fontSize}" font-weight="${TIP.fontWeight}" dy="${TEXT_BASELINE_SHIFT}" class="xychart-tip xychart-tip-text">${escapeXml5(entry.text)}</text>`;
  }
  return svg;
}
function tooltipAbove(cx, topY, text) {
  const textW = estimateTextWidth(text, TIP.fontSize, TIP.fontWeight);
  const bgW = textW + TIP.padX * 2;
  const bgH = TIP.height;
  const tipY = Math.max(TIP.minY, topY - TIP.offsetY - bgH - TIP.pointerSize);
  const bgX = cx - bgW / 2;
  const textX = cx;
  const textY = tipY + bgH / 2;
  const ptrX = cx;
  const ptrY = tipY + bgH;
  const ps = TIP.pointerSize;
  const pointer = `<polygon points="${r(ptrX - ps)},${r(ptrY)} ${r(ptrX + ps)},${r(ptrY)} ${r(ptrX)},${r(ptrY + ps)}" class="xychart-tip xychart-tip-ptr"/>`;
  return `<rect x="${r(bgX)}" y="${r(tipY)}" width="${r(bgW)}" height="${bgH}" rx="${TIP.rx}" class="xychart-tip xychart-tip-bg"/>` + pointer + `<text x="${r(textX)}" y="${r(textY)}" text-anchor="middle" dy="${TEXT_BASELINE_SHIFT}" class="xychart-tip xychart-tip-text">${escapeXml5(text)}</text>`;
}
function formatTipValue(v) {
  if (Number.isInteger(v)) return v.toLocaleString("en-US");
  return v.toFixed(Math.abs(v) < 10 ? 1 : 0);
}
function r(n) {
  return String(Math.round(n * 10) / 10);
}
function escapeXml5(text) {
  return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

// src/index.ts
function detectDiagramType2(text) {
  const firstLine = text.trim().split(/[\n;]/)[0]?.trim().toLowerCase() ?? "";
  if (/^xychart(-beta)?\b/.test(firstLine)) return "xychart";
  if (/^sequencediagram\s*$/.test(firstLine)) return "sequence";
  if (/^classdiagram\s*$/.test(firstLine)) return "class";
  if (/^erdiagram\s*$/.test(firstLine)) return "er";
  return "flowchart";
}
function buildColors(options) {
  return {
    bg: options.bg ?? DEFAULTS.bg,
    fg: options.fg ?? DEFAULTS.fg,
    line: options.line,
    accent: options.accent,
    muted: options.muted,
    surface: options.surface,
    border: options.border
  };
}
function renderMermaidSVG(text, options = {}) {
  text = decodeXML(text);
  const colors = buildColors(options);
  const font = options.font ?? "Inter";
  const transparent = options.transparent ?? false;
  const diagramType = detectDiagramType2(text);
  const lines = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("%%"));
  switch (diagramType) {
    case "sequence": {
      const diagram = parseSequenceDiagram(lines);
      const positioned = layoutSequenceDiagram(diagram, options);
      return renderSequenceSvg(positioned, colors, font, transparent);
    }
    case "class": {
      const diagram = parseClassDiagram(lines);
      const positioned = layoutClassDiagramSync(diagram, options);
      return renderClassSvg(positioned, colors, font, transparent);
    }
    case "er": {
      const diagram = parseErDiagram(lines);
      const positioned = layoutErDiagramSync(diagram, options);
      return renderErSvg(positioned, colors, font, transparent);
    }
    case "xychart": {
      const chart = parseXYChart(lines);
      const positioned = layoutXYChart(chart, options);
      return renderXYChartSvg(positioned, colors, font, transparent, options.interactive ?? false);
    }
    case "flowchart":
    default: {
      const graph = parseMermaid(text);
      const positioned = layoutGraphSync(graph, options);
      return renderSvg(positioned, colors, font, transparent);
    }
  }
}
async function renderMermaidSVGAsync(text, options = {}) {
  return renderMermaidSVG(text, options);
}
var renderMermaidSync = renderMermaidSVG;
var renderMermaid = renderMermaidSVGAsync;
export {
  DEFAULTS,
  THEMES,
  fromShikiTheme,
  parseMermaid,
  renderMermaid,
  renderMermaidASCII,
  renderMermaidAscii,
  renderMermaidSVG,
  renderMermaidSVGAsync,
  renderMermaidSync
};
//# sourceMappingURL=index.js.map