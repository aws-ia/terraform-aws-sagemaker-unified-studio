interface MermaidGraph {
    direction: Direction;
    nodes: Map<string, MermaidNode>;
    edges: MermaidEdge[];
    subgraphs: MermaidSubgraph[];
    classDefs: Map<string, Record<string, string>>;
    /** Maps node IDs to their class names (from `class X className` or `:::className` shorthand) */
    classAssignments: Map<string, string>;
    /** Maps node IDs to inline styles (from `style X fill:#f00,stroke:#333`) */
    nodeStyles: Map<string, Record<string, string>>;
    /** Maps edge indices (or 'default') to inline styles from `linkStyle` directives */
    linkStyles: Map<number | 'default', Record<string, string>>;
}
type Direction = 'TD' | 'TB' | 'LR' | 'BT' | 'RL';
interface MermaidNode {
    id: string;
    label: string;
    shape: NodeShape;
}
type NodeShape = 'rectangle' | 'rounded' | 'diamond' | 'stadium' | 'circle' | 'subroutine' | 'doublecircle' | 'hexagon' | 'cylinder' | 'asymmetric' | 'trapezoid' | 'trapezoid-alt' | 'state-start' | 'state-end';
interface MermaidEdge {
    source: string;
    target: string;
    label?: string;
    style: EdgeStyle;
    /** Whether to render an arrowhead at the start (source end) of the edge */
    hasArrowStart: boolean;
    /** Whether to render an arrowhead at the end (target end) of the edge */
    hasArrowEnd: boolean;
}
type EdgeStyle = 'solid' | 'dotted' | 'thick';
interface MermaidSubgraph {
    id: string;
    label: string;
    nodeIds: string[];
    children: MermaidSubgraph[];
    /** Optional direction override for this subgraph's internal layout */
    direction?: Direction;
}
interface PositionedGraph {
    width: number;
    height: number;
    nodes: PositionedNode[];
    edges: PositionedEdge[];
    groups: PositionedGroup[];
}
interface PositionedNode {
    id: string;
    label: string;
    shape: NodeShape;
    x: number;
    y: number;
    width: number;
    height: number;
    /** Inline styles resolved from classDef + explicit `style` statements — override theme defaults */
    inlineStyle?: Record<string, string>;
}
interface PositionedEdge {
    source: string;
    target: string;
    label?: string;
    style: EdgeStyle;
    hasArrowStart: boolean;
    hasArrowEnd: boolean;
    /** Full path including bends — array of {x, y} points */
    points: Point[];
    /** Layout-computed label center position (avoids label-label collisions) */
    labelPosition?: Point;
    /** Inline styles resolved from `linkStyle` directives — override theme defaults */
    inlineStyle?: Record<string, string>;
}
interface Point {
    x: number;
    y: number;
}
interface PositionedGroup {
    id: string;
    label: string;
    x: number;
    y: number;
    width: number;
    height: number;
    children: PositionedGroup[];
}
interface RenderOptions {
    /** Background color → CSS variable --bg. Default: '#FFFFFF' */
    bg?: string;
    /** Foreground / primary text color → CSS variable --fg. Default: '#27272A' */
    fg?: string;
    /** Edge/connector color → CSS variable --line */
    line?: string;
    /** Arrow heads, highlights → CSS variable --accent */
    accent?: string;
    /** Secondary text, edge labels → CSS variable --muted */
    muted?: string;
    /** Node/box fill tint → CSS variable --surface */
    surface?: string;
    /** Node/group stroke color → CSS variable --border */
    border?: string;
    /** Font family for all text. Default: 'Inter' */
    font?: string;
    /** Canvas padding in px. Default: 40 */
    padding?: number;
    /** Horizontal spacing between sibling nodes. Default: 24 */
    nodeSpacing?: number;
    /** Vertical spacing between layers. Default: 40 */
    layerSpacing?: number;
    /** Spacing between disconnected components. Default: nodeSpacing (24) */
    componentSpacing?: number;
    /** Render with transparent background (no background style on SVG). Default: false */
    transparent?: boolean;
    /** Enable hover tooltips on chart data points (xychart only). Default: false */
    interactive?: boolean;
}

