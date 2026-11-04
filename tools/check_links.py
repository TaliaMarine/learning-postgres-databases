#!/usr/bin/env python3
"""Fail if any local href/src in any HTML page does not resolve, or if a
same-site '#anchor' link points at an id that no page defines.

Usage:  python3 tools/check_links.py [site-root]     (default: .)

Run by the Pages workflow against the staged _site, so a broken link fails the
build rather than shipping. Safe to run against the repo root too.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote

REF_RE = re.compile(r'(?:href|src)="([^"]+)"')
ID_RE = re.compile(r'\sid="([^"]+)"')
SKIP_PREFIXES = ("http://", "https://", "mailto:", "tel:", "data:", "//", "#")


def is_fragment(path: Path) -> bool:
    """Authoring fragments are not pages: their relative links only resolve once
    the builder has assembled them into a page one directory up, and the Pages
    workflow never publishes them. Skipping them keeps a run against the repo
    root agreeing with the run against the staged _site."""
    return "_src" in path.parts or path.name.startswith("_")


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    pages = sorted(p for p in root.rglob("*.html")
                   if ".git" not in p.parts and not is_fragment(p))

    if not pages:
        print(f"no HTML pages found under {root}", file=sys.stderr)
        return 1

    ids: dict[Path, set[str]] = {p: set(ID_RE.findall(p.read_text())) for p in pages}
    problems: list[str] = []
    checked = 0

    for page in pages:
        for raw in sorted(set(REF_RE.findall(page.read_text()))):
            if raw.startswith(SKIP_PREFIXES):
                continue

            path_part, _, anchor = raw.partition("#")
            path_part = unquote(path_part.split("?", 1)[0])
            if not path_part:
                continue

            target = (root / path_part.lstrip("/")) if path_part.startswith("/") \
                else (page.parent / path_part)
            target = Path(target)

            if target.is_dir():
                target = target / "index.html"

            checked += 1
            rel = page.relative_to(root)

            if not target.exists():
                problems.append(f"{rel} -> {raw}  (no such file)")
                continue

            if anchor and target.suffix == ".html":
                if anchor not in ids.get(target.resolve(), set()):
                    problems.append(f"{rel} -> {raw}  (no element with that id)")

    for problem in problems:
        print(f"broken reference: {problem}", file=sys.stderr)

    print(f"checked {checked} local references across {len(pages)} pages: "
          f"{len(problems)} broken")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
