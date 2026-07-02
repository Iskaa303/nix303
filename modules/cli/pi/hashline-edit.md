---
name: hashline-edit
description: Correct usage of pi-hashline-edit-pro for editing files. Use whenever you need to read or edit a file — this replaces the built-in read/edit tools.
---

# Hashline Edit Workflow

The `pi-hashline-edit-pro` extension replaces the built-in `read` and `edit` tools.
There is no built-in `edit` tool anymore — use `replace` instead.

## Reading files

`read` returns every line as `HASH│content`. The HASH is a 3-character content hash.
Do NOT copy `HASH│` prefixes into file content — they are metadata, not actual file content.

## Editing files — use replace, NOT edit

There is no `edit` tool. Use `replace` with hash anchors from a recent `read`:

```json
{
  "path": "src/main.ts",
  "changes": [
    { "hash_range_incl": ["aB3", "xY7"], "content_lines": ["new line 1", "new line 2"] }
  ]
}
```

## Common mistakes to avoid

1. **Do NOT paste `HASH│` into file content.** The `HASH│` prefix is a display artifact from `read`.
   If you write it into a file, the tool rejects it with `[E_BARE_HASH_PREFIX]`.
2. **Do NOT use `edit`.** It was replaced by `replace`. Using it produces `[E_LEGACY_SHAPE]`.
3. **Do NOT duplicate closing brackets.** When replacing a range, the replacement content
   replaces those lines exactly. If the last replacement line matches the next surviving line
   (e.g., both are `}`), the tool warns about boundary duplication. Call `read` to see the file
   and remove the duplicate in a follow-up `replace`.
4. **After a successful replace**, call `read` on the file to get fresh anchors before more edits.
   The replace response is empty — anchors are stale for the changed region.
5. **Multiple edits to one file** go in the same `replace` call, using anchors from a single `read`.
   The runtime applies them bottom-up against the same snapshot.
6. **Use `content_lines: []` to delete lines.** Provide an empty array as replacement.

## Auto-read after write

When `write` is called, the response includes fresh hashline anchors automatically
(unless auto-read is disabled via `/toggle-auto-read`). This lets you immediately
use `replace` on a newly written file without an extra `read` call.