/**
 * Diagram color configuration.
 *
 * Required: bg + fg give you a clean mono diagram.
 * Optional: line, accent, muted, surface, border bring in richer color
 * from Shiki themes or custom palettes. Each falls back to a color-mix()
 * derivation from bg + fg if not set.
 */
interface DiagramColors {
    /** Background color → CSS variable --bg */
    bg: string;
    /** Foreground / primary text color → CSS variable --fg */
    fg: string;
    /** Edge/connector color → CSS variable --line */
    line?: string;
    /** Arrow heads, highlights, special nodes → CSS variable --accent */
    accent?: string;
    /** Secondary text, edge labels → CSS variable --muted */
    muted?: string;
    /** Node/box fill tint → CSS variable --surface */
    surface?: string;
    /** Node/group stroke color → CSS variable --border */
    border?: string;
}
/** Default bg/fg when no colors are provided (zinc light) */
declare const DEFAULTS: Readonly<{
    bg: string;
    fg: string;
}>;
declare const THEMES: Record<string, DiagramColors>;
type ThemeName = keyof typeof THEMES;
/**
 * Minimal subset of Shiki's ThemeRegistrationResolved that we need.
 * We don't import from shiki to avoid a hard dependency.
 */
interface ShikiThemeLike {
    type?: string;
    colors?: Record<string, string>;
    tokenColors?: Array<{
        scope?: string | string[];
        settings?: {
            foreground?: string;
        };
    }>;
}
/**
 * Extract diagram colors from a Shiki theme object.
 * Works with any VS Code / TextMate theme loaded by Shiki.
 *
 * Maps editor UI colors to diagram roles:
 *   editor.background         → bg
 *   editor.foreground         → fg
 *   editorLineNumber.fg       → line (optional)
 *   focusBorder / keyword     → accent (optional)
 *   comment token             → muted (optional)
 *   editor.selectionBackground→ surface (optional)
 *   editorWidget.border       → border (optional)
 *
 * @example
 * ```ts
 * import { getSingletonHighlighter } from 'shiki'
 * import { fromShikiTheme } from 'beautiful-mermaid'
 *
 * const hl = await getSingletonHighlighter({ themes: ['tokyo-night'] })
 * const colors = fromShikiTheme(hl.getTheme('tokyo-night'))
 * const svg = renderMermaidSVG(code, colors)
 * ```
 */
declare function fromShikiTheme(theme: ShikiThemeLike): DiagramColors;

/**
 * Parse Mermaid text into a logical graph structure.
 * Auto-detects diagram type (flowchart or state diagram).
 * Throws on invalid/unsupported input.
 */
declare function parseMermaid(text: string): MermaidGraph;

/**
 * Theme colors for ASCII output — hex color strings.
 * Derived from the SVG theme system for visual consistency.
 */
interface AsciiTheme {
    /** Text color (node labels, edge labels) */
    fg: string;
    /** Box border color (node borders, subgraph borders) */
    border: string;
    /** Edge line color (paths between nodes) */
    line: string;
    /** Arrowhead color (▲▼◄► or ^v<>) */
    arrow: string;
    /** Theme accent color (optional, used by xycharts for series 0) */
    accent?: string;
    /** Background color (optional, used by xycharts for dark-mode-aware shading) */
    bg?: string;
    /** Corner character color (optional, defaults to line) */
    corner?: string;
    /** Junction character color (optional, defaults to border) */
    junction?: string;
}
/** Color mode for output. */
type ColorMode = 'none' | 'ansi16' | 'ansi256' | 'truecolor' | 'html';

