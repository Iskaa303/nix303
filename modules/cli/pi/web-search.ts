import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

//
// web-search — pi extension that registers web_search, web_fetch, and code_search
// tools backed by ketch (https://github.com/1broseidon/ketch).
//
// Requires ketch in PATH. Configure backends once:
//   ketch config set brave_api_key <key>   # or exa_api_key, firecrawl_api_key
//   ketch config set context7_api_key <key> # for docs (optional)
//
// ketch exit codes:
//   0 = success, 2 = bad input, 3 = not found, 4 = upstream/network,
//   5 = missing precondition (API key, browser), 6 = cancelled
//

const KETCH = "ketch";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web and return results with title, URL, and description. " +
      "Backed by ketch (Brave, DuckDuckGo, SearXNG, Exa, Firecrawl, or Keenable — configured by the operator).",
    promptSnippet: "Search the web for any topic",
    promptGuidelines: [
      "Use web_search to find current information, documentation, or answers on the open web.",
      "Use web_fetch (not web_search) when you already have a specific URL to retrieve.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      limit: Type.Optional(
        Type.Integer({ minimum: 1, maximum: 50, default: 10 })
      ),
    }),
    async execute(_toolCallId, params, signal, _onUpdate) {
      const limit = params.limit ?? 10;
      const result = await pi.exec(KETCH, [
        "search",
        "--json",
        "--limit",
        String(limit),
        params.query,
      ], { signal, timeout: 30_000 });

      if (result.code === 2) {
        return err(`Invalid search input: ${result.stderr}`);
      }
      if (result.code === 4) {
        return err(`Search upstream failure: ${result.stderr}`);
      }
      if (result.code === 5) {
        return err(
          `Search not configured. Set an API key: ketch config set brave_api_key <key> (or exa_api_key, firecrawl_api_key). Details: ${result.stderr}`,
        );
      }
      if (result.code !== 0) {
        return err(`Search failed (exit ${result.code}): ${result.stderr}`);
      }

      return {
        content: [{ type: "text", text: result.stdout || "(no results)" }],
        details: {},
      };
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description:
      "Fetch a URL and extract clean markdown content. " +
      "Handles HTML, PDFs (text extraction), and JS-rendered pages. " +
      "Supports CSS selector extraction and /llms.txt auto-detection. " +
      "Backed by ketch scrape.",
    promptSnippet: "Fetch a web page and extract clean content as markdown",
    promptGuidelines: [
      "Use web_fetch to retrieve the full content of a specific URL you already know.",
      "Set max_chars to bound response size for large or unknown pages.",
      "Use web_search first to discover URLs, then web_fetch to read them.",
    ],
    parameters: Type.Object({
      url: Type.String({ description: "URL to fetch and extract" }),
      max_chars: Type.Optional(
        Type.Integer({ minimum: 0, default: 15_000, description: "Truncate output to N chars (0 = unlimited)" })
      ),
      selector: Type.Optional(
        Type.String({ description: "CSS selector to extract a specific element instead of the full page" })
      ),
      force_browser: Type.Optional(
        Type.Boolean({ default: false, description: "Render via headless browser for JS-heavy pages" })
      ),
    }),
    async execute(_toolCallId, params, signal, _onUpdate) {
      const args: string[] = ["scrape", "--json", "--max-chars", String(params.max_chars ?? 15_000)];
      if (params.selector) args.push("--select", params.selector);
      if (params.force_browser) args.push("--force-browser");

      args.push(params.url);

      const result = await pi.exec(KETCH, args, { signal, timeout: 60_000 });

      if (result.code === 2) {
        return err(`Invalid fetch input: ${result.stderr}`);
      }
      if (result.code === 3) {
        return err(`Resource not found: ${result.stderr}`);
      }
      if (result.code === 4) {
        return err(`Fetch upstream failure: ${result.stderr}`);
      }
      if (result.code === 5) {
        return err(
          `Fetch precondition not met: ${result.stderr}`,
        );
      }
      if (result.code !== 0) {
        return err(`Fetch failed (exit ${result.code}): ${result.stderr}`);
      }

      return {
        content: [{ type: "text", text: result.stdout || "(no content)" }],
        details: {},
      };
    },
  });

  pi.registerTool({
    name: "code_search",
    label: "Code Search",
    description:
      "Search real open-source code across public repositories. " +
      "Backed by Grep (mcp.grep.app), Sourcegraph, or GitHub Code Search. " +
      "Supports language filtering and regex queries.",
    promptSnippet: "Search open-source code for real-world usage examples",
    promptGuidelines: [
      "Use code_search to find real-world usage of APIs, libraries, or patterns in public OSS repos.",
      "Specify --lang to filter by programming language.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Code search query (symbol name, pattern, etc.)" }),
      lang: Type.Optional(
        Type.String({ description: "Language filter (e.g. go, rust, python, typescript)" })
      ),
      limit: Type.Optional(
        Type.Integer({ minimum: 1, maximum: 30, default: 5 })
      ),
      regex: Type.Optional(
        Type.Boolean({ default: false, description: "Interpret query as a regular expression" })
      ),
    }),
    async execute(_toolCallId, params, signal, _onUpdate) {
      const args: string[] = [
        "code",
        "--json",
        "--limit",
        String(params.limit ?? 5),
      ];
      if (params.lang) args.push("--lang", params.lang);
      if (params.regex) args.push("--regex");

      args.push(params.query);

      const result = await pi.exec(KETCH, args, { signal, timeout: 30_000 });

      if (result.code === 2) {
        return err(`Invalid code search input: ${result.stderr}`);
      }
      if (result.code === 4) {
        return err(`Code search upstream failure: ${result.stderr}`);
      }
      if (result.code === 5) {
        return err(
          `Code search not configured. Set a token: ketch config set github_token <token> (for GitHub backend). Details: ${result.stderr}`,
        );
      }
      if (result.code !== 0) {
        return err(`Code search failed (exit ${result.code}): ${result.stderr}`);
      }

      return {
        content: [{ type: "text", text: result.stdout || "(no results)" }],
        details: {},
      };
    },
  });
}

function err(message: string) {
  return {
    content: [{ type: "text" as const, text: message }],
    details: {},
    isError: true,
  };
}
