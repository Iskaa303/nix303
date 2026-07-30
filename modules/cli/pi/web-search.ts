import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const KETCH = "ketch";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web using ketch (Brave, DuckDuckGo, SearXNG, Exa, Firecrawl, or Keenable — configured by the operator). Returns title, URL, and description for each result.",
    promptSnippet: "Search the web for any topic",
    promptGuidelines: [
      "Use web_search to find current information, documentation, or answers on the open web.",
      "Use web_fetch (not web_search) when you already have a specific URL to retrieve.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 50, default: 10 })),
    }),
    async execute(_id, params, signal) {
      const r = await pi.exec(KETCH, [
        "search", "--json", "--limit", String(params.limit ?? 10), params.query,
      ], { signal, timeout: 30_000 });
      return {
        content: [{ type: "text", text: r.code === 0 ? r.stdout : `ketch: ${r.stderr}` }],
        details: {},
        isError: r.code !== 0,
      };
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description:
      "Fetch a URL and extract clean markdown content via ketch scrape. Handles HTML, PDFs, and JS-rendered pages. Set max_chars to bound response size.",
    promptSnippet: "Fetch a web page and extract clean content as markdown",
    promptGuidelines: [
      "Use web_fetch to retrieve the full content of a specific URL you already know.",
      "Set max_chars to bound response size for large or unknown pages.",
      "Use web_search first to discover URLs, then web_fetch to read them.",
    ],
    parameters: Type.Object({
      url: Type.String({ description: "URL to fetch and extract" }),
      max_chars: Type.Optional(Type.Integer({ minimum: 0, default: 15_000 })),
      selector: Type.Optional(Type.String({ description: "CSS selector to extract a specific element" })),
      force_browser: Type.Optional(Type.Boolean({ default: false })),
    }),
    async execute(_id, params, signal) {
      const args = ["scrape", "--json", "--max-chars", String(params.max_chars ?? 15_000)];
      if (params.selector) args.push("--select", params.selector);
      if (params.force_browser) args.push("--force-browser");
      args.push(params.url);
      const r = await pi.exec(KETCH, args, { signal, timeout: 60_000 });
      return {
        content: [{ type: "text", text: r.code === 0 ? r.stdout : `ketch: ${r.stderr}` }],
        details: {},
        isError: r.code !== 0,
      };
    },
  });

  pi.registerTool({
    name: "code_search",
    label: "Code Search",
    description:
      "Search real open-source code across public repositories via ketch code (Grep, Sourcegraph, or GitHub Code Search). Supports language filtering and regex.",
    promptSnippet: "Search open-source code for real-world usage examples",
    promptGuidelines: [
      "Use code_search to find real-world usage of APIs, libraries, or patterns in public OSS repos.",
      "Specify --lang to filter by programming language.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Code search query (symbol name, pattern, etc.)" }),
      lang: Type.Optional(Type.String({ description: "Language filter" })),
      limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 30, default: 5 })),
      regex: Type.Optional(Type.Boolean({ default: false })),
    }),
    async execute(_id, params, signal) {
      const args = ["code", "--json", "--limit", String(params.limit ?? 5)];
      if (params.lang) args.push("--lang", params.lang);
      if (params.regex) args.push("--regex");
      args.push(params.query);
      const r = await pi.exec(KETCH, args, { signal, timeout: 30_000 });
      return {
        content: [{ type: "text", text: r.code === 0 ? r.stdout : `ketch: ${r.stderr}` }],
        details: {},
        isError: r.code !== 0,
      };
    },
  });
}