interface AsciiRenderOptions {
    /** true = ASCII chars (+,-,|,>), false = Unicode box-drawing (┌,─,│,►). Default: false */
    useAscii?: boolean;
    /** Horizontal spacing between nodes. Default: 5 */
    paddingX?: number;
    /** Vertical spacing between nodes. Default: 5 */
    paddingY?: number;
    /** Padding inside node boxes. Default: 1 */
    boxBorderPadding?: number;
    /**
     * Color mode for output.
     * - 'none': No colors (plain text)
     * - 'auto': Auto-detect (terminal ANSI capabilities, or HTML in browsers)
     * - 'ansi16': 16-color ANSI
     * - 'ansi256': 256-color xterm
     * - 'truecolor': 24-bit RGB
     * - 'html': HTML <span> tags with inline color styles (for browser rendering)
     * Default: 'auto'
     */
    colorMode?: ColorMode | 'auto';
    /** Theme colors for ASCII output. Uses default theme if not provided. */
    theme?: Partial<AsciiTheme>;
}
/**
 * Render Mermaid diagram text to an ASCII/Unicode string.
 *
 * Synchronous — no async layout engine needed (unlike the SVG renderer).
 * Auto-detects diagram type from the header line and dispatches to
 * the appropriate renderer.
 *
 * @param text - Mermaid source text (any supported diagram type)
 * @param options - Rendering options
 * @returns Multi-line ASCII/Unicode string
 *
 * @example
 * ```ts
 * const result = renderMermaidAscii(`
 *   graph LR
 *     A --> B --> C
 * `, { useAscii: true })
 *
 * // Output:
 * // +---+     +---+     +---+
 * // |   |     |   |     |   |
 * // | A |---->| B |---->| C |
 * // |   |     |   |     |   |
 * // +---+     +---+     +---+
 * ```
 */
declare function renderMermaidASCII(text: string, options?: AsciiRenderOptions): string;
/** @deprecated Use `renderMermaidASCII` */
declare const renderMermaidAscii: typeof renderMermaidASCII;

/**
 * Render Mermaid diagram text to an SVG string — synchronously.
 *
 * Uses elk.bundled.js with a direct FakeWorker bypass (no setTimeout(0) delay).
 * The ELK singleton is created lazily on first use and cached forever.
 *
 * Use this in React components with useMemo() to avoid flash:
 *   const svg = useMemo(() => renderMermaidSVG(code, opts), [code])
 *
 * @param text - Mermaid source text
 * @param options - Rendering options (colors, font, spacing)
 * @returns A self-contained SVG string
 *
 * @example
 * ```ts
 * const svg = renderMermaidSVG('graph TD\n  A --> B')
 *
 * // With theme
 * const svg = renderMermaidSVG('graph TD\n  A --> B', {
 *   bg: '#1a1b26', fg: '#a9b1d6'
 * })
 *
 * // With CSS variables (for live theme switching)
 * const svg = renderMermaidSVG('graph TD\n  A --> B', {
 *   bg: 'var(--background)', fg: 'var(--foreground)', transparent: true
 * })
 * ```
 */
declare function renderMermaidSVG(text: string, options?: RenderOptions): string;
/**
 * Render Mermaid diagram text to an SVG string — async.
 *
 * Same result as renderMermaidSVG() but returns a Promise.
 * Useful in async contexts (server handlers, data loaders, etc.)
 */
declare function renderMermaidSVGAsync(text: string, options?: RenderOptions): Promise<string>;
/** @deprecated Use `renderMermaidSVG` */
declare const renderMermaidSync: typeof renderMermaidSVG;
/** @deprecated Use `renderMermaidSVGAsync` */
declare const renderMermaid: typeof renderMermaidSVGAsync;

export { type AsciiRenderOptions, DEFAULTS, type DiagramColors, type MermaidGraph, type PositionedGraph, type RenderOptions, THEMES, type ThemeName, fromShikiTheme, parseMermaid, renderMermaid, renderMermaidASCII, renderMermaidAscii, renderMermaidSVG, renderMermaidSVGAsync, renderMermaidSync };
