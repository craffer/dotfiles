---
name: confluence
description: Fetch and read Confluence pages by URL. Use when the user shares a confluence.internal.salesforce.com link or asks to read a Confluence page.
user-invocable: true
allowed-tools: Bash(python3 *confluence-fetch.py*)
---

# Fetching Confluence pages

The `confluence-fetch.py` script fetches a Confluence page by URL and outputs its content as Markdown.

## Location

`~/dev/other/personal/dotfiles/claude/scripts/confluence-fetch.py`

## Usage

```bash
# Fetch a single page
source ~/.dotfiles/zsh/secrets.zsh && python3 ~/dev/other/personal/dotfiles/claude/scripts/confluence-fetch.py "<CONFLUENCE_URL>"

# Fetch a page and list its child pages (useful for space home pages)
source ~/.dotfiles/zsh/secrets.zsh && python3 ~/dev/other/personal/dotfiles/claude/scripts/confluence-fetch.py "<CONFLUENCE_URL>" --children

# Fetch with deeper child tree (default depth is 1)
source ~/.dotfiles/zsh/secrets.zsh && python3 ~/dev/other/personal/dotfiles/claude/scripts/confluence-fetch.py "<CONFLUENCE_URL>" --children --depth 2
```

## When to use this

- The user shares a `confluence.internal.salesforce.com` URL
- The user asks you to read or summarize a Confluence page
- You need to look up internal documentation on Confluence
- Use `--children` when the URL points to a space home or parent page and the user wants to browse what's available
- Use `--depth 2` with `--children` to see grandchild pages too

## URL formats supported

Both of these work:
- `https://confluence.internal.salesforce.com/spaces/HURON/pages/661456052/Huron+Metrics+User+Guide+and+FAQ`
- `https://confluence.internal.salesforce.com/spaces/HURON/pages/661457731/Huron+Home`

The script extracts the page ID from the URL automatically.

## Environment

Requires `CONFLUENCE_API_TOKEN` to be set (exported from `zsh/secrets.zsh`). This is a read-only Personal Access Token.

## Output

The script outputs clean Markdown to stdout with:
- Page title, space key, breadcrumb path, version number
- Child page listing (if `--children` is used)
- The full page body converted from HTML to Markdown

$ARGUMENTS
