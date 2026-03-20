#!/usr/bin/env python3
"""Fetch a Confluence page by URL and output its content as Markdown."""

import json
import os
import re
import sys
import urllib.request
import urllib.error

from markdownify import markdownify


BASE_URL = "https://confluence.internal.salesforce.com"
API_TOKEN = os.environ.get("CONFLUENCE_API_TOKEN", "")


def api_get(path):
    url = f"{BASE_URL}{path}"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {API_TOKEN}"})
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def parse_url(url):
    """Extract page ID and space key from a Confluence URL."""
    m = re.search(r"/pages/(\d+)", url)
    page_id = m.group(1) if m else None
    m = re.search(r"/spaces/([^/]+)", url)
    space_key = m.group(1) if m else None
    return page_id, space_key


def fetch_page(page_id):
    """Fetch a single page and return metadata + markdown body."""
    data = api_get(f"/rest/api/content/{page_id}?expand=body.export_view,space,version,ancestors")
    html = data.get("body", {}).get("export_view", {}).get("value", "")
    md = markdownify(html, heading_style="ATX", bullets="-", strip=["script", "style"])
    # Clean up excessive blank lines
    md = re.sub(r"\n{3,}", "\n\n", md).strip()
    return {
        "title": data.get("title", ""),
        "space": data.get("space", {}).get("key", ""),
        "version": data.get("version", {}).get("number", ""),
        "url": f"{BASE_URL}/spaces/{data.get('space', {}).get('key', '')}/pages/{page_id}",
        "ancestors": [a["title"] for a in data.get("ancestors", [])],
        "markdown": md,
    }


def fetch_children(page_id, depth=1):
    """Fetch child pages (table of contents)."""
    data = api_get(f"/rest/api/content/{page_id}/child/page?limit=100")
    children = []
    for r in data.get("results", []):
        entry = {"id": r["id"], "title": r["title"]}
        if depth > 1:
            entry["children"] = fetch_children(r["id"], depth - 1)
        children.append(entry)
    return children


def main():
    if len(sys.argv) < 2:
        print("Usage: confluence-fetch.py <URL> [--children] [--depth N]", file=sys.stderr)
        sys.exit(1)

    if not API_TOKEN:
        print("Error: CONFLUENCE_API_TOKEN not set", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    show_children = "--children" in sys.argv
    depth = 1
    if "--depth" in sys.argv:
        idx = sys.argv.index("--depth")
        depth = int(sys.argv[idx + 1]) if idx + 1 < len(sys.argv) else 1

    page_id, space_key = parse_url(url)
    if not page_id:
        print(f"Error: could not extract page ID from URL: {url}", file=sys.stderr)
        sys.exit(1)

    page = fetch_page(page_id)

    # Output header
    breadcrumb = " > ".join(page["ancestors"] + [page["title"]]) if page["ancestors"] else page["title"]
    print(f"# {page['title']}")
    print(f"\n**Space:** {page['space']} | **Breadcrumb:** {breadcrumb} | **Version:** {page['version']}")
    print(f"**URL:** {page['url']}")
    print()

    if show_children:
        children = fetch_children(page_id, depth)
        if children:
            print("## Child Pages\n")
            for c in children:
                print(f"- {c['title']} (ID: {c['id']})")
                for gc in c.get("children", []):
                    print(f"  - {gc['title']} (ID: {gc['id']})")
            print()

    print("---\n")
    print(page["markdown"])


if __name__ == "__main__":
    main()
